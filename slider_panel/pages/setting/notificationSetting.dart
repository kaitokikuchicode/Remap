import 'package:flutter/material.dart';
import 'package:remap/size_config.dart';

class NotificationSettng extends StatefulWidget {
  NotificationSettng({Key key}) : super(key: key);

  @override
  _NotificationSettngState createState() => _NotificationSettngState();
}

class _NotificationSettngState extends State<NotificationSettng> {
  bool _switchVal;
  @override
  void initState() {
    _switchVal = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottom: PreferredSize(
            child: Container(
              color: Colors.white,
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(1.0)),
        title: Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: SizeConfig.blockSizeVertical * 2.65,
            color: Color.fromRGBO(31, 157, 28, 1),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5.0),
              height: SizeConfig.blockSizeVertical * 6.5,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment(-0.60, 0),
                    child: Text(
                      'Allow Notifications',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w200,
                        fontSize: SizeConfig.blockSizeVertical * 2.50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.85, 0),
                    child: Switch(
                        value: _switchVal,
                        onChanged: (bool value) {
                          _swithChanged(value);
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swithChanged(bool value) {
    setState(() {
      _switchVal = value;
    });
  }
}
