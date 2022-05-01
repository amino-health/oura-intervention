import 'dart:html';
import 'dart:io';
// ignore_for_file: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/SleepData.dart';

const clientId = 'Q4EDXKDK2244IHFU';
const clientSecret = 'VYOANLDLNJ473P6W7YAA2FRB6C4KRBXX';
final currentUri = Uri.base;
final redirectUri = Uri(
  host: currentUri.host,
  scheme: currentUri.scheme,
  port: currentUri.port,
  path: '/index.html',
);
final authUrl = 'https://cloud.ouraring.com/oauth/authorize?client_id=$clientId&state=$clientSecret&redirect_uri=$redirectUri&response_type=token';

class OuraLoginButton extends StatefulWidget {
  const OuraLoginButton({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<OuraLoginButton> createState() => _OuraLoginButtonState();
}

class _OuraLoginButtonState extends State<OuraLoginButton> {
  bool _isConnected = false;
  String _loginButtonText = 'Connect Oura Ring';

  /// TODO: document function
  Future<String> _login(String data, popupWindow) async {
    /// Parse data into an Uri to extract the token easily.
    final receivedUri = Uri.parse(data);

    /// Parse fragment string to token
    var token = receivedUri.fragment.split('&').firstWhere((e) => e.startsWith('access_token=')).substring('access_token='.length);

    if (popupWindow != null) {
      popupWindow.close();
      popupWindow = null;
    }

    return token;
  }

  /// TODO: Documentation for function
  void _authenticate() {
    html.WindowBase popupWindow = html.window.open(authUrl, "Oura authentication", "width=800, height=900, scrollbars=yes");

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
        var url = Uri.parse('https://api.ouraring.com/v1/sleep?start=2020-01-01&end=2022-04-22&access_token=$token');
        var response = await http.get(url, headers: {"Accept": "application/json", "Access-Control-Allow-Origin": "*"});

        // Decode the string from HTTP request to API
        Map<String, dynamic> sleepJson = jsonDecode(response.body) as Map<String, dynamic>;

        // Translate it so that Database method can be used to upload
        List<SleepData> sleepList = [];
        for (int i = 0; i < sleepJson['sleep']!.length; i++) {
          sleepList.add(SleepData.fromJson(sleepJson['sleep']![i]));
        }

        widget.database.uploadSleepData(sleepList);
        widget.database.getActionDates('run');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !_isConnected ? _authenticate : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
      ),
      child: Text(
        _loginButtonText,
        style: const TextStyle(fontSize: 25.0, color: Colors.white),
      ),
    );
  }
}
