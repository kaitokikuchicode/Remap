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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success;
  String _userEmail;

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
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email address'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
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
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _success == null
                        ? ''
                        : (_success
                            ? 'Successfully signed in ' + _userEmail
                            : 'Sign in failed'),
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInWithEmailAndPassword() async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BaseGMap()),
      );
    } else {
      _success = false;
    }
  }
}
