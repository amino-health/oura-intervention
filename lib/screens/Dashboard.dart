// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.title}) : super(key: key);

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
            actions: const <Widget>[OuraLoginButton()]),
        body: Center(child: Text('TODO'),
        ));
  }
}
