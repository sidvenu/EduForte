import 'package:eduforte/helpers/firebase_helper.dart';
import 'package:eduforte/routes/edit_timetable_route.dart';
import 'package:eduforte/routes/mark_attendance_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashboardRoute extends StatefulWidget {
  final String title = 'Your EduForte Dashboard';

  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  bool isEditTimeTableButtonVisible = false;

  void goToMarkAttendanceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkAttendanceRoute(),
      ),
    );
  }

  void goToEditTimeTableScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTimeTableRoute(),
      ),
    );
  }

  void checkIfUserIsACR() async {
    isEditTimeTableButtonVisible = await FirebaseHelper.isStudentACR();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfUserIsACR();
    });
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton markAttendanceButton = FloatingActionButton.extended(
      heroTag: "markAttendanceButton",
      onPressed: goToMarkAttendanceScreen,
      icon: Icon(Icons.add),
      label: Text("Mark Attendance"),
    );

    FloatingActionButton editTimeTableButton = FloatingActionButton.extended(
      heroTag: "editTimeTableButton",
      onPressed: goToEditTimeTableScreen,
      icon: Icon(Icons.edit),
      label: Text("Edit Timetable"),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(
            child: editTimeTableButton,
            visible: isEditTimeTableButtonVisible,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: markAttendanceButton,
          ),
        ],
      ),
    );
  }
}
