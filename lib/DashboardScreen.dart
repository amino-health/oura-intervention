// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';
import 'package:ouraintervention/misc/Database.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.title, required this.database}) : super(key: key);

  final Database database;

  final String title;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // User login state.
  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 25.0, color: Colors.white),
            ),
            centerTitle: true,
            actions: <Widget>[OuraLoginButton(database: widget.database,)]),
        body: Center(child: Text('TODO'),
        ));
  }
}
