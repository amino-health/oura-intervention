// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ouraintervention/objects/SleepData.dart';
import 'package:firebase_core/firebase_core.dart';

enum AddUserStatus { successful, emailBusy, emailInvalid, passwordWeak, tooManyRequests, unknownError }

enum LoginUserStatus { successful, emailInvalid, userNotFound, passwordInvalid, tooManyRequests, unknownError }

enum updatePasswordStatus { successful, emailInvalid, passwordIncorrect, unknownError, passwordWeak }

class Database {
  Database(this.firestore, this.authentication);

  final FirebaseFirestore firestore;
  final FirebaseAuth authentication;

  /// Returns all data from a [collection] as a list.
  /// Returns `[]` if collection is non-existing.
  Future<List> getCollectionData(String collection) async {
    QuerySnapshot snapshot = await firestore.collection(collection).get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();
    return data;
  }

  /// Returns the value of a field given a [collection] and a [field]
  Future<String> getFieldValue(String collection, String field) async {
    String uid = authentication.currentUser!.uid;
    String fieldValue = await firestore.collection('users').doc(uid).get().then((value) {
      return value.data()![field];
    });
    return fieldValue;
  }

  /// Adds a users [email] and [password] to the database.
  Future<AddUserStatus> addUser(String email, String password, String username) async {
    try {
      // TODO: send this to coach
      UserCredential credential = await authentication.createUserWithEmailAndPassword(email: email, password: password);
      String uid = credential.user!.uid;
      firestore.collection('users').doc(uid).set({
        'admin': false,
        'username': username,
      }).catchError((error) => throw Exception('Unknown error'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return AddUserStatus.emailInvalid;
      } else if (e.code == 'weak-password') {
        return AddUserStatus.passwordWeak;
      } else if (e.code == 'email-already-in-use') {
        return AddUserStatus.emailBusy;
      } else if (e.code == 'too-many-requests') {
        return AddUserStatus.tooManyRequests;
      } else {
        return AddUserStatus.unknownError;
      }
    } catch (e) {
      throw Exception(e);
    }
    return AddUserStatus.successful;
  }

  /// Deletes a user from the database based on their [email] and [password].
  /// Returns `true` if deletion is successfull, `false` if not.
  Future<bool> deleteUser(String email, String password) async {
    User? user = authentication.currentUser;
    if (user == null) {
      return false;
    }

    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
    DocumentReference document = firestore.collection('users').doc(user.uid);
    await document.delete();
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(e);
      }
    }
    return true;
  }

  /// Logins a user from the databased based on their [email] and [password].
  Future<LoginUserStatus> loginUser(String email, String password) async {
    UserCredential credential;
    try {
      credential = await authentication.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return LoginUserStatus.emailInvalid;
      } else if (e.code == 'user-not-found') {
        return LoginUserStatus.userNotFound;
      } else if (e.code == 'wrong-password') {
        return LoginUserStatus.passwordInvalid;
      } else if (e.code == 'too-many-requests') {
        return LoginUserStatus.tooManyRequests;
      } else {
        print(e.code);
        return LoginUserStatus.unknownError;
      }
    } catch (e) {
      throw Exception(e);
    }
    return LoginUserStatus.successful;
  }

  /// Logs out the currently logged in user
  Future<void> logoutUser() async {
    await authentication.signOut();
  }

  /// Uploads data from Oura API
  Future<bool> uploadOuraData(List<SleepData> data) async {
    final userid = authentication.currentUser!.uid;

    if (data.length == 0.0) {
      return false; //no data to upload
    }
    for (SleepData doc in data) {
      firestore
          .collection('users')
          .doc(userid)
          .collection('sleep')
          .doc(doc.date)
          .set({
            'minHr': doc.minHr,
            'avgHr': doc.avgHr,
            'maxHr': doc.maxHr,
            'totalSleep': doc.totalSleep,
            'lightSleep': doc.lightSleep,
            'remSleep': doc.remSleep,
            'deepSleep': doc.deepSleep,
            'date': doc.date
          })
          .then((value) => print("Sleep data uploaded"))
          .catchError((error) => print("Failed to upload sleep data for ${doc.date}: $error"));
    }
    return true;
  }

  Future<bool> uploadAction(String action, String date) async {
    final userid = authentication.currentUser!.uid;
    if (action == "") return false; // no action
    if (date == "") return false; //TODO: check that date is not in the future?

    firestore
        .collection('users')
        .doc(userid)
        .collection('actions')
        .add({'action': action, 'date': date})
        .then((value) => print("Action uploaded"))
        .catchError((error) => print("Failed to upload action($action), for date($date): $error"));

    return true;
  }

  Future<void> uploadMessage(String userId, String message, bool coach) async {
    assert(userId != "" && message != "");
    FieldValue timeStamp = FieldValue.serverTimestamp();
    firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .add({'message': message, 'timeStamp': timeStamp, 'coach': coach})
        .then((value) => print("Sleep data uploaded"))
        .catchError((error) => print("Failed to upload sleep data for ${timeStamp}: $error"));
  }

  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    assert(userId != "");
    List<Map<String, dynamic>> messages = [];
    await firestore.collection('users').doc(userId).collection('messages').orderBy('timeStamp').get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        messages.add({'message': element['message'], 'coach': element['coach']});
      }
    });
    return messages;
  }

  Future<List<String>> getActionDates(String action) async {
    final userid = authentication.currentUser!.uid;
    List<String> dates = [];
    await firestore.collection('users').doc(userid).collection('actions').where('action', isEqualTo: action).get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        dates.add(element['date']);
      }
    });
    return dates;
  }

  Future<String?> getEmail() async {
    User? user = authentication.currentUser;
    if (user == null) {
      return "";
    }
    return user.email;
  }

  Future<List<Map<String, dynamic>>> getSleepData() async {
    final userid = authentication.currentUser!.uid;
    QuerySnapshot snapshot = await firestore.collection('users').doc(userid).collection('sleep').get();

    List<Map<String, dynamic>> sleepData = snapshot.docs.map((doc) => doc.data()).toList().cast();
    return sleepData;
  }

  /// Updates the [password] of a user in the database to a new
  /// password given the [email] of the user and a [newPassword].
  Future<updatePasswordStatus> updatePassword(String email, String password, String newPassword) async {
    final user = authentication.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return updatePasswordStatus.emailInvalid;
      } else if (e.code == 'wrong-password') {
        return updatePasswordStatus.passwordIncorrect;
      } else {
        print(e.code);
        return updatePasswordStatus.unknownError;
      }
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return updatePasswordStatus.passwordWeak;
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
    return updatePasswordStatus.successful;
  }
}
