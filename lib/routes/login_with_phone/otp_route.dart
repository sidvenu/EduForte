import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduforte/routes/dashboard_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'create_profile_route.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class OTPRoute extends StatefulWidget {
  final String phoneNumber;

  OTPRoute({Key key, this.phoneNumber}) : super(key: key);

  @override
  _OTPRouteState createState() => new _OTPRouteState();
}

class _OTPRouteState extends State<OTPRoute> {
  ProgressDialog automaticOTPVerificationProgress, checkEnteredOTPProgress;
  String otp = '', _verificationId;

  void goBackToPreviousScreen() {
    Navigator.pop(context);
  }

  void goToDashboardRoute() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardRoute(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void goToCreateProfileRoute() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProfileRoute(
          phoneNumber: widget.phoneNumber,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void loginCompleteAction() async {
    print("loginCompleteAction");
    QuerySnapshot snapshot = await Firestore.instance
        .collection('students')
        .where('phoneNumber', isEqualTo: widget.phoneNumber)
        .getDocuments();
    if (snapshot.documents.length == 0) {
      goToCreateProfileRoute();
    } else {
      goToDashboardRoute();
    }
  }

  // Example code of how to verify phone number
  Future<bool> verifyOTPWithFirebase() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: otp,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    return user != null;
  }

  void automaticOTPCheck() async {
    print('${widget.phoneNumber}');
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      automaticOTPVerificationProgress.dismiss();
      _auth.signInWithCredential(phoneAuthCredential);
      loginCompleteAction();
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      automaticOTPVerificationProgress.dismiss();
      checkEnteredOTPProgress.dismiss();
      print("Phone Verification Failed");
      print(authException.message);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      print("$verificationId");
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      automaticOTPVerificationProgress.dismiss();
    };

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  void onSubmitOTP() async {
    checkEnteredOTPProgress.show();
    bool isOTPCorrect = await verifyOTPWithFirebase();
    checkEnteredOTPProgress.dismiss();
    if (isOTPCorrect) {
      loginCompleteAction();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("OTP incorrect"),
            content: new Text("Please verify the OTP and try again"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      automaticOTPVerificationProgress.show();
      automaticOTPCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    automaticOTPVerificationProgress =
        ProgressDialog(context, isDismissible: false);
    checkEnteredOTPProgress = ProgressDialog(context, isDismissible: false);

    automaticOTPVerificationProgress.style(
      message: "Automatically verifying OTP",
    );
    checkEnteredOTPProgress.style(
      message: "Verifying OTP",
    );

    FloatingActionButton previousScreenButton = FloatingActionButton.extended(
      heroTag: "previousScreenButton",
      onPressed: () => goBackToPreviousScreen(),
      icon: Icon(
        Icons.navigate_before,
        color: Colors.black,
      ),
      label: Text("Previous"),
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );

    FloatingActionButton nextScreenButton = FloatingActionButton.extended(
      heroTag: "nextScreenButton",
      onPressed: () => onSubmitOTP(),
      icon: Icon(
        Icons.navigate_next,
        color: Colors.black,
      ),
      label: Text("Submit"),
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );

    Size size = MediaQuery.of(context).size;
    double minDimension = min(size.height, size.width);
    double pinBoxDimension = min(minDimension / 6 - 15, 70);

    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.teal[700],
                Colors.teal[600],
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: PinCodeTextField(
                  autofocus: true,
                  maxLength: 6,
                  pinBoxHeight: pinBoxDimension,
                  pinBoxWidth: pinBoxDimension,
                  onDone: (String otp) {
                    onSubmitOTP();
                  },
                  onTextChanged: (String otp) => this.otp = otp,
                  pinBoxBorderWidth: 0.00000000000001,
                  pinBoxColor: Colors.teal[600],
                  wrapAlignment: WrapAlignment.center,
                  pinTextStyle: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                margin: EdgeInsets.only(top: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              child: previousScreenButton,
              margin: EdgeInsets.only(left: 15),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: nextScreenButton,
              margin: EdgeInsets.only(right: 15),
            ),
          ),
        ],
      ),
    );
  }
}
