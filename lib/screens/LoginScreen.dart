import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/SidebarScreenContainer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _errorText = "";
  bool _loggedIn = false;
  bool _signup = false;

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
    AddUserStatus addUserStatus = await widget.database.addUser(
        emailController.text, passwordController.text, usernameController.text);
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
      case AddUserStatus.tooManyRequests:
        return setState(() {
          _errorText = "Too many requests";
        });
      default:
        return setState(() {
          _errorText = "Unknown error";
        });
    }
  }

  Widget generateTextField(TextEditingController controller, String labelText,
      bool obscureText, Icon icon) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 67, 84, 98), width: 2.0)),
            border: const OutlineInputBorder(),
            labelText: labelText,
            fillColor: Colors.white,
            filled: true),
        obscureText: obscureText);
  }

  // User login state.
  @override
  Widget build(BuildContext context) {
    return _loggedIn
        ? SidebarScreenContainer(database: widget.database)
        : MaterialApp(
            theme: ThemeData(
                scaffoldBackgroundColor:
                    const Color.fromARGB(255, 230, 230, 230)),
            home: Scaffold(
                body: SafeArea(
                    child: Center(
                        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Oura Intervention',
                  style: TextStyle(fontSize: 30.0),
                ),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                        width: 350,
                        height: _signup ? 300 : 250,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 130, 130, 130)),
                                color: const Color.fromARGB(255, 204, 204, 204),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _errorText == ""
                                      ? const SizedBox.shrink()
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.red,
                                          ),
                                          child:
                                              Center(child: Text(_errorText)),
                                          height: 40,
                                        ),
                                  _signup
                                      ? generateTextField(
                                          usernameController,
                                          'Username',
                                          false,
                                          const Icon(
                                              Icons.account_circle_sharp))
                                      : const SizedBox.shrink(),
                                  generateTextField(emailController, 'Email',
                                      false, const Icon(Icons.email_sharp)),
                                  generateTextField(passwordController,
                                      'Password', true, const Icon(Icons.lock)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _signup
                                          ? ElevatedButton(
                                              onPressed: signup,
                                              child: const Text('Signup'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.black))
                                          : ElevatedButton(
                                              onPressed: login,
                                              child: const Text('Login'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.green,
                                                  onPrimary: Colors.black)),
                                    ],
                                  ),
                                  _signup
                                      ? TextButton(
                                          onPressed: () => {
                                                setState(
                                                  () {
                                                    _signup = false;
                                                    _errorText = "";
                                                  },
                                                )
                                              },
                                          child: const Text(
                                              'Already have an account? Log in'))
                                      : TextButton(
                                          onPressed: () => {
                                                setState(
                                                  () {
                                                    _signup = true;
                                                    _errorText = "";
                                                  },
                                                )
                                              },
                                          child: const Text(
                                              'Have no account? Sign up'))
                                ],
                              ),
                            ))))
              ],
            )))));
  }
}
