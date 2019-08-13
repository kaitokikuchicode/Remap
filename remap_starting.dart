import 'package:flutter/material.dart';

import 'remap_createAccount.dart';
import 'remap_logIn.dart';

class Starting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => StartingScreen(),
        '/createAccount': (context) => CreateAccount(),
        '/logIn': (context) => LogIn(),
        //'/home': (context) => BaseGMap()
      },
    );
  }
}

class StartingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final devWid = MediaQuery.of(context).size.width; // device width
    final devHei = MediaQuery.of(context).size.height; // device height

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: devHei * 0.40,
            child: Image.asset(
              'assets/images/remap_header.png',
              fit: BoxFit.fill,
            ),
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
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: devHei * 0.019,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/createAccount');
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
                        Navigator.pushNamed(context, '/logIn');
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
