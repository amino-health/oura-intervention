import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/LoadingWidget.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final messageController = TextEditingController();

  Future<void> uploadMessage(String message) async {
    String userId = widget.database.authentication.currentUser!.uid;
    String dateTime = DateTime.now().toString();
    await widget.database.uploadMessage(dateTime, userId, message, false);
    globals.messages.add({'message': message, 'date': dateTime, 'coach': false});
    messageController.clear();
  }

  Future<List<Widget>> createMessageContainers() async {
    List<Widget> containers = [];
    String userId = widget.database.authentication.currentUser!.uid;

    // This is to reduce the number of database requests
    if (globals.messages.isEmpty) {
      globals.messages = await widget.database.getMessages(userId);
    }

    for (var message in globals.messages) {
      bool isCoach = message['coach'];
      String appendMessage = isCoach ? 'Coach: ' : 'User: ';
      String date = message['date'];
      date = date.substring(0, date.length - 7);
      Color color = isCoach ? Colors.white : Colors.blue;
      containers.add(Align(
          alignment: isCoach ? Alignment.topRight : Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: SizedBox(
                  height: 70.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 50.0,
                        width: 300.0,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              appendMessage + message['message'],
                              style: const TextStyle(fontSize: 10.0),
                            )),
                        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(15.0))),
                      ),
                      Text(date, style: const TextStyle(fontSize: 10.0, color: Color.fromARGB(255, 158, 158, 158)))
                    ],
                  )))));
    }
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Column(
          children: [
            Center(child: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3uaMgPeSlemqzxsUKJGsLNBIK6AY7S5YaLg&usqp=CAU')),
            Expanded(
                child: Center(
                    child: FutureBuilder(
                        future: widget.database.getEmail(),
                        builder: (BuildContext context, AsyncSnapshot<String?> text) {
                          return Text(
                            text.data ?? "",
                            style: const TextStyle(fontSize: 20),
                          );
                        }))),
            Expanded(
                child: Center(
                    child: FutureBuilder(
                        future: widget.database.getFieldValue('users', 'username'),
                        builder: (BuildContext context, AsyncSnapshot<String?> text) {
                          return Text(
                            text.data ?? "",
                            style: const TextStyle(fontSize: 20),
                          );
                        })))
          ],
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: DecoratedBox(
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 8,
                          child: FutureBuilder(
                              future: createMessageContainers(),
                              builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                                if (snapshot.hasData) {
                                  List<Widget>? messageContainers = snapshot.data;
                                  return ListView.builder(
                                      controller: ScrollController(),
                                      itemCount: messageContainers!.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return messageContainers[index];
                                      });
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else {
                                  return const LoadingWidget();
                                }
                              })),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextField(
                            onSubmitted: (value) {
                              uploadMessage(value);
                            },
                            controller: messageController,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: globals.dark, width: 2.0)),
                                border: const OutlineInputBorder(),
                                labelText: 'Enter Message',
                                fillColor: Colors.white,
                                filled: true),
                          ),
                        ),
                        flex: 2,
                      )
                    ],
                  )),
              decoration: BoxDecoration(color: globals.grey, borderRadius: BorderRadius.all(Radius.circular(15.0)))),
        )),
      ],
    );
  }
}
/*SizedBox(
                    width: 50.0,
                    height: 15.0,
                    child: Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        child: Text(
                          'Test',
                          style: TextStyle(fontSize: 15.0),
                        )),
                  )*/