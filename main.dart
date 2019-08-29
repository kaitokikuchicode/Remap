import 'package:flutter/material.dart';
import 'package:remap/remap_createAccount.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remap',
      home: CreateAccount(),
    );
  }
}
