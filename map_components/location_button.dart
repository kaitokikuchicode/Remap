import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final goToDeviceLocation;
  LocationButton({this.goToDeviceLocation});
  @override
  Widget build(BuildContext context) {
    return Align(
      //location button
      alignment: Alignment(0.4, 0.95),
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
