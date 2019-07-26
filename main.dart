import 'dart:async';
// import 'dart:math';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as PackLoc;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:line_icons/line_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remap',
      home: BaseGMap(),
    );
  }
}

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
  List<LatLng> markersLocation = []; //used when draw polyline

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "Your api key";
  bool drawMode = false;
  bool drawRoute = false;
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
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
          ),
          Container(
            //center cursor
            child: drawMode
                ? Icon(
                    LineIcons.crosshairs,
                    size: 30,
                  )
                : null,
          ),
          Positioned(
            //location button
            bottom: 20,
            right: 40,
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
                    Icons.gps_fixed,
                    color: Colors.green,
                  ),
                ),
                onPressed: () {
                  _goToDeviceLocation();
                },
              ),
            ),
          ),
          Positioned(
            //search button
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
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  _searchLocation();
                },
              ),
            ),
          ),
          Positioned(
            //draw route button
            top: 80,
            child: Visibility(
              visible: true, //drawRoute,
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green, width: 1.5),
                    color: Colors.white),
                height: 50,
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.place,
                          color: Colors.redAccent,
                        ),
                      ),
                      Icon(
                        Icons.brush,
                        color: Colors.blue,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.place,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _getPolyline();
                  },
                ),
              ),
            ),
          ),
          Container(
              //add pin button
              child: drawMode
                  ? Positioned(
                      bottom: 80,
                      child: Container(
                        width: 55,
                        height: 55,
                        child: RaisedButton(
                          elevation: 10,
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            _add();
                          },
                        ),
                      ),
                    )
                  : null),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //mode change button
        backgroundColor: drawMode ? Colors.red : Colors.green,
        onPressed: () {
          setState(() {
            drawMode ? drawMode = false : drawMode = true;
          });
        },
        child: drawMode ? Icon(Icons.close) : Icon(Icons.brush),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
    });
  }

  void _getCenterLocation(CameraPosition position) {
    _centerLocation = position.target;
  }

  _searchLocation() {}

  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker]
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

  _goToDeviceLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15)));
  }

  _add() {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    markersLocation.add(_centerLocation);

    final Marker marker = Marker(
      markerId: markerId,
      position: _centerLocation,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _remove() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
      }
    });
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    final double originLat =
        markersLocation[markersLocation.length - 2].latitude;
    final double originLong =
        markersLocation[markersLocation.length - 2].longitude;
    final double destLat = markersLocation[markersLocation.length - 1].latitude;
    final double destLong =
        markersLocation[markersLocation.length - 1].longitude;
    //problem is here
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey, originLat, originLong, destLat, destLong);

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
