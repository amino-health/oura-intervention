import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;
import 'package:ouraintervention/widgets/groupedBarChart.dart';
import 'package:ouraintervention/widgets/LoadingWidget.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ActionScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ActionScreen> {
  final actionController = TextEditingController();
  final dateController = TextEditingController();
  final currentDate = DateTime.now().toString().substring(0, DateTime.now().toString().length - 13);

  late String _selectedAction;

  //FIXME: These should be fetched from the database.
  var biometrics = ['Sleep', 'Heart Rate', 'Other Item'];
  var _selectedBiometric = 'Sleep';

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
    if (globals.uniqueActions.isEmpty) {
      globals.uniqueActions = await widget.database.getUniqueActions();
      setState(() {
        _selectedAction = globals.uniqueActions[0];
      });
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
                items: globals.uniqueActions.map((String actions) {
                  return DropdownMenuItem(
                    value: actions,
                    child: Text(actions),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAction = newValue!;
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

  bool addAction() {
    String date = dateController.text;
    if (date.isEmpty) {
      date = currentDate;
    } else if (!isValidDate(date)) {
      return false;
    }

    widget.database.uploadAction(actionController.text, date);
    setState(() {
      globals.uniqueActions.add(actionController.text);
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

  Future<List<List<Data>>> getData() async {
    List<Map<String, dynamic>> sleepData = await widget.database.getSleepData();
    List<List<Data>> data = [];

    for (var i = 0; i < sleepData.length; i++) {
      data.add([Data(sleepData[i]['date'], sleepData[i]['totalSleep'] / 3600)]);
    }

    return data;
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
              onPressed: () {
                if (addAction()) {
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
            child: FutureBuilder<List<List<Data>>>(
                future: getData(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    return GroupedBarChart(
                      dataLists: snapshot.data!,
                      xLabel: 'Date',
                      yLabel: 'Sleep (Hours)',
                    );
                  } else if (snapshot.hasError) {
                    return const Text('no data');
                  }
                  return const LoadingWidget();
                })),
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
                                  return const LoadingWidget();
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
