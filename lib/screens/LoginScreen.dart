import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/widgets/SidebarScreenContainer.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;

/**
 * LoginScreen: window displayed when logging in
 * database: the database object that is used when communicating with the backend
 */
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
  bool? acceptTC = false;
  String _errorText = "";
  bool _loggedIn = false;
  bool _signup = false;

  void login() async {
    //Send login request
    LoginUserStatus loginUserStatus = await widget.database.loginUser(emailController.text, passwordController.text);

    //Check response from the database
    switch (loginUserStatus) {
      case LoginUserStatus.successful:
        globals.isAdmin = await widget.database.getFieldValue('users', 'admin');
        resetAfterLogin();
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

  //Reset text fields so that the login screen does not store text
  void resetAfterLogin() {
    setState(() {
      _loggedIn = true;
      _signup = false;
      _errorText = "";
    });
    usernameController.text = "";
    emailController.text = "";
    passwordController.text = "";
  }

  void signup() async {
    //Send sign in request
    AddUserStatus addUserStatus = await widget.database.addUser(emailController.text, passwordController.text, usernameController.text);

    //Check status of the response from the backend
    switch (addUserStatus) {
      case AddUserStatus.successful:
        resetAfterLogin();
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

  //creates a text field widget
  Widget generateTextField(TextEditingController controller, String labelText, bool obscureText, Icon icon) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 67, 84, 98), width: 2.0)),
            border: const OutlineInputBorder(),
            labelText: labelText,
            fillColor: Colors.white,
            filled: true),
        obscureText: obscureText);
  }

  // logout function that allows the user to return to the login page
  void logout() {
    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loggedIn
        ? SidebarScreenContainer(database: widget.database, callback: logout)
        : MaterialApp(
            theme: ThemeData(scaffoldBackgroundColor: globals.grey),
            home: Scaffold(
                body: SafeArea(
                    child: Center(
                        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Amino Health',
                  style: TextStyle(fontSize: 30.0),
                ),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                        width: 350,
                        height: _signup ? 300 : 250,
                        child: DecoratedBox(
                            decoration: BoxDecoration(boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset: Offset(-5, 5), // changes position of shadow
                              ),
                            ], color: globals.mainColor, borderRadius: const BorderRadius.all(Radius.circular(15.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _errorText == ""
                                      ? const SizedBox.shrink()
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.red,
                                          ),
                                          child: Center(child: Text(_errorText)),
                                          height: 40,
                                        ),
                                  _signup
                                      ? generateTextField(usernameController, 'Username', false, const Icon(Icons.account_circle_sharp))
                                      : const SizedBox.shrink(),
                                  generateTextField(emailController, 'Email', false, const Icon(Icons.email_sharp)),
                                  generateTextField(passwordController, 'Password', true, const Icon(Icons.lock)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _signup
                                          ? Row(children: [
                                              ElevatedButton(
                                                  onPressed: acceptTC! ? signup : null,
                                                  child: const Text('Signup'),
                                                  style: ElevatedButton.styleFrom(primary: Colors.green, onPrimary: Colors.black)),
                                              Checkbox(
                                                value: acceptTC,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    acceptTC = value;
                                                  });
                                                },
                                              ),
                                              const Text("Accept Terms and Conditions", style: TextStyle(color: Colors.white))
                                            ])
                                          : ElevatedButton(
                                              onPressed: login,
                                              child: const Text('Login'),
                                              style: ElevatedButton.styleFrom(primary: Colors.green, onPrimary: Colors.black)),
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
                                          child: const Text('Already have an account? Log in'))
                                      : TextButton(
                                          onPressed: () => {
                                                setState(
                                                  () {
                                                    _signup = true;
                                                    _errorText = "";
                                                  },
                                                )
                                              },
                                          child: const Text('Have no account? Sign up'))
                                ],
                              ),
                            ))))
              ],
            )))));
  }
}
