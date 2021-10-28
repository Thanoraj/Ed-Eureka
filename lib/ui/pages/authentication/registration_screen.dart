import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/initialization.dart';
import 'package:ed_eureka/ui/pages/authentication/verification_screen.dart';
import 'package:ed_eureka/ui/widgets/initial_screen_bg.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:ed_eureka/ui/widgets/rounded_Button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  final List countriesList;
  RegistrationScreen({
    @required this.countriesList,
  });

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String errorMessage = '';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  String email;
  String password;
  String userName;
  String phoneNumber;
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  String selectedCode = '+94';
  bool notConnected = false;
  String selectedMethod = 'phone';

  @override
  dispose() async {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    await loggedInUser.reload();
    !loggedInUser.emailVerified ? loggedInUser.delete() : null;
    super.dispose();
  }

  validate() {
    if (formKey.currentState.validate()) {}
  }

  DropdownButton dropDown(List dropList, type) {
    List<DropdownMenuItem> dropdownList = [];
    for (String listItem in dropList) {
      var newItem = DropdownMenuItem(
        child: Text(
          listItem.toString(),
          style: TextStyle(color: Colors.white),
        ),
        value: listItem,
      );
      dropdownList.add(newItem);
    }
    return DropdownButton(
      dropdownColor: Colors.grey,
      underline: SizedBox(),
      value: type == 'code' ? selectedCode : selectedMethod,
      items: dropdownList,
      onChanged: (value) {
        type == 'code' ? selectedCode = value : selectedMethod = value;
        setState(() {});
      },
    );
  }

  List mediumsList = [];
  List streamsList = [];
  Map subjectsCollection = {};

  getList() async {
    await _fireStore
        .collection('App Info')
        .doc('selectionDetails')
        .get()
        .then((value) {
      mediumsList = value['mediumList'];
      streamsList = value['StreamList'];
      subjectsCollection = value['subjectsCollection'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: [
        InitialScreenBackGround(),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Column(
                    children: [
                      SizedBox(
                        height: 48.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (val) {
                                return val.isEmpty || val.length < 4
                                    ? 'Please Input a valid User Name'
                                    : null;
                              },
                              controller: userNameController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                validate();
                                userName = value;
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: kTextFieldDecoration.copyWith(
                                  hintStyle: TextStyle(color: Colors.white54),
                                  hintText: 'Enter Your User Name'),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            TextFormField(
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
                            SizedBox(
                              height: 8.0,
                            ),
                            Stack(children: [
                              TextFormField(
                                validator: (val) {
                                  try {
                                    return val.isEmpty || val.length < 9
                                        ? 'Please Input a valid PhoneNumber'
                                        : null;
                                  } on Exception catch (e) {
                                    return 'Please Input a valid PhoneNumber';
                                  }
                                },
                                style: TextStyle(color: Colors.white),
                                controller: mobileNumberController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  validate();
                                  phoneNumber = value;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                  hintText: 'Enter Your Mobile Number',
                                  hintStyle: TextStyle(color: Colors.white54),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: dropDown(widget.countriesList, 'code'),
                              ),
                            ]),
                            SizedBox(
                              height: 8.0,
                            ),
                            TextFormField(
                              validator: (val) {
                                return val.isEmpty || val.length < 6
                                    ? 'Please Input a Strong Password with 6+ characters'
                                    : null;
                              },
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                              obscureText: true,
                              onChanged: (value) {
                                validate();
                                password = value;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Enter Your Password',
                                hintStyle: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                    ],
                  ),
                  RoundedButton(
                    color: Colors.blueAccent,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);

                        Map selectionDetails;
                        selectionDetails = await Initialize.getSelectionInfo();
                        if (selectionDetails == null) {
                          notConnected = true;
                          isLoading = false;
                          setState(() {});
                        } else {
                          User loggedInUser = _auth.currentUser;
                          await loggedInUser.sendEmailVerification();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerificationScreen(
                                  streamList: selectionDetails['streamsList'],
                                  mediumList: selectionDetails['mediumsList'],
                                  subjectCollection:
                                      selectionDetails['subjectsCollection'],
                                  userName: userName,
                                  email: email,
                                  phoneNumber: '$selectedCode$phoneNumber',
                                  isLogin: false,
                                  password: password),
                            ),
                          );
                        }
                      } on Exception catch (e) {
                        if (e.toString().contains('email-already-in-use')) {
                          errorMessage =
                              'The email address is already in use by another account.';
                          isLoading = false;
                        } else if (e
                            .toString()
                            .contains('network-request-failed')) {
                          notConnected = true;
                          isLoading = false;
                          setState(() {});
                        }
                      } catch (e) {}
                      setState(() {
                        isLoading = false;
                      });
                    },
                    title: isLoading ? 'Signing Up...' : 'Next',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Text(
                            'Login Now',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
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
