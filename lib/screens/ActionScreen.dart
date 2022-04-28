import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;

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

  void addAction() {
    String date = dateController.text;
    if (date.isEmpty) {
      date = currentDate;
    } else if (!isValidDate(date)) {
      print("Invalid Date!");
      return;
    }

    widget.database.uploadAction(actionController.text, date);
  }

  Widget generateTextField(TextEditingController controller, String labelText, bool obscureText, Icon icon) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: globals.grey,
                  ),
                  child: Column(
                    children: [
                      Center(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: generateTextField(actionController, "Action", false, const Icon(Icons.email_sharp)))),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: generateTextField(dateController, currentDate, false, const Icon(Icons.calendar_month_sharp))),
                      Center(
                          child: ElevatedButton(
                        onPressed: addAction,
                        child: const Text("Add Action"),
                      ))
                    ],
                  ),
                ))),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: globals.grey,
                  ),
                  child: const Center(
                      child: Text(
                    'Other information',
                    style: TextStyle(fontSize: 20),
                  )),
                ))),
      ],
    );
  }
}
