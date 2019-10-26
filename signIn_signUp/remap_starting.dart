import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remap/main.dart';
import 'package:remap/remap_load.dart';
import 'package:remap/size_config.dart';
import 'remap_createAccount.dart';
import 'remap_logIn.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore db = Firestore.instance;
double devHei, devWid; // device's height, device's width

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: StartingScreen(),
    );
  }
}

class StartingScreen extends StatefulWidget {
  @override
  StartingScreenState createState() => StartingScreenState();
}

class StartingScreenState extends State<StartingScreen> {
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<bool> _getUser() async {
    setState(() {
      _isLoding = true;
    });

    FirebaseUser _user = await auth.currentUser();

    if (_user != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => BaseGMap(user: _user),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 0),
        ),
      );
    }

    setState(() {
      _isLoding = false;
    });

    return (_user != null) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    setState(() {
      devWid = MediaQuery.of(context).size.width;
      devHei = MediaQuery.of(context).size.height;
    });

    return _isLoding
        ? RemapLoad()
        : Scaffold(
            body: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment(0.00, -0.65),
                  child: Text(
                    'Remapable',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: SizeConfig.blockSizeVertical * 5,
                      color: Color.fromRGBO(31, 157, 28, 1),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.00, -0.325),
                  child: Text(
                    'Discover another small worlds in minutes',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w200,
                      fontSize: SizeConfig.blockSizeVertical * 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.00, 0.00),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 70,
                    height: SizeConfig.blockSizeVertical * 6.0,
                    child: RaisedButton(
                      color: Color.fromRGBO(50, 226, 46, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0)),
                      child: Text(
                        'Create account',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: SizeConfig.blockSizeVertical * 2.2,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAccount()));
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.00, 0.22),
                  child: Text(
                    'or',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w200,
                      fontSize: SizeConfig.blockSizeVertical * 1.6,
                      color: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.00, 0.40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w200,
                          fontSize: SizeConfig.blockSizeVertical * 1.6,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 2,
                      ),
                      GestureDetector(
                        child: Text(
                          'log in',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w200,
                            fontSize: SizeConfig.blockSizeVertical * 1.6,
                            color: Colors.blue[300],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => LogIn()));
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
