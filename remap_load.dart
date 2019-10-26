import 'package:flutter/material.dart';
import 'package:remap/size_config.dart';

class RemapLoad extends StatelessWidget {
  const RemapLoad({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0.00, -0.10),
            child: Image.asset(
              'assets/images/logo.png',
              width: SizeConfig.blockSizeHorizontal * 20,
              height: SizeConfig.blockSizeVertical * 9,
            ),
          ),
        ],
      ),
    );
  }
}
