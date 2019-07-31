import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as PackLoc;
import 'package:geolocator/geolocator.dart';

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

  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  bool drawMode = false;
  bool drawRoute = false;
  bool markerSelected = false;

  String inpAd;
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
            polylines: polylines, //Set<Polyline>.of(polylines.values),
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
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  _goToDeviceLocation();
                },
              ),
            ),
          ),
          Positioned(
            top: 30.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
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
              //draw route button
              child: drawRoute
                  ? Positioned(
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
                              Icons.done,
                              color: Colors.greenAccent,
                            ),
                          ),
                          onPressed: () {
                            _createPolyline();
                          },
                        ),
                      ),
                    )
                  : null),
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
          Container(
              //delete pin button
              child: markerSelected
                  ? Positioned(
                      top: 250,
                      right: 80,
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
                            _remove();
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

  _searchLocation() {
    Geolocator().placemarkFromAddress(inpAd).then((result) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 15.0)));
    });
  }

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
            BitmapDescriptor.hueRed,
          ),
        );
        markers[markerId] = newMarker;
        markerSelected = true;
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
    });

    if (markers.length != 0 && markers.length != 1) {
      setState(() {
        drawRoute = true;
      });
    }
  }

  void _remove() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
      }
      markerSelected = false;
    });
  }

  _createPolyline() {
    LatLng origin = markersLocation[markersLocation.length - 2];
    LatLng destination = markersLocation[markersLocation.length - 1];
    polylines.add(Polyline(
      polylineId: PolylineId(destination.toString()),
      visible: true,
      //latlng is List<LatLng>
      points: [origin, destination],
      width: 8,
      color: Colors.blue,
    ));

    setState(() {
      drawRoute = false;
    });
  }
}
