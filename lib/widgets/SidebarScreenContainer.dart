// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';
import 'package:ouraintervention/screens/Dashboard.dart';
import 'package:ouraintervention/screens/ProfileScreen.dart';
import 'package:ouraintervention/screens/SettingsScreen.dart';
import 'package:ouraintervention/screens/ActionScreen.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;

class SidebarScreenContainer extends StatefulWidget {
  const SidebarScreenContainer({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<SidebarScreenContainer> createState() => _SidebarScreenContainerState();
}

class _SidebarScreenContainerState extends State<SidebarScreenContainer> {
  List<Widget> routes = [];
  List<String> images = ['home.png', 'profile.png', 'running.png', 'settings.png'];

  @override
  void initState() {
    routes = [
      Dashboard(),
      ProfileScreen(database: widget.database),
      ActionScreen(database: widget.database),
      SettingsScreen(database: widget.database),
    ];
    super.initState();
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
            style: ElevatedButton.styleFrom(side: const BorderSide(width: 1.0), fixedSize: Size(buttonSize, buttonSize), primary: _currentScreenIndex == i ? Colors.grey : Colors.white),
          )));
    }
    return buttons;
  }

  // User login state.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(appBarTheme: AppBarTheme(color: globals.mainColor)),
        home: Scaffold(
            appBar: AppBar(
                title: Text(
                  'Oura Intervention',
                  style: const TextStyle(fontSize: 25.0, color: Colors.white),
                ),
                centerTitle: true,
                actions: <Widget>[OuraLoginButton(database: widget.database)]),
            body: Row(
              children: [
                SizedBox(
                    width: buttonSize + 2 * padding, child: Container(color: globals.secondaryColor, child: ListView(children: _createButtons()))),
                Expanded(child: routes[_currentScreenIndex])
              ],
            )));
  }
}
