import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber = '';

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
    });
  }

  void onPressSendOTP() {
    print(phoneNumber);
    // TODO: use firebase to send OTP and move to the next screen
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
        onPressed: onPressSendOTP,
        icon: Icon(Icons.message),
        label: Text("Send OTP"),
      ),
    );
  }
}
