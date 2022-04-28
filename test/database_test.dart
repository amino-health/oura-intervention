import 'package:flutter_test/flutter_test.dart';

import 'package:ouraintervention/misc/Database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ouraintervention/objects/SleepData.dart';

void main() {
  void expectNotReached() {
    expect(true, false);
  }

  void expectReached() {
    expect(true, true);
  }

  final mockUser = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
  );
  group('getCollectionData()', () {
    test('Test get non-existing data', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      expect(await database.getCollectionData('testCollection'), []);
    });

    test('Test add data to collection and then get collection data', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      database.firestore.collection('testCollection').doc('someId').set({'testdata': 1, 'testdata2': 2});
      database.firestore.collection('testCollection').doc('someOtherId').set({'testdata': 1, 'testdata2': 2});
      expect(await database.getCollectionData('testCollection'), [
        {'testdata': 1, 'testdata2': 2},
        {'testdata': 1, 'testdata2': 2},
      ]);
    });
  });

  group('getFieldValue()', () {
    test('Test field value from non-existing collection', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      try {
        await database.getFieldValue('nonExisting', 'nonExisting');
        expectNotReached();
      } catch (e) {
        expectReached();
      }
    });

    test('Test field value from non-existing field', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      database.firestore.collection('testCollection').doc('someId').set({'testdata': 1, 'testdata2': 2});
      try {
        await database.getFieldValue('testCollection', 'nonExisting');
        expectNotReached();
      } catch (e) {
        expectReached();
      }
    });

    test('Add field value to collection and test fetching it', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth(signedIn: true, mockUser: mockUser));
      database.firestore.collection('testCollection').doc(mockUser.uid).set({'testdata': "1", 'testdata2': "2"});
      expect(await database.getFieldValue('testCollection', 'testdata'), "1");
      expect(await database.getFieldValue('testCollection', 'testdata2'), "2");
    });
  });

  group('addUser()', () {
    /// Unfortunately 'createUserWithEmailAndPassword' does not return any error
    /// codes for the fake authentication, which means it can't be tested properly
  });

  group('deleteUser()', () {
    test('Delete non-existing user', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      expect(await database.deleteUser('nonexisting', 'nonexisting'), false);
    });

    test('Add user, delete it and check that the users data is erased', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth(mockUser: mockUser));
      await database.addUser(mockUser.email!, 'password', 'username');
      expect(await database.getCollectionData('users'), isNot([]));
      expect(await database.deleteUser(mockUser.email!, 'password'), true);
      expect(await database.getCollectionData('users'), []);
    });
  });

  group('loginUser()', () {
    /// Unfortunately 'signInWithEmailAndPassword' does not return any error
    /// codes for the fake authentication, which means it can't be tested properly
  });

  group('logoutUser()', () {
    test('Check that logging out when there is no logged in user does not crash program', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      try {
        database.logoutUser();
        expectReached();
      } catch (error) {
        expectNotReached();
      }
    });
    test('Check that there is no currentUser after logout', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth(signedIn: true, mockUser: mockUser));
      expect(database.authentication.currentUser, mockUser);
      database.logoutUser();
      expect(database.authentication.currentUser, null);
    });
  });

  group('uploadOuraData()', () {
    test('Upload empty data, expect return false', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth());
      expect(await database.uploadOuraData([]), false);
    });

    test('Upload data, and test fetching it', () async {
      final Database database = Database(FakeFirebaseFirestore(), MockFirebaseAuth(signedIn: true, mockUser: mockUser));
      SleepData sleepData =
          const SleepData(minHr: 0.0, avgHr: 0.0, maxHr: 0, totalSleep: 0, lightSleep: 0, remSleep: 0, deepSleep: 0, date: '2022-04-28');
      expect(await database.uploadOuraData([sleepData]), true);
      await database.firestore.collection('userData').doc(mockUser.uid).collection('sleep').get().then((QuerySnapshot snapshot) {
        expect(snapshot.docs[0]['minHr'], 0.0);
      });
    });
  });
}
