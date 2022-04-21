import 'package:flutter/material.dart';
import 'package:ouraintervention/widgets/Sidebar.dart';
import 'package:ouraintervention/widgets/OuraLoginButton.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Column(
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
                        child: const Center(
                            child: Text(
                          'MAIL.MAIL@MAIL.MAIL\n\nUSERNAME\n\nAccount created: 2022-04-12',
                          style: TextStyle(fontSize: 20),
                        )),
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
        ])));
  }
}
