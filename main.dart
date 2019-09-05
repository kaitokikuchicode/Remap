import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as PackLoc;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; //used when _createFitPolyline called
import 'package:remap/remap_load.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:remap/remap_starting.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
void main() => runApp(MyApp());

class BaseGMap extends StatefulWidget {
  const BaseGMap({Key key, @required this.user}) : super(key: key);
  final FirebaseUser user;
  @override
  State<BaseGMap> createState() => BaseGMapState();
}

class BaseGMapState extends State<BaseGMap> {
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;

  var currentLocation = PackLoc.LocationData;
  var location = new PackLoc.Location();

  LatLng startPosition; //first camera position

  Geolocator geolocator = Geolocator();
  //LatLng _centerLocation; //map's center location
  String googleAPiKey = "Your API key";

  PolylinePoints polylinePoints =
      PolylinePoints(); //they are used when _createFitPolyline called

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 0;
  Map<MarkerId, LatLng> markersLocation = {}; //used when draw polyline
  List<MarkerId> markerIds = [];

  Map<PolylineId, Polyline> polylines = {};
  PolylineId selectedPolyline;

  bool isLoading = false;
  bool drawMode = false;
  bool markerSelected = false;
  bool polylineSelected = false;
  bool cameraMove = false;
  bool ableToBeDone = false;

  String currentPanelType; // current widget type inside panel
  String currentSettingPage; // current setting page

  String inpAd;

  int pinCounter = 0;

  PanelController _pc = PanelController();
  final double _initButtonsPos = 90.0;
  double _buttonsPos;
  double _panelHeightO = 575.0;
  double _panelHeightC = 110.0;

