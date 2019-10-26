import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:remap/main.dart';
import 'package:remap/size_config.dart';
import 'remap_starting.dart';

class CreateAccount extends StatefulWidget {
  @override
  State<CreateAccount> createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage;

  bool _alert;
  String _userNameAlert;
  Pattern userNamePattern = r'^([a-z0-9_]{3,16})$';

  //bool _isIos;

  @override
  void initState() {
    _errorMessage = '';
    _userNameAlert = '';
    _alert = false;
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
                  "Create account",
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
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Name'),
                        validator: (String value) {
                          return (value.length == 0)
                              ? 'Please enter a valid name'
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
                      height: SizeConfig.blockSizeVertical * 8.5,
                      child: TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(hintText: 'User name'),
                        validator: _userNameValidator,
                        onChanged: _userNameChecker,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                        ],
                      ),
                    ),
                    Wrap(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.blockSizeHorizontal * 70,
                          child: (_userNameAlert.length > 0 &&
                                  _userNameAlert != null)
                              ? Text(
                                  _userNameAlert,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w200,
                                    fontSize:
                                        SizeConfig.blockSizeVertical * 1.6,
                                    color:
                                        _alert ? Colors.red[700] : Colors.green,
                                  ),
                                )
                              : SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 70,
                                  height: SizeConfig.blockSizeVertical * 1.5,
                                ),
                        ),
                      ],
                    ),
                    Container(
                      width: SizeConfig.blockSizeHorizontal * 70,
                      height: SizeConfig.blockSizeVertical * 8.5,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(hintText: 'Email address'),
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
                        decoration: InputDecoration(hintText: 'Password'),
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
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _register();
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
    _nameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  String _userNameValidator(String value) {
    RegExp regex = new RegExp(userNamePattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid User name';
    else
      return null;
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

  Future<Null> _userNameChecker(String value) async {
    if (value.length != 0) {
      RegExp regex = new RegExp(userNamePattern);
      if (!regex.hasMatch(value)) {
        setState(() {
          _userNameAlert =
              'User name must have 3 to 16 characters and contain only letters, numbers, "_" and no spaces. So, "@$value" is not allowed.';
          _alert = true;
        });
      } else {
        String _userName = '@' + value;
        await db
            .collection('username')
            .document('$_userName')
            .get()
            .then((documentSnapshot) {
          if (documentSnapshot.exists) {
            setState(() {
              _alert = true;
            });
          } else if (!documentSnapshot.exists) {
            setState(() {
              _alert = false;
            });
          }
        });

        setState(() {
          _userNameAlert = _alert
              ? '$_userName has already been taken'
              : '$_userName is available';
        });
      }
    } else {
      setState(() {
        _userNameAlert = '';
        _alert = false;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        FirebaseUser _user = (await auth.createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim()))
            .user;

        //user.sendEmailVerification();

        if (_user != null) {
          final QuerySnapshot result = await db
              .collection('users')
              .where('id', isEqualTo: _user.uid)
              .getDocuments();
          final List<DocumentSnapshot> documents = result.documents;

          if (documents.length == 0) {
            // Update data to server if new user
            String _userName;
            _userName = '@' + _userNameController.text.trim();

            //collection of user name
            db
                .collection('username')
                .document(_userName)
                .setData({'id': _user.uid});

            //collection of user's data
            db.collection('users').document(_userName).setData({
              'name': _nameController.text.trim(),
              'userName': _userName,
              'photoUrl': _user.photoUrl,
              'id': _user.uid,
              'createdAt': DateTime.now(),
              'scoreOfTrust': 0,
            });
          }
        }

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
        print(e.message);
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }
}
