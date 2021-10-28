import 'dart:async';
import 'package:ed_eureka/ui/pages/authentication/profile_adding_screen.dart';
import 'package:ed_eureka/ui/widgets/initial_screen_bg.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  VerificationScreen({
    this.userName,
    this.email,
    this.loggedInUser,
    this.phoneNumber,
    this.mediumList,
    this.streamList,
    this.subjectCollection,
    this.code,
    this.userDetails,
    this.isLogin,
    this.password,
  });
  final password;
  final List mediumList;
  final List streamList;
  final userName;
  final email;
  final User loggedInUser;
  final phoneNumber;
  final Map subjectCollection;
  final code;
  final bool isLogin;
  final userDetails;

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _auth = FirebaseAuth.instance;
  bool notConnected = false;
  bool submitIsActive = false;
  String errorMessage = '';
  Timer timer;
  bool activateResend = false;
  String time = '60';

  @override
  void initState() {
    int i = 0;
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (i == 12) {
        activateResend = true;
        time = 'Resend';
      } else if (i < 12) {
        time = (int.parse(time) - 5).toString();
      }
      i++;
      setState(() {});
      checkEmailVerified();
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.isActive ? timer.cancel() : null;
    User loggedInUser = FirebaseAuth.instance.currentUser;
    !loggedInUser.emailVerified ? loggedInUser.delete() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        InitialScreenBackGround(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    'Please check your email box & verify your account using the mail to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (activateResend) {
                      User loggedInUser = FirebaseAuth.instance.currentUser;
                      loggedInUser.sendEmailVerification();
                      time = '60';
                      activateResend = false;
                      setState(() {});
                    }
                  },
                  child: Text(time),
                ),
              ],
            ),
          ),
        ),
        NotConnectedAlert(notConnected: notConnected),
      ]),
    );
  }

  Future<void> checkEmailVerified() async {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    await loggedInUser.reload();
    if (loggedInUser.emailVerified) {
      timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileAddingScreen(
              mediumList: widget.mediumList,
              streamList: widget.streamList,
              userName: widget.userName,
              email: widget.email,
              phoneNumber: widget.phoneNumber,
              subjectCollection: widget.subjectCollection),
        ),
      );
    }
  }
}
