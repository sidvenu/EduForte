import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/data_classes/course_timing.dart';
import 'package:eduforte/helpers/date_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        .where(
          "classroomID",
          isEqualTo: (await getStudentProfile(
            phoneNumber: await getUserPhoneString(),
          ))["classroomID"],
        )
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

  static Future<List<CourseTiming>> getAttendance({String date}) async {
    List<CourseTiming> courseTimings = List();
    Map<String, dynamic> studentProfile =
        await getStudentProfile(phoneNumber: await getUserPhoneString());

    final attendancesQuery = await Firestore.instance
        .collection("attendances")
        .where("date", isEqualTo: date)
        .where("studentID", isEqualTo: studentProfile["studentID"])
        .getDocuments();

    if (attendancesQuery.documents.length != 0) {
      courseTimings = CourseTiming.fromDynamicList(
        attendancesQuery.documents[0].data["courseTimings"],
      );
    }

    return courseTimings;
  }

  static Future<void> setAttendance(
      {String date, List<CourseTiming> attendedCourseTimings}) async {
    Map<String, dynamic> studentProfile =
        await getStudentProfile(phoneNumber: await getUserPhoneString());

    final attendancesQuery = await Firestore.instance
        .collection("attendances")
        .where("date", isEqualTo: date)
        .where("studentID", isEqualTo: studentProfile["studentID"])
        .getDocuments();
    String documentID;
    if (attendancesQuery.documents.length != 0) {
      documentID = attendancesQuery.documents[0].documentID;
    }
    await Firestore.instance
        .collection("attendances")
        .document(documentID)
        .setData(<String, dynamic>{
      "studentID": studentProfile["studentID"],
      "date": date,
      "courseTimings": CourseTiming.toListMap(attendedCourseTimings),
    });
  }

  static Future<void> setTimetable(
      {String date, List<CourseTiming> courseTimings}) async {
    Map<String, dynamic> studentProfile =
        await getStudentProfile(phoneNumber: await getUserPhoneString());

    final attendancesQuery = await Firestore.instance
        .collection("dateSpecificTimeTables")
        .where("date", isEqualTo: date)
        .where("classroomID", isEqualTo: studentProfile["classroomID"])
        .getDocuments();
    String documentID;
    if (attendancesQuery.documents.length != 0) {
      documentID = attendancesQuery.documents[0].documentID;
    }
    await Firestore.instance
        .collection("dateSpecificTimeTables")
        .document(documentID)
        .setData(<String, dynamic>{
      "classroomID": studentProfile["classroomID"],
      "date": date,
      "courseTimings": CourseTiming.toListMap(courseTimings),
    });
  }

  static Future<bool> isStudentACR() async {
    Map<String, dynamic> userProfile =
        await getStudentProfile(phoneNumber: await getUserPhoneString());
    Map<String, dynamic> classroomData = (await Firestore.instance
            .collection("classrooms")
            .document(userProfile["classroomID"])
            .get())
        .data;
    return classroomData["classroomRepresentatives"]
        .contains(userProfile["studentID"]);
  }
}
