import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/data_classes/course_timing.dart';
import 'package:eduforte/helpers/date_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';

class FirebaseHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<DocumentSnapshot> getStudentProfileDocument(
      {String phoneNumber}) async {
    if (phoneNumber == null) {
      phoneNumber = await FirebaseHelper.getUserPhoneString();
    }
    QuerySnapshot snapshot = await Firestore.instance
        .collection('students')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .getDocuments();
    return snapshot.documents.length != 0 ? snapshot.documents[0] : null;
  }

  static Future<Map<String, dynamic>> getStudentProfile(
      {String phoneNumber}) async {
    DocumentSnapshot studentProfileDocument =
        await getStudentProfileDocument(phoneNumber: phoneNumber);
    return studentProfileDocument?.data;
  }

  static Future<String> getUserPhoneString() async {
    FirebaseUser user = await _auth.currentUser();
    print('phone ${user.phoneNumber}');
    return user.phoneNumber;
  }

  static Future<bool> isUserLoggedIn() async {
    return await _auth.currentUser() != null;
  }

  static Future<List<CourseTiming>> getCourseTimings({String date = ""}) async {
    List<CourseTiming> courseTimings = List();

    final dateSpecificTimeTablesQuery = await Firestore.instance
        .collection("dateSpecificTimeTables")
        .where("date", isEqualTo: date)
        .getDocuments();

    if (dateSpecificTimeTablesQuery.documents.length == 0) {
      final generalTimeTablesQuery = await Firestore.instance
          .collection("generalTimeTables")
          .where(
            "day",
            isEqualTo: DateHelper.getDay(
              date: Jiffy(
                date,
                DateHelper.dateFormat,
              ),
            ),
          )
          .getDocuments();

      if (generalTimeTablesQuery.documents.length != 0) {
        courseTimings = CourseTiming.fromDynamicList(
            generalTimeTablesQuery.documents[0].data["courseTimings"]);
      }
    } else {
      courseTimings = CourseTiming.fromDynamicList(
          dateSpecificTimeTablesQuery.documents[0].data["courseTimings"]);
    }

    return courseTimings;
  }
}
