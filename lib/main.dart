// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

// Screens
import 'package:ouraintervention/screens/LoginScreen.dart';

//Misc
import 'package:ouraintervention/misc/Database.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth authentication = FirebaseAuth.instance;
  Database database = Database(firestore, authentication);

  runApp(AppGlobalState(
    database: database,
  ));
}

class AppGlobalState extends StatefulWidget {
  const AppGlobalState({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<AppGlobalState> createState() => _AppGlobalStateState();
}

class _AppGlobalStateState extends State<AppGlobalState> {
  @override
  Widget build(BuildContext context) {
    return LoginScreenTemp(database: widget.database);
  }
}
