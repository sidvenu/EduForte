import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OTPRoute extends StatefulWidget {
  final String title;

  OTPRoute({Key key, this.title}) : super(key: key);

  @override
  _OTPRouteState createState() => new _OTPRouteState();
}

class _OTPRouteState extends State<OTPRoute> {
  ProgressDialog automaticOTPVerificationProgress, checkEnteredOTPProgress;
  String otp = '';

  void goBackToPreviousScreen(BuildContext context) {
    Navigator.pop(context);
  }

  void goToNextScreen(BuildContext context) {
    print("Next screen");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => OTPRoute(title: 'EduForte - Enter OTP')),
    // );
  }

  Future<bool> verifyOTPWithFirebase() async {
    // TODO: check OTP with firebase using otp field
    return Future.delayed(Duration(seconds: 4), () => false);
  }

  Future<void> onSubmitOTP(BuildContext context) async {
    automaticOTPVerificationProgress.dismiss();
    bool isOTPCorrect = await verifyOTPWithFirebase();
    if (isOTPCorrect) {
      goToNextScreen(context);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // automaticOTPVerificationProgress.show();
      // TODO: after firebase autoverify has completed
      // automaticOTPVerificationProgress.dismiss();
    });

    FloatingActionButton previousScreenButton = FloatingActionButton.extended(
      heroTag: "previousScreenButton",
      onPressed: () => goBackToPreviousScreen(context),
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
      onPressed: () => onSubmitOTP(context),
      icon: Icon(
        Icons.navigate_next,
        color: Colors.black,
      ),
      label: Text("Submit"),
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );

    Size size = MediaQuery.of(context).size;
    double ratio = size.height / size.width;
    if (ratio < 1) ratio = 1 / ratio;

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
