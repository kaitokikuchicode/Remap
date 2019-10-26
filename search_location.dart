import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:remap/main.dart';
import 'package:remap/size_config.dart';

class SearchLocation extends StatefulWidget {
  final BaseGMapState baseGMapState;
  SearchLocation(this.baseGMapState);

  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: googleAPiKey);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.90, -0.90),
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(SizeConfig.blockSizeVertical * 5.0),
        child: Container(
          height: SizeConfig.blockSizeVertical * 5.0,
          width: SizeConfig.blockSizeVertical * 5.0,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(SizeConfig.blockSizeVertical * 5.0),
          ),
          child: InkWell(
            child: Icon(
              Icons.search,
              color: Color.fromRGBO(50, 226, 46, 1),
            ),
            onTap: () {
              _handlePressButton();
            },
          ),
        ),
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
