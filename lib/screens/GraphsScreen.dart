// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ouraintervention/widgets/LoadingWidget.dart';
import 'package:ouraintervention/widgets/groupedBarChart.dart';
import 'package:ouraintervention/misc/Database.dart';

class GraphsScreen extends StatefulWidget {
  const GraphsScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  Future<List<List<Data>>> getData() async {
    List<Map<String, dynamic>> sleepData = await widget.database.getSleepData();
    List<List<Data>> data = [];

    for (var i = 0; i < sleepData.length; i++) {
      data.add([Data(sleepData[i]['date'], sleepData[i]['totalSleep'] / 3600)]);
    }

    return data;
  }

  // User login state.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Data>>>(
        future: getData(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return GroupedBarChart(
              dataLists: snapshot.data!,
              xLabel: 'Date',
              yLabel: 'Sleep (Hours)',
            );
          } else if (snapshot.hasError) {
            return Text('no data');
          }
          return LoadingWidget();
        });
  }
}
