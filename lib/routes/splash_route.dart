import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashRoute extends StatefulWidget {
  SplashRoute({Key key}) : super(key: key);

  @override
  _SplashRouteState createState() => _SplashRouteState();
}

class _SplashRouteState extends State<SplashRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: FlutterLogo(
          colors: Colors.deepOrange,
          size: 75,
        ),
      ),
      color: Colors.white,
    );
  }
}
