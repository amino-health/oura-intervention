import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              child: Center(
                  child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3uaMgPeSlemqzxsUKJGsLNBIK6AY7S5YaLg&usqp=CAU'))),
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
                        child: Center(
                            child: FutureBuilder(
                                future: widget.database.getEmail(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String?> text) {
                                  return Text(
                                    text.data ?? "",
                                    style: const TextStyle(fontSize: 20),
                                  );
                                })),
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
