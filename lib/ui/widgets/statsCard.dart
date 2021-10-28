import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/ui/pages/video.dart';
import 'package:ed_eureka/ui/widgets/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final Map correctAnswers;
  final Map scores;
  final Map answeredQuestion;
  final List subjectList;

  StatsCard(
      {this.correctAnswers,
      this.answeredQuestion,
      this.scores,
      this.subjectList});

  getScore(Map scores) {
    int totalScore = 0;
    scores.forEach((key, value) {
      if (subjectList.contains(key)) {
        totalScore += value;
      }
    });
    return totalScore.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
              color: kWhiteGrey,
              //gradient: ColorTheme().waves,
              borderRadius: BorderRadius.circular(30)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              getScore(scores),
              style: TextStyle(
                fontFamily: 'Red Hat Display',
                fontSize: 18,
                color: kBlackGreen600white,
              ),
            ),
            Text(
              'My Scores',
              style: TextStyle(
                fontFamily: 'Red Hat Display',
                fontSize: 18,
                color: kBlackGreen600white,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
