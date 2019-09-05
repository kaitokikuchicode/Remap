import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage;

  //bool _isIos;

  @override
  void initState() {
    _errorMessage = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //_isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final devWid = MediaQuery.of(context).size.width; // device width
    final devHei = MediaQuery.of(context).size.height; // device height

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Stack(
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
                Container(
                  width: 35,
                  height: 35,
                  child: IconButton(
                    padding: EdgeInsets.all(
                        0), //IconButton has padding: EdgeInsets.all(8.0) as the default
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
            SizedBox(
              height: devHei * 0.01,
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
                            fontSize: devHei * 0.015,
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email address'),
                      validator: emailValidator,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (String value) {
                        return !(value.length > 6)
                            ? 'Please enter longer password'
                            : null;
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              email: _emailController.text.trim(),
              password: _passwordController.text.trim()))
          .user;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => BaseGMap(user: user),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 2000),
        ),
      );
    } catch (e) {
      print(e.toString());
      setState(() {
        _errorMessage = e.message;
      });
    }
  }
}
