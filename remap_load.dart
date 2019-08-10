import 'package:flutter/material.dart';

class RemapLoad extends StatelessWidget {
  const RemapLoad({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            color: Color.fromRGBO(222, 255, 223, 1),
          ),
          Image.asset('assets/images/remap_logo.png'),
        ],
      )),
    );
  }
}
