import 'package:flutter/material.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:ouraintervention/widgets/groupedBarChart.dart';

const clientId = 'Q4EDXKDK2244IHFU';
const clientSecret = 'VYOANLDLNJ473P6W7YAA2FRB6C4KRBXX';
final currentUri = Uri.base;
final redirectUri = Uri(
  host: currentUri.host,
  scheme: currentUri.scheme,
  port: currentUri.port,
  path: '/index.html',
);
final authUrl =
    'https://cloud.ouraring.com/oauth/authorize?client_id=$clientId&state=$clientSecret&redirect_uri=$redirectUri&response_type=token';

void main() async {
  runApp(const OuraIntervention());
}

/// TODO: document function
Future<String> _login(String data, popupWindow) async {
  /// Parse data into an Uri to extract the token easily.
  final receivedUri = Uri.parse(data);

  /// Parse fragment string to token
  var token = receivedUri.fragment
      .split('&')
      .firstWhere((e) => e.startsWith('access_token='))
      .substring('access_token='.length);

  if (popupWindow != null) {
    popupWindow.close();
    popupWindow = null;
  }

  return token;
}

class OuraIntervention extends StatelessWidget {
  const OuraIntervention({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oura Intervention',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Oura Intervention'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = false;
  String _loginButtonText = 'Connect Oura Ring';

  /// TODO: Documentation for function
  void _authenticate() {
    html.WindowBase popupWindow = html.window.open(authUrl,
        "Oura authentication", "width=800, height=900, scrollbars=yes");

    setState(() {
      _loginButtonText = 'Waiting For Login...';
    });

    html.window.onMessage.listen((event) async {
      /// If the event contains the token it means the user is authenticated.

      if (event.data.toString().contains('access_token=')) {
        setState(() {
          _isConnected = true;
          _loginButtonText = 'Oura Ring Connected';
        });
        var token = await _login(event.data, popupWindow);
        var url = Uri.parse(
            'http://api.ouraring.com/v1/userinfo?access_token=$token');

        // TODO: To avoid CORS-issues, this HTTP GET
        //       request should moved to the backend!
        var response = await http.get(url, headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 25.0, color: Colors.white),
            ),
            centerTitle: true,
            actions: <Widget>[
              ElevatedButton(
                onPressed: !_isConnected ? _authenticate : null,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: Text(
                  _loginButtonText,
                  style: const TextStyle(fontSize: 25.0, color: Colors.white),
                ),
              ),
            ]),
        body: Center(
          // Example usage of GroupedBarChart
          child: GroupedBarChart(dataLists: [
            [
              Data('2015', 1),
              Data('2016', 2),
              Data('2017', 3),
              Data('2018', 4),
              Data('2019', 5)
            ],
            [
              Data('2015', 6),
              Data('2016', 7),
              Data('2017', 8),
              Data('2018', 9),
              Data('2019', 10)
            ],
            [
              Data('2015', 11),
              Data('2016', 12),
              Data('2017', 13),
              Data('2018', 14),
              Data('2019', 15)
            ]
          ]),
        ));
  }
}
