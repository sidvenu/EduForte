import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/data_classes/course_timing.dart';
import 'package:eduforte/helpers/date_helper.dart';
import 'package:eduforte/helpers/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:progress_dialog/progress_dialog.dart';

class EditTimeTableRoute extends StatefulWidget {
  final String title = 'Edit EduForte Timetable';

  EditTimeTableRoute({Key key}) : super(key: key);

  @override
  _EditTimeTableRouteState createState() => _EditTimeTableRouteState();
}

class _EditTimeTableRouteState extends State<EditTimeTableRoute> {
  String date = Jiffy().format(DateHelper.dateFormat);
  List<CourseTiming> courseTimings = List();
  Map<String, dynamic> courseNames = Map();
  bool saveButtonEnabled = true;

  CourseTiming newCourseTiming = CourseTiming();
  TextEditingController startTimeController = TextEditingController(),
      endTimeController = TextEditingController();
  String startTimeError, endTimeError;

  Future<void> fetchCourseNames() async {
    final querySnapshot =
        await Firestore.instance.collection("classCourses").getDocuments();
    for (DocumentSnapshot snapshot in querySnapshot.documents) {
      courseNames[snapshot.documentID] = snapshot.data["courseName"];
    }
  }

  void sortCourseTimings() {
    courseTimings.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  void fetchCourseTimingsAndAttendance() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Getting attendances");

    progress.show();

    await fetchCourseNames();

    courseTimings = await FirebaseHelper.getCourseTimings(date: date);
    sortCourseTimings();

    setState(() {});
    for (CourseTiming t in courseTimings) {
      print(
          '\$\$\$sd${t.courseCode} starts at ${t.startsAt} and ends at ${t.endsAt}');
    }

    progress.dismiss();
  }

  void publishCourseTimings() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Publishing your attendance");

    progress.show();
    await FirebaseHelper.setTimetable(date: date, courseTimings: courseTimings);
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
    courseTimings.forEach((CourseTiming courseTiming) {
      courseTimingWidgets.add(
        Card(
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
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        courseTimings.remove(courseTiming);
                        saveButtonEnabled = true;
                      });
                    },
                    child: Container(
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return courseTimingWidgets;
  }

  String getCourseCode(dynamic courseName) {
    String courseCode;
    courseNames.forEach((String cCode, dynamic cName) {
      if (courseName == cName) {
        courseCode = cCode;
      }
    });
    return courseCode;
  }

  Widget getAddNewCourseTimingWidget() {
    Size windowSize = MediaQuery.of(context).size;

    String selectedValue;
    if (newCourseTiming.courseCode != null)
      selectedValue = courseNames[newCourseTiming.courseCode];
    else if (courseNames.values.length > 0) {
      selectedValue = courseNames.values.toList()[0];
    } else {
      selectedValue = "";
    }

    List<DropdownMenuItem<dynamic>> dropDownItems = courseNames.values
        .map(
          (courseName) => DropdownMenuItem(
            value: courseName,
            child: Text(courseName),
          ),
        )
        .toList();
    if (dropDownItems.length == 0) {
      dropDownItems.add(DropdownMenuItem(
        value: "",
        child: Text(""),
      ));
    }
    return Card(
      child: Container(
        width: windowSize.width * 0.5,
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Text(
            "Add new slot",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          DropdownButton(
            isExpanded: true,
            value: selectedValue,
            items: dropDownItems,
            onChanged: (course) {
              setState(() {
                newCourseTiming.courseCode = getCourseCode(course);
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: startTimeController,
            onChanged: (newStartTime) {
              setState(() {
                newCourseTiming.startsAt = newStartTime;
                startTimeError = null;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: new BorderSide(),
              ),
              hintText: '14:00',
              labelText: 'Start Time',
              errorText: startTimeError,
              hasFloatingPlaceholder: true,
            ),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: endTimeController,
            onChanged: (newEndTime) {
              setState(() {
                newCourseTiming.endsAt = newEndTime;
                endTimeError = null;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: new BorderSide(),
              ),
              hintText: '15:00',
              labelText: 'End Time',
              errorText: endTimeError,
              hasFloatingPlaceholder: true,
            ),
            textInputAction: TextInputAction.done,
          ),
          FlatButton(
            child: Text("Add"),
            onPressed: () {
              RegExp regex = RegExp(r'\d{2}:\d{2}');
              if (newCourseTiming.startsAt == null ||
                  regex.stringMatch(newCourseTiming.startsAt) !=
                      newCourseTiming.startsAt) {
                startTimeError = "Pattern not correct";
              }
              if (newCourseTiming.endsAt == null ||
                  regex.stringMatch(newCourseTiming.endsAt) !=
                      newCourseTiming.endsAt) {
                endTimeError = "Pattern not correct";
              }
              if (startTimeError == null && endTimeError == null) {
                courseTimings.add(newCourseTiming);
                sortCourseTimings();
                newCourseTiming = CourseTiming();
                saveButtonEnabled = true;
                startTimeController.clear();
                endTimeController.clear();
              }
              setState(() {});
            },
          ),
        ]),
      ),
    );
  }

  void showDatePickerAndSetDate() async {
    date = Jiffy(
      await showDatePicker(
          context: context,
          initialDate: Jiffy(date, DateHelper.dateFormat).dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050)),
    ).format(DateHelper.dateFormat);
    saveButtonEnabled = true;
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
                  children: [
                    getAddNewCourseTimingWidget(),
                    ...getCourseTimingsWidgets(),
                    SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveButtonEnabled ? publishCourseTimings : null,
        backgroundColor: saveButtonEnabled
            ? Theme.of(context).primaryColor
            : Colors.grey[600],
        icon: Icon(Icons.save),
        label: Text("Save"),
      ),
    );
  }
}
