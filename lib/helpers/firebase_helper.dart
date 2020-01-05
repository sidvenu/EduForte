import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> doesProfileExist({@required String phoneNumber}) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('students')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .getDocuments(source: Source.server);
    return snapshot.documents.length != 0;
  }

  static Future<String> getUserPhoneString() async {
    FirebaseUser user = await _auth.currentUser();
    print('phone ${user.phoneNumber}');
    return user.phoneNumber;
  }

  static Future<bool> isUserLoggedIn() async {
    return await _auth.currentUser() != null;
  }
}
