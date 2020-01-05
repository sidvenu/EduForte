import 'package:eduforte/helpers/firebase_helper.dart';
import 'package:eduforte/routes/dashboard_route.dart';
import 'package:eduforte/routes/login_with_phone/create_profile_route.dart';
import 'package:eduforte/routes/login_with_phone/login_route.dart';
import 'package:eduforte/routes/splash_route.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String routeNameToShow = "splash";
  String phoneNumber;

  void checkIfUserIsAlreadyLoggedIn() async {
    if (await FirebaseHelper.isUserLoggedIn()) {
      phoneNumber = await FirebaseHelper.getUserPhoneString();
      if (await FirebaseHelper.doesProfileExist(
        phoneNumber: phoneNumber,
      )) {
        routeNameToShow = "dashboard";
      } else {
        routeNameToShow = "create_profile";
      }
    } else {
      routeNameToShow = "login";
    }
    setState(() {});
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
      case "create_profile":
        routeToShow = CreateProfileRoute(
          phoneNumber: phoneNumber,
        );
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
