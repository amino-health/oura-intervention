import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/LoadingWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<Widget>> createMessageContainers() async {
    List<Widget> containers = [];
    String userId = widget.database.authentication.currentUser!.uid;
    List<Map<String, dynamic>> messages = await widget.database.getMessages(userId); //FIX
    for (var message in messages) {
      Color color = message['coach'] ? Colors.white : Colors.blue;
      containers.add(Align(
          alignment: message['coach'] ? Alignment.topRight : Alignment.topLeft,
          child: Container(
            height: 100.0,
            width: 300.0,
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                    child: Text(
                  message['message'],
                  style: const TextStyle(fontSize: 10.0),
                ))),
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(15.0))),
          )));
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
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder(
                      future: createMessageContainers(),
                      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                        if (snapshot.hasData) {
                          List<Widget>? messageContainers = snapshot.data;
                          return ListView.builder(
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
              decoration: const BoxDecoration(color: Color.fromARGB(255, 204, 204, 204), borderRadius: BorderRadius.all(Radius.circular(15.0)))),
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