// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';
import 'package:ouraintervention/widgets/SideBar.dart';

class SideNavigationContainer extends StatefulWidget {
  const SideNavigationContainer({Key? key}) : super(key: key);

  @override
  State<SideNavigationContainer> createState() =>
      _SideNavigationContainerState();
}

class _SideNavigationContainerState extends State<SideNavigationContainer> {
  // User login state.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: Text(
                  'Oura Intervention',
                  style: const TextStyle(fontSize: 25.0, color: Colors.white),
                ),
                centerTitle: true,
                actions: const <Widget>[OuraLoginButton()]),
            body: Sidebar()));
  }
}
