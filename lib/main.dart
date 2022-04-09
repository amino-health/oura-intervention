import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:html' as html;

// import 'package:flutter/widgets.dart';

// import 'package:oauth2/oauth2.dart' as oauth2;
// import 'package:webview_flutter/webview_flutter.dart';

//final authorizationEndpoint = Uri.parse('https://cloud.ouraring.com/oauth/authorize');
//final tokenEndpoint = Uri.parse('https://api.ouraring.com/oauth/token');
final clientId = 'Q4EDXKDK2244IHFU';
final clientSecret = 'VYOANLDLNJ473P6W7YAA2FRB6C4KRBXX';
//final redirectUrl = Uri.parse('wss://authresponse.ouraintervention.com');
// final credentialsFile = File('~/.myapp/credentials.json');
final currentUri = Uri.base;
final redirectUri = Uri(
    host: currentUri.host,
    scheme: currentUri.scheme,
    port: currentUri.port,
    path: '/index.html',
  );
final authUrl = 'https://cloud.ouraring.com/oauth/authorize?client_id=$clientId&state=$clientSecret&redirect_uri=$redirectUri&response_type=token';


void main() async {
  runApp(const MyApp());
  // Open window
  html.WindowBase _popupWin = html.window.open(authUrl, "Oura authentication", "width=800, height=900, scrollbars=yes");
  var _token;

  html.window.onMessage.listen((event) async {
  /// If the event contains the token it means the user is authenticated.
    if (event.data.toString().contains('access_token=')) {
      _token = await _login(event.data, _popupWin);
      var url = Uri.parse('http://api.ouraring.com/v1/userinfo?access_token=$_token');
      var response = await http.get(url, headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        });
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  });
}

Future<String> _login(String data, _popupWin) async {
  /// Parse data into an Uri to extract the token easily.
  final receivedUri = Uri.parse(data);
  
  /// Get the access_token from the `Uri.fragement` (depending of the
  /// authentication service it might be contained in another
  /// property of your Uri.
  var _token = receivedUri.fragment
    .split('&')
    .firstWhere((e) => e.startsWith('access_token='))
    .substring('access_token='.length);
  
  //print(_token);
  /// Close the popup window
  if (_popupWin != null) {
    _popupWin.close();
    _popupWin = null;
  }

  return _token;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
