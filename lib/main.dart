// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'login_widget.dart';
import 'loading_widget.dart';

void main() async {
  runApp(const AppGlobalState());
}

class AppGlobalState extends StatefulWidget {
  const AppGlobalState({Key? key}) : super(key: key);

  @override
  State<AppGlobalState> createState() => _AppGlobalStateState();
}

class _AppGlobalStateState extends State<AppGlobalState> {
  // User login state.
  String? _userToken;
  String? _userSecret;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: _userToken == null ? '/login' : '/dashboard',
      routes: {
        '/login': (context) => LoginWidget(
              onLogin: (identity, secret) {
                setState(() {
                  _userToken = identity;
                  _userSecret = secret;
                });
              },
            ),
        '/dashboard': (context) => Column(
              children: [
                Text('..Hello, $_userToken...'),
                Text(
                  'Please.. Make a pull request that changes me into a real dashboard...',
                  textScaleFactor: 0.8,
                ),
                LoadingWidget(
                  future: Future<Widget>.delayed(Duration(days: 1)),
                ),
                Text(
                  'Ill be loading in the meanwhile...',
                  textScaleFactor: 0.3,
                ),
                Text(
                  'Your secret is $_userSecret, please keep it safe. :)',
                  textScaleFactor: 0.6,
                ),
                Text(
                  'Never print it in big red text, it is a secret! Remember that.',
                  textScaleFactor: 0.8,
                ),
              ],
            ),
        '/settings': (context) =>
            throw UnimplementedError("TODO place ex. SettingsWidget here"),
        '/settings/addservice': (context) =>
            throw UnimplementedError("TODO place ex. ServiceListWidget here"),
        '/services/oura': (context) =>
            throw UnimplementedError("TODO place Jakob's oura auth page here"),
      },
      onUnknownRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) =>
            Text("Unknown route: '${routeSettings.name}', Ay caramba!"),
      ),
      title: 'Oura Intervention',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
