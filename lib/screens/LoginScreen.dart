import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatelessWidget {
  final void Function(String identity, String secret) onLogin;

  const LoginScreen({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // TODO ....dont show these obviously
      showDebugButtons: true,
      disableCustomPageTransformer: true,
      onLogin: (data) {
        print(data.name);
        print(data.password);
        return null;
      },
      onSignup: (data) {
        print(data.name);
        print(data.password);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).popAndPushNamed("/dashboard");
      },
      onRecoverPassword: (data) {
        print("onRecoverPassword and ${data.toString()} turned up");

        return Future.delayed(
            const Duration(seconds: 1), () => "onRecoverPassword done");
      },
    );
  }
}
