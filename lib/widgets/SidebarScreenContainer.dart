// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';
import 'package:ouraintervention/screens/Dashboard.dart';
import 'package:ouraintervention/screens/InboxScreen.dart';
import 'package:ouraintervention/screens/ProfileScreen.dart';
import 'package:ouraintervention/screens/SettingsScreen.dart';


class SidebarScreenContainer extends StatefulWidget {
  const SidebarScreenContainer({Key? key, required this.database})
      : super(key: key);

  final Database database;

  @override
  State<SidebarScreenContainer> createState() => _SidebarScreenContainerState();
}

class _SidebarScreenContainerState extends State<SidebarScreenContainer> {
  List<Widget> routes = [];
  List<String> images = ['home.png', 'profile.png', 'settings.png', 'inbox.png'];
  
  @override
  void initState() {
    routes = [
      Dashboard(),
      ProfileScreen(database: widget.database),
      SettingsScreen(database: widget.database),
      InboxScreen()
    ];
  }

  int _currentScreenIndex = 0;

  double buttonSize = 100.0;
  double padding = 10;

  List<Widget> _createButtons() {
    List<Widget> buttons = [];
    for (var i = 0; i < routes.length; i++) {
      buttons.add(Padding(
          padding: EdgeInsets.all(padding),
          child: ElevatedButton(
            onPressed: () => {
              setState(
                () {
                  _currentScreenIndex = i;
                },
              )
            },
            child: Image.asset('../../assets/images/' + images[i]),
            style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 1.0),
                fixedSize: Size(buttonSize, buttonSize),
                primary: Colors.white),
          )));
    }
    return buttons;
  }

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
            body: Row(
              children: [
                SizedBox(
                    width: buttonSize + 2 * padding,
                    child: Container(
                        color: Color.fromARGB(255, 143, 143, 143),
                        child: ListView(children: _createButtons()))),
                Expanded(child: routes[_currentScreenIndex])
              ],
            )));
  }
}
