import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GroupedBarChart extends StatefulWidget {
  const GroupedBarChart({Key? key, required this.dataLists}) : super(key: key);

  final List<List<Data>> dataLists;

  @override
  State<GroupedBarChart> createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<GroupedBarChart> {
  final List<charts.Series<Data, String>> _seriesList = [];

  @override
  void initState() {
    //TODO: Should probably add alot more constraints on the
    //      data here like asserting that all the x-values of 
    //      the data are the same.

    //Only supports three colors at the momentF
    assert(widget.dataLists.length < 4); 
    super.initState();
    List<dynamic> colors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.teal.shadeDefault
    ];
    for (var i = 0; i < widget.dataLists.length; i++) {
      _seriesList.add(charts.Series<Data, String>(
        id: 'Data',
        domainFn: (Data data, _) => data.x,
        measureFn: (Data data, _) => data.y,
        data: widget.dataLists[i],
        fillColorFn: (Data data, _) {
          return colors[i];
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(70.0),
        child: charts.BarChart(
          _seriesList,
          vertical: true,
          barGroupingType: charts.BarGroupingType.grouped,
        ),
      ),
    );
  }
}

class Data {
  final String x;
  final int y;

  Data(this.x, this.y);
}
