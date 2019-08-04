import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final goToDeviceLocation;
  LocationButton({this.goToDeviceLocation});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      //location button
      bottom: 20,
      right: 40,
      child: Container(
        width: 55,
        height: 55,
        child: RaisedButton(
          elevation: 10,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Center(
            child: Icon(
              Icons.gps_fixed,
              color: Colors.grey,
            ),
          ),
          onPressed: () {
            goToDeviceLocation();
          },
        ),
      ),
    );
  }
}
