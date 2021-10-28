import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/ui/pages/authentication/profile_screen.dart';
import 'package:ed_eureka/ui/pages/topics/subtopics.dart';
import 'package:ed_eureka/ui/widgets/sectionHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    Key key,
    @required this.controller,
    @required this.expanded,
    @required this.onMenuTap,
    this.callBack,
  });

  final TextEditingController controller;
  final bool expanded;
  final onMenuTap;
  final callBack;

  @override
  _TopBarState createState() => _TopBarState();
}

List subjectList = [];
String selectedSubject;

class _TopBarState extends State<TopBar> {
  String userName = '';
  String email = '';
  String uid = '';
  String photoURL;
  List userInfo = [];
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String serverId;
  Map scores = {};
  Map correctAnswers = {};
  Map answeredQuestion = {};

  List topicList = [];
  String progress;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  userData() async {
    await LocalUserData.getUserNameKey();
    await LocalUserData.getUserEmailKey();
  }

  List mediumsList = [];
  List streamsList = [];
  Map subjectsCollection = {};
  List subscriptionList = [];
  List icons = [
    BoxIcons.bx_shape_circle,
    BoxIcons.bx_shape_triangle,
    BoxIcons.bx_shape_square,
    BoxIcons.bx_shape_polygon,
    Icons.biotech,
    BoxIcons.bx_abacus,
    BoxIcons.bx_book
  ];

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

  void getUser() async {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    await _fireStore.collection('User').doc(loggedInUser.uid).get().then(
      (value) {
        String name = value['userName'].toString().trim();
        userName = name.length > 10 ? name.substring(0, 10) + '..' : name;
        photoURL = value['photoURL'];
        email = value['email'];
        uid = value['uid'];
        userInfo = value['userInfo'];
        subjectList = value['subjectList'];
        scores = value['subjectPoints'];
        answeredQuestion = value['totalAnswered'];
        correctAnswers = value['totalCorrect'];
        subscriptionList = value['subscriptionList'];
      },
    ).catchError((e) {
      if (e ==
          'Bad state: field does not exist within the DocumentSnapshotPlatform') {
        answeredQuestion = answeredQuestion;
        correctAnswers = correctAnswers;
        scores = scores;
        subscriptionList = subscriptionList;
      }
    });

    await _fireStore
        .collection('Subjects')
        .get()
        .then((querySnapshots) => querySnapshots.docs.forEach((element) {
              for (String subject in subjectList) {
                if (element.id == subject) {
                  topicList.add([
                    element['Topic'],
                    element['Subtopics'],
                    element['ImageURL'],
                    element['SubtopicsImages'],
                    element['prefix'],
                    subject,
                  ]);
                }
              }
            }));
    setState(() {});
  }

  int tab = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 10, color: Colors.transparent),
        borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0)),
        color: kTopBarColor,
      ),
      width: MediaQuery.of(context).size.width,
      height: widget.expanded ? 255 : 120,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        "Hi, ${userName.split(' ')[0].length > 2 ? userName.split(' ')[0].toString().substring(0, 1).toUpperCase() + userName.split(' ')[0].toString().substring(1, userName.split(' ')[0].toString().length) : userName.split(' ')[0]}",
                        maxLines: 1,
                        style: TextStyle(
                            color: kWhiteGreen600White,
                            fontSize: 24,
                            fontFamily: kTextFontFamily,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector(
                      child: Container(
                        width: 55,
                        height: 55,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  backgroundImage: photoURL != null
                                      ? NetworkImage(
                                          photoURL,
                                        )
                                      : AssetImage(
                                          'assets/images/userImage.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        /*Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MainApp()));
                        */
                        await getList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              answeredQuestion: answeredQuestion,
                              correctAnswers: correctAnswers,
                              streamList: streamsList,
                              mediumList: mediumsList,
                              subjectCollection: subjectsCollection,
                              image: photoURL,
                              userName: userName,
                              email: email,
                              uid: uid,
                              userInfo: userInfo,
                              subjectList: subjectList,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            widget.expanded
                ? SectionHeader(
                    color: kWhite70Green400White70,
                    isNeeded: 'No',
                    text: 'Classified Questions & Notes',
                    onPressed: () {},
                  )
                : SizedBox(),
            widget.expanded
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 100,
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int index = 0;
                                index < topicList.length;
                                index++)
                              Column(children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 10, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedSubject = topicList[index][5];

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubTopicScreen(
                                                    topic: topicList[index],
                                                    serverId: serverId,
                                                    subscriptionList:
                                                        subscriptionList,
                                                  )));
                                    },
                                    child: Material(
                                      elevation: 5,
                                      shadowColor: kBlackGreen600white,
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: kBodyFull,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              icons[index % 7],
                                              color: kBlackGreen600white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 5, right: 5, top: 10),
                                    child: Text(
                                      topicList == []
                                          ? 'Loading'
                                          : topicList[index][0].split('(')[0],
                                      style: TextStyle(
                                          color: kWhite70Green400White70,
                                          fontSize: 10),
                                    ),
                                  ),
                                ),
                              ])
                          ]),
                    ),
                  ])
                : Container(),
          ],
        ),
      ),
    );
  }
}
