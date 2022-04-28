import 'package:flutter_test/flutter_test.dart';

import 'package:ouraintervention/misc/Database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}
