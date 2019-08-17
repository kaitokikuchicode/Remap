import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as PackLoc;
import 'package:geolocator/geolocator.dart';
import 'package:line_icons/line_icons.dart';

import 'package:remap/map_components/location_button.dart';

class BaseGMap extends StatefulWidget {
  @override
  State<BaseGMap> createState() => BaseGMapState();
}

class BaseGMapState extends State<BaseGMap> {
  Completer<GoogleMapController> _controller = Completer();

  var currentLocation = PackLoc.LocationData;
  var location = new PackLoc.Location();

  static final LatLng center =
      const LatLng(-33.86711, 151.1947171); //first camera position
  LatLng _centerLocation = center; //map's center location

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 0;
  Map<MarkerId, LatLng> markersLocation = {}; //used when draw polyline
  List<MarkerId> markerIds = [];

  Map<PolylineId, Polyline> polylines = {};
  PolylineId selectedPolyline;

  bool drawMode = false;
  bool drawRoute = false;
  bool markerSelected = false;
  bool polylineSelected = false;
  bool cameraMove = false;
  bool ableToBeDone = false;

  String inpAd;

  int routeCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(-33.86711, 151.1947171), zoom: 15),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.hybrid,
            onCameraMove: _getCenterLocation,
            onTap: _onMapTapped,
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          Positioned(
            //search location input
            top: 35.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Address',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _searchLocation,
                        iconSize: 30.0)),
                onChanged: (val) {
                  setState(() {
                    inpAd = val;
                  });
                },
              ),
            ),
          ),
          Container(
            //center cursor
            child: drawMode
                ? Icon(
                    LineIcons.crosshairs,
                    size: 45,
                    color: Colors.green,
                  )
                : null,
          ),
          LocationButton(goToDeviceLocation: _goToDeviceLocation),
          Container(
              //menu button
              child: Positioned(
            bottom: 20,
            left: 40,
            child: Container(
              width: 55,
              height: 55,
              child: RaisedButton(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Center(
                  child: Icon(
                    Icons.menu,
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  _drawRouteDone();
                },
              ),
            ),
          )),
          Container(
              //draw done button
              child: drawMode
                  ? Positioned(
                      bottom: 85,
                      right: 60,
                      child: Container(
                        width: 90,
                        height: 45,
                        child: RaisedButton(
                            elevation: 10,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Text(
                              'Done',
                              style: TextStyle(
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
                  : null),
          Container(
              //add marker button
              child: drawMode
                  ? Positioned(
                      bottom: 80,
                      child: Container(
                        width: 55,
                        height: 55,
                        child: RaisedButton(
                          elevation: 10,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Center(
                            child: Icon(
                              Icons.place,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () {
                            _addMarker();
                          },
                        ),
                      ),
                    )
                  : null),
          Container(
              //delete marker and polyline button
              child: (markerSelected || polylineSelected) &&
                      drawMode &&
                      !cameraMove
                  ? Positioned(
                      top: 300,
                      right: 100,
                      child: Container(
                        width: 55,
                        height: 55,
                        child: RaisedButton(
                          elevation: 10,
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (markerSelected) _removeMarker();
                            if (polylineSelected) _removePolyline();
                          },
                        ),
                      ),
                    )
                  : null),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //mode change button
        backgroundColor: Colors.green,
        onPressed: () {
          if (drawMode) {
            _resetMarkerColor();
            _resetPolylineColor();
          }
          setState(() {
            drawMode ? drawMode = false : drawMode = true;
          });
        },
        child: drawMode ? Icon(Icons.arrow_back) : Icon(Icons.brush),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

  void _onMapTapped(LatLng latLng) {
    _resetPolylineColor();
    _resetMarkerColor();
    setState(() {
      markerSelected = false;
      polylineSelected = false;
    });
  }

  void _getCenterLocation(CameraPosition position) {
    _centerLocation = position.target;
    setState(() {
      cameraMove = true;
    });
  }

  void _searchLocation() {
    Geolocator().placemarkFromAddress(inpAd).then((result) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 15.0)));
    });
  }

  void _goToDeviceLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15)));
  }

  void _onMarkerTapped(MarkerId markerId) {
    _resetPolylineColor();

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

  _addMarker() {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    markerIds.add(markerId);

    final Marker marker = Marker(
      alpha: 0.7,
      consumeTapEvents: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      markerId: markerId,
      position: _centerLocation,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
      markersLocation[markerId] = _centerLocation;
      routeCounter++;
    });

    if (markers.length != 0 && markers.length != 1 && routeCounter > 1) {
      setState(() {
        _createPolyline();
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
  }

  void _onPolylineTapped(PolylineId polylineId) {
    _resetMarkerColor();

    final Polyline tappedPolyline = polylines[polylineId];
    if (tappedPolyline != null) {
      setState(() {
        if (polylines.containsKey(selectedPolyline)) {
          final Polyline resetOld = polylines[selectedPolyline]
              .copyWith(colorParam: Color.fromRGBO(3, 169, 244, 1));
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

  _createPolyline() {
    LatLng origin = markersLocation[markerIds[markerIds.length - 2]];
    LatLng destination = markersLocation[markerIds[markerIds.length - 1]];
    final PolylineId polylineId = PolylineId(destination.toString());

    final Polyline polyline = Polyline(
        geodesic: true,
        consumeTapEvents: true,
        polylineId: polylineId,
        visible: true,
        points: [origin, destination],
        width: 6,
        color: Color.fromRGBO(144, 238, 144, 0.5),
        onTap: () {
          _onPolylineTapped(polylineId);
        });

    setState(() {
      polylines[polylineId] = polyline;
    });
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
  }

  _drawRouteDone() {
    setState(() {
      ableToBeDone = false;
      routeCounter = 0;
    });
  }
}
