import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ActionScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ActionScreen> {
  final actionController = TextEditingController();
  final dateController = TextEditingController();

  void addAction() {
    widget.database.uploadAction(actionController.text, dateController.text);
  }

  Widget generateTextField(TextEditingController controller, String labelText, bool obscureText, Icon icon) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 67, 84, 98), width: 2.0)),
            border: const OutlineInputBorder(),
            labelText: labelText,
            fillColor: Colors.white,
            filled: true),
        obscureText: obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
      Expanded(
          child: Center(
              child: ElevatedButton(
        onPressed: addAction,
        child: const Text("Add Action"),
      ))),
      Expanded(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 241, 241, 241),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: Center(child: generateTextField(actionController, "Action", false, Icon(Icons.email_sharp)))),
                        Expanded(child: Center(child: generateTextField(dateController, "Date", false, Icon(Icons.email_sharp)))),
                      ],
                    ),
                  ))),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 241, 241, 241),
                    ),
                    child: const Center(
                        child: Text(
                      'Other information',
                      style: TextStyle(fontSize: 20),
                    )),
                  ))),
        ],
      ))
    ]);
  }
}
