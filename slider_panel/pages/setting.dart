import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:remap/signIn_signUp/remap_starting.dart';
import 'package:remap/main.dart';

class Setting extends StatefulWidget {
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String currentSettingPage = 'SETTING_HOME'; // current setting page

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _settingPageWidgets(),
      ),
    );
  }

  _settingPageWidgets() {
    switch (currentSettingPage) {
      case 'SETTING_HOME':
        return _settingHome();
        break;
      case 'SETTING_USER':
        return _settingUser();
        break;
      case 'SETTING_USER_ID':
        return _settingUserId();
        break;
      case 'SETTING_USER_EMAIL':
        return _settingUserEmail();
        break;
      case 'SETTING_USER_PASSWORD':
        return _settingUserPassword();
        break;
    }
  }

  Widget _settingHome() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: devHei * 0.05,
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'User setting',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                currentSettingPage = 'SETTING_USER';
              });
            },
          ),
        ),
        SizedBox(
          height: devHei * 0.02,
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: _logOutAlert,
          ),
        ),
      ],
    );
  }

  Widget _settingUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: devHei * 0.01,
        ),
        Container(
          margin: EdgeInsets.only(right: devHei * 0.35),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                currentSettingPage = 'SETTING_HOME';
              });
            },
          ),
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'User id',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                currentSettingPage = 'SETTING_USER_ID';
              });
            },
          ),
        ),
        SizedBox(
          height: devHei * 0.02,
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                currentSettingPage = 'SETTING_USER_EMAIL';
              });
            },
          ),
        ),
        SizedBox(
          height: devHei * 0.02,
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          elevation: 3.0,
          child: InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              width: devWid * 0.4,
              height: devHei * 0.045,
              child: Center(
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: devHei * 0.02,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                currentSettingPage = 'SETTING_USER_PASSWORD';
              });
            },
          ),
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot> _settingUserId() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          db.collection('users').where('id', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: devHei * 0.01,
            ),
            Container(
              margin: EdgeInsets.only(right: devHei * 0.35),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    currentSettingPage = 'SETTING_USER';
                  });
                },
              ),
            ),
            Center(
              child: (snapshot.data != null)
                  ? Text('${snapshot.data.documents[0].data['userName']}')
                  : CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot> _settingUserEmail() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          db.collection('users').where('id', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: devHei * 0.01,
            ),
            Container(
              margin: EdgeInsets.only(right: devHei * 0.35),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    currentSettingPage = 'SETTING_USER';
                  });
                },
              ),
            ),
            Center(
              child: (snapshot.data != null)
                  ? Text('${user.email}')
                  : CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot> _settingUserPassword() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          db.collection('users').where('id', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: devHei * 0.01,
            ),
            Container(
              margin: EdgeInsets.only(right: devHei * 0.35),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    currentSettingPage = 'SETTING_USER';
                  });
                },
              ),
            ),
            Center(
              child: (snapshot.data != null)
                  ? Text('${user.providerData[0].providerId}')
                  : CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _logOutAlert() {
    return Alert(
      context: context,
      style: AlertStyle(
          animationType: AnimationType.grow,
          isCloseButton: false,
          titleStyle: TextStyle(
            fontSize: devHei * 0.025,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
          descStyle: TextStyle(
            fontSize: devHei * 0.015,
            fontWeight: FontWeight.w200,
            fontFamily: 'Roboto',
          )),
      title: 'Log out of Remap?',
      desc: 'Are you sure you want to log out of Remap?',
      buttons: [
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: devHei * 0.017,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
          ),
          radius: BorderRadius.all(Radius.circular(10.0)),
          onPressed: () => Navigator.pop(context),
          color: Colors.black12,
        ),
        DialogButton(
          child: Text(
            'Log out',
            style: TextStyle(
              color: Colors.red,
              fontSize: devHei * 0.015,
              fontWeight: FontWeight.w200,
              fontFamily: 'Roboto',
            ),
          ),
          radius: BorderRadius.all(Radius.circular(10.0)),
          onPressed: () => _handleLogOut(),
          color: Colors.red[100],
        )
      ],
    ).show();
  }

  Future<Null> _handleLogOut() async {
    await auth.signOut();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => StartingScreen(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 1000),
      ),
    );
  }
}
