import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/routes/dashboard_route.dart';
import 'package:eduforte/routes/join_classroom_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:validators/validators.dart';

class CreateProfileRoute extends StatefulWidget {
  final String title = "Create your EduForte profile";
  final String phoneNumber;

  CreateProfileRoute({Key key, @required this.phoneNumber}) : super(key: key);

  @override
  _CreateProfileRouteState createState() => _CreateProfileRouteState();
}

class _CreateProfileRouteState extends State<CreateProfileRoute> {
  String name = '', studentID = '';
  String nameError, studentIDError;
  ProgressDialog progressMessageDialog;

  bool isStudentIDValid() {
    return studentID.length >= 6 &&
        studentID.toLowerCase() == studentID &&
        isAlpha(studentID[0]);
  }

  void showProgressMessage(String message) {
    progressMessageDialog =
        ProgressDialog(context, isDismissible: false, showLogs: true);
    progressMessageDialog.style(message: message);
    progressMessageDialog.show();
  }

  void goToJoinClassroomRoute() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => JoinClassroomRoute(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> checkStudentID() async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('students')
        .where('studentID', isEqualTo: studentID)
        .getDocuments();
    if (snapshot.documents.length != 0) {
      setState(() {
        studentIDError = "Student ID already taken";
      });
    }
  }

  Future<void> createProfile() async {
    await Firestore.instance.collection('students').document().setData({
      'name': name.trim(),
      'studentID': studentID.trim(),
      'phoneNumber': widget.phoneNumber
    });
  }

  void checkStudentIDAndCreateProfile() async {
    showProgressMessage("Checking your student ID...");
    await checkStudentID();
    await progressMessageDialog.hide();

    if (studentIDError != null) {
      return;
    }

    showProgressMessage("Creating your EduForte profile...");
    await createProfile();
    Navigator.pop(context);
    goToJoinClassroomRoute();
  }

  void createProfileButtonClick() {
    setState(() {
      if (name.length == 0) {
        nameError = "Name must not be empty";
      }
      if (!isStudentIDValid()) {
        studentIDError =
            "Student ID must have a minimum length of 6 characters, all lowercase or digits, and must start with an alphabet";
      }
    });
    if (nameError == null && studentIDError == null) {
      print("Hello");
      checkStudentIDAndCreateProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  hintText: 'Chandler Bing',
                  labelText: 'Name',
                  errorText: nameError,
                  hasFloatingPlaceholder: true,
                ),
                onChanged: (String name) {
                  this.name = name;
                  setState(() {
                    nameError = null;
                  });
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  hintText: 'misschanandlerbong',
                  labelText: 'Student ID',
                  errorText: studentIDError,
                  errorMaxLines: 100,
                  hasFloatingPlaceholder: true,
                ),
                onChanged: (String studentID) {
                  this.studentID = studentID;
                  setState(() {
                    studentIDError = null;
                  });
                },
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          width: 400,
          constraints: BoxConstraints(maxWidth: size.width * 0.8),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createProfileButtonClick,
        icon: Icon(Icons.add),
        label: Text("Create"),
      ),
    );
  }
}
