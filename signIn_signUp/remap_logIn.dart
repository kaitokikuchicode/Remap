import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:remap/size_config.dart';

import '../main.dart';
import 'remap_starting.dart';

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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment(-0.95, -0.95),
                child: Container(
                  width: SizeConfig.blockSizeHorizontal * 5.8,
                  height: SizeConfig.blockSizeVertical * 3.3,
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
              ),
              Align(
                alignment: Alignment(0.00, -0.90),
                child: Text(
                  "Log in to Remapable",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: SizeConfig.blockSizeVertical * 3.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal * 70.0,
                height: SizeConfig.blockSizeVertical * 6.0,
                child: Center(
                  child: (_errorMessage.length > 0 && _errorMessage != null)
                      ? Text(
                          _errorMessage,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w200,
                            fontSize: SizeConfig.blockSizeVertical * 1.6,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : null,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      height: SizeConfig.blockSizeVertical * 8.5,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email address'),
                        validator: _emailValidator,
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      height: SizeConfig.blockSizeVertical * 1.5,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      height: SizeConfig.blockSizeVertical * 8.5,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (String value) {
                          return !(value.length > 6)
                              ? 'Please enter longer password'
                              : null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(32),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      height: SizeConfig.blockSizeVertical * 1.5,
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      alignment: Alignment.centerRight,
                      child: RaisedButton(
                        color: Color.fromRGBO(50, 226, 46, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27.0)),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _signInWithEmailAndPassword();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  String _emailValidator(String value) {
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
      FirebaseUser _user = (await auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim()))
          .user;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => BaseGMap(user: _user),
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
