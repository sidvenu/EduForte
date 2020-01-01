import 'package:eduforte/routes/dashboard_route.dart';
import 'package:eduforte/routes/login_with_phone/login_route.dart';
import 'package:eduforte/routes/splash_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String routeNameToShow = "splash";

  void checkIfUserIsAlreadyLoggedIn() async {
    FirebaseUser user = await _auth.currentUser();
    setState(() {
      if (user == null) {
        routeNameToShow = "login";
      } else {
        routeNameToShow = "dashboard";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfUserIsAlreadyLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget routeToShow;
    switch (routeNameToShow) {
      case "splash":
        routeToShow = SplashRoute();
        break;
      case "login":
        routeToShow = LoginRoute();
        break;
      case "dashboard":
        routeToShow = DashboardRoute();
        break;
    }

    return MaterialApp(
      title: 'EduForte',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: routeToShow,
    );
  }
}
