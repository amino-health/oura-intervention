import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/SidebarScreenContainer.dart';

class LoginScreenTemp extends StatefulWidget {
  const LoginScreenTemp({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<LoginScreenTemp> createState() => _LoginScreenTempState();
}

class _LoginScreenTempState extends State<LoginScreenTemp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorText = "";
  bool _loggedIn = true;

  void login() async {
    LoginUserStatus loginUserStatus = await widget.database
        .loginUser(emailController.text, passwordController.text);
    switch (loginUserStatus) {
      case LoginUserStatus.successful:
        setState(() {
          _loggedIn = true;
        });
        return;
      case LoginUserStatus.userNotFound:
        return setState(() {
          _errorText = "User not found";
        });
      case LoginUserStatus.emailInvalid:
        return setState(() {
          _errorText = "Invalid email";
        });
      case LoginUserStatus.passwordInvalid:
        return setState(() {
          _errorText = "Invalid password";
        });
      case LoginUserStatus.tooManyRequests:
        return setState(() {
          _errorText = "Too many requests";
        });
      default:
        return setState(() {
          _errorText = "Unknown error";
        });
    }
  }

  void signup() async {
    AddUserStatus addUserStatus = await widget.database
        .addUser(emailController.text, passwordController.text, 'username');
    switch (addUserStatus) {
      case AddUserStatus.successful:
        setState(() {
          _loggedIn = true;
        });
        return;
      case AddUserStatus.emailBusy:
        return setState(() {
          _errorText = "Email already in use";
        });
      case AddUserStatus.emailInvalid:
        return setState(() {
          _errorText = "Invalid email";
        });
      case AddUserStatus.passwordWeak:
        return setState(() {
          _errorText = "Password is too weak";
        });
      default:
        return setState(() {
          _errorText = "Unknown error";
        });
    }
  }

  // User login state.
  @override
  Widget build(BuildContext context) {
    return _loggedIn
        ? const SidebarScreenContainer()
        : MaterialApp(
            home: Scaffold(
                body: SafeArea(
                    child: Center(
                        child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _errorText == ""
                    ? const SizedBox.shrink()
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(255, 212, 128, 122),
                        ),
                        child: Center(child: Text(_errorText)),
                        width: 300,
                        height: 30,
                      ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: login, child: const Text('Login')),
                    ElevatedButton(
                        onPressed: signup, child: const Text('Signup'))
                  ],
                )
              ],
            ),
            width: 300,
            height: 300,
          )))));
  }
}
