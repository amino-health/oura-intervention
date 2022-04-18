//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AddUserStatus { successful, usernameBusy, emailBusy, invalidEmail }

class Database {
  Database(this.firestore);

  final FirebaseFirestore firestore;

  /// Returns all data from a [collection] as a list.
  /// Returns `[]` if collection is non-existing.
  Future<List> getCollectionData(String collection) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection(collection).get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();
    return data;
  }

  /// Adds a users [username], [password] and [email] to the database.
  Future<AddUserStatus> addUser(
      String username, String password, String email) async {
    List users = await getCollectionData('users');

    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!emailValid) {
      return AddUserStatus.invalidEmail;
    }

    for (var user in users) {
      if (user['username'] == username) {
        return AddUserStatus.usernameBusy;
      }
      if (user['email'] == email) {
        return AddUserStatus.emailBusy;
      }
    }

    firestore.collection('users').add({
      'username': username,
      'password': password,
      'email': email
    }).catchError((error) => throw Exception('Unknown error'));

    return AddUserStatus.successful;
  }
}
