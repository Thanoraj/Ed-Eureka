import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/widgets/topBar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/topics/pdf_viewer.dart';
import 'package:ed_eureka/ui/widgets/bottom_bar_button.dart';
import 'package:ed_eureka/ui/widgets/question_navigator.dart';
import 'package:ed_eureka/ui/widgets/read_mode_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'advertisement_screen.dart';

class Question extends StatefulWidget {
  Question({
    this.topic,
    this.serverId,
    this.subTopic,
    this.prefix,
    this.mode,
    this.questionNumber,
    this.selectedBook,
    this.collection,
    this.domain,
    this.lastLeaders,
  });
  final prefix;
  final serverId;
  final selectedBook;
  final mode;
  final questionNumber;
  final topic;
  final subTopic;
  final domain;
  final collection;
  final lastLeaders;
  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState<T extends Question> extends State<T> {
  int index = 0;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController controller = PageController(initialPage: 0);
  List<Map> questionList = [];
  List<Widget> questionAnswerTile = [];
  int pageNumber;
  List responseList = [];
  String selected = 'none';
  bool navigateNext = false;
  String nextButtonState = 'active';
  int answeredQuestion = 1;
  int checkedQuestion = 1;
  bool checking = false;
  String correctAnswer = 'none';
  Map<dynamic, dynamic> answerList = {};
  int correctAnswers = 0;
  int totalQuestions = 0;
  bool showScore = false;

  List keyWords = [];
  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  String videoId;
  YoutubePlayerController _controller =
      YoutubePlayerController(initialVideoId: null);

  bool _isPlayerReady = false;

  @override
  void initState() {
    widget.collection == 'Subjects' ? getQuestions() : null;
    super.initState();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  Future<List> postRequest(String question) async {
    http.Response response = await http.post(
      Uri.parse('http://52.14.106.14:8080/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {"file": '${widget.prefix}$question'},
      ),
    );

    if (response.statusCode == 200) {
      String data = response.body;
      List decodedData = jsonDecode(data);
      return decodedData;
    } else {}
  }

  answersTile(List choiceAnswerList, String questionNo) {
    List<Widget> answerTileList = [];
    selected = answerList[questionNo][0];
    correctAnswer = answerList[questionNo][1];
    for (int i = 0; i < choiceAnswerList.length; i++) {
      answerTileList.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                correctAnswer == 'none' ? selected = choiceAnswerList[i] : null;
                answerList[questionNo][0] = selected;
              });
            },
            child: Ink(
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                splashFactory: InkRipple.splashFactory,
                splashColor: Colors.blue[900],
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: choiceAnswerList[i] == correctAnswer
                          ? Colors.green
                          : selected == choiceAnswerList[i] &&
                                  correctAnswer == 'none'
                              ? Colors.blue[300]
                              : selected == choiceAnswerList[i] &&
                                      correctAnswer != choiceAnswerList[i]
                                  ? Colors.red
                                  : null,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: Colors.grey[600])),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1})',
                        style: TextStyle(color: kWhiteGreen600White),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: choiceAnswerList[i]
                                .toString()
                                .split('/')[0]
                                .contains('http')
                            ? Image.network(choiceAnswerList[i].toString())
                            : Text(
                                '${choiceAnswerList[i]}',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: kWhiteGreen600White,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: answerTileList,
    );
  }

  explanationTile(explanationList) {
    List<Widget> explanationTileList = [];
    for (int i = 1; i < explanationList.length; i++) {
      explanationTileList.add(
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    alignment: Alignment.topCenter,
                    child: Text(
                      '${i + 1})',
                      style: TextStyle(
                        fontSize: 15,
                        color: kTextFull,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Red Hat Display',
                      ),
                    )),
                Flexible(
                  child: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Text(
                        explanationList[i].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Red Hat Display',
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: explanationTileList,
    );
  }

  Map finalResults;
  int pointA = 5;
  int pointB = 3;
  int pointC = 1;
  int marks;
  User loggedInUser = FirebaseAuth.instance.currentUser;
  Map subjectPoints = {};
  Map totalAnswered = {};
  Map totalCorrect = {};
  Map leaderList = {};
  List userInfo = [];
  Map allStreamsLeadersList = {};
  List subjectList = [];
  String userName;
  Map subtopicsDetails = {};
  List flashcardList = [];
  bool delete = false;

  saveStats() async {
    await _firestore
        .collection('User')
        .doc(loggedInUser.uid)
        .collection('Results')
        .doc('${selectedSubject}_${widget.subTopic}')
        .get()
        .then((value) {
      marks = value['marks'];
      finalResults = value['${widget.domain}_finalResults'];
    }).catchError((e) {
      if (e.toString() ==
          'Bad state: cannot get a field on a DocumentSnapshotPlatform which does not exist') {
        marks = 0;
        finalResults = {};
      }
      print(e);
      marks = 0;
      finalResults = {};
    });
    await _firestore
        .collection('User')
        .doc(loggedInUser.uid)
        .get()
        .then((value) {
      userInfo = value['userInfo'];
      subjectList = value['subjectList'];
      userName = value['userName'];
      subtopicsDetails = value['subtopics'];
      subjectPoints = value['subjectPoints'];
      totalAnswered = value['totalAnswered'];
      totalCorrect = value['totalCorrect'];
    }).catchError((e) {
      print(e);
      if (e.toString() ==
          'Bad state: cannot get a field on a DocumentSnapshotPlatform which does not exist') {
        subjectPoints = {};
        totalAnswered = {};
        totalCorrect = {};
        subtopicsDetails = {};
      }
    });

    int score = 0;
    answerList.forEach((key, value) {
      if (value[1] != 'none') {
        if (finalResults[key] == null) {
          finalResults[key] = [0, 0];
        }
        if (totalAnswered[selectedSubject] == null) {
          subjectPoints[selectedSubject] = 0;
          totalAnswered[selectedSubject] = 0;
          totalCorrect[selectedSubject] = 0;
        }
        totalAnswered[selectedSubject]++;

        finalResults[key][0]++;
        if (answerList[key][0] == answerList[key][1]) {
          totalCorrect[selectedSubject]++;
          finalResults[key][1]++;

          finalResults[key][0] == 1
              ? score += 5
              : finalResults[key][0] == 2
                  ? score += 3
                  : finalResults[key][0] == 3
                      ? score += 1
                      : score += 0;
        }
      }
    });
    subjectPoints[selectedSubject] += score;
    marks += score;

    int totalScore = 0;
    subjectPoints.forEach((key, value) {
      if (subjectList.contains(key)) {
        totalScore += value;
      }
    });

    subtopicsDetails[selectedSubject] == null
        ? subtopicsDetails[selectedSubject] = {
            widget.subTopic: finalResults.length
          }
        : subtopicsDetails[selectedSubject][widget.subTopic] =
            finalResults.length;

    _firestore
        .collection('User')
        .doc(loggedInUser.uid)
        .collection('Results')
        .doc('${selectedSubject}_${widget.subTopic}')
        .set({
      '${widget.domain}_finalResults': finalResults,
      'marks': marks,
      'topic': selectedSubject,
      'subtopic': widget.subTopic,
    });

    _firestore.collection('User').doc(loggedInUser.uid).update(
      {
        'totalAnswered': totalAnswered,
        'totalCorrect': totalCorrect,
        'subjectPoints': subjectPoints,
        'subtopics': subtopicsDetails,
      },
    );

    if (score > 0) {
      await _firestore
          .collection('App Info')
          .doc('Leader Board')
          .get()
          .then((value) {
        leaderList = value['${userInfo[1]}'];
        allStreamsLeadersList = value['All Streams'];
      }).catchError((e) {
        if (e.toString() ==
            'Bad state: cannot get a field on a DocumentSnapshotPlatform which does not exist') {}
      });

      if (totalScore > leaderList['Scores'].last) {
        if (!leaderList['Names'].contains(userName)) {
          List allLeaderList = leaderList['Scores'];
          allLeaderList.add(totalScore);
          allLeaderList.sort((b, a) => a.compareTo(b));
          leaderList['Names']
              .insert(allLeaderList.indexOf(totalScore), userName);

          if (allLeaderList.length > 100) {
            allLeaderList.removeLast();
            leaderList['Names'].removeLast();
          }
        } else {
          List allLeaderList = leaderList['Scores'];
          allLeaderList
              .remove(allLeaderList[leaderList['Names'].indexOf(userName)]);
          leaderList['Names'].remove(userName);
          allLeaderList.add(totalScore);
          allLeaderList.sort((b, a) => a.compareTo(b));
          leaderList['Names']
              .insert(allLeaderList.indexOf(totalScore), userName);
        }

        if (totalScore > allStreamsLeadersList['Scores'].last) {
          if (!allStreamsLeadersList['Names'].contains(userName)) {
            List allLeaderList = allStreamsLeadersList['Scores'];
            allLeaderList.add(totalScore);
            allLeaderList.sort((b, a) => a.compareTo(b));
            allStreamsLeadersList['Names']
                .insert(allLeaderList.indexOf(totalScore), userName);

            if (allLeaderList.length > 100) {
              allLeaderList.removeLast();
              allStreamsLeadersList['Names'].removeLast();
            }
          } else {
            List allLeaderList = allStreamsLeadersList['Scores'];
            allLeaderList.remove(allLeaderList[
                allStreamsLeadersList['Names'].indexOf(userName)]);
            allStreamsLeadersList['Names'].remove(userName);
            allLeaderList.add(totalScore);
            allLeaderList.sort((b, a) => a.compareTo(b));
            allStreamsLeadersList['Names']
                .insert(allLeaderList.indexOf(totalScore), userName);
          }
          _firestore.collection('App Info').doc('Leader Board').update({
            'All Streams': allStreamsLeadersList,
            userInfo[1]: leaderList,
          });
        } else {
          _firestore.collection('App Info').doc('Leader Board').update({
            userInfo[1]: leaderList,
          });
        }
      }
    }
  }

  deleteAd(imageInfo) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/${imageInfo[1]}';
    Uri myUri = Uri.parse(path);
    File file = new File.fromUri(myUri);
    file.delete();
    flashList.remove(imageInfo[1]);
    await LocalUserData.saveFlashCard(
        '${widget.subTopic}_flashCards', flashList);
    flashcardList.remove(imageInfo);
    setState(() {
      delete = false;
    });
  }

  buildAdTileList(flashcardList) {
    List<Widget> leftFlashCardList = [];
    List<Widget> rightFlashCardList = [];
    List<Widget> flashCardWidgetList = [];

    for (int i = 0; i < flashcardList.length; i++) {
      flashCardWidgetList.add(
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdvertisementScreen(image: flashcardList[i][0]),
                  ),
                );
              },
              onLongPress: () {
                setState(() {
                  delete = true;
                });
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                elevation: 5,
                child: Image.memory(flashcardList[i][0]),
              ),
            ),
            delete
                ? GestureDetector(
                    onTap: () {
                      deleteAd(flashcardList[i]);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        child: Icon(Icons.close),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );
    }

    for (int i = 0; i < flashCardWidgetList.length; i++) {
      i % 2 == 0
          ? leftFlashCardList.add(flashCardWidgetList[i])
          : rightFlashCardList.add(flashCardWidgetList[i]);
    }

    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: leftFlashCardList,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: rightFlashCardList,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  dispose() async {
    widget.collection == 'Subjects' ? saveStats() : null;
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }

  generateExplanation() async {
    for (Map questionData in questionList) {
      List response = await postRequest(questionData['Question']);
      List<String> keyWords = [];
      for (var value in response[0]) {
        keyWords.add(value.toString());
      }
      response[1].insert(0, 'available');
      questionData['Explanation'] = response[1];
      questionData['keyWords'] = keyWords;
      questionData['CorrectKeyWords'] = response[2];
      _firestore
          .collection('Subjects')
          .doc(selectedSubject)
          .collection('${widget.subTopic}_${widget.domain}')
          .doc('QuestionNumber_${questionData['Question Number'].toString()}')
          .set({
        'Question Number': questionData['Question Number'],
        'Question': questionData['Question'].toString().replaceAll('\\n', '\n'),
        'Answers': questionData['Answers'].toString().replaceAll('\\n', '\n'),
        'Correct Answer':
            questionData['Correct Answer'].toString().replaceAll('\\n', '\n'),
        'Explanation': questionData['Explanation'],
        'Link': questionData['Link'],
        'Image': questionData['Image'],
        'KeyWords': keyWords,
        'CorrectKeyWords': response[2],
        'bookBytes': widget.selectedBook,
      });
    }
  }

  List shuffle(List items) {
    var random = new Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  Future<Uint8List> _readFileByte(filePath, type) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/$filePath';
    Uri myUri = Uri.parse(type == 'path' ? filePath : path);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
    }).catchError((onError) {});
    return bytes;
  }

  List flashCardList = [];
  List flashList = [];
  getFlashCard() async {
    flashcardList = [];
    List list =
        await LocalUserData.getFlashCardList('${widget.subTopic}_flashCards');
    flashList = list == null ? [] : list;
    for (String imageName in flashList) {
      var bytes = await _readFileByte(imageName, 'name');
      flashcardList.add([bytes, imageName]);
    }
    return flashcardList;
  }

  getQuestions() async {
    getFlashCard();
    questionList = [];
    await _firestore
        .collection(widget.collection)
        .doc(selectedSubject)
        .collection('${widget.subTopic}_${widget.domain}')
        .orderBy('Question Number')
        .get()
        .then(
          (querySnapshots) => {
            querySnapshots.docs.forEach(
              (element) {
                if (element['Question'] != '') {
                  questionList.add({
                    'Question Number': element.id,
                    'Question': element['Question'],
                    'Answers': shuffle(element['Answers']),
                    'Correct Answer': element['Correct Answer'],
                    'Explanation': element['Explanation'],
                    'Link': element['Link'],
                    'Image': element['Image'],
                    'keyWords': element['KeyWords'],
                    'CorrectKeyWords': element['CorrectKeyWords'],
                    'bookBytes': widget.selectedBook,
                  });
                }
              },
            ),
          },
        );
    for (int i = 0; i < questionList.length; i++) {
      answerList[questionList[i]['Question Number'].toString()] = [
        'none',
        'none',
      ];
    }
    setState(() {});
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  bool showAlert = false;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) => Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: kWhitef5Black,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: questionList.length == 0
                    ? Container(
                        child: Text(
                          'No questions available Now in this section',
                          style: TextStyle(color: kWhiteGreen600White),
                        ),
                      )
                    : index % 2 == 0
                        ? Card(
                            margin: EdgeInsets.all(5),
                            color: kWhitef5Black,
                            child: Stack(children: [
                              Column(
                                children: [
                                  Spacer(),
                                  Material(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                    color: Colors.transparent,
                                    child: Container(
                                      height: 90,
                                      decoration: new BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: kBlueGreen900,
                                            blurRadius: 500.0,
                                            spreadRadius: 40.0,
                                            offset: Offset(
                                              0.0,
                                              50.0,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ListView(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, top: 20, bottom: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Q ) ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: kWhiteGreen600White,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: Text(
                                                  questionList[(index ~/ 2)]
                                                      ['Question'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Red Hat Display',
                                                    fontSize: 20,
                                                    color: kWhiteGreen600White,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 40,
                                              ),
                                              questionList[(index ~/ 2)]
                                                          ['Image'] !=
                                                      'none'
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      height: 100,
                                                      child: Image.network(
                                                        questionList[(index ~/
                                                            2)]['Image'],
                                                        fit: BoxFit.fill,
                                                        errorBuilder: (context,
                                                                url, error) =>
                                                            new Icon(
                                                                Icons.error),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 5,
                                                    ),
                                            ]),
                                      ],
                                    ),
                                  ),
                                  answersTile(
                                    questionList[(index ~/ 2)]['Answers'],
                                    questionList[(index ~/ 2)]
                                            ['Question Number']
                                        .toString()
                                        .toString(),
                                  ),
                                  Container(
                                    height: 60,
                                  ),
                                ],
                              ),
                            ]),
                          )
                        : Stack(children: [
                            Card(
                              margin: EdgeInsets.all(5),
                              color: kWhitef5Black,
                              child: Stack(children: [
                                Column(
                                  children: [
                                    Spacer(),
                                    Material(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                      ),
                                      color: Colors.transparent,
                                      child: Container(
                                        height: 90,
                                        decoration: new BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: kBlueGreen900,
                                              blurRadius: 500.0,
                                              spreadRadius: 40.0,
                                              offset: Offset(
                                                0.0,
                                                50.0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Explanation',
                                        style: TextStyle(
                                            color: kWhiteGreen600White,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    explanationTile(questionList[(index == 1
                                        ? 0
                                        : (index - 1) ~/ 2)]['Explanation']),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'Related Video:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: kWhiteGreen600White,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child:
                                            _controller.initialVideoId != null
                                                ? player
                                                : SizedBox()),
                                    checkedQuestion ==
                                                2 * widget.questionNumber &&
                                            (widget.mode != 'Instance' ||
                                                index ==
                                                    2 * questionList.length - 1)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                                QuestionNavigationButton(
                                                  long: true,
                                                  buttonText: 'Go to Menu',
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                index !=
                                                        2 *
                                                                questionList
                                                                    .length -
                                                            1
                                                    ? QuestionNavigationButton(
                                                        long: false,
                                                        buttonText: 'Continue',
                                                        colour:
                                                            Colors.green[600],
                                                        onTap: () {
                                                          setState(() {
                                                            checking = false;
                                                            index = index + 1;
                                                            answeredQuestion =
                                                                1;
                                                            checkedQuestion = 1;
                                                          });
                                                        },
                                                      )
                                                    : Container(),
                                              ])
                                        : Container(),
                                    Container(
                                      height: 60,
                                    ),
                                    buildAdTileList(
                                      widget.collection == 'Papers'
                                          ? questionList[(index == 1
                                                  ? 0
                                                  : (index - 1) ~/ 2)]
                                              ['flashCardList']
                                          : flashcardList,
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            ReadModeButton(
                              onTap: () async {
                                String theme = await LocalUserData.getTheme();
                                if (questionList[(index == 1
                                        ? 0
                                        : (index - 1) ~/ 2)]['bookBytes'] !=
                                    'No Books') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PdfViewer(
                                                tutorial: false,
                                                theme: theme,
                                                selectedBook: questionList[
                                                        (index == 1
                                                            ? 0
                                                            : (index - 1) ~/ 2)]
                                                    ['bookBytes'],
                                                keyWords: questionList[
                                                        (index == 1
                                                            ? 0
                                                            : (index - 1) ~/ 2)]
                                                    ['keyWords'],
                                                correctKeyWords: questionList[
                                                        (index == 1
                                                            ? 0
                                                            : (index - 1) ~/ 2)]
                                                    ['CorrectKeyWords'],
                                              )));
                                } else {
                                  showAlert = true;
                                  setState(() {});
                                }
                              },
                            )
                          ]),
              ),
            ),
            Column(
              children: [
                Spacer(),
                Material(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  color: Colors.transparent,
                  child: Container(
                    height: 90,
                    decoration: new BoxDecoration(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BottomBarButton(
                          state: index == 0 ? 'inactive' : 'active',
                          icon: Icons.navigate_before_sharp,
                          text: 'Previous',
                          onTap: () {
                            setState(() {
                              widget.mode != 'Instance' && checking == false
                                  ? index = index - 2
                                  : index = index - 1;
                              checking ? checkedQuestion-- : answeredQuestion--;
                            });
                          },
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10, bottom: 10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (answeredQuestion == widget.questionNumber ||
                                            index ==
                                                2 * questionList.length - 2) &&
                                        checking == false
                                    ? selected == 'none'
                                        ? QuestionNavigationButton(
                                            buttonText: 'Check',
                                            long: false,
                                            colour: Colors.green[300],
                                            onTap: () {},
                                          )
                                        : QuestionNavigationButton(
                                            buttonText: 'Check',
                                            long: false,
                                            colour: Colors.green[600],
                                            onTap: () {
                                              checking = true;
                                              index = index +
                                                  2 -
                                                  2 * (answeredQuestion);
                                              for (int i = 0;
                                                  i < (answeredQuestion);
                                                  i++) {
                                                totalQuestions++;
                                                answerList[questionList[
                                                                (index ~/ 2) +
                                                                    i]
                                                            ['Question Number']
                                                        .toString()][1] =
                                                    questionList[(index ~/ 2) +
                                                        i]['Correct Answer'];
                                                if (answerList[questionList[
                                                                (index ~/ 2) +
                                                                    i]
                                                            ['Question Number']
                                                        .toString()][0] ==
                                                    answerList[questionList[
                                                                (index ~/ 2) +
                                                                    i]
                                                            ['Question Number']
                                                        .toString()][1]) {
                                                  correctAnswers++;
                                                }
                                              }
                                              if (widget.collection ==
                                                  'Papers') {
                                                showScore = true;
                                              }
                                              setState(() {});
                                            },
                                          )
                                    : SizedBox(
                                        width: 70,
                                      ),
                              ]),
                        ),
                        BottomBarButton(
                          state: index == 2 * questionList.length - 2 &&
                                  checking == false
                              ? 'inactive'
                              : answeredQuestion == widget.questionNumber &&
                                      checking == false
                                  ? 'inactive'
                                  : index == 2 * questionList.length - 1 &&
                                          checking == true
                                      ? 'inactive'
                                      : widget.mode == 'Instance'
                                          ? 'active'
                                          : checkedQuestion ==
                                                      2 *
                                                          widget
                                                              .questionNumber &&
                                                  checking == true
                                              ? 'inactive'
                                              : 'active',
                          icon: Icons.navigate_next_sharp,
                          text: 'Next',
                          onTap: () {
                            UserManagement.checkUser(context);

                            widget.mode != 'Instance' && checking == false
                                ? index = index + 2
                                : index = index + 1;
                            if (widget.mode == 'Instance' || checking == true) {
                              videoId = YoutubePlayer.convertUrlToId(
                                  questionList[(index == 1
                                      ? 0
                                      : (index - 1) ~/ 2)]['Link']);
                              _controller.reset();
                              _controller = YoutubePlayerController(
                                initialVideoId: videoId,
                                flags: const YoutubePlayerFlags(
                                  mute: false,
                                  autoPlay: false,
                                  disableDragSeek: false,
                                  loop: false,
                                  isLive: false,
                                  forceHD: false,
                                  enableCaption: true,
                                ),
                              )..addListener(listener);
                            }
                            selected = 'none';
                            correctAnswer = 'none';
                            checking ? checkedQuestion++ : answeredQuestion++;
                            if (widget.mode == 'Instance' &&
                                checkedQuestion == 3) {
                              answeredQuestion = 1;
                              checkedQuestion = 1;
                              checking = false;
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: showAlert,
              child: AlertDialog(
                title: Text('No Books Are Available'),
                content: Container(
                  child: Text(
                      'No Books Are Available here \nGo back to the relevant section and upload a book of your preference or download available guide books to find the theory related to question '),
                ),
                actions: [
                  widget.collection == 'Papers'
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(bottom: 10, right: 25, top: 60),
                            child: Text('Navigate to section page'),
                          ),
                        ),
                  GestureDetector(
                    onTap: () {
                      showAlert = false;
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10, right: 25, top: 60),
                      child:
                          Text(widget.collection == 'Papers' ? 'Ok' : 'Cancel'),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: showScore,
              child: ScoreCard(
                  func: () {
                    setState(() {
                      showScore = false;
                    });
                  },
                  correctAnswers: correctAnswers,
                  totalQuestions: totalQuestions),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    Key key,
    @required this.correctAnswers,
    @required this.totalQuestions,
    this.func,
  }) : super(key: key);
  final func;
  final int correctAnswers;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    double percentage = correctAnswers * 100 / totalQuestions;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(children: [
          Spacer(),
          Material(
            borderRadius: BorderRadius.circular(20),
            color: kGrey100Black,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: kGrey100Black,
              ),
              padding: EdgeInsets.only(bottom: 30),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      percentage >= 75
                          ? 'Congratulations'
                          : percentage >= 50
                              ? 'Good Job'
                              : 'Never Give Up',
                      style: TextStyle(fontSize: 20, color: kBlackGreen600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 10),
                    child: Text(
                      'You Got',
                      style: TextStyle(fontSize: 20, color: kBlackGreen600),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          correctAnswers.toString(),
                          style: TextStyle(
                            fontSize: 50,
                            color: percentage >= 75
                                ? Colors.green
                                : percentage >= 50
                                    ? Colors.yellow
                                    : Colors.red,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          ' / $totalQuestions',
                          style: TextStyle(fontSize: 50, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextButton(
                    onPressed: () {
                      func();
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: kBlue300Grey,
                        elevation: 10,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                    child: Text(
                      'View Answers',
                      style: TextStyle(fontSize: 17, color: kUpdateTextColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
        ]),
      ),
    );
  }
}

function() {}

class PaperScreen extends Question {
  PaperScreen(
      {@required this.subscription,
      @required this.time,
      @required this.mode,
      @required this.questionNumber,
      @required this.selectedBook,
      @required this.collection,
      @required this.subtopics,
      @required this.domain,
      @required this.topic,
      @required this.medium})
      : super(
            collection: collection,
            mode: mode,
            questionNumber: questionNumber,
            selectedBook: selectedBook,
            domain: domain);
  final selectedBook;
  final subtopics;
  final mode;
  final questionNumber;
  final subscription;
  final time;
  final domain;
  final collection;
  final topic;
  final medium;

  @override
  PaperScreenState createState() => PaperScreenState();
}

class PaperScreenState extends _QuestionState<PaperScreen> {
  @override
  void initState() {
    getQuestions();
    super.initState();
  }

  List shuffle(List items) {
    var random = new Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  Future<Uint8List> _readFileByte(filePath, type) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/$filePath';
    Uri myUri = Uri.parse(type == 'path' ? filePath : path);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
    }).catchError((onError) {});
    return bytes;
  }

  Map bookList = {};
  Map allFlashCardList = {};

  @override
  getQuestions() async {
    List<Map> examQuestion = [];
    for (String subtopic in widget.subtopics) {
      var bookName = await LocalUserData.getLastBook('${subtopic}_lastBook');
      var selectedBook;
      if (bookName != 'No Books' && bookName != null) {
        selectedBook = await _readFileByte(bookName, 'name');
      } else {
        selectedBook = 'No Books';
      }
      bookList[subtopic] = selectedBook;
      List cardList = [];
      List list =
          await LocalUserData.getFlashCardList('${subtopic}_flashCards');
      List flashList = list == null ? [] : list;
      for (String imageName in flashList) {
        var bytes = await _readFileByte(imageName, 'name');
        cardList.add([bytes, imageName]);
      }

      allFlashCardList[subtopic] = cardList;
    }
    await _firestore
        .collection('Papers')
        .doc(widget.subscription['name'])
        .collection(widget.subscription['name'] != 'Ed-Eureka'
            ? '${widget.subscription['batch']}_${widget.time}_${widget.medium}'
            : '${widget.topic}_${widget.time}')
        .orderBy('Question Number')
        .get()
        .then((value) async {
      int i = 0;
      value.docs.forEach((element) async {
        examQuestion.add({
          'docId': element.id,
          'Question Number': element['Question Number'],
          'Question': element['Question'],
          'Answers': shuffle(element['Answers']),
          'Correct Answer': element['Correct Answer'],
          'Explanation': element['Explanation'],
          'Link': element['Link'],
          'Image': element['Image'],
          'keyWords': element['KeyWords'],
          'CorrectKeyWords': element['CorrectKeyWords'],
          'bookBytes': bookList[element['Subtopic']],
          'flashCardList': allFlashCardList[element['Subtopic']]
        });
        i++;
      });
    }).catchError((e) {});
    super.questionList = examQuestion;
    Map answers = {};
    for (int i = 0; i < examQuestion.length; i++) {
      answers[questionList[i]['Question Number'].toString()] = [
        'none',
        'none',
      ];
    }
    super.answerList = answers;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}
