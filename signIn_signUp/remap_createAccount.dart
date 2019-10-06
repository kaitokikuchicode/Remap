import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:remap/main.dart';
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
                  "Let's get started !",
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
              width: devWid * 0.7,
              height: devHei * 0.06,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: devWid * 0.7,
                    height: devHei * 0.085,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
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
                    width: devWid * 0.7,
                    height: devHei * 0.015,
                  ),
                  Container(
                    width: devWid * 0.7,
                    height: devHei * 0.085,
                    child: TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(labelText: 'User name'),
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
                        width: devWid * 0.7,
                        child: (_userNameAlert.length > 0 &&
                                _userNameAlert != null)
                            ? Text(
                                _userNameAlert,
                                style: TextStyle(
                                    color:
                                        _alert ? Colors.red[700] : Colors.green,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'Roboto'),
                              )
                            : Container(
                                width: devWid * 0.7,
                                height: devHei * 0.015,
                                child: null,
                              ),
                      ),
                    ],
                  ),
                  Container(
                    width: devWid * 0.7,
                    height: devHei * 0.085,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email address'),
                      validator: _emailValidator,
                    ),
                  ),
                  SizedBox(
                    width: devWid * 0.7,
                    height: devHei * 0.015,
                  ),
                  Container(
                    width: devWid * 0.7,
                    height: devHei * 0.085,
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
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    margin: EdgeInsets.only(left: devWid * 0.6),
                    alignment: Alignment.center,
                    child: RaisedButton(
                      elevation: 7,
                      color: Color.fromRGBO(119, 236, 124, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _register();
                        }
                      },
                      child: const Text(
                        'Submit',
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
