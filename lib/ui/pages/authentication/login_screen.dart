import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_eureka/services/initialization.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/authentication/resetScreen.dart';
import 'package:ed_eureka/ui/pages/navmenu/menu_dashboard_layout.dart';
import 'package:ed_eureka/ui/widgets/initial_screen_bg.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:ed_eureka/ui/widgets/rounded_Button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  final List countriesList;
  LoginScreen({
    @required this.countriesList,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String errorMessage = '';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool notConnected = false;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  saveDeviceInfo() async {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    List deviceList = [];
    await FirebaseFirestore.instance
        .collection('User')
        .doc(loggedInUser.uid)
        .get()
        .then((value) {
      deviceList = value['deviceList'];
    }).catchError((e) {});
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var build = await deviceInfoPlugin.androidInfo;
    String model = build.model;
    if (!deviceList.contains(model)) {
      deviceList.add(model);
    }
    await FirebaseFirestore.instance
        .collection('User')
        .doc(loggedInUser.uid)
        .update({'deviceList': deviceList});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: <Widget>[
        InitialScreenBackGround(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(
                    height: 22.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter Your Email Address',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                          controller: passwordController,
                          textAlign: TextAlign.center,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: kTextFieldDecoration.copyWith(
                              hintText: 'Enter Your Password',
                              hintStyle: TextStyle(color: Colors.white54)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetScreen()));
                      },
                      child: Container(
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  RoundedButton(
                    color: Colors.lightBlueAccent,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      UserCredential newUser;
                      try {
                        newUser = await _auth.signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim());
                      } on Exception catch (e) {
                        setState(() {
                          List error = e.toString().split('/');
                          List detailedError = error[1].toString().split(']');
                          if (detailedError[0] == 'network-request-failed') {
                            notConnected = true;
                            isLoading = false;
                          } else if (detailedError[0] == 'user-not-found') {
                            errorMessage = 'No user found';
                            isLoading = false;
                          } else {
                            errorMessage = '!! Invalid Email or Password';
                            isLoading = false;
                          }
                        });
                      }

                      User loggedInUser = _auth.currentUser;

                      if (newUser != null) {
                        LocalUserData.saveLoggedInKey(true);
                        LocalUserData.saveUserUidKey(loggedInUser.uid);
                        Map updateInfo = {};
                        updateInfo = await Initialize.getUpdateInfo();
                        if (!kIsWeb) {
                          saveDeviceInfo();
                          final DeviceInfoPlugin deviceInfoPlugin =
                              DeviceInfoPlugin();
                          var build = await deviceInfoPlugin.androidInfo;
                          String id = build.androidId;
                          loggedInUser.updatePhotoURL(id);

                          while (loggedInUser.photoURL != id) {
                            User loggedInUser =
                                FirebaseAuth.instance.currentUser;
                            await loggedInUser.reload();
                            if (loggedInUser.photoURL == id) {
                              break;
                            }
                          }
                          User user = _auth.currentUser;
                          if (user.photoURL == id) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuDashboardLayout(
                                          updateInfo: updateInfo,
                                        )));
                          }
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MenuDashboardLayout(
                                        updateInfo: updateInfo,
                                      )));
                        }
                      }
                    },
                    title: isLoading ? 'Logging in ...' : 'Log in',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationScreen(
                                        countriesList: widget.countriesList,
                                      )));
                        },
                        child: Container(
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
        NotConnectedAlert(notConnected: notConnected),
      ]),
    );
  }
}
