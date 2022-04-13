import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginWidget extends StatelessWidget {
  final void Function(String identity, String secret) onLogin;

  const LoginWidget({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // TODO ....dont show these obviously
      showDebugButtons: true,
      disableCustomPageTransformer: true,
      onLogin: (p0) {
        onLogin(p0.name, p0.password);
        return null;
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).popAndPushNamed("/dashboard");
      },
      onRecoverPassword: (p0) {
        print("onRecoverPassword and ${p0.toString()} turned up");

        return Future.delayed(
            const Duration(seconds: 1), () => "onRecoverPassword done");
      },
    );
  }
}
