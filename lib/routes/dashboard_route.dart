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
  void goToMarkAttendanceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkAttendanceRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToMarkAttendanceScreen,
        icon: Icon(Icons.add),
        label: Text("Mark Attendance"),
      ),
    );
  }
}
