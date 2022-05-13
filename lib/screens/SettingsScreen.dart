import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;
import 'package:ouraintervention/screens/LoginScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.database, required this.callback}) : super(key: key);

  final Database database;
  final Function callback;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _errorText = "";
  bool _loggedIn = true;

  // Reset password
  final emailControllerReset = TextEditingController();
  final oldPasswordControllerReset = TextEditingController();
  final newPasswordControllerReset = TextEditingController();

  // Delete account
  final emailControllerDelete = TextEditingController();
  final passwordControllerDelete = TextEditingController();

  TextField generateTextField(TextEditingController controller, String labelText, bool obscureText, Icon icon) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: globals.dark, width: 2.0)),
            border: const OutlineInputBorder(),
            labelText: labelText,
            fillColor: Colors.white,
            filled: true),
        obscureText: obscureText);
  }

  Future<bool> submitNewPassword() async {
    UpdatePasswordStatus status =
        await widget.database.updatePassword(emailControllerReset.text, oldPasswordControllerReset.text, newPasswordControllerReset.text);
    String errorText;

    switch (status) {
      case UpdatePasswordStatus.successful:
        return true;

      case UpdatePasswordStatus.emailInvalid:
        errorText = "Invaild email";
        break;

      case UpdatePasswordStatus.passwordIncorrect:
        errorText = "Incorrect password";
        break;

      case UpdatePasswordStatus.passwordWeak:
        errorText = "New Password Is Too Weak";
        break;

      case UpdatePasswordStatus.unknownError:
        errorText = "Unknown Error";
        break;
    }

    setState(() {
      _errorText = errorText;
    });

    return false;
  }

  Future<bool> deleteAccount() async {
    bool success = await widget.database.deleteUser(emailControllerDelete.text, passwordControllerDelete.text);
    if (success) {
      globals.resetAllGlobals();
      widget.callback();
    }
    return success;
  }

  Future<void> _logoutAccount() async {
    await widget.database.logoutUser();
    globals.resetAllGlobals();
    widget.callback();
  }

  Future<void> _submitPasswordDialog() async {
    setState(() {
      _errorText = "";
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Password'),
          content: SizedBox(
              width: 200,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // FIXME: wrap in statefulbuilder. Does not update live at the moment
                _errorText == ""
                    ? const SizedBox.shrink()
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(255, 212, 128, 122),
                        ),
                        child: Center(child: Text(_errorText)),
                        width: 300,
                        height: 30,
                      ),
                generateTextField(emailControllerReset, 'Email', false, const Icon(Icons.email_sharp)),
                generateTextField(oldPasswordControllerReset, 'Old Password', true, const Icon(Icons.lock)),
                generateTextField(newPasswordControllerReset, 'New Password', true, const Icon(Icons.lock)),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit Password'),
              onPressed: () async {
                if (await submitNewPassword()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: SizedBox(
              width: 200,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Confirm your credentials'),
                generateTextField(emailControllerDelete, 'Email', false, const Icon(Icons.email_sharp)),
                generateTextField(passwordControllerDelete, 'Password', true, const Icon(Icons.lock)),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete Account'),
              onPressed: () async {
                if (await deleteAccount()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _disclaimerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disclaimer'),
          content: const SizedBox(
              width: 400,
              child: Text(
                  'This product is for general informational purposes only and does not constitute the practice of medicine, nursing or other professional health care services, including the giving of medical advice.\n\n The use of this information is at the user’s own risk.\n\n None of this is intended to be a substitute for professional medical advice, diagnosis, or treatment.\n\n Amino Health disclaims all responsibility and liability for the information collected or used by any third party service provider.\n\n Amino Health will have no responsibility or liability for any information, software, materials or services provided by any third parties.')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _termsAndConditionsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const SizedBox(width: 400, child: Text('TODO')),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: 700,
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: globals.grey,
            ),
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ElevatedButton(
                                onPressed: _disclaimerDialog,
                                child: const Text('Disclaimer'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(globals.dark),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ElevatedButton(
                                onPressed: _termsAndConditionsDialog,
                                child: const Text('Terms and Conditions'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(globals.dark),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ElevatedButton(
                                onPressed: _submitPasswordDialog,
                                child: const Text('Update Password'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(globals.dark),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ElevatedButton(
                                onPressed: _logoutAccount,
                                child: const Text('Logout'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(globals.dark),
                                )))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ElevatedButton(
                                onPressed: _deleteAccountDialog,
                                child: const Text('Delete Account'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                )))),
                    // 1200x715
                    
                  ],
                ))));
  }
}
