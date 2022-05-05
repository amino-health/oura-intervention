import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;
import 'package:ouraintervention/widgets/LoadingWidget.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ActionScreen extends StatefulWidget {
  const ActionScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  final actionController = TextEditingController();
  final dateController = TextEditingController();
  final currentDate = DateTime.now().toString().substring(0, DateTime.now().toString().length - 13);

  String _selectedAction = "";
  List<charts.Series<Data, String>> _data = [];
  String xLabel = 'x';
  String yLabel = 'y';
  //FIXME: These should be fetched from the database.
  var biometrics = ['Sleep', 'Heart Rate', 'Other Item'];
  var _selectedBiometric = 'Sleep';

  @override
  void initState() {
    super.initState();
    initializeSleepData();
  }

  void initializeSleepData() async {
    var seriesList = await getData('2022-04-10', '2022-04-15');
    setState(() {
      _data = seriesList;
    });
  }

  bool isValidDate(String date) {
    List<String> split = date.split('-');

    if (split.length != 3) {
      return false;
    }

    if (split[0].length == 4 && split[1].length == 2 && split[2].length == 2 && int.tryParse(date.replaceAll('-', '')) != null) {
      return true;
    }

    return false;
  }

  Future<Row> loadActions() async {
    if (globals.actions.isEmpty) {
      await widget.database.getActions();
    }
    if (_selectedAction == "") {
      setState(() {
        _selectedAction = 'Choose an action';
      });
    }
    List<String> uniqueActions = ['Choose an action'];
    for (var action in globals.actions) {
      String? actionCheck = action['action'];
      if (actionCheck != null && !uniqueActions.contains(actionCheck)) {
        uniqueActions.add(actionCheck);
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 8,
          child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                isExpanded: true,
                value: _selectedAction,
                dropdownColor: globals.grey,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: uniqueActions.map((String actions) {
                  return DropdownMenuItem(
                    value: actions,
                    child: Text(actions),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  setState(() {
                    _selectedAction = newValue!;
                  });

                  //FIXME: Let user pick dates
                  var seriesList = await getData('2022-04-10', '2022-04-15');

                  setState(() {
                    _data = seriesList;
                  });
                },
              ))),
      Expanded(
          flex: 2,
          child: ElevatedButton(
              onPressed: _addActionDialog,
              child: const Text("+"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              )))
    ]);
  }

  Future<bool> addAction() async {
    String date = dateController.text;
    if (date.isEmpty) {
      date = currentDate;
    } else if (!isValidDate(date)) {
      return false;
    }

    widget.database.uploadAction(actionController.text, date);
    setState(() {
      globals.actions.add({'action': actionController.text, 'date': date});
    });
    var seriesList = await getData('2022-04-10', '2022-04-15');

    setState(() {
      _data = seriesList;
    });
    return true;
  }

  TextField generateTextField(TextEditingController controller, String labelText, bool obscureText, Icon icon) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: globals.dark, width: 2.0)),
            border: const OutlineInputBorder(),
            labelText: labelText,
            fillColor: Colors.white,
            filled: true),
        obscureText: obscureText);
  }

  Future<List<charts.Series<Data, String>>> getData(String startDate, String endDate) async {
    if (globals.sleepData.isEmpty) {
      globals.sleepData = await widget.database.getSleepData();
    }

    List<List<Data>> data = [];
    for (var i = 0; i < globals.sleepData.length; i++) {
      if (globals.sleepData[i]['date'].compareTo(startDate) >= 0 && globals.sleepData[i]['date'].compareTo(endDate) <= 0) {
        bool hasAction = false;
        for (var action in globals.actions) {
          if (action['action'] == _selectedAction && globals.sleepData[i]['date'] == action['date']) {
            hasAction = true;
          }
        }

        data.add([Data(globals.sleepData[i]['date'], globals.sleepData[i]['totalSleep'], hasAction ? Colors.green : Colors.blue)]);

        if (globals.sleepData[i]['date'].compareTo(endDate) >= 0) {
          break;
        }
      }
    }

    List<charts.Series<Data, String>> seriesList = [];

    for (var i = 0; i < data.length; i++) {
      seriesList.add(charts.Series<Data, String>(
        id: 'Data',
        domainFn: (Data data, _) => data.x,
        measureFn: (Data data, _) => data.y,
        data: data[i],
        fillColorFn: (Data data, _) {
          return charts.ColorUtil.fromDartColor(data.color);
        },
      ));
    }

    return seriesList;
  }

  Future<void> _addActionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Action'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(10.0), child: generateTextField(actionController, "Action", false, const Icon(Icons.email_sharp)))),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: generateTextField(dateController, currentDate, false, const Icon(Icons.calendar_month_sharp))),
          ]),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Action'),
              onPressed: () async {
                if (await addAction()) {
                  Navigator.of(context).pop();
                } else {
                  //FIXME: Display some text saying that the action is invalid
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            flex: 7,
            child: _data.isEmpty
                ? const LoadingWidget()
                : Scaffold(
                    body: Container(
                      padding: const EdgeInsets.all(70.0),
                      child: charts.BarChart(
                        _data,
                        vertical: true,
                        barGroupingType: charts.BarGroupingType.grouped,
                        behaviors: [
                          charts.ChartTitle('x',
                              behaviorPosition: charts.BehaviorPosition.bottom,
                              titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                          charts.ChartTitle('y',
                              behaviorPosition: charts.BehaviorPosition.start, titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                        ],
                      ),
                    ),
                  )),
        Expanded(
            flex: 3,
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: globals.grey,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: FutureBuilder<Row>(
                                future: loadActions(),
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return const Text('no data');
                                  }
                                  return const SizedBox.shrink();
                                }),
                          )))),
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: globals.grey,
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(children: [
                                Row(children: [
                                  Expanded(
                                      child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: _selectedBiometric,
                                            dropdownColor: globals.grey,
                                            icon: const Icon(Icons.keyboard_arrow_down),
                                            items: biometrics.map((String biometrics) {
                                              return DropdownMenuItem(
                                                value: biometrics,
                                                child: Text(biometrics),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedBiometric = newValue!;
                                              });
                                            },
                                          ))),
                                ]),
                              ]))))),
              const Expanded(
                flex: 3,
                child: Center(child: Text("TODO: Choose dates")),
              )
            ])),
      ],
    );
  }
}

class Data {
  final String x;
  final double y;
  final Color color;

  Data(this.x, this.y, this.color);
}
