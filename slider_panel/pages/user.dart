import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remap/main.dart';
import 'package:remap/signIn_signUp/remap_starting.dart';

class User extends StatefulWidget {
  User({Key key}) : super(key: key);

  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  TextEditingController _nameController;
  String _name = '';
  String currentUserPage = 'USER_HOME'; // current user page

  @override
  void initState() {
    super.initState();
    _loadDB();
  }

  void _loadDB() async {
    QuerySnapshot _userData = await db
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();

    _name = _userData.documents[0].data['name'];

    _nameController = TextEditingController(text: _name);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _userPageWidgets(),
      ),
    );
  }

  _userPageWidgets() {
    switch (currentUserPage) {
      case 'USER_HOME':
        return _userHome();
        break;
      case 'USER_SETTING':
        return _userSetting();
        break;
    }
  }

  Widget _userHome() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //user home bar
        Positioned(
          top: 0,
          height: devHei * 0.05,
          width: devWid,
          child: Container(
            color: Colors.greenAccent,
            child: Center(child: Text('home')),
          ),
        ),

        //picture
        Positioned(
          top: devHei * 0.06,
          child: Container(
            width: devHei * 0.06,
            height: devHei * 0.06,
            child: Center(child: Text('Picture')),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(devHei * 0.03)),
                border: Border.all()),
          ),
        ),

        //name
        Positioned(
          top: devHei * 0.12,
          height: devHei * 0.05,
          child: StreamBuilder<QuerySnapshot>(
            stream: db
                .collection('users')
                .where('id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return Center(
                child: (snapshot.data != null)
                    ? Text('${snapshot.data.documents[0].data['name']}')
                    : CircularProgressIndicator(),
              );
            },
          ),
        ),

        //name and picture setting
        Positioned(
          top: devHei * 0.12,
          right: devWid * 0.1,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.settings,
                size: devHei * 0.02,
              ),
              onPressed: () {
                setState(() {
                  currentUserPage = 'USER_SETTING';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _userSetting() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //user setting bar
        Positioned(
          top: 0,
          height: devHei * 0.05,
          width: devWid,
          child: Container(
            color: Colors.greenAccent,
            child: Center(
              child: Text('settings'),
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: devWid * 0.02,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                currentUserPage = 'USER_HOME';
              });
            },
          ),
        ),

        //picture
        Positioned(
          top: devHei * 0.06,
          child: Container(
            width: devHei * 0.06,
            height: devHei * 0.06,
            child: Center(child: Text('Picture')),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(devHei * 0.03)),
                border: Border.all()),
          ),
        ),

        //name
        Positioned(
          top: devHei * 0.12,
          height: devHei * 0.05,
          width: devWid * 0.3,
          child: TextField(
            textAlign: TextAlign.center,
            controller: _nameController,
            decoration: InputDecoration(hintText: 'Name'),
            onChanged: (value) {
              _name = value;
            },
          ),
        ),

        Positioned(
          top: devHei * 0.2,
          child: RaisedButton(
            child: Text(
              'Update',
              style: TextStyle(color: Colors.greenAccent),
            ),
            color: Colors.white,
            onPressed: _updateData,
          ),
        )

        //name
        // Positioned(
        //   top: devHei * 0.12,
        //   height: devHei * 0.05,
        //   child: StreamBuilder<QuerySnapshot>(
        //     stream: db
        //         .collection('users')
        //         .where('id', isEqualTo: user.uid)
        //         .snapshots(),
        //     builder: (context, snapshot) {
        //       return Center(
        //         child: (snapshot.data != null)
        //             ? Text('${snapshot.data.documents[0].data['name']}')
        //             : CircularProgressIndicator(),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  void _updateData() {
    db
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments()
        .then((document) => {document.documents});
  }
}
