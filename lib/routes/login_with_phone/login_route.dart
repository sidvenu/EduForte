import 'package:eduforte/routes/login_with_phone/otp_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class LoginRoute extends StatefulWidget {
  final String title = "EduForte - Login";

  LoginRoute({Key key}) : super(key: key);

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  String phoneNumber = '';
  String errorText;

  MaskedTextController getPhoneNumberController() {
    final translator = MaskedTextController.getDefaultTranslator();
    translator['P'] = new RegExp(r'[6-9]');

    final controller = new MaskedTextController(
      mask: 'P0000 00000',
      translator: translator,
    );

    controller.value = TextEditingValue(
      text: phoneNumber,
      selection: TextSelection.fromPosition(
        TextPosition(offset: phoneNumber.length),
      ),
    );
    controller.afterChange = (String previous, String next) {
      onChangePhoneNumber(next);
    };
    return controller;
  }

  void onChangePhoneNumber(String phoneNumber) {
    setState(() {
      this.phoneNumber = phoneNumber;
      this.errorText = null;
    });
  }

  void setError(String errorText) {
    setState(() {
      this.errorText = errorText;
    });
  }

  void goToOTPPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPRoute(
          phoneNumber: '+91${phoneNumber.replaceAll(" ", "")}',
        ),
      ),
    );
  }

  void onPressSendOTP() {
    print(phoneNumber);
    if (phoneNumber.replaceAll(" ", "").length != 10) {
      setError("Please check your phone number again");
    } else {
      goToOTPPage();
    }
  }

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
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.phone,
                controller: getPhoneNumberController(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  hintText: '98765 43210',
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
                  errorText: errorText,
                  counterText: '${phoneNumber.replaceAll(' ', '').length}/10',
                  hasFloatingPlaceholder: true,
                ),
                textInputAction: TextInputAction.done,
              ),
              width: 400,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onPressSendOTP(),
        icon: Icon(Icons.message),
        label: Text("Send OTP"),
      ),
    );
  }
}
