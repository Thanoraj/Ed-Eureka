import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/pages/home.dart';
import 'package:ed_eureka/ui/pages/onboarding1.dart';
import 'package:ed_eureka/ui/widgets/details_card.dart';
import 'package:ed_eureka/ui/widgets/statistics_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen(
      {@required this.image,
      @required this.userName,
      this.streamList,
      this.mediumList,
      this.subjectCollection,
      this.email,
      this.userInfo,
      this.subjectList,
      this.theme,
      this.correctAnswers,
      this.answeredQuestion,
      this.uid,
      this.textColor});
  final Map answeredQuestion;
  final Map correctAnswers;
  final subjectList;
  final image;
  final userName;
  final email;
  final List userInfo;
  final uid;
  final theme;
  final streamList;
  final mediumList;
  final subjectCollection;
  final textColor;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedMedium;
  String selectedStream;
  bool changed = false;
  String initialStream;
  String initialMedium;
  List subjects = [];
  List referenceList = [];
  bool isSwitched;
  bool showTextSwitch = false;

  @override
  void initState() {
    if (widget.userInfo[0] != null) {
      selectedMedium = widget.userInfo[0];
    } else {
      selectedMedium = selectedMedium;
    }
    if (widget.userInfo[1] != null) {
      selectedStream = widget.userInfo[1];
    } else {
      selectedStream = selectedStream;
    }
    initialMedium = selectedMedium;
    initialStream = selectedStream;
    super.initState();
  }

  getTheme() async {
    UserManagement.checkUser(context);
    String selected = await LocalUserData.getTheme();
    String textColor = await LocalUserData.getTextColor();
    isSwitched = selected == null ? true : selected != 'Light';
    showTextSwitch = isSwitched;
    isTextSwitched = textColor == null ? true : textColor == 'green';
    return isSwitched;
  }

  saveDetails(BuildContext context, selectedSubjectList) async {
    await LocalUserData.saveUserInfo(
        jsonEncode([selectedMedium, selectedStream]));
    await _fireStore.collection('User').doc(widget.uid).update({
      'userInfo': [selectedMedium, selectedStream],
      'subjectList': selectedSubjectList,
    });
    Map userDetails = {
      'userName': widget.userName,
      'userInfo': widget.userInfo,
      'email': widget.email,
      'subjectList': widget.subjectList,
      'photoURL': widget.image,
      'uid': widget.uid,
    };
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  String selectedTheme;

  DropdownButton dropDown(List dropList, String type) {
    List<DropdownMenuItem> dropdownList = [];
    for (String listItem in dropList) {
      var newItem = DropdownMenuItem(
        child: Text(
          listItem,
          style: TextStyle(color: kBlackGreen600white),
        ),
        value: listItem,
      );
      dropdownList.add(newItem);
    }
    return DropdownButton(
      dropdownColor: kRemainderCardColor,
      iconEnabledColor: kGrey600Green600white70,
      value: type == 'medium' ? selectedMedium : selectedStream,
      items: dropdownList,
      onChanged: (value) {
        type == 'medium' ? selectedMedium = value : selectedStream = value;

        setState(() {});
      },
    );
  }

  getSubjectList(selectedStream, selectedMedium) {
    return widget.subjectCollection['${selectedMedium}_$selectedStream'];
  }

  statisticsCardGenerator() {
    List<Widget> statisticCardList = [
      StatisticsCard(
        dataType: 'Overall',
        correctAnswers: totalCorrect,
        answeredQuestions: totalAnswered,
        needed: true,
      ),
    ];
    int i = 1;
    for (String subject in widget.subjectList) {
      statisticCardList.add(
        StatisticsCard(
          dataType: subject,
          answeredQuestions: widget.answeredQuestion[subject] == null
              ? 0
              : widget.answeredQuestion[subject],
          correctAnswers: widget.correctAnswers[subject] == null
              ? 0
              : widget.correctAnswers[subject],
          needed: i == widget.subjectList.length ? false : true,
        ),
      );
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statisticCardList,
    );
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      isSwitched = true;
      showTextSwitch = true;
      selectedTheme = 'Dark';
    } else {
      isSwitched = false;
      showTextSwitch = false;
      selectedTheme = 'Light';
    }
    LocalUserData.setTheme(selectedTheme);
    initializeTheme();
    setState(() {});
  }

  bool isTextSwitched;
  String selectedTextColor;

  void textSwitch(bool value) {
    if (isTextSwitched == false) {
      isTextSwitched = true;
      selectedTextColor = 'green';
    } else {
      isTextSwitched = false;
      selectedTextColor = 'white';
    }
    LocalUserData.saveTextColor(selectedTextColor);
    initializeTheme();
    setState(() {});
  }

  int totalAnswered = 0;
  int totalCorrect = 0;
  List<ChartData> chartData = [];

  dataSourceGenerator() {
    totalAnswered = 0;
    totalCorrect = 0;
    chartData = [];
    widget.correctAnswers.forEach((key, value) {
      if (widget.subjectList.contains(key)) {
        totalCorrect += value;
      }
    });
    widget.answeredQuestion.forEach((key, value) {
      if (widget.subjectList.contains(key)) {
        totalAnswered += value;
      }
    });

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTheme(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Stack(
                children: [
                  Container(
                      child: Column(
                    children: [
                      Container(
                        child: GestureDetector(
                          onTap: () async {
                            await _auth.signOut();
                            await LocalUserData.saveLoggedInKey(false);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OnBoarding()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 40),
                            alignment: Alignment.topRight,
                            child: Stack(children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                          color: kWhiteGreen600White,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.logout,
                                      color: kWhiteGreen600White,
                                    ),
                                  ]),
                            ]),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height *
                            kProfileScreenFactor,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                          colors: kProfileBackGround,
                          radius: 1.25,
                          center: Alignment.bottomCenter,
                        )),
                      ),
                      Container(
                        color: kHomeMaterialColor,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height *
                            (1 - kProfileScreenFactor),
                        child: ListView(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                DetailsCard(
                                  title: 'Name',
                                  text: widget.userName,
                                ),
                                DetailsCard(
                                  title: 'email',
                                  text: widget.email,
                                ),
                                Row(children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Language :',
                                      style: TextStyle(color: kText70),
                                    ),
                                  ),
                                  dropDown(widget.mediumList, 'medium'),
                                ]),
                                Row(children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 25),
                                    child: Text(
                                      'Stream      :',
                                      style: TextStyle(color: kText70),
                                    ),
                                  ),
                                  dropDown(widget.streamList, 'stream'),
                                ]),
                                initialMedium != selectedMedium ||
                                        initialStream != selectedStream
                                    ? Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              List selectedSubjectList =
                                                  await getSubjectList(
                                                      selectedStream,
                                                      selectedMedium);
                                              saveDetails(
                                                  context, selectedSubjectList);
                                            },
                                            child: Material(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              elevation: 5,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text('Save Change'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(height: 5),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 20, bottom: 20),
                                  child: Material(
                                    borderRadius: BorderRadius.circular(10),
                                    elevation: 3,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          color: kBodyFull,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ProfileTitleCard(
                                            text: 'Statistics',
                                          ),
                                          statisticsCardGenerator(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  Stack(children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height *
                              kProfileScreenFactor -
                          2 * kProfileScreenAvatarRadius +
                          30,
                      left: MediaQuery.of(context).size.width * 0.5 -
                          kProfileScreenAvatarRadius,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[700],
                        radius: kProfileScreenAvatarRadius,
                        backgroundImage: widget.image != null
                            ? NetworkImage(widget.image)
                            : AssetImage(
                                'assets/images/userImage.png',
                              ),
                      ),
                    ),
                  ]),
                  Positioned(
                    top: MediaQuery.of(context).size.height *
                            kProfileScreenFactor -
                        2 * kProfileScreenAvatarRadius +
                        -60,
                    left: MediaQuery.of(context).size.width * 0.25 -
                        kProfileScreenAvatarRadius,
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        RadialBarSeries<ChartData, String>(
                            dataSource: dataSourceGenerator(),
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            radius: '55%',
                            animationDuration: 5000,
                            gap: '8%',
                            innerRadius: '75%',
                            trackOpacity: 0.5,
                            cornerStyle: CornerStyle.bothCurve,
                            strokeWidth: 2),
                      ],
                    ),
                  ),
                  Column(children: [
                    Container(
                      padding: EdgeInsets.only(top: 30, left: 20),
                      child: Column(children: [
                        Transform.scale(
                            scale: 1.5,
                            child: Switch(
                              onChanged: toggleSwitch,
                              value: isSwitched,
                              activeColor: Colors.green[900],
                              activeTrackColor: Colors.green,
                              inactiveThumbColor: Color(0xFF0a0a46),
                              inactiveTrackColor: Colors.blue[700],
                            )),
                        Text(
                          'Select Theme',
                          style: TextStyle(
                              fontSize: 10, color: kWhiteGreen600White),
                        )
                      ]),
                    ),
                    Visibility(
                      visible: showTextSwitch,
                      child: Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Column(children: [
                          Transform.scale(
                              scale: 1.5,
                              child: Switch(
                                onChanged: textSwitch,
                                value: isTextSwitched,
                                activeColor: Colors.green[900],
                                activeTrackColor: Colors.green,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.white54,
                              )),
                          Text(
                            'Select Text Color',
                            style: TextStyle(
                                fontSize: 10, color: kBlackGreen600white),
                          )
                        ]),
                      ),
                    ),
                  ]),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class ProfileTitleCard extends StatelessWidget {
  ProfileTitleCard({@required this.text});

  final text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0.0,
        bottom: 15.0,
      ),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 40,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: kTopBarColor, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
              margin: EdgeInsets.only(right: 10),
              height: 40,
              width: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                color: kBlue900Green,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 15,
                  color: kWhiteGreen600White,
                  fontFamily: kTextFontFamily,
                  fontWeight: FontWeight.w200),
            ),
          ]),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
