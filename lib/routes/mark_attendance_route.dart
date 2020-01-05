import 'dart:convert';

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

  void fetchClassTimings() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Getting attendances");

    progress.show();

    List<CourseTiming> courseTimings =
        await FirebaseHelper.getCourseTimings(date: date);

    courseTimingsAttendanceMap.clear();
    courseTimings.forEach(
        (courseTiming) => courseTimingsAttendanceMap[courseTiming] = false);

    setState(() {});
    for (CourseTiming t in courseTimingsAttendanceMap.keys) {
      print('${t.courseCode} starts at ${t.startsAt} and ends at ${t.endsAt}');
    }

    progress.dismiss();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchClassTimings();
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
            setState(() {});
          },
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 120,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      courseTiming.courseCode,
                      style: TextStyle(fontSize: 40),
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
    setState(() {});
    fetchClassTimings();
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
                width: windowSize.width * 0.45,
                height: 60,
                child: RaisedButton(
                  color: Colors.deepPurple,
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
        onPressed: () => {},
        icon: Icon(Icons.save),
        label: Text("Save"),
      ),
    );
  }
}
