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
  final scrollController = ScrollController();

  Future<void> uploadMessage(String message) async {
    String dateTime = DateTime.now().toString();
    await widget.database.uploadMessage(dateTime, message, globals.isAdmin, globals.coachedId);
    setState(() {
      globals.messages.add({'message': message, 'date': dateTime, 'coach': globals.isAdmin});
    });

    messageController.clear();
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  Future<List<Widget>> createMessageContainers() async {
    print("hello");
    List<Widget> containers = [];
    String userId = globals.coachedId != null ? globals.coachedId! : widget.database.authentication.currentUser!.uid;

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
                  height: 100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 70.0,
                        width: 400.0,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              appendMessage + message['message'],
                              style: const TextStyle(fontSize: 17.0),
                            )),
                        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(15.0))),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 5.0, right: 10.0),
                          child: Text(date, style: const TextStyle(fontSize: 15.0, color: Color.fromARGB(255, 158, 158, 158))))
                    ],
                  )))));
    }
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(children: [
          Padding(padding: const EdgeInsets.all(20.0), child: Container(
            width: 100.0,
            height: 100.0,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1), border: Border.all(width: 3.0), borderRadius: const BorderRadius.all(Radius.circular(15.0))),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0.0),
                    elevation: 0.0,
                    shadowColor: Colors.transparent,
                    primary: Colors.transparent,
                  ),
                child: Padding(padding: const EdgeInsets.all(5.0), child: Image.asset('../../assets/images/refresh.png')),
                onPressed: () {setState(() {
                  globals.messages = [];
                });},
              ))),
          Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Container(
                  height: 200.0,
                  decoration:
                      BoxDecoration(color: Colors.white, border: Border.all(width: 2.0), borderRadius: const BorderRadius.all(Radius.circular(15.0))),
                  child: Column(
                    children: [
                      FutureBuilder(
                          future: widget.database.getEmail(),
                          builder: (BuildContext context, AsyncSnapshot<String?> text) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                              child: Text(
                                text.data == null ? 'Email: ' : 'Email: ' + text.data!,
                                style: const TextStyle(fontSize: 20),
                              ),
                            );
                          }),
                      FutureBuilder(
                          future: widget.database.getFieldValue('users', 'username'),
                          builder: (BuildContext context, AsyncSnapshot<dynamic?> text) {
                            return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  text.data == null ? 'Username: ' : 'Username: ' + text.data!,
                                  style: const TextStyle(fontSize: 20),
                                ));
                          })
                    ],
                  )))
        ]),
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
                                      controller: scrollController,
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
                            onSubmitted: (value) async {
                              await uploadMessage(value);
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
              decoration:
                  BoxDecoration(color: globals.grey, border: Border.all(width: 2.0), borderRadius: const BorderRadius.all(Radius.circular(15.0)))),
        )),
      ],
    );
  }
}
