//Slider panel body

import 'package:flutter/material.dart';

import 'package:remap/main.dart';
import 'package:remap/size_config.dart';
import 'package:remap/slider_panel/pages/discover.dart';
import 'package:remap/slider_panel/pages/draw.dart';
import 'package:remap/slider_panel/pages/setting/setting.dart';
import 'package:remap/slider_panel/pages/user.dart';

class SliderPanel extends StatefulWidget {
  final BaseGMapState baseGMapState;
  SliderPanel(this.baseGMapState);

  SliderPanelState createState() => SliderPanelState();
}

class SliderPanelState extends State<SliderPanel> {
  static int currentTab;
  static final List<Widget> screens = [
    SettingHome(),
    DiscoverHome(),
    DrawHome(),
    UserHome(),
  ];
  Widget currentPage;

  static double buttonDiameter = SizeConfig.blockSizeHorizontal * 12;

  double marginBetweenButton =
      ((SizeConfig.screenWidth / 4) - buttonDiameter) / 2;
  //(SizeConfig.screenWidth - buttonDiameter * 4) / 10;

  @override
  void initState() {
    currentTab = 3;
    currentPage = screens[currentTab];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24.0), topLeft: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Colors.grey,
            ),
          ]),
      margin: const EdgeInsets.only(top: 24.0),
      child: _insidePanel(),
    );
  }

  Widget _insidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _bar(),
        _buttonsBar(),
        Expanded(
          child: _pannelBody(),
        ),
      ],
    );
  }

  Widget _bar() {
    return Center(
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 8.0,
        height: 5,
        margin:
            EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 1.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(196, 196, 196, 1),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buttonsBar() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _settingB(),
            _discoverB(),
            _drawB(),
            _userB(),
          ],
        ),
      ),
    );
  }

  Widget _settingB() {
    return Column(
      children: <Widget>[
        _buttonClass(icon: Icons.settings, pageNum: 0),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical * 0.80),
          child: Text(
            'Setting',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w200,
              fontSize: SizeConfig.blockSizeVertical * 1.5,
              color: currentTab == 0
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
        Center(
          child: Container(
            width: SizeConfig.screenWidth / 4,
            height: 1,
            decoration: BoxDecoration(
              color: currentTab == 0
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _discoverB() {
    return Column(
      children: <Widget>[
        _buttonClass(icon: Icons.search, pageNum: 1),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical * 0.80),
          child: Text(
            'Discover',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w200,
              fontSize: SizeConfig.blockSizeVertical * 1.5,
              color: currentTab == 1
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
        Center(
          child: Container(
            width: SizeConfig.screenWidth / 4,
            height: 1,
            decoration: BoxDecoration(
              color: currentTab == 1
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _drawB() {
    return Column(
      children: <Widget>[
        _buttonClass(
            image: Image.asset('assets/images/drawIcon.png'), pageNum: 2),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical * 0.80),
          child: Text(
            'Draw',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w200,
              fontSize: SizeConfig.blockSizeVertical * 1.5,
              color: currentTab == 2
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
        Center(
          child: Container(
            width: SizeConfig.screenWidth / 4,
            height: 1,
            decoration: BoxDecoration(
              color: currentTab == 2
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userB() {
    return Column(
      children: <Widget>[
        _buttonClass(icon: Icons.person, pageNum: 3),
        Container(
          margin: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical * 0.80),
          child: Text(
            'You',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w200,
              fontSize: SizeConfig.blockSizeVertical * 1.5,
              color: currentTab == 3
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
        Center(
          child: Container(
            width: SizeConfig.screenWidth / 4,
            height: 1,
            decoration: BoxDecoration(
              color: currentTab == 3
                  ? Color.fromRGBO(50, 226, 46, 1)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonClass({int pageNum, IconData icon, image}) {
    return Container(
      width: buttonDiameter,
      height: buttonDiameter,
      margin: EdgeInsets.symmetric(horizontal: marginBetweenButton),
      child: FloatingActionButton(
        heroTag: 'tag$pageNum',
        child: icon != null
            ? Icon(
                icon,
                color: Colors.white,
              )
            : Container(
                child: image,
                width: SizeConfig.blockSizeHorizontal * 8.0,
                height: SizeConfig.blockSizeVertical * 8.0,
              ),
        onPressed: () {
          _changePanelType(pageNum);
          widget.baseGMapState.pc.animatePanelToPosition(1.0);
        },
        backgroundColor: Color.fromRGBO(50, 226, 46, 1),
      ),
    );
  }

  _changePanelType(pageNum) {
    setState(() {
      currentTab = pageNum;
      currentPage = screens[currentTab];
    });
  }

  _pannelBody() {
    return Container(
      child: currentPage,
    );
  }
}
