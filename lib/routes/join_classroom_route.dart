import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/data_classes/classroom.dart';
import 'package:eduforte/helpers/firebase_helper.dart';
import 'package:eduforte/routes/dashboard_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';

class JoinClassroom extends StatefulWidget {
  final String title = 'Join an EduForte Classroom';
  @override
  _JoinClassroomState createState() => _JoinClassroomState();
}

class _JoinClassroomState extends State<JoinClassroom> {
  String classroomID = "";
  String error;
  void joinClassroom() async {
    ProgressDialog progress = ProgressDialog(context);
    progress.style(message: "Joining EduForte classroom...");
    progress.show();

    DocumentSnapshot studentProfileDocument =
        await FirebaseHelper.getStudentProfileDocument();
    Map studentProfile = studentProfileDocument.data;

    final DocumentReference classroomDocumentReference =
        Firestore.instance.document("classrooms/$classroomID");

    if ((await classroomDocumentReference.get()).exists) {
      await Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentSnapshot classroomDocument =
            await transaction.get(classroomDocumentReference);
        Map<String, dynamic> classroom = classroomDocument.data;
        await transaction.set(classroomDocumentReference, classroom);

        studentProfile["classroomID"] = classroomID;
        await transaction.update(
          classroomDocumentReference,
          <String, dynamic>{
            "students": (classroom["students"].toList()
                  ..add(studentProfile["studentID"]))
                .toSet()
                .toList()
          },
        );
      });
    } else {
      setError(
          "This ID doesn't seem to be valid. Please check it and try again.");
    }
    if (error == null) {
      await Firestore.instance
          .collection("students")
          .document(studentProfileDocument.documentID)
          .updateData(
        <String, dynamic>{
          "classroomID": studentProfile["classroomID"],
        },
      );

      progress.dismiss();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => DashboardRoute()),
        (Route<dynamic> route) => false,
      );
    } else {
      progress.dismiss();
    }
  }

  void setError(String error) {
    setState(() {
      this.error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.text,
                onChanged: (s) {
                  classroomID = s;
                  setError(null);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  hintText: 'dfjaHDr4rZASDLasadSAD',
                  labelText: 'Classroom ID',
                  errorText: error,
                  hasFloatingPlaceholder: true,
                ),
                textInputAction: TextInputAction.done,
              ),
              width: 400,
              constraints: BoxConstraints(maxWidth: windowSize.width * 0.8),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: joinClassroom,
        icon: Icon(Icons.people),
        label: Text("Join"),
      ),
    );
  }
}
