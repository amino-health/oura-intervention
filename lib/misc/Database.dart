// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AddUserStatus {
  successful,
  emailBusy,
  emailInvalid,
  passwordWeak,
  unknownError
}

enum LoginUserStatus {
  successful,
  emailInvalid,
  userNotFound,
  passwordInvalid,
  tooManyRequests,
  unknownError
}

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

  /// Adds a users [email] and [password] to the database.
  Future<AddUserStatus> addUser(
      String email, String password, String username) async {
    try {
      // TODO: send this to coach
      UserCredential credential = await authentication
          .createUserWithEmailAndPassword(email: email, password: password);
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

    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);

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
    UserCredential? credential;
    try {
      credential = await authentication.signInWithEmailAndPassword(
          email: email, password: password);
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
}
