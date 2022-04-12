import 'package:flutter/material.dart';

import 'package:ouraintervention/screens/ProfilePage.dart';
import 'package:ouraintervention/widgets/GroupedBarChart.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';

void main() async {
  runApp(const OuraIntervention());
}

class OuraIntervention extends StatelessWidget {
  const OuraIntervention({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oura Intervention',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Oura Intervention'),
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
  void _navigateProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

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
        body: Center(
          // Example usage of GroupedBarChart
          child: GroupedBarChart(dataLists: exampleData),
        ));
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
