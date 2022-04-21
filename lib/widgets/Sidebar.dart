import 'package:flutter/material.dart';
import 'package:ouraintervention/screens/Dashboard.dart';
import 'package:ouraintervention/screens/InboxScreen.dart';
import 'package:ouraintervention/screens/ProfileScreen.dart';
import 'package:ouraintervention/screens/SettingsScreen.dart';

List<Widget> routes = [
  Dashboard(),
  ProfileScreen(),
  SettingsScreen(),
  InboxScreen()
];
List<String> images = ['home.png', 'profile.png', 'settings.png', 'inbox.png'];

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _currentScreenIndex = 1;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: buttonSize + 2 * padding,
            child: Container(
                color: Color.fromARGB(255, 143, 143, 143),
                child: ListView(children: _createButtons()))),
        routes[_currentScreenIndex]
      ],
    );
  }
}
