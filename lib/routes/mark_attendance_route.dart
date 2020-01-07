import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/data_classes/course_timing.dart';
import 'package:eduforte/helpers/date_helper.dart';
import 'package:eduforte/helpers/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MarkAttendanceRoute extends StatefulWidget {
  final String title = 'Mark Attendance';

  MarkAttendanceRoute({Key key}) : super(key: key);

  @override
  _MarkAttendanceRouteState createState() => _MarkAttendanceRouteState();
}

class _MarkAttendanceRouteState extends State<MarkAttendanceRoute> {
  String date = Jiffy().format(DateHelper.dateFormat);
  Map<CourseTiming, bool> courseTimingsAttendanceMap = Map();
  Map<String, dynamic> courseNames = Map();
  bool saveButtonEnabled = false;

  Future<void> fetchCourseNames() async {
    final querySnapshot =
        await Firestore.instance.collection("classCourses").getDocuments();
    for (DocumentSnapshot snapshot in querySnapshot.documents) {
      courseNames[snapshot.documentID] = snapshot.data["courseName"];
    }
  }

  List<CourseTiming> getAttendedCourses() {
    final attendedCourses = <CourseTiming>[];
    courseTimingsAttendanceMap
        .forEach((CourseTiming courseTiming, bool attended) {
      if (attended) {
        attendedCourses.add(courseTiming);
      }
    });
    return attendedCourses;
  }

  void fetchCourseTimingsAndAttendance() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Getting attendances");

    progress.show();

    await fetchCourseNames();

    List<CourseTiming> courseTimings =
        await FirebaseHelper.getCourseTimings(date: date);

    List<CourseTiming> attendance =
        await FirebaseHelper.getAttendance(date: date);

    courseTimingsAttendanceMap.clear();
    courseTimings.forEach((courseTiming) {
      bool attended = false;
      attendance.forEach((attendedCourseTiming) {
        if (courseTiming == attendedCourseTiming) {
          attended = true;
        }
      });
      courseTimingsAttendanceMap[courseTiming] = attended;
    });

    setState(() {});
    for (CourseTiming t in courseTimingsAttendanceMap.keys) {
      print('${t.courseCode} starts at ${t.startsAt} and ends at ${t.endsAt}');
    }
    for (CourseTiming t in attendance) {
      print(
          '\$\$\$sd${t.courseCode} starts at ${t.startsAt} and ends at ${t.endsAt}');
    }

    progress.dismiss();
  }

  void publishAttendedCourseTimings() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Publishing your attendance");

    progress.show();
    await FirebaseHelper.setAttendance(
        date: date, attendedCourseTimings: getAttendedCourses());
    progress.dismiss();
    setState(() {
      saveButtonEnabled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCourseTimingsAndAttendance();
    });
  }

  List<Widget> getCourseTimingsWidgets() {
    List<Widget> courseTimingWidgets = List();
    courseTimingsAttendanceMap
        .forEach((CourseTiming courseTiming, bool attended) {
      courseTimingWidgets.add(
        InkWell(
          onTap: () {
            courseTimingsAttendanceMap[courseTiming] = !attended;
            saveButtonEnabled = true;
            setState(() {});
          },
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 150,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      courseNames[courseTiming.courseCode],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '${courseTiming.startsAt} to ${courseTiming.endsAt}',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      attended ? Icons.done : Icons.clear,
                      color: attended ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return courseTimingWidgets;
  }

  void showDatePickerAndSetDate() async {
    date = Jiffy(
      await showDatePicker(
          context: context,
          initialDate: Jiffy(date, DateHelper.dateFormat).dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050)),
    ).format(DateHelper.dateFormat);
    saveButtonEnabled = false;
    setState(() {});
    fetchCourseTimingsAndAttendance();
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: windowSize.width * 0.42,
                height: 60,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    showDatePickerAndSetDate();
                  },
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.date_range,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: windowSize.height * 0.75,
                child: ListView(
                  children: getCourseTimingsWidgets(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveButtonEnabled ? publishAttendedCourseTimings : null,
        backgroundColor:
            saveButtonEnabled ? Theme.of(context).primaryColor : Colors.grey[600],
        icon: Icon(Icons.save),
        label: Text("Save"),
      ),
    );
  }
}
