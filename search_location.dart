import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:remap/signIn_signUp/remap_starting.dart';
import 'package:remap/main.dart';

class SearchLocation extends StatefulWidget {
  final BaseGMapState baseGMapState;
  SearchLocation(this.baseGMapState);

  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: googleAPiKey);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: devHei * 0.05,
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
            height: devHei * 0.05,
            width: devWid * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              child: Center(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: devWid * 0.1),
                      child: Text(
                        'Search location',
                        style: TextStyle(
                            color: Colors.greenAccent[400],
                            fontSize: devHei * 0.018,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                        )),
                  ],
                ),
              ),
              onTap: () {
                _handlePressButton();
              },
            )),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleAPiKey,
      mode: Mode.overlay,
    );

    displayPrediction(p);
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      final GoogleMapController controller =
          await widget.baseGMapState.controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 15.0)));
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
