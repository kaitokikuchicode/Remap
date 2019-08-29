import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'baseMap.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  String _errorMessage;

  @override
  void initState() {
    _errorMessage = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final devWid = MediaQuery.of(context).size.width; // device width
    final devHei = MediaQuery.of(context).size.height; // device height

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: devHei * 0.05),
            child: Stack(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Image.asset('assets/images/remap_logo.png'),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromRGBO(47, 142, 253, 1),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: devHei * 0.08),
            child: Center(
              child: Text(
                "Log in to Remap",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: devHei * 0.030,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Center(
              child: (_errorMessage.length > 0 && _errorMessage != null)
                  ? Text(
                      _errorMessage,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: devHei * 0.01,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Roboto'),
                    )
                  : null,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Email address'),
                    validator: emailValidator,
                    onSaved: (value) => _email = value.trim(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (String value) {
                      return !(value.length > 6)
                          ? 'Please enter longer password'
                          : null;
                    },
                    onSaved: (value) => _password = value.trim(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: devWid * 0.6),
                  child: RaisedButton(
                    elevation: 7,
                    color: Color.fromRGBO(119, 236, 124, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _signInWithEmailAndPassword();
                      }
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  void _signInWithEmailAndPassword() async {
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(
              email: _email, password: _password))
          .user;

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => BaseGMap(user: user)));
    } catch (e) {
      print(e.message);
      _errorMessage = e.message;
    }
  }
}
