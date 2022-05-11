// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ouraintervention/objects/SleepData.dart';
import 'package:ouraintervention/objects/Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AddUserStatus { successful, emailBusy, emailInvalid, passwordWeak, tooManyRequests, unknownError }

enum LoginUserStatus { successful, emailInvalid, userNotFound, passwordInvalid, tooManyRequests, unknownError }

enum UpdatePasswordStatus { successful, emailInvalid, passwordIncorrect, unknownError, passwordWeak }

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
  Future<dynamic> getFieldValue(String collection, String field, [String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    dynamic fieldValue = await firestore.collection(collection).doc(uid).get().then((value) {
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
        'latestUpdate': '2000-01-01',
      }).catchError((error) => throw Exception('Unknown error'));

      firestore.collection('userActions').doc(uid).set({}).catchError((error) => throw Exception('Unknown error'));
      firestore.collection('userData').doc(uid).set({}).catchError((error) => throw Exception('Unknown error'));
      firestore.collection('userMessages').doc(uid).set({}).catchError((error) => throw Exception('Unknown error'));
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
    uploadMessage(DateTime.now().toString(), 'Welcome to the application. This is where you will recieve messages from your coach. Try sending them a message!', true);
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

  /// Uploads sleepdata using the Oura api and a [token]
  Future<bool> uploadSleepData(String token) async {
    final userid = authentication.currentUser!.uid;
    String latestUpdate = await getFieldValue('users', 'latestUpdate');
    String currentDate = DateTime.now().toString().substring(0, DateTime.now().toString().length - 13);
    var url = Uri.parse('https://api.ouraring.com/v1/sleep?start=$latestUpdate&end=$currentDate&access_token=$token');
    var response = await http.get(url, headers: {"Accept": "application/json", "Access-Control-Allow-Origin": "*"});

    Map<String, dynamic> sleepJson = jsonDecode(response.body) as Map<String, dynamic>;

    List<SleepData> sleepList = [];

    for (int i = 0; i < sleepJson['sleep']!.length; i++) {
      sleepList.add(SleepData.fromJson(sleepJson['sleep']![i]));
    }

    if (sleepList.length == 0.0) {
      return false; //no data to upload
    }
    for (SleepData doc in sleepList) {
      firestore
          .collection('userData')
          .doc(userid)
          .collection('sleep')
          .doc(doc.date)
          .set({
            'Minimum Heartrate': doc.minHr,
            'Average Heartrate': doc.avgHr,
            'Maximum Heartrate': doc.maxHr,
            'Total Sleep': doc.totalSleep,
            'Light Sleep': doc.lightSleep,
            'Rem Sleep': doc.remSleep,
            'Deep Sleep': doc.deepSleep,
            'Minimum Heartrate Variance': doc.minHrv,
            'Average Heartrate Variance': doc.avgHrv,
            'Maximum Heartrate Variance': doc.maxHrv,
            'date': doc.date
          })
          .then((value) => print("Sleep data uploaded"))
          .catchError((error) => print("Failed to upload sleep data for ${doc.date}: $error"));
    }
    firestore.collection('users').doc(userid).update({'latestUpdate': currentDate});

    return true;
  }

  Future<bool> uploadAction(String action, String date, [String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    if (action == "") return false; // no action
    if (date == "") return false; //TODO: check that date is not in the future?

    firestore
        .collection('userActions')
        .doc(uid)
        .collection('actions')
        .add({'action': action, 'date': date})
        .then((value) => print("Action uploaded"))
        .catchError((error) => print("Failed to upload action($action), for date($date): $error"));

    return true;
  }

  Future<bool> deleteAction(String action, String date, [String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    bool foundAction = true;

    await firestore
        .collection('userActions')
        .doc(uid)
        .collection('actions')
        .where('action', isEqualTo: action)
        .where('date', isEqualTo: date)
        .get()
        .then((QuerySnapshot snapshot) async => {
              if (snapshot.docs.isEmpty) {foundAction = false},
              for (var element in snapshot.docs) {await firestore.collection('userActions').doc(uid).collection('actions').doc(element.id).delete()}
            });
    return foundAction;
  }

  Future<List<Map<String, String>>> getActions([String? uid]) async {
    if (globals.actions.isNotEmpty) {
      return globals.actions;
    }
    uid ??= authentication.currentUser!.uid;
    List<Map<String, String>> actions = [];
    await firestore.collection('userActions').doc(uid).collection('actions').get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        actions.add({'date': element['date'], 'action': element['action']});
      }
    });
    globals.actions = actions;
    return actions;
  }

  Future<void> uploadMessage(String dateTime, String message, bool coach, [String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    assert(uid != "" && message != "");
    firestore
        .collection('userMessages')
        .doc(uid)
        .collection('messages')
        .add({'message': message, 'date': dateTime, 'coach': coach})
        .then((value) => print("Sleep data uploaded"))
        .catchError((error) => print("Failed to upload sleep data for ${dateTime}: $error"));
  }

  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    assert(userId != "");
    List<Map<String, dynamic>> messages = [];
    //Limited to 2 messages to lower amount of reads
    await firestore.collection('userMessages').doc(userId).collection('messages').orderBy('date').get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        messages.add({'message': element['message'], 'date': element['date'], 'coach': element['coach']});
      }
    });
    return messages;
  }

  Future<List<String>> getActionDates(String action, [String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    List<String> dates = [];
    await firestore.collection('userActions').doc(uid).collection('actions').where('action', isEqualTo: action).get().then((QuerySnapshot snapshot) {
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

  Future<List<Map<String, dynamic>>> getSleepData([String? uid]) async {
    uid ??= authentication.currentUser!.uid;
    QuerySnapshot snapshot = await firestore.collection('userData').doc(uid).collection('sleep').get();

    List<Map<String, dynamic>> sleepData = snapshot.docs.map((doc) => doc.data()).toList().cast();
    return sleepData;
  }

  /// Updates the [password] of a user in the database to a new
  /// password given the [email] of the user and a [newPassword].
  Future<UpdatePasswordStatus> updatePassword(String email, String password, String newPassword) async {
    final user = authentication.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return UpdatePasswordStatus.emailInvalid;
      } else if (e.code == 'wrong-password') {
        return UpdatePasswordStatus.passwordIncorrect;
      } else {
        print(e.code);
        return UpdatePasswordStatus.unknownError;
      }
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return UpdatePasswordStatus.passwordWeak;
      }
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
    return UpdatePasswordStatus.successful;
  }

  Future<List<Map<String, String>>> getallUsers() async {
    QuerySnapshot snapshot = await firestore.collection('users').where('admin', isEqualTo: false).get();

    List<Map<String, dynamic>> userData = snapshot.docs.map((doc) => doc.data()).toList().cast();
    List<String> ids = snapshot.docs.map((doc) => doc.id).toList().cast();
    List<Map<String, String>> users = [];

    for (var i = 0; i < userData.length; i++) {
      users.add({'username': userData[i]['username'], 'id': ids[i]});
    }

    return users;
  }
}
