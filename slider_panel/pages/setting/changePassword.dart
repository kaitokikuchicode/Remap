import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remap/signIn_signUp/remap_starting.dart';
import 'package:remap/size_config.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final _currentPasswordInputController = new TextEditingController();
  final _newPasswordInputController = new TextEditingController();

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
          'Update Password',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5.0),
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
                  controller: _currentPasswordInputController,
                  obscureText: true,
                  decoration:
                      InputDecoration(hintText: 'Enter current Password'),
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
                height: SizeConfig.blockSizeVertical * 8.5,
                child: TextFormField(
                  controller: _newPasswordInputController,
                  obscureText: true,
                  decoration:
                      InputDecoration(hintText: 'Enter current Password'),
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
                      _changePassword();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  void dispose() {
    super.dispose();
    _currentPasswordInputController.dispose();
    _newPasswordInputController.dispose();
  }

  void _changePassword() async {
    FirebaseUser _user = await auth.currentUser();
    _checkUser(_user)
        ? _user
            .updatePassword(_newPasswordInputController.text)
            .then((success) {
            Navigator.pop(context);
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Your Password has been updated",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: SizeConfig.blockSizeVertical * 2.65,
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          }).catchError((err) {
            Navigator.pop(context);
            _showErrorDialog(err);
          })
        : showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Enter correct email\n"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
  }

  _showErrorDialog(err) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                Text(
                  "Something went wrong",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: SizeConfig.blockSizeVertical * 2.65,
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1.50),
                  width: SizeConfig.blockSizeHorizontal * 43.0,
                  child: Text(
                    err.toString(),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w200,
                      fontSize: SizeConfig.blockSizeVertical * 1.50,
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  bool _checkUser(FirebaseUser _user) {
    return _user.email == _emailController.text.trim() ? true : false;
  }
}

// body: Column(
//   children: <Widget>[
//     Container(
//       height: SizeConfig.blockSizeVertical * 7.60,
//       child: Stack(
//         children: <Widget>[
//           Align(
//             alignment: Alignment(-0.85, 0),
//             child: InkWell(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.w200,
//                   fontSize: SizeConfig.blockSizeVertical * 2.50,
//                   color: Colors.blue,
//                 ),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//           Align(
//             alignment: Alignment(0, 0),
//             child: Text(
//               'Update Password',
//               style: TextStyle(
//                 fontFamily: 'Roboto',
//                 fontWeight: FontWeight.w200,
//                 fontSize: SizeConfig.blockSizeVertical * 2.65,
//                 color: Color.fromRGBO(31, 157, 28, 1),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment(0.85, 0),
//             child: InkWell(
//               child: Text(
//                 'Done',
//                 style: TextStyle(
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.w200,
//                   fontSize: SizeConfig.blockSizeVertical * 2.50,
//                   color: Colors.blue,
//                 ),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ],
//       ),
//     )
//   ],
// ),