  double devWid, devHei;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    _getLocation().then((position) {
      setState(() {
        startPosition = LatLng(position.latitude, position.longitude);
      });
    });
    _buttonsPos = _initButtonsPos;
    currentPanelType = 'USER';
    currentSettingPage = 'SETTING_HOME';

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      devWid = MediaQuery.of(context).size.width; // device width
      devHei = MediaQuery.of(context).size.height; // device height
    });

    return isLoading || startPosition == null
        ? RemapLoad() //while user's location == null
        : Scaffold(
            body: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                SlidingUpPanel(
                  controller: _pc,
                  maxHeight: _panelHeightO,
                  minHeight: _panelHeightC,
                  renderPanelSheet: false,
                  panel: _sliderPanel(),
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

  Widget _sliderPanel() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Colors.grey,
            ),
          ]),
      margin: const EdgeInsets.all(24.0),
      child: _insidePanel(),
    );
  }

  Widget _insidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        _buttons(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0))),
            child: _buttonWidgets(),
          ),
        )
      ],
    );
  }

  Widget _myLocationButton() {
    return Positioned(
      right: devWid * 0.10,
      bottom: _buttonsPos,
      child: _myLocationB(),
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
        _searchLocationInput(),
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
      mapType: _currentMapType,
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

  Widget _searchLocationInput() {
    return Positioned(
      top: 35.0,
      right: devWid * 0.08,
      left: devWid * 0.08,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10.0,
        child: Container(
          height: devHei * 0.05,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Enter Address',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: devWid * 0.02),
                  child: IconButton(
                      icon: Icon(
                        Icons.search,
                        size: devHei * 0.033,
                      ),
                      onPressed: _searchLocation,
                      iconSize: devHei * 0.04),
                )),
            onChanged: (val) {
              setState(() {
                inpAd = val;
              });
            },
          ),
        ),
      ),
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

  Widget _buttons() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      height: 70.0,
      width: double.infinity,
      child: Center(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            _settingB(),
            _userB(),
            _rankingB(),
            _favoriteB(),
            _searchB(),
            _mapTypeB(),
          ],
        ),
      ),
    );
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

  Widget _settingB() {
    return _buttonClass(
        Colors.white, Icons.settings, Colors.grey, _changePanelType,
        type: 'SETTING');
  }

  Widget _userB() {
    return _buttonClass(
        Colors.white, Icons.person, Colors.black54, _changePanelType,
        type: 'USER');
  }

  Widget _rankingB() {
    return _buttonClass(
        Colors.white, Icons.star, Colors.greenAccent[400], _changePanelType,
        type: 'RANKING');
  }

  Widget _favoriteB() {
    return _buttonClass(
        Colors.white, Icons.favorite, Colors.greenAccent[400], _changePanelType,
        type: 'FAVORITE');
  }

  Widget _searchB() {
    return _buttonClass(
        Colors.white, Icons.search, Colors.blue[200], _changePanelType,
        type: 'SEARCH');
  }

  Widget _mapTypeB() {
    return _buttonClass(
        Colors.white, Icons.map, Colors.greenAccent[400], _changeMapType);
  }

  Widget _myLocationB() {
    return _buttonClass(
        Colors.white, Icons.gps_fixed, Colors.grey, _goToDeviceLocation,
        buttonWid: 55.0, buttonHei: 55.0);
  }

  Widget _buttonClass(
      Color buttonColor, IconData icon, Color iconColor, onPressedFunction,
      {buttonWid = 50.0, buttonHei = 50.0, type = ''}) {
    return Container(
      width: buttonWid,
      height: buttonHei,
      margin: EdgeInsets.all(5),
      child: FloatingActionButton(
        child: Icon(
          icon,
          color: iconColor,
        ),
        onPressed: type == ''
            ? onPressedFunction
            : () {
                onPressedFunction(type);
                _pc.animatePanelToPosition(1.0);
              },
        backgroundColor: buttonColor,
      ),
    );
  }

  _changePanelType(type) {
    setState(() {
      currentPanelType = type;
      currentSettingPage = 'SETTING_HOME';
    });
  }

  _buttonWidgets() {
    switch (currentPanelType) {
      case 'SETTING':
        return _setting();
        break;
      case 'USER':
        return _user();
        break;
      case 'RANKING':
        return _ranking();
        break;
      case 'FAVORITE':
        return _favorite();
        break;
      case 'SEARCH':
        return _search();
        break;
      case 'USER_SETTING':
        return _settingUser();
        break;
    }
  }

  Widget _setting() {
    return Container(
      child: Center(
        child: _settingPageWidgets(),
      ),
    );
  }

  _settingPageWidgets() {
    switch (currentSettingPage) {
      case 'SETTING_HOME':
        return _settingHome();
        break;
      case 'SETTING_USER':
        return _settingUser();
        break;
    }
  }

  Widget _settingHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'User setting',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                currentSettingPage = 'SETTING_USER';
              });
            },
          ),
        ),
        SizedBox(
          height: devHei * 0.02,
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: _logOutAlert,
          ),
        ),
      ],
    );
  }

  Widget _settingUser() {
    return Container(
      child: Center(
        child: Text('user setting'),
      ),
    );
  }

  Future<bool> _logOutAlert() {
    return Alert(
      context: context,
      style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          titleStyle: TextStyle(
            fontSize: devHei * 0.025,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
          descStyle: TextStyle(
            fontSize: devHei * 0.015,
            fontWeight: FontWeight.w200,
            fontFamily: 'Roboto',
          )),
      title: 'Log out of Remap?',
      desc: 'Are you sure you want to log out of Remap?',
      buttons: [
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: devHei * 0.017,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
          ),
          radius: BorderRadius.all(Radius.circular(10.0)),
          onPressed: () => Navigator.pop(context),
          color: Colors.black12,
        ),
        DialogButton(
          child: Text(
            'Log out',
            style: TextStyle(
              color: Colors.red,
              fontSize: devHei * 0.015,
              fontWeight: FontWeight.w200,
              fontFamily: 'Roboto',
            ),
          ),
          radius: BorderRadius.all(Radius.circular(10.0)),
          onPressed: () => _handleLogOut(),
          color: Colors.red[100],
        )
      ],
    ).show();
  }

  Future<Null> _handleLogOut() async {
    await _auth.signOut();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => StartingScreen(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 1000),
      ),
    );
  }

  Widget _user() {
    return Container(
      child: Center(
        child: Text('${widget.user}'),
      ),
    );
  }

  Widget _ranking() {
    return Container(
      child: Center(
        child: Text('ranking'),
      ),
    );
  }

  Widget _favorite() {
    return Container(
      child: Center(
        child: Text('favorite'),
      ),
    );
  }

  Widget _search() {
    return Container(
      child: Center(
        child: Text('search'),
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);
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

  void _searchLocation() {
    Geolocator().placemarkFromAddress(inpAd).then((result) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 15.0)));
    });
  }

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

  _changeMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _goToDeviceLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
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
