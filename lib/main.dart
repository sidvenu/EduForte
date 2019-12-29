import 'package:eduforte/login_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduForte',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(title: 'EduForte - Login'),
    );
  }
}
