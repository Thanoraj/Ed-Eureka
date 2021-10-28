import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/pages/authentication/profile_screen.dart';
import 'package:ed_eureka/ui/pages/video/all_videos_screen.dart';
import 'package:ed_eureka/ui/widgets/sectionHeader.dart';
import 'package:ed_eureka/ui/widgets/videoCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../services/user_management.dart';

class PlanerPage extends StatefulWidget {
  PlanerPage({
    Key key,
    this.userDetails,
    @required this.onMenuTap,
  }) : super(key: key);
  final Map userDetails;
  final Function onMenuTap;

  @override
  _PlanerPageState createState() => _PlanerPageState();
}

class _PlanerPageState extends State<PlanerPage> {
  TextEditingController controller = TextEditingController();
  List userInfo = [];
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  List subjectList = [];

  @override
  void initState() {
    super.initState();
  }

  List videoDetailList = [];
  User loggedInUser = FirebaseAuth.instance.currentUser;
  Map answeredQuestions = {};
  Map correctAnswers = {};
  List revisionVideoList = [];
  List recommendedLecturesList = [];
  Map totalQuestions;
  List topicList = [];
  Map subtopicsData = {};
  int allQuestions = 0;

  videoListGenerator() async {
    UserManagement.checkUser(context);
    await _fireStore
        .collection('User')
        .doc(loggedInUser.uid)
        .get()
        .then((value) {
      subjectList = value['subjectList'];
      userInfo = value['userInfo'];
      answeredQuestions = value['totalAnswered'];
      correctAnswers = value['totalCorrect'];
      subtopicsData = value['subtopics'];
    }).catchError((e) {
      correctAnswers = {};
      answeredQuestions = {};
      subtopicsData = {};
    });

    await _fireStore
        .collection('App Info')
        .doc('Questions Info')
        .get()
        .then((element) {
      totalQuestions = element['Total Questions'];
    }).catchError((e) {
      totalQuestions = {
        'All Syllabus': 200.toDouble(),
      };
    });

    allQuestions = 0;

    totalQuestions.forEach((key, value) {
      if (subjectList.contains(key)) {
        value.forEach((key, value) {
          allQuestions += value;
        });
      }
    });
    if (allQuestions == 0) {
      allQuestions = 100;
    }

    topicList = [];

    await _fireStore
        .collection('Subjects')
        .get()
        .then((querySnapshots) => querySnapshots.docs.forEach((element) {
              topicList.add([
                element['Topic'],
                element['Subtopics'],
              ]);
            }));

    return true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int totalAnswered = 0;
  int totalCorrect = 0;
  List<ChartData> chartData = [];

  dataSourceGenerator() {
    totalAnswered = 0;
    totalCorrect = 0;
    chartData = [];

    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.green[600],
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.brown
    ];
    correctAnswers.forEach((key, value) {
      if (subjectList.contains(key)) {
        totalCorrect += value;
      }
    });
    answeredQuestions.forEach((key, value) {
      if (subjectList.contains(key)) {
        totalAnswered += value;
      }
    });

    int i = 0;

    for (String subject in subjectList) {
      chartData.add(ChartData(
          subject,
          (answeredQuestions[subject] == null
                  ? 0.0
                  : answeredQuestions[subject])
              .toDouble(),
          colors[i]));
      i++;
    }
    return chartData;
  }

