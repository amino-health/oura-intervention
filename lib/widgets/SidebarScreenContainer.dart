// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';
import 'package:ouraintervention/screens/Dashboard.dart';
import 'package:ouraintervention/screens/ProfileScreen.dart';
import 'package:ouraintervention/screens/SettingsScreen.dart';
import 'package:ouraintervention/screens/DataScreen.dart';
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
  List<String> screenTitles = ['Dashboard', 'Profile', 'Data',  'Compare', 'Settings'];
  List<String> images = ['home.png', 'profile.png', 'chart.png', 'balance.png', 'settings.png'];
  List<String> _users = ['Choose a user'];
  String _selectedUser = 'Choose a user';

  void intializeUsers() async {
    if (globals.users.isEmpty) {
      globals.users = await widget.database.getallUsers();
    }

    List<String> usernames = [];
    for (var i = 0; i < globals.users.length; i++) {
      usernames.add(globals.users[i]['username']!);
    }
    setState(() {
      _users = _users + usernames;
    });
  }

  @override
  void initState() {
    routes = [
      Dashboard(database: widget.database),
      ProfileScreen(database: widget.database),
      DataScreen(database: widget.database),
      ActionScreen(database: widget.database),
      SettingsScreen(database: widget.database),
    ];
    if (globals.isAdmin) {
      intializeUsers();
    }
    super.initState();
  }

  int _currentScreenIndex = 0;

  List<Widget> _createButtons() {
    List<Widget> buttons = [];
    for (var i = 0; i < routes.length; i++) {
      buttons.add(
        Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
                width: 70.0,
                height: 70.0,
                child: ElevatedButton(
                  onPressed: () => {
                    setState(
                      () {
                        _currentScreenIndex = i;
                      },
                    )
                  },
                  child: Padding(
                      padding: _currentScreenIndex == i ? EdgeInsets.all(5.0) : EdgeInsets.all(0.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white, border: Border.all(width: 3.0), borderRadius: BorderRadius.all(Radius.circular(15.0))),
                            child: Padding(padding: EdgeInsets.all(5.0), child: Image.asset('../../assets/images/' + images[i]))),
                        Text('   ' + screenTitles[i])
                      ])),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(0.0),
                    primary: _currentScreenIndex == i ? globals.mainColor : globals.secondaryColor,
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                  ),
                ))),
      );
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
                actions: <Widget>[
                  globals.isAdmin
                      ? Container(
                          decoration: BoxDecoration(color: globals.grey),
                          height: double.infinity,
                          width: 200.0,
                          child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                isExpanded: true,
                                value: _selectedUser,
                                dropdownColor: globals.grey,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _users.map((String user) {
                                  return DropdownMenuItem(
                                    value: user,
                                    child: Text(user),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedUser = newValue!;
                                  });
                                  globals.resetGlobals();
                                  for (var i = 0; i < globals.users.length; i++) {
                                    if (globals.users[i]['username'] == _selectedUser) {
                                      globals.coachedId = globals.users[i]['id'];
                                      break;
                                    }
                                  }
                                },
                              )))
                      : OuraLoginButton(database: widget.database)
                ]),
            body: Row(
              children: [
                SizedBox(width: 200.0, child: Container(color: globals.secondaryColor, child: ListView(children: _createButtons()))),
                Expanded(child: routes[_currentScreenIndex])
              ],
            )));
  }
}
