import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remap/signIn_signUp/remap_starting.dart';
import 'package:remap/size_config.dart';
import 'package:remap/slider_panel/pages/setting/changePassword.dart';
import 'package:remap/slider_panel/pages/setting/notificationSetting.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SettingHome extends StatefulWidget {
  _SettingHomeState createState() => _SettingHomeState();
}

class _SettingHomeState extends State<SettingHome> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: SizeConfig.blockSizeVertical * 8.0,
        ),
        InkWell(
          child: Container(
            height: SizeConfig.blockSizeVertical * 6.5,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment(-0.85, 0),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment(-0.15, 0),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 50.0,
                    child: Text(
                      'Update Password',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w200,
                        fontSize: SizeConfig.blockSizeVertical * 2.50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.9, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 80.0,
                    height: 1.0,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.push(context, SlideBottomRoute(page: ChangePassword()));
          },
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 2.0,
        ),
        InkWell(
          child: Container(
            height: SizeConfig.blockSizeVertical * 6.5,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment(-0.85, 0),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment(-0.15, 0),
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 50.0,
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w200,
                        fontSize: SizeConfig.blockSizeVertical * 2.50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.9, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal * 80.0,
                    height: 1.0,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context, SlideBottomRoute(page: NotificationSettng()));
          },
        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical * 40,
        ),
        Container(
          width: SizeConfig.blockSizeHorizontal * 70,
          height: SizeConfig.blockSizeVertical * 6.0,
          child: RaisedButton(
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27.0),
                side: BorderSide(color: Colors.red)),
            child: Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w200,
                fontSize: SizeConfig.blockSizeVertical * 2.5,
                color: Colors.red,
              ),
            ),
            onPressed: _logOutAlert,
          ),
        ),
      ],
    );
  }

  Future<bool> _logOutAlert() {
    return Alert(
      context: context,
      title: 'Log out of Remap?',
      desc: 'Are you sure you want to log out of Remap?',
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        titleStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: SizeConfig.blockSizeVertical * 2.50,
        ),
        descStyle: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w200,
            fontSize: SizeConfig.blockSizeVertical * 1.50),
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: SizeConfig.blockSizeVertical * 1.70,
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
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w200,
              fontSize: SizeConfig.blockSizeVertical * 1.50,
              color: Colors.red,
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

class SlideBottomRoute extends PageRouteBuilder {
  final Widget page;
  SlideBottomRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
