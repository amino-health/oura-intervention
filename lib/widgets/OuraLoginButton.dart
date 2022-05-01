// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';

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
        await widget.database.uploadSleepData(token);

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
