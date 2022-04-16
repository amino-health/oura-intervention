import 'package:flutter/material.dart';
import 'package:ouraintervention/screens/ProfilePage.dart';
import 'package:ouraintervention/widgets/GroupedBarChart.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';

/// This file is used for testing and debugging widgets or screens.
///
/// Usage:
/// 1. Import widget and add to 'widgetList'
/// 2. Flutter run -t lib/TestWidgets.dart
/// 3. Press corresponding button

List<Widget> widgetList = [
  GroupedBarChart(dataLists: exampleData),
  const OuraLoginButton(),
  const ProfilePage(),
];

void main() async {
  runApp(const TestWidgets());
}

class TestWidgets extends StatelessWidget {
  const TestWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Widget Tests',
      home: HomePage(title: 'Widget Tests'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indexWidget = -1;

  /// Retrieves the name of a widget in the 
  /// widgetList given an [index] of the list
  String _getWidgetName(index) {
    String name = widgetList.elementAt(index).toString();
    return name.substring(0, name.length - 1); // Remove dollar sign
  }

  /// Creates elevatedButtons from the widgetList
  List<Widget> _createButtons() {
    List<Widget> buttons = [];
    for (var i = 0; i < widgetList.length; i++) {
      buttons.add(ElevatedButton(
          onPressed: (() => {
                setState(() {
                  indexWidget = i;
                })
              }),
          child: Text(_getWidgetName(i))));
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: _createButtons()),
      indexWidget == -1
          ? const SizedBox.shrink() // Can't return null for a widget
          : Expanded(child: Center(child: widgetList.elementAt(indexWidget)))
    ]));
  }
}

List<List<Data>> exampleData = [
  [
    Data('2015', 1),
    Data('2016', 2),
    Data('2017', 3),
    Data('2018', 4),
    Data('2019', 5)
  ],
  [
    Data('2015', 6),
    Data('2016', 7),
    Data('2017', 8),
    Data('2018', 9),
    Data('2019', 10)
  ],
  [
    Data('2015', 11),
    Data('2016', 12),
    Data('2017', 13),
    Data('2018', 14),
    Data('2019', 15)
  ]
];