  barData(topic) {
    List<BarData> chart = [];
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.green[600],
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.brown,
      Colors.blueAccent,
      Colors.teal,
      Colors.grey,
      Colors.black,
      Colors.pink,
      Colors.yellowAccent,
      Colors.deepPurple,
      Colors.tealAccent,
      Colors.redAccent,
      Colors.purpleAccent
    ];
    int i = 0;
    for (String subtopic in topic[1]) {
      chart.add(BarData(
          i,
          subtopicsData[topic[0]] == null ||
                  subtopicsData[topic[0]][subtopic] == null
              ? 0
              : subtopicsData[topic[0]][subtopic],
          '$subtopic  ${subtopicsData[topic[0]] == null || subtopicsData[topic[0]][subtopic] == null ? 0 : subtopicsData[topic[0]][subtopic]}',
          colors[i]));
      i++;
    }
    return chart;
  }

  subjectBuilder() {
    List<Widget> chartList = [];

    for (List topic in topicList) {
      if (subjectList.contains(topic[0])) {
        chartList.add(SectionHeader(
          text: topic[0],
          onPressed: () {},
          isNeeded: 'No',
        ));
        chartList.add(
          Container(
            width: MediaQuery.of(context).size.width,
            height: 500,
            child: SfCartesianChart(
                margin: EdgeInsets.symmetric(horizontal: 20),
                borderColor: Colors.transparent,
                plotAreaBorderWidth: 0,
                plotAreaBackgroundColor: Colors.transparent,
                primaryXAxis: NumericAxis(
                  isVisible: false,
                ),
                primaryYAxis: CategoryAxis(
                  isVisible: false,
                  labelPlacement: LabelPlacement.onTicks,
                  rangePadding: ChartRangePadding.none,
                ),
                series: <ChartSeries>[
                  StackedBarSeries<BarData, int>(
                    isTrackVisible: true,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    trackColor: Colors.grey,
                    width: 0.5,
                    dataSource: barData(topic),
                    dataLabelSettings: DataLabelSettings(
                      textStyle: TextStyle(color: Colors.white, fontSize: 12),
                      labelAlignment: ChartDataLabelAlignment.bottom,
                      isVisible: true,
                    ),
                    xValueMapper: (BarData data, _) => data.x,
                    yValueMapper: (BarData data, _) => data.y,
                    dataLabelMapper: (BarData data, _) => data.label,
                    pointColorMapper: (BarData data, _) => data.color,
                  ),
                ]),
          ),
        );
      }
    }

    return Column(
      children: chartList,
    );
  }

  Float64List _resolveTransform(Rect bounds, TextDirection textDirection) {
    final GradientTransform transform = GradientRotation(_degreeToRadian(-90));
    return transform.transform(bounds, textDirection: textDirection).storage;
  }

  double _degreeToRadian(int deg) => deg * (3.141592653589793 / 180);

  List<Color> colors = <Color>[
    const Color.fromRGBO(75, 135, 185, 1),
    const Color.fromRGBO(192, 108, 132, 1),
    const Color.fromRGBO(246, 114, 128, 1),
    const Color.fromRGBO(248, 177, 149, 1),
    const Color.fromRGBO(116, 180, 155, 1)
  ];

  List<double> stops = <double>[
    0.2,
    0.4,
    0.6,
    0.8,
    1,
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: videoListGenerator(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Material(
            child: CupertinoPageScaffold(
              backgroundColor: kBodyFull,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SafeArea(
                    child: ListView(children: [
                      SizedBox(
                        height: 110,
                      ),
                      SectionHeader(
                        text: 'Total Syllabus Insights',
                        isNeeded: 'No',
                        onPressed: () {},
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 245,
                        child: SfCircularChart(
                          legend: Legend(
                              position: LegendPosition.bottom,
                              isResponsive: true,
                              isVisible: true,
                              toggleSeriesVisibility: false,
                              textStyle: TextStyle(color: kBlackGreen600white),
                              borderWidth: 2),
                          series: <CircularSeries>[
                            RadialBarSeries<ChartData, String>(
                              dataSource: dataSourceGenerator(),
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              pointColorMapper: (ChartData data, _) =>
                                  data.color,
                              maximumValue: allQuestions.toDouble(),
                              legendIconType: LegendIconType.circle,
                              radius: '100%',
                              animationDuration: 1000,
                              gap: '8%',
                              innerRadius: '55%',
                              trackOpacity: 0.5,
                              cornerStyle: CornerStyle.bothCurve,
                              strokeWidth: 2,
                            ),
                          ],
                        ),
                      ),
                      subjectBuilder(),
                    ]),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
              color: kBodyFull,
              child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class BarData {
  BarData(this.x, this.y, this.label, [this.color]);
  final int x;
  final num y;
  final String label;
  final Color color;
}
