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
    if (globals.username != "") {
      _username = globals.username;
      return;
    }

    String username = await widget.database.getFieldValue('users', 'username');
    globals.username = username;

    setState(() {
      _username = username;
    });
  }

  void _initializeLatestUpdate() async {
    if (globals.latestUpdate != "No data") {
      _latestUpdate = globals.latestUpdate;
      return;
    }

    String latestUpdate = await widget.database.getFieldValue('users', 'latestUpdate');
    globals.latestUpdate = latestUpdate;

    setState(() {
      _latestUpdate = latestUpdate;
    });
  }

  @override
  void initState() {
    _initializeUsername();
    _initializeLatestUpdate();
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
      Center(child: Text(
        globals.isAdmin ? "You can select a user to display in the top-right corner" : "Last Oura ring synchronization: " + _latestUpdate,
        style: TextStyle(fontSize: 30.0)),
      )
    ]);
  }
}
