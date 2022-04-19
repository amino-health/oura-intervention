// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'screens/LoginScreen.dart';
import 'widgets/LoadingWidget.dart';
import 'package:ouraintervention/screens/Dashboard.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth authentication = FirebaseAuth.instance;
  Database database = Database(firestore, authentication);

  runApp(const AppGlobalState());
}

class AppGlobalState extends StatefulWidget {
  const AppGlobalState({Key? key}) : super(key: key);

  @override
  State<AppGlobalState> createState() => _AppGlobalStateState();
}

class _AppGlobalStateState extends State<AppGlobalState> {
  // User login state.
  String? _email;
  String? _password;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: _email == null ? '/login' : '/dashboard',
      routes: {
        '/login': (context) => LoginScreen(
              onLogin: (identity, secret) {
                setState(() {
                  _email = identity;
                  _password = secret;
                });
              },
            ),
        '/dashboard': (context) => Dashboard(
              title: 'Oura Intervention',
            ),
        '/settings': (context) =>
            throw UnimplementedError("TODO place ex. SettingsWidget here"),
        '/settings/addservice': (context) =>
            throw UnimplementedError("TODO place ex. ServiceListWidget here"),
        '/services/oura': (context) =>
            throw UnimplementedError("TODO place Jakob's oura auth page here"),
      },
      onUnknownRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) => Text("Unknown route: '${routeSettings.name}'"),
      ),
      title: 'Oura Intervention',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
