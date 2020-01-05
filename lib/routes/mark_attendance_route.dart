import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MarkAttendanceRoute extends StatefulWidget {
  final String title = 'Mark Attendance';

  MarkAttendanceRoute({Key key}) : super(key: key);

  @override
  _MarkAttendanceRouteState createState() => _MarkAttendanceRouteState();
}

class _MarkAttendanceRouteState extends State<MarkAttendanceRoute> {
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
        onPressed: () => {},
        icon: Icon(Icons.add),
        label: Text("Mark Attendance"),
      ),
    );
  }
}