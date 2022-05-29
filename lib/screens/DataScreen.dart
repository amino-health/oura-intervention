import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;
import 'package:ouraintervention/widgets/LoadingWidget.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DataScreen extends StatefulWidget {
  const DataScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final addActionController = TextEditingController();
  final addDateController = TextEditingController();
  final deleteActionController = TextEditingController();
  final deleteDateController = TextEditingController();
  final currentDate = DateTime.now().toString().substring(0, DateTime.now().toString().length - 13);
  final startDateController =
      TextEditingController(text: DateTime.now().subtract(const Duration(days: 7)).toString().substring(0, DateTime.now().toString().length - 13));
  final endDateController = TextEditingController(text: DateTime.now().toString().substring(0, DateTime.now().toString().length - 13));

  String _selectedAction = "";
  List<charts.Series<Data, String>> _data = [];
  String xLabel = 'x';
  String yLabel = 'y';
  //FIXME: These should be fetched from the database.
  //var biometrics = ['Sleep', 'Heart Rate', 'Other Item'];
  var _selectedBiometric = "";

  @override
  void initState() {
    super.initState();
    updateData();
    if (globals.startDate != "") {
      startDateController.text = globals.startDate;
      endDateController.text = globals.endDate;
    }
  }

  bool _isValidDate(String date) {
    List<String> split = date.split('-');

    if (split.length != 3) {
      return false;
    }

    if (split[0].length == 4 && split[1].length == 2 && split[2].length == 2 && int.tryParse(date.replaceAll('-', '')) != null) {
      return true;
    }

    return false;
  }

  List<String> _getBiometrics() {
    return [
      'Minimum Heartrate',
      'Average Heartrate',
      'Maximum Heartrate',
      'Total Sleep',
      'Light Sleep',
      'Rem Sleep',
      'Deep Sleep',
      'Minimum Heartrate Variance',
      'Average Heartrate Variance',
      'Maximum Heartrate Variance'
    ];
  }

  Future<Expanded> loadBiometrics() async {
    List<String> biometrics = await _getBiometrics();

    if (_selectedBiometric == "") {
      setState(() {
        _selectedBiometric = "Average Heartrate";
      });
    }

    return Expanded(
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              isExpanded: true,
              value: _selectedBiometric,
              dropdownColor: globals.grey,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: biometrics.map((String biometric) {
                return DropdownMenuItem(
                  value: biometric,
                  child: Text(biometric),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                setState(() {
                  _selectedBiometric = newValue!;
                });

                await updateData();
              },
            )));
  }

  List<String> _getUniqueActions() {
    List<String> uniqueActions = ['Choose an activity'];
    for (var action in globals.actions) {
      String? actionCheck = action['action'];
      if (actionCheck != null && !uniqueActions.contains(actionCheck)) {
        uniqueActions.add(actionCheck);
      }
    }
    return uniqueActions;
  }

  Future<Row> loadActions() async {
    if (globals.actions.isEmpty) {
      await widget.database.getActions(globals.coachedId);
    }

    if (_selectedAction == "") {
      setState(() {
        _selectedAction = 'Choose an activity';
      });
    }

    List<String> uniqueActions = _getUniqueActions();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 7,
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

                  await updateData();
                },
              ))),
      Expanded(
          flex: 3,
          child: Row(children: [
            Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: _addActionDialog,
                    child: const Text("+"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ))),
            Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: _deleteActionDialog,
                    child: const Text("-"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    )))
          ]))
    ]);
  }

  Future<bool> addAction() async {
    String date = addDateController.text;
    if (date.isEmpty) {
      date = currentDate;
    } else if (!_isValidDate(date)) {
      return false;
    }

    widget.database.uploadAction(addActionController.text, date, globals.coachedId);
    setState(() {
      globals.actions.add({'action': addActionController.text, 'date': date});
    });

    await updateData();

    return true;
  }

  bool _hasAction(String action) {
    for (var i = 0; i < globals.actions.length; i++) {
      if (globals.actions[i]['action'] == action) {
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteAction() async {
    String date = deleteDateController.text;
    String action = deleteActionController.text;
    if (date.isEmpty) {
      date = currentDate;
    } else if (!_isValidDate(date)) {
      return false;
    }

    for (var i = 0; i < globals.actions.length; i++) {
      if (globals.actions[i]['date'] == date && globals.actions[i]['action'] == action) {
        await widget.database.deleteAction(action, date);

        setState(() {
          globals.actions.removeAt(i);
          _selectedAction = _hasAction(action) ? action : 'Choose an activity';
        });

        await updateData();

        return true;
      }
    }

    return false;
  }

  Future<void> updateData() async {
    var seriesList = await getData(startDateController.text, endDateController.text);

    setState(() {
      _data = seriesList;
    });

    globals.startDate = startDateController.text;
    globals.endDate = endDateController.text;
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

  List<charts.Series<Data, String>> _createSeriesList(List<Data> data) {
    List<charts.Series<Data, String>> seriesList = [];

    seriesList.add(charts.Series<Data, String>(
      id: _selectedAction,
      domainFn: (Data data, _) => data.x,
      measureFn: (Data data, _) => data.y,
      data: data,
      fillColorFn: (Data data, _) {
        return charts.ColorUtil.fromDartColor(data.color);
      },
    ));

    return seriesList;
  }

  Future<List<charts.Series<Data, String>>> getData(String startDate, String endDate) async {
    if (globals.sleepData.isEmpty) {
      globals.sleepData = await widget.database.getSleepData(globals.coachedId);
    }

    List<Data> data = [];
    for (var i = 0; i < globals.sleepData.length; i++) {
      if (globals.sleepData[i]['date'].compareTo(startDate) >= 0 && globals.sleepData[i]['date'].compareTo(endDate) <= 0) {
        bool hasAction = false;
        for (var action in globals.actions) {
          if (action['action'] == _selectedAction && globals.sleepData[i]['date'] == action['date']) {
            hasAction = true;
            break;
          }
        }

        data.add(Data(globals.sleepData[i]['date'], globals.sleepData[i][_selectedBiometric], hasAction ? Colors.green : Colors.red));

        if (globals.sleepData[i]['date'].compareTo(endDate) >= 0) {
          break;
        }
      }
    }

    return _createSeriesList(data);
  }

  Future<void> _deleteActionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Activity'),
          content: SizedBox(
              width: 350.0,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: generateTextField(deleteActionController, "Enter Name of Activity", false, const Icon(Icons.email_sharp)))),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: generateTextField(deleteDateController, currentDate, false, const Icon(Icons.calendar_month_sharp))),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete Activity'),
              onPressed: () async {
                if (await deleteAction()) {
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

  Future<void> _addActionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Activity'),
          content: SizedBox(
              width: 350.0,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: generateTextField(addActionController, "Enter Name of Activity", false, const Icon(Icons.email_sharp)))),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: generateTextField(addDateController, currentDate, false, const Icon(Icons.calendar_month_sharp))),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Activity'),
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
          child: Container(
              decoration: BoxDecoration(border: Border.all(width: 3, color: globals.dark)),
              child: _data.isEmpty
                  ? const LoadingWidget()
                  : charts.BarChart(
                      _data,
                      animate: true,
                      behaviors: [
                        charts.ChartTitle('Days',
                            behaviorPosition: charts.BehaviorPosition.bottom, titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                        charts.ChartTitle(_selectedBiometric, behaviorPosition: charts.BehaviorPosition.start),
                      ],
                    )),
        ),
        Expanded(
            flex: 3,
            child: Container(
                decoration: BoxDecoration(border: Border.all(width: 3, color: globals.dark)),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
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
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: globals.grey,
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(children: [
                                        Row(children: [
                                          FutureBuilder<Expanded>(
                                              future: loadBiometrics(),
                                              builder: (BuildContext context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return snapshot.data!;
                                                } else if (snapshot.hasError) {
                                                  return const Text('no data');
                                                }
                                                return const SizedBox.shrink();
                                              })
                                        ]),
                                      ]))))),
                      Expanded(
                        flex: 3,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: TextField(
                                          controller: startDateController,
                                          decoration: const InputDecoration(
                                              focusedBorder:
                                                  OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 67, 84, 98), width: 2.0)),
                                              border: OutlineInputBorder(),
                                              labelText: "Start Date",
                                              fillColor: Colors.white,
                                              filled: true))),
                                  Expanded(
                                      child: TextField(
                                          controller: endDateController,
                                          decoration: const InputDecoration(
                                              focusedBorder:
                                                  OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 67, 84, 98), width: 2.0)),
                                              border: OutlineInputBorder(),
                                              labelText: "End Date",
                                              fillColor: Colors.white,
                                              filled: true))),
                                ],
                              )),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(globals.secondaryColor),
                                      ),
                                      onPressed: updateData,
                                      child: const Text("Update Date", style: TextStyle(fontSize: 25.0, color: Colors.white)))))
                        ]),
                      )
                    ])))),
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
