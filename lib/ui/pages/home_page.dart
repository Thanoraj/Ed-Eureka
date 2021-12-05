import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/pages/video/all_videos_screen.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:ed_eureka/ui/widgets/sectionHeader.dart';
import 'package:ed_eureka/ui/widgets/slider_widget.dart';
import 'package:ed_eureka/ui/widgets/videoCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'subscription_packages/google_sheet_exam.dart';
import 'topics/questions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  final onMenuTap;
  final userDetails;
  final bool forcedRefresh;
  final callBack;
  final DateTime time;

  HomePage({
    Key key,
    @required this.onMenuTap,
    @required this.userDetails,
    @required this.forcedRefresh,
    @required this.callBack,
    this.time,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static var platform;
  TextEditingController controller = TextEditingController();
  List<String> recommendedLecturesList = [];
  List<String> revisionVideoList = [];
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String progress;
  List subjectList = [];
  List userInfo = [];
  List subscriptionList = [];
  List recommendedSubjects = [];
  List revisionSubjects = [];
  String zoomMeetingId = '8343482976';
  User loggedInUser = FirebaseAuth.instance.currentUser;
  Map attempts = {};
  bool canRefresh = false;
  int refreshIndex = 0;
  DateTime time;

  Future getUser() async {
    await _fireStore.collection('User').doc(loggedInUser.uid).get().then(
      (element) {
        userInfo = element['userInfo'];
        subjectList = element['subjectList'];
        recommendedSubjects = element['recommended'];
        revisionSubjects = element['revision'];
        subscriptionList = element['subscriptionList'];
        attempts = element['attempts'];
      },
    ).catchError((e) {
      recommendedSubjects = recommendedSubjects;
      revisionSubjects = revisionSubjects;
      subscriptionList = subscriptionList;
      attempts = attempts;
    });
    LocalUserData.saveUserInfo(jsonEncode(userInfo));
    LocalUserData.saveSubjects(jsonEncode(subjectList));
    LocalUserData.saveRecommendedSubjects(jsonEncode(recommendedSubjects));
    LocalUserData.saveRevisionSubjects(jsonEncode(revisionSubjects));
    LocalUserData.saveSubscriptions(jsonEncode(subscriptionList));
    LocalUserData.saveAttemptTimes(jsonEncode(attempts));
  }

  @override
  void initState() {
    if (!kIsWeb) {
      platform = const MethodChannel(
        'package:us.zoom.sdksample.inmeetingfunction.customizedmeetingui',
      );
    }
    super.initState();
    getInfo();
    canRefresh = widget.forcedRefresh;
    UserManagement.checkUser(context);
    removeData();
  }

  removeData() async {
    await FirebaseFirestore.instance
        .collection("User")
        .where("subscriptionList", isEqualTo: ["Ed-Eureka"])
        .get()
        .then((value) async {
          value.docs.forEach((element) async {
            print(element['userName']);
            await FirebaseFirestore.instance
                .collection("User")
                .doc(element['uid'])
                .update({"subscriptionList": []});
          });
        });

    print("done");
  }

  getInfo() async {
    if (!widget.forcedRefresh) {
      var data = await LocalUserData.getUserInfo();
      userInfo = data != null ? await jsonDecode(data) : [];
      var value = await LocalUserData.getSubscriptions();
      if (value == null || await value.length == 0) {
        getVideoLectures();
      } else {
        subscriptionList = await jsonDecode(value);
        zoomLectures = await LocalUserData.getLectures('subscriptionLectures');
        recommendedSubjects =
            await jsonDecode(await LocalUserData.getRecommendedSubjects());
        recommendedLecturesList = await LocalUserData.getRecommendedLectures();
        revisionVideoList = await LocalUserData.getRevisionLectures();
        revisionSubjects =
            await jsonDecode(await LocalUserData.getRevisionSubjects());
        subjectList = await jsonDecode(await LocalUserData.getSubjects());
        subscriptionList =
            await jsonDecode(await LocalUserData.getSubscriptions());
        attempts = await jsonDecode(await LocalUserData.getAttemptTimes());
        examList = await LocalUserData.getExams('subscriptionExams');
        setState(() {});
      }
    } else {
      widget.callBack();
      getVideoLectures();
      canRefresh = false;
    }
  }

  getVideoLectures() async {
    await getUser();
    await paperGenerator();
    recommendedLecturesList = [];
    revisionVideoList = [];
    for (Map recommend in recommendedSubjects) {
      await _fireStore
          .collection('Videos')
          .doc(recommend['subject'])
          .collection(recommend['subject'])
          .where('url', isEqualTo: recommend['url'])
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((element) {
          recommendedLecturesList.add(jsonEncode({
            'title': element['title'],
            'thumbnail': element['thumbnail'],
            'text': element['text'],
            'length': element['length'],
            'level': element['level'],
            'videoURL': element['url'],
          }));
        });
      });
    }
    LocalUserData.saveRecommendedLectures(recommendedLecturesList);
    for (Map revision in revisionSubjects) {
      await _fireStore
          .collection('Videos')
          .doc(revision['subject'])
          .collection(revision['subject'])
          .where('url', isEqualTo: revision['url'])
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((element) {
          revisionVideoList.add(jsonEncode({
            'title': element['title'],
            'thumbnail': element['thumbnail'],
            'text': element['text'],
            'length': element['length'],
            'level': element['level'],
            'videoURL': element['url'],
          }));
        });
      });
    }
    LocalUserData.saveRevisionLectures(revisionVideoList);
    setState(() {});
  }

  List<String> examList = [];
  List<String> zoomLectures = [];
  List<String> eurekaExamList = [];

  paperGenerator() async {
    zoomLectures = [];
    examList = [];
    eurekaExamList = [];
    await _fireStore.collection('Papers').doc('Ed-Eureka').get().then((value) {
      for (Map paper in value['${userInfo[0]}_${userInfo[1]}']) {
        eurekaExamList.add(jsonEncode({
          'subscription': {'name': 'Ed-Eureka'},
          'examName': paper['examName'],
          'description': paper['description'],
          'time': paper['time'],
          'date': paper['date'],
          'subtopics': paper['subtopics'],
          'topic': paper['topic'],
          'startTime': paper['startTime'],
          'finishTime': paper['finishTime'], //'2021-08-18 02:15:29.134921',
          'duration': paper['duration'],
        }));
      }
    }).catchError((e) {
      eurekaExamList = eurekaExamList;
    });

    for (Map subscription in subscriptionList) {
      List subscriptionExam = [subscription['name']];
      List subscriptionLectures = [subscription['name']];
      await _fireStore
          .collection('subscriptions')
          .doc(subscription['name'])
          .get()
          .then((value) {
        for (Map lectureDetails in value['lectures']) {
          if (lectureDetails['batch'] == subscription['batch']) {
            subscriptionLectures.insert(
              1,
              jsonEncode(
                {
                  'subscription': subscription['name'],
                  'title': lectureDetails['title'],
                  'time': lectureDetails['time'],
                  'date': lectureDetails['date'],
                  'meetingId': lectureDetails['meetingId'],
                  'password': lectureDetails['password'],
                  'description': lectureDetails['description'],
                  'startTime': lectureDetails['startTime'],
                  'finishTime': lectureDetails['finishTime'],
                },
              ),
            );
          }
        }
      }).catchError((e) {
        subscriptionLectures = subscriptionLectures;
      });
      await _fireStore
          .collection('Papers')
          .doc(subscription['name'])
          .get()
          .then((value) {
        for (Map examDetails in value['exams']) {
          if (examDetails['batch'] == subscription['batch']) {
            subscriptionExam.insert(
              1,
              jsonEncode(
                {
                  'subscription': subscription,
                  'examName': examDetails['examName'],
                  'description': examDetails['description'],
                  'time': examDetails['time'],
                  'date': examDetails['date'],
                  'topic': examDetails['topics'],
                  'medium': examDetails['medium'],
                  'Link': examDetails['Link'],
                  'subtopics': examDetails['subtopics'],
                  'waterMarkerNeeded': examDetails['waterMarkerNeeded'],
                  'allowed': examDetails['allowed'],
                  'startTime': examDetails['startTime'],
                  'finishTime': examDetails['finishTime'],
                  'duration': examDetails['duration'],
                },
              ),
            );
          }
        }
      }).catchError((e) {
        subscriptionExam = subscriptionExam;
      });
      examList.add(jsonEncode(subscriptionExam));
      zoomLectures.add(jsonEncode(subscriptionLectures));
    }
    LocalUserData.saveExams('Ed-Eureka', eurekaExamList);
    LocalUserData.saveExams('subscriptionExams', examList);
    LocalUserData.saveLectures('subscriptionLectures', zoomLectures);
  }

  eurekaCardBuilder() {
    List<Widget> examCardList = [SizedBox()];
    if (eurekaExamList.length > 0) {
      examCardList.add(SizedBox(
        height: 20,
      ));
      examCardList.add(
        SectionHeader(
          isNeeded: 'No',
          text: 'Eureka Daily Exams',
          onPressed: () {},
        ),
      );
      examCardList.add(SizedBox(
        height: 20,
      ));
    }
    for (String examDetails in eurekaExamList) {
      Map exam = jsonDecode(examDetails);
      examCardList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Material(
            elevation: 2,
            shadowColor: kBlackGreen600white,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              margin: EdgeInsets.zero,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: kBodyFull,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30.0),
                      child: Text(
                        exam['examName'],
                        style: TextStyle(
                          color: kBlackGreen600white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 4),
                    child: Text(
                      'Exam Time : ${exam['time']}',
                      //exam['description'],
                      style: TextStyle(
                        color: kExamCardText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      exam['description'].toString().replaceAll('\\n', '\n'),
                      style: TextStyle(
                        color: kExamCardText,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StartExamButton(exam: exam, context: context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: examCardList,
    );
  }

  examPaperCard() {
    UserManagement.checkUser(context);
    List<Widget> examCardList = [SizedBox()];
    for (String subscriptionExams in examList) {
      List exams = jsonDecode(subscriptionExams);
      int i = 0;
      for (String examDetails in exams) {
        if (i == 0) {
          if (exams.length > 1) {
            examCardList.add(SizedBox(
              height: 20,
            ));
            examCardList.add(
              SectionHeader(
                isNeeded: 'No',
                text: '$examDetails Exams',
                onPressed: () {},
              ),
            );
            examCardList.add(SizedBox(
              height: 20,
            ));
          }
        } else {
          Map exam = jsonDecode(examDetails);
          examCardList.add(
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(22),
                shadowColor: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kBodyFull,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 20),
                          child: Text(
                            exam['examName'],
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 4),
                        child: Row(children: [
                          Text(
                            'Date : ',
                            //exam['description'],
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            exam['date'] ?? '',
                            //exam['description'],
                            style: TextStyle(
                              color: kExamCardText,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 4),
                        child: Row(children: [
                          Text(
                            'Time : ',
                            //exam['description'],
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            exam['time'],
                            //exam['description'],
                            style: TextStyle(
                              color: kExamCardText,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 15, right: 15, bottom: 15),
                        child: Text(
                          exam['description']
                              .toString()
                              .replaceAll('\\n', '\n'),
                          style: TextStyle(
                            color: kExamCardText,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          StartExamButton(exam: exam, context: context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        i++;
      }
    }
    for (String subscriptionLectures in zoomLectures) {
      List lectures = jsonDecode(subscriptionLectures);
      int i = 0;
      for (String lectureDetails in lectures) {
        if (i == 0) {
          if (lectures.length > 1) {
            examCardList.add(SizedBox(
              height: 20,
            ));
            examCardList.add(
              SectionHeader(
                isNeeded: 'No',
                text: '$lectureDetails Lectures',
                onPressed: () {},
              ),
            );
            examCardList.add(SizedBox(
              height: 20,
            ));
          }
        } else {
          Map lectures = jsonDecode(lectureDetails);
          examCardList.add(
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(22),
                shadowColor: kBlackGreen600white,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kBodyFull,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 20),
                          child: Text(
                            '${lectures['title']} - ${lectures['subscription']}',
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 4),
                        child: Row(children: [
                          Text(
                            'Date : ',
                            //exam['description'],
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            lectures['date'] ?? '',
                            //exam['description'],
                            style: TextStyle(
                              color: kExamCardText,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 4),
                        child: Row(children: [
                          Text(
                            'Time : ',
                            //exam['description'],
                            style: TextStyle(
                              color: kBlackGreen600white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            lectures['time'] ?? '',
                            //exam['description'],
                            style: TextStyle(
                              color: kExamCardText,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          lectures['description'],
                          style: TextStyle(
                            color: kExamCardText,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 13),
                                primary: kBlue300Grey,
                              ),
                              onPressed: () async {
                                if (!kIsWeb) {
                                  await platform.invokeMethod('openZoom', {
                                    'zoomMeetingId': lectures['meetingId'],
                                    'meetingPassword': lectures['password'],
                                  });
                                }
                              },
                              child: Text(
                                "Open Zoom",
                                style: TextStyle(color: kUpdateTextColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        i++;
      }
    }

    return Column(
      children: examCardList,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forcedRefresh && time != widget.time) {
      time = widget.time;
    }
    final GlobalKey<RefreshIndicatorState> refresh =
        GlobalKey<RefreshIndicatorState>();
    return Material(
      child: Scaffold(
        backgroundColor: kHomeMaterialColor,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  getVideoLectures();
                },
                key: refresh,
                child: ListView(shrinkWrap: true, children: [
                  SizedBox(
                    height: 270,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (MediaQuery.of(context).size.width * 0.15)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: SliderWidget(
                        alignLabel: Alignment.centerLeft,
                        label: Text(
                          'Swipe to Refresh',
                          maxLines: 1,
                          style: TextStyle(
                              color: kWhiteGreen600White,
                              fontSize: 22,
                              fontFamily: kTextFontFamily,
                              fontWeight: FontWeight.w600),
                        ),
                        action: () {
                          //widget.callBack();
                          getVideoLectures();
                        },

                        ///Put label over here
                        icon: Icon(
                          Icons.chevron_right,
                          size: 30,
                          color: kWhiteGreen600White,
                        ),

                        //Put BoxShadow here
                        boxShadow: BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),

                        //Adjust effects such as shimmer and flag vibration here
                        // shimmer: true,
                        // vibrationFlag: true,

                        ///Change All the color and size from here.
                        shimmer: true,
                        buttonSize: 40,
                        height: 50,
                        dismissible: false,
                        width: MediaQuery.of(context).size.width * 0.7,
                        radius: 25,
                        buttonColor: kBlue300Grey,
                        backgroundColor: kTopBarColor,
                        highlightedColor: kWhite54Green400White54,
                        baseColor: kWhiteGreen600White,
                        buttonWidth: 200.0,
                      ),
                    ),
                  ),
                  eurekaCardBuilder(),
                  examPaperCard(),
                  SectionHeader(
                    text: 'Recommended Lectures',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVideosScreen(
                            title: 'Recommended Lectures',
                            videoList: recommendedLecturesList,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 245,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedLecturesList == []
                          ? 1
                          : recommendedLecturesList.length < 6
                              ? recommendedLecturesList.length
                              : 5,
                      itemBuilder: (context, index) {
                        return recommendedLecturesList == []
                            ? Container()
                            : VideoCard(
                                long: false,
                                videoDetail:
                                    jsonDecode(recommendedLecturesList[index]),
                              );
                      },
                    ),
                  ),
                  SectionHeader(
                    text: 'Revision Lectures',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => AllVideosScreen(
                                  title: 'Revision Lectures',
                                  videoList: revisionVideoList)));
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 245,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: revisionVideoList == []
                          ? 1
                          : revisionVideoList.length < 6
                              ? revisionVideoList.length
                              : 5,
                      itemBuilder: (context, index) {
                        return revisionVideoList == []
                            ? Container()
                            : VideoCard(
                                long: false,
                                videoDetail:
                                    jsonDecode(revisionVideoList[index]),
                              );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartExamButton extends StatefulWidget {
  const StartExamButton({
    Key key,
    @required this.exam,
    @required this.context,
  }) : super(key: key);

  final Map exam;
  final BuildContext context;

  @override
  _StartExamButtonState createState() => _StartExamButtonState();
}

class _StartExamButtonState extends State<StartExamButton> {
  bool startExam = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.bottomRight,
      child: Material(
        elevation: 5,
        color: kBlue300Grey,
        borderRadius: BorderRadius.circular(10),
        child: CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: kBlue300Grey,
            child: Text(
              'Start Exam',
              style: TextStyle(color: kUpdateTextColor, fontSize: 16),
            ),
            onPressed: () async {
              if (widget.exam['Link'] == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaperScreen(
                      subtopics: widget.exam['subtopics'],
                      mode: 'Collection',
                      domain: 'Model Paper',
                      selectedBook: 'No Books',
                      subscription: widget.exam['subscription'],
                      time: widget.exam['time'],
                      questionNumber: 50,
                      collection: 'Papers',
                      topic: widget.exam['topic'],
                      medium: widget.exam['medium'],
                    ),
                  ),
                );
              } else {
                Map attempts =
                    await jsonDecode(await LocalUserData.getAttemptTimes());
                if (attempts[widget.exam['Link']] == null ||
                    attempts[widget.exam['Link']].runtimeType == int ||
                    attempts[widget.exam['Link']]['attempts'] <
                        widget.exam['allowed']) {
                  if (attempts[widget.exam['Link']] == null) {
                    attempts[widget.exam['Link']] = {
                      'attempts': 0,
                      'timeRemaining':
                          Duration(minutes: widget.exam['duration']).inSeconds,
                      'lastTime': '',
                    };
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewExample(
                        duration: widget.exam['duration'],
                        attempts: attempts,
                        link: widget.exam['Link'],
                        waterMarkerNeeded: widget.exam['waterMarkerNeeded'],
                        startTime: widget.exam['startTime'],
                        endTime: widget.exam['finishTime'],
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotConnectedAlert(
                                notConnected: true,
                                title: 'Too many attempts',
                                content:
                                    'You have already used your ${widget.exam['allowed']} attempts',
                                icon: Icons.close,
                              )));
                }
              }
            }),
      ),
    );
  }
}
