//Slider panel body

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:remap/main.dart';
import 'package:remap/slider_panel/pages/setting.dart';
import 'package:remap/slider_panel/pages/user.dart';

class SliderPanel extends StatefulWidget {
  final BaseGMapState baseGMapState;
  SliderPanel(this.baseGMapState);

  SliderPanelState createState() => SliderPanelState();
}

class SliderPanelState extends State<SliderPanel> {
  String currentPanelType; // current widget type inside panel
  String currentSettingPage; // current setting page

  settingPageToHome() {
    setState(() {
      currentSettingPage = 'SETTING_HOME';
    });
  }

  @override
  void initState() {
    super.initState();
    currentPanelType = 'USER';
    currentSettingPage = 'SETTING_HOME';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Colors.grey,
            ),
          ]),
      margin: const EdgeInsets.all(24.0),
      child: _insidePanel(),
    );
  }

  Widget _insidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
        _buttons(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            child: _buttonsWidgets(),
          ),
        )
      ],
    );
  }

  Widget _buttons() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      height: 70.0,
      width: double.infinity,
      child: Center(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            _settingB(),
            _userB(),
            _rankingB(),
            _favoriteB(),
            _searchB(),
            _mapTypeB(),
          ],
        ),
      ),
    );
  }

  Widget _settingB() {
    return _buttonClass(
        Colors.white, Icons.settings, Colors.grey, _changePanelType,
        type: 'SETTING');
  }

  Widget _userB() {
    return _buttonClass(
        Colors.white, Icons.person, Colors.black54, _changePanelType,
        type: 'USER');
  }

  Widget _rankingB() {
    return _buttonClass(
        Colors.white, Icons.star, Colors.greenAccent[400], _changePanelType,
        type: 'RANKING');
  }

  Widget _favoriteB() {
    return _buttonClass(
        Colors.white, Icons.favorite, Colors.greenAccent[400], _changePanelType,
        type: 'FAVORITE');
  }

  Widget _searchB() {
    return _buttonClass(
        Colors.white, Icons.search, Colors.blue[200], _changePanelType,
        type: 'SEARCH');
  }

  Widget _mapTypeB() {
    return _buttonClass(
        Colors.white, Icons.map, Colors.greenAccent[400], _changeMapType);
  }

  Widget _buttonClass(
      Color buttonColor, IconData icon, Color iconColor, onPressedFunction,
      {buttonWid = 50.0, buttonHei = 50.0, type = ''}) {
    return Container(
      width: buttonWid,
      height: buttonHei,
      margin: EdgeInsets.all(5),
      child: FloatingActionButton(
        child: Icon(
          icon,
          color: iconColor,
        ),
        onPressed: type == ''
            ? onPressedFunction
            : () {
                onPressedFunction(type);
                widget.baseGMapState.pc.animatePanelToPosition(1.0);
              },
        backgroundColor: buttonColor,
      ),
    );
  }

  _changePanelType(type) {
    setState(() {
      currentPanelType = type;
    });
  }

  _buttonsWidgets() {
    switch (currentPanelType) {
      case 'SETTING':
        return Setting();
        break;
      case 'USER':
        return User();
        break;
      case 'RANKING':
        return _ranking();
        break;
      case 'FAVORITE':
        return _favorite();
        break;
      case 'SEARCH':
        return _search();
        break;
    }
  }

  Widget _ranking() {
    return Container(
      child: Center(
        child: Text('ranking'),
      ),
    );
  }

  Widget _favorite() {
    return Container(
      child: Center(
        child: Text('favorite'),
      ),
    );
  }

  Widget _search() {
    return Container(
      child: Center(
        child: Text('search'),
      ),
    );
  }

  _changeMapType() {
    widget.baseGMapState.setState(() {
      widget.baseGMapState.currentMapType =
          widget.baseGMapState.currentMapType == MapType.normal
              ? MapType.hybrid
              : MapType.normal;
    });
  }
}
