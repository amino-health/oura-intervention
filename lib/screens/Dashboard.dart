// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _username = "";
  String _latestUpdate = "";

  void _initializeUsername() async {
    if(globals.username != "") {
      _username = globals.username;
      return;
    }

    String username = await widget.database.getFieldValue('users', 'username');
    globals.username = username;

    setState(() {
      _username = username;
    });
  }

  @override
  void initState() {
    _initializeUsername();
    super.initState();
  }

  // User login state.
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        "Welcome " + _username,
        style: TextStyle(fontSize: 70.0),
      ),
      Text(
        "Last Oura ring synchronization: " + _latestUpdate,
        style: TextStyle(fontSize: 30.0),
      )
    ]);
  }
}
