import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remap/main.dart';
import 'package:remap/remap_load.dart';

import 'remap_createAccount.dart';
import 'remap_logIn.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartingScreen(),
    );
  }
}

class StartingScreen extends StatefulWidget {
  @override
  StartingScreenState createState() => StartingScreenState();
}

class StartingScreenState extends State<StartingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isLoding = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<bool> _getUser() async {
    setState(() {
      isLoding = true;
    });

    FirebaseUser firebaseUser = await _auth.currentUser();

    user = firebaseUser;

    if (user != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => BaseGMap(user: user),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 0),
        ),
      );
    }

    setState(() {
      isLoding = false;
    });

    return (user != null) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final devWid = MediaQuery.of(context).size.width; // device width
    final devHei = MediaQuery.of(context).size.height; // device height
    return isLoding
        ? RemapLoad()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: devHei * 0.40,
                      child: Image.asset(
                        'assets/images/remap_header_pic.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 40,
                                height: 35,
                              ),
                            ),
                          ),
                          Text(
                            'Remap',
                            style: TextStyle(
                              color: Color.fromRGBO(31, 157, 28, 1),
                              fontSize: devHei * 0.045,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: devHei * 0.02),
                            child: Text(
                              'Discover another small world in minutes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: devHei * 0.02,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: devWid * 0.65,
                  height: devHei * 0.05,
                  child: RaisedButton(
                    elevation: 7,
                    color: Color.fromRGBO(119, 236, 124, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Center(
                      child: Text(
                        'Create a new account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: devHei * 0.019,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
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
                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: devWid * 0.65,
                  height: devHei * 0.05,
                  child: Center(
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: devHei * 0.016,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: devWid * 0.65,
                  height: devHei * 0.05,
                  child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Already have an account ?  ',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: devHei * 0.016,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              'log in',
                              style: TextStyle(
                                  fontSize: devHei * 0.016,
                                  color: Colors.blue[300],
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'Roboto',
                                  fontStyle: FontStyle.italic),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LogIn()));
                            },
                          )
                        ]),
                  ),
                ),
              ],
            ),
          );
  }
}
