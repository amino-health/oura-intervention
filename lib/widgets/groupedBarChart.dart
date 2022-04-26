import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GroupedBarChart extends StatefulWidget {
  const GroupedBarChart({Key? key, required this.dataLists, required this.xLabel, required this.yLabel}) : super(key: key);

  final String xLabel;
  final String yLabel;
  final List<List<Data>> dataLists;

  @override
  State<GroupedBarChart> createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<GroupedBarChart> {
  final List<charts.Series<Data, String>> _seriesList = [];

  @override
  void initState() {
    for (var i = 0; i < widget.dataLists.length / 2; i++) {
      _seriesList.add(charts.Series<Data, String>(
        id: 'Data',
        domainFn: (Data data, _) => data.x,
        measureFn: (Data data, _) => data.y,
        data: widget.dataLists[i],
        fillColorFn: (Data data, _) {
          return charts.MaterialPalette.blue.shadeDefault;
        },
      ));
    }
    super.initState();
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
          behaviors: [
            charts.ChartTitle(widget.xLabel,
                behaviorPosition: charts.BehaviorPosition.bottom, titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
            charts.ChartTitle(widget.yLabel,
                behaviorPosition: charts.BehaviorPosition.start, titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
          ],
        ),
      ),
    );
  }
}

class Data {
  final String x;
  final double y;

  Data(this.x, this.y);
}
