import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashboardRoute extends StatefulWidget {
  final String title = 'EduForte - Dashboard';

  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
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
            Container(
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {},
        icon: Icon(Icons.message),
        label: Text("Send OTP"),
      ),
    );
  }
}
