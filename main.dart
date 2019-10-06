import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as PackLoc;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; //used when _createFitPolyline called

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:remap/signIn_signUp/remap_starting.dart';
import 'package:remap/remap_load.dart';
import 'package:remap/slider_panel/slider_panel.dart';
import 'package:remap/search_location.dart';

String googleAPiKey = "Your API key";

FirebaseUser user;

void main() => runApp(MyApp());

class BaseGMap extends StatefulWidget {
  const BaseGMap({Key key, @required this.user}) : super(key: key);
  final FirebaseUser user;
  @override
  State<BaseGMap> createState() => BaseGMapState();
}

class BaseGMapState extends State<BaseGMap> {
  MapType currentMapType = MapType.normal;

  var currentLocation = PackLoc.LocationData;
  var location = new PackLoc.Location();

  LatLng startPosition; //first camera position

  Geolocator geolocator = Geolocator();
  //LatLng _centerLocation; //map's center location

  Completer<GoogleMapController> controller = Completer();

  PolylinePoints polylinePoints =
      PolylinePoints(); //they are used when _createFitPolyline called

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 0;
  Map<MarkerId, LatLng> markersLocation = {}; //used when draw polyline
  List<MarkerId> markerIds = [];
  int pinCounter = 0;

  Map<PolylineId, Polyline> polylines = {};
  PolylineId selectedPolyline;

  bool isLoading = false;
  bool drawMode = false;
  bool markerSelected = false;
  bool polylineSelected = false;
  bool cameraMove = false;
  bool ableToBeDone = false;

  PanelController pc = PanelController();

  String inpAd;

  final double _initButtonsPos = 90.0;
  double _buttonsPos;
  double _panelHeightO = 575.0;
  double _panelHeightC = 110.0;

