import 'package:flutter/material.dart';
import 'package:remap/slider_panel/pages/discover.dart';
import 'package:remap/slider_panel/pages/draw.dart';
import 'package:remap/slider_panel/pages/setting/setting.dart';
import 'package:remap/slider_panel/pages/user.dart';

class PannelHome extends StatefulWidget {
  PannelHome({Key key}) : super(key: key);

  _PannelHomeState createState() => _PannelHomeState();
}

class _PannelHomeState extends State<PannelHome> {
  int currentTab = 0;
  final List<Widget> screens = [
    SettingHome(),
    DiscoverHome(),
    DrawHome(),
    UserHome(),
  ];
  Widget currentPage = UserHome();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: currentPage,
    );
  }
}
