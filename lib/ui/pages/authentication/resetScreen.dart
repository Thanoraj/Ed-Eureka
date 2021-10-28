import 'dart:async';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:ed_eureka/ui/pages/authentication/profile_adding_screen.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final _auth = FirebaseAuth.instance;
  User user;
  bool notConnected = false;
  bool submitIsActive = false;
  String errorMessage = '';

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController emailController = TextEditingController();
  String email;
  String _verificationId;
  final SmsAutoFill _autoFill = SmsAutoFill();

  TextEditingController controller = TextEditingController();
  bool showText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();

  validate() {
    if (formKey.currentState.validate()) {
      setState(() {
        submitIsActive = true;
      });
    } else {
      setState(() {
        submitIsActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF000029),
              Color(0xFF0a0a46),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: showText
                ? Text(
                    'Check your mail for reset mail. \n Reset your password to continue')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val)
                                    ? null
                                    : "Enter correct email";
                              },
                              controller: emailController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                validate();
                                email = value;
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Enter Your Email Address',
                                hintStyle: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 30.0, horizontal: 10),
                              child: CupertinoButton(
                                onPressed: () {
                                  if (submitIsActive) {
                                    setState(() {
                                      showText = true;
                                    });
                                    _auth.sendPasswordResetEmail(email: email);
                                  }
                                },
                                child: Material(
                                  elevation: 5,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: submitIsActive
                                          ? Colors.white
                                          : Colors.grey[300],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Text(
                                      'Reset Password',
                                      style: TextStyle(
                                          color: submitIsActive
                                              ? Colors.black
                                              : Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      ]),
          ),
        ),
        NotConnectedAlert(notConnected: notConnected),
      ]),
    );
  }
}