  @override
  void initState() {
    super.initState();

    setState(() {
      user = widget.user;
    });

    setState(() {
      isLoading = true;
    });

    _getLocation().then((position) {
      setState(() {
        startPosition = LatLng(position.latitude, position.longitude);
      });
    });
    _buttonsPos = _initButtonsPos;

    setState(() {
      isLoading = false;
    });
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || startPosition == null
        ? RemapLoad() //while user's location == null
        : Scaffold(
            body: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                SlidingUpPanel(
                  controller: pc,
                  maxHeight: _panelHeightO,
                  minHeight: _panelHeightC,
                  renderPanelSheet: false,
                  panel: SliderPanel(this), //_sliderPanel(),
                  body: _mainBody(),
                  onPanelSlide: (double pos) => setState(() {
                    _buttonsPos =
                        pos * (_panelHeightO - _panelHeightC) + _initButtonsPos;
                  }),
                ),
                _myLocationButton(),
                _drawRouteButton(),
                _drawDoneButton()
              ],
            ),
          );
  }

  Widget _myLocationButton() {
    return Positioned(
      right: devWid * 0.10,
      bottom: _buttonsPos,
      child: _myLocationB(),
    );
  }

  Widget _myLocationB() {
    return Container(
      width: 55.0,
      height: 55.0,
      margin: EdgeInsets.all(5.0),
      child: FloatingActionButton(
        child: Icon(
          Icons.gps_fixed,
          color: Colors.grey,
        ),
        onPressed: _goToDeviceLocation,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _drawRouteButton() {
    return Positioned(
      left: devWid * 0.10,
      bottom: _buttonsPos,
      child: _drawRoute(),
    );
  }

  Widget _drawDoneButton() {
    return Container(
        //draw done button
        child: drawMode
            ? Positioned(
                bottom: _buttonsPos,
                child: Container(
                  width: devWid * 0.2,
                  height: devHei * 0.045,
                  margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(
                      elevation: 10,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: devHei * 0.017,
                          color: Color.fromRGBO(119, 236, 124, 1),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      onPressed: ableToBeDone & (polylines.length > 0)
                          ? () {
                              _drawRouteDone();
                            }
                          : null),
                ),
              )
            : null);
  }

  Widget _mainBody() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        _googleMap(),
        SearchLocation(this),
        //_searchLoc(),
        _deleteButton(),
      ],
    );
  }

  Widget _googleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
          target: LatLng(startPosition.latitude, startPosition.longitude),
          zoom: 15),
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: currentMapType,
      //onCameraMove: _getCenterLocation,
      onTap: (value) {
        if (drawMode && !markerSelected && !polylineSelected)
          _addMarker(value.latitude, value.longitude);
        _onMapTapped();
      },
      markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  Widget _deleteButton() {
    return Container(
        //delete marker and polyline button
        child: (markerSelected || polylineSelected) && drawMode
            ? Align(
                alignment: Alignment(0, -0.15),
                child: Container(
                  width: 90,
                  child: RaisedButton(
                    elevation: 10,
                    color: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.red),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    onPressed: () {
                      if (markerSelected) _removeMarker();
                      if (polylineSelected) _removePolyline();
                    },
                  ),
                ),
              )
            : null);
  }

  Widget _drawRoute() {
    return Container(
      width: 55.0,
      height: 55.0,
      margin: EdgeInsets.all(5),
      child: FloatingActionButton(
        backgroundColor: Colors.greenAccent[400],
        child: drawMode
            ? Icon(Icons.arrow_back, color: Colors.white)
            : Icon(Icons.brush, color: Colors.white),
        onPressed: () {
          if (drawMode) {
            _resetMarkerColor();
            _resetPolylineColor();
          }
          setState(() {
            drawMode ? drawMode = false : drawMode = true;
          });
        },
      ),
    );
  }

  //TODO Peek problem or not use geolocator then change it to something by Oct 7
  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print(e);
      currentLocation = null;
    }
    return currentLocation;
  }

  _onMapCreated(GoogleMapController gmapcontroller) {
    if (!controller.isCompleted)
      setState(() {
        controller.complete(gmapcontroller);
      });
  }

  void _onMapTapped() {
    _resetPolylineColor();
    _resetMarkerColor();
    setState(() {
      markerSelected = false;
      polylineSelected = false;
    });
  }

  // void _getCenterLocation(CameraPosition position) {
  //   _centerLocation = position.target;
  //   setState(() {
  //     cameraMove = true;
  //   });
  // }

  void _onMarkerTapped(MarkerId markerId) {
    _resetPolylineColor();
    print(markers[markerId].position);

    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker].copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen));
          markers[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        );

        markers[markerId] = newMarker;
        markerSelected = true;
        polylineSelected = false;
        cameraMove = false;
      });
    }
  }

  _addMarker(latitude, longitude) {
    LatLng tappedLatLng = LatLng(latitude, longitude);
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    markerIds.add(markerId);

    final Marker marker = Marker(
      alpha: 0.7,
      consumeTapEvents: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      markerId: markerId,
      position: tappedLatLng,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
      markersLocation[markerId] = tappedLatLng;
      pinCounter++;
    });

    if (markers.length != 0 && markers.length != 1 && pinCounter > 1) {
      setState(() {
        _createFitPolyline();
        ableToBeDone = true;
      });
    }
  }

  void _removeMarker() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
        markersLocation.remove(selectedMarker);
      }
      if (markerIds.contains(selectedMarker)) {
        markerIds.remove(selectedMarker);
      }
      markerSelected = false;
    });
  }

  void _resetMarkerColor() {
    //change marker's color when anything else tapped
    markers.updateAll((markerId, marker) => marker = marker.copyWith(
        iconParam:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    setState(() {
      markerSelected = false;
    });
  }

  void _onPolylineTapped(PolylineId polylineId) {
    _resetMarkerColor();

    final Polyline tappedPolyline = polylines[polylineId];
    if (tappedPolyline != null) {
      setState(() {
        if (polylines.containsKey(selectedPolyline)) {
          final Polyline resetOld = polylines[selectedPolyline]
              .copyWith(colorParam: Color.fromRGBO(144, 238, 144, 0.5));
          polylines[selectedPolyline] = resetOld;
        }
        selectedPolyline = polylineId;
        final Polyline newPolyline =
            tappedPolyline.copyWith(colorParam: Color.fromRGBO(180, 0, 0, 0.5));
        polylines[polylineId] = newPolyline;
        polylineSelected = true;
        markerSelected = false;
        cameraMove = false;
      });
    }
  }

  void _removePolyline() {
    setState(() {
      if (polylines.containsKey(selectedPolyline)) {
        polylines.remove(selectedPolyline);
      }

      polylineSelected = false;
    });
  }

  void _resetPolylineColor() {
    //change polyline's color when anything else tapped
    polylines.updateAll((polylineid, polyline) => polyline = polyline.copyWith(
          colorParam: Color.fromRGBO(144, 238, 144, 0.5),
        ));
    setState(() {
      polylineSelected = false;
    });
  }

  _drawRouteDone() {
    setState(() {
      _resetMarkerColor();
      _resetPolylineColor();

      ableToBeDone = false;
      pinCounter = 0;
    });
  }

  void _goToDeviceLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController gmapcontroller = await controller.future;
    gmapcontroller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15)));
  }

  //create polyline which fits maps route
  _createFitPolyline() async {
    LatLng origin = markersLocation[markerIds[markerIds.length - 2]];
    LatLng destination = markersLocation[markerIds[markerIds.length - 1]];
    final PolylineId polylineId = PolylineId(destination.toString());
    List<LatLng> polylineCoordinates = [];

    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    Polyline polyline = Polyline(
        polylineId: polylineId,
        points: polylineCoordinates,
        consumeTapEvents: true,
        width: 6,
        color: Color.fromRGBO(144, 238, 144, 0.5),
        onTap: () {
          _onPolylineTapped(polylineId);
        });

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  //create polyline which doesn't fit map's route
  // _createPolyline() {
  //   LatLng origin = markersLocation[markerIds[markerIds.length - 2]];
  //   LatLng destination = markersLocation[markerIds[markerIds.length - 1]];
  //   final PolylineId polylineId = PolylineId(destination.toString());

  //   final Polyline polyline = Polyline(
  //       geodesic: true,
  //       consumeTapEvents: true,
  //       polylineId: polylineId,
  //       points: [origin, destination],
  //       width: 6,
  //       color: Color.fromRGBO(144, 238, 144, 0.5),
  //       onTap: () {
  //         _onPolylineTapped(polylineId);
  //       });

  //   setState(() {
  //     polylines[polylineId] = polyline;
  //   });
  // }
}
