import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/widgets/card.dart';
import 'package:ed_eureka/ui/widgets/sectionHeader.dart';
import 'package:ed_eureka/ui/widgets/statsCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_management.dart';

class LeaderboardPage extends StatefulWidget {
  LeaderboardPage({
    Key key,
    @required this.onMenuTap,
  }) : super(key: key);
  final Function onMenuTap;

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  TextEditingController controller = TextEditingController();
  bool local;
  bool full;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List colors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
    Color(0xFF0396FF),
    Color(0xFF0396FF),
    Color(0xFF0396FF),
    Color(0xFF0396FF),
    Color(0xFF0396FF),
    Color(0xFF0396FF),
    Color(0xFF0396FF)
  ];
  @override
  void initState() {
    local = true;
    full = false;
    super.initState();
  }

  User loggedInUser = FirebaseAuth.instance.currentUser;

  Map userDetails = {};
  String userName;
  List userInfo;
  Map streamLeadersList = {};
  Map allStreamsLeadersList = {};
  Map answeredQuestion = {};
  Map correctAnswers = {};
  Map scores = {};
  List subjectList = [];

  getStats() async {
    UserManagement.checkUser(context);
    await _firestore
        .collection('User')
        .doc(loggedInUser.uid)
        .get()
        .then((value) {
      userInfo = value['userInfo'];
      subjectList = value['subjectList'];
      answeredQuestion = value['totalAnswered'];
      correctAnswers = value['totalCorrect'];
      scores = value['subjectPoints'];
    }).catchError((e) {
      if (e ==
          'Bad state: field does not exist within the DocumentSnapshotPlatform') {
        answeredQuestion = {};
        correctAnswers = {};
        scores = {};
      }
    });
    await _firestore
        .collection('App Info')
        .doc('Leader Board')
        .get()
        .then((value) {
      streamLeadersList = value['${userInfo[1]}'];
      allStreamsLeadersList = value['All Streams'];
    }).catchError((e) {
      streamLeadersList = {};
      allStreamsLeadersList = {};
    });
    return true;
  }

  allLeaderScreen(Map leadersList) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(height: MediaQuery.of(context).size.height * 0.23),
        SectionHeader(
          text: '${userInfo[1]} Leader Board',
          onPressed: () {
            setState(() {
              full = false;
            });
          },
          isNeeded: 'No',
          leading: 'yes',
        ),
        Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: leadersList['Names'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 14),
                    child: CardWidget(
                      color: kWhite54Black,
                      gradient: false,
                      button: false,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${index + 1}.",
                              style: TextStyle(
                                  fontFamily: 'Red Hat Display',
                                  fontSize: 18,
                                  color: Color(0xFF585858)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${leadersList['Names'][index].toString().length < 20 ? leadersList['Names'][index] : leadersList['Names'][index].toString().substring(0, 17) + '..'}",
                              style: TextStyle(
                                  fontFamily: 'Red Hat Display',
                                  fontSize: 17,
                                  color: kBlackGreen600white),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.elliptical(10, 50),
                                    bottomLeft: Radius.elliptical(10, 50)),
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      index < 10 ? colors[index] : Colors.blue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    "${leadersList['Scores'][index]}",
                                    style: TextStyle(
                                        fontFamily: 'Red Hat Display',
                                        fontSize: 18,
                                        color: Color(0xFF585858)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                  );
                },
              ),
            ),
            Positioned(
                top: -5,
                left: -4,
                child: Image.asset('assets/images/crown.png'))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getStats(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Material(
              color: Colors.black54,
              child: Scaffold(
                backgroundColor: kBodyFull,
                body: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SafeArea(
                      child: local
                          ? full
                              ? allLeaderScreen(streamLeadersList)
                              : ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.23),
                                    SectionHeader(
                                      text: '${userInfo[1]} Leader Board',
                                      onPressed: () {
                                        full = true;
                                        setState(() {});
                                      },
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                streamLeadersList['Names']
                                                            .length >
                                                        3
                                                    ? 3
                                                    : streamLeadersList['Names']
                                                        .length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 14),
                                                child: CardWidget(
                                                  color: kWhite54Black,
                                                  gradient: false,
                                                  button: false,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "${index + 1}.",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Red Hat Display',
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xFF585858)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "${streamLeadersList['Names'][index].toString().length < 20 ? streamLeadersList['Names'][index] : streamLeadersList['Names'][index].toString().substring(0, 17) + '..'}",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Red Hat Display',
                                                              fontSize: 17,
                                                              color:
                                                                  kBlackGreen600white),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .elliptical(
                                                                        10,
                                                                        50),
                                                                bottomLeft: Radius
                                                                    .elliptical(
                                                                        10,
                                                                        50)),
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  colors[index]
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: <Widget>[
                                                              Text(
                                                                "${streamLeadersList['Scores'][index]}",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Red Hat Display',
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xFF585858)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  height: 60,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                            top: -5,
                                            left: -4,
                                            child: Image.asset(
                                                'assets/images/crown.png'))
                                      ],
                                    ),
                                    SectionHeader(
                                      text: 'My Statistics',
                                      onPressed: () {},
                                      isNeeded: 'No',
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 150,
                                      child: StatsCard(
                                        scores: scores,
                                        answeredQuestion: answeredQuestion,
                                        correctAnswers: correctAnswers,
                                        subjectList: subjectList,
                                      ),
                                    ),
                                  ],
                                )
                          : full
                              ? allLeaderScreen(allStreamsLeadersList)
                              : ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.23),
                                    SectionHeader(
                                      text: 'Leader Board',
                                      onPressed: () {
                                        full = true;
                                        setState(() {});
                                      },
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: allStreamsLeadersList[
                                                            'Names']
                                                        .length >
                                                    10
                                                ? 10
                                                : allStreamsLeadersList['Names']
                                                    .length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 14),
                                                child: CardWidget(
                                                  color: kWhite54Black,
                                                  gradient: false,
                                                  button: false,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "${index + 1}.",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Red Hat Display',
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xFF585858)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "${allStreamsLeadersList['Names'][index].toString().length < 20 ? allStreamsLeadersList['Names'][index] : allStreamsLeadersList['Names'][index].toString().substring(0, 17) + '..'}",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Red Hat Display',
                                                              fontSize: 17,
                                                              color:
                                                                  kBlackGreen600white),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .elliptical(
                                                                        10,
                                                                        50),
                                                                bottomLeft: Radius
                                                                    .elliptical(
                                                                        10,
                                                                        50)),
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  colors[index]
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: <Widget>[
                                                              Text(
                                                                "${allStreamsLeadersList['Scores'][index]}",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Red Hat Display',
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xFF585858)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  height: 60,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                            top: -5,
                                            left: -4,
                                            child: Image.asset(
                                                'assets/images/crown.png'))
                                      ],
                                    ),
                                  ],
                                ),
                    ),
                    Positioned(
                      top: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 80,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                color: kBody87,
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            local = true;
                                            full = false;
                                          });
                                        },
                                        child: Text(
                                          userInfo[1],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: kRemainderToday,
                                              fontSize: 20,
                                              fontFamily: 'Red Hat Display',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            local = false;
                                            full = false;
                                          });
                                        },
                                        child: Text(
                                          "All Streams",
                                          style: TextStyle(
                                              color: kRemainderToday,
                                              fontSize: 20,
                                              fontFamily: 'Red Hat Display',
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    ]),
                              )
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: AnimatedContainer(
                              margin: local
                                  ? EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                              0.33 -
                                          35)
                                  : EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                              0.67 -
                                          10),
                              width: 40,
                              height: 4,
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                  color: kSectionHeaderArrowColor,
                                  borderRadius: BorderRadius.circular(500)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              color: kBodyFull,
            );
          }
        });
  }
}
