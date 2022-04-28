import 'package:flutter/material.dart';
import 'package:ouraintervention/misc/Database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.database}) : super(key: key);

  final Database database;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showInputFields = false;
  String _errorText = "";

  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  void submitNewPassword() async {
    UpdatePasswordStatus status = await widget.database.updatePassword(emailController.text, oldPasswordController.text, newPasswordController.text);
    switch (status) {
      case UpdatePasswordStatus.successful:
        return setState(() {
          _showInputFields = false;
        });

      case UpdatePasswordStatus.emailInvalid:
        return setState(() {
          _errorText = "Invaild email";
        });

      case UpdatePasswordStatus.passwordIncorrect:
        return setState(() {
          _errorText = "Incorrect password";
        });

      case UpdatePasswordStatus.passwordWeak:
        return setState(() {
          _errorText = "New Password Is Too Weak";
        });

      case UpdatePasswordStatus.unknownError:
        return setState(() {
          _errorText = "Unknown Error";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ElevatedButton(
          onPressed: () => {
                setState(() {
                  _showInputFields = true;
                })
              },
          child: Text('Update Password')),
      _showInputFields
          ? Container(
              width: 200,
              child: Column(children: [
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
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email', fillColor: Colors.white, filled: true),
                ),
                TextField(
                  controller: oldPasswordController,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Old Password', fillColor: Colors.white, filled: true),
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'New Password', fillColor: Colors.white, filled: true),
                ),
                ElevatedButton(onPressed: submitNewPassword, child: Text('Submit'))
              ]))
          : const SizedBox.shrink()
    ]);
  }
}
