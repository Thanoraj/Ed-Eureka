import 'package:ed_eureka/constants.dart';
import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  StatisticsCard(
      {@required this.dataType,
      @required this.answeredQuestions,
      @required this.correctAnswers,
      @required this.needed});

  final dataType;
  final answeredQuestions;
  final correctAnswers;
  final bool needed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Text(
            dataType,
            style: TextStyle(
              fontSize: 15,
              color: kBlackTeal,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Row(children: [
            Text(
              'Answered Questions : ',
              style: TextStyle(fontSize: 13, color: kBlackGreen600white),
            ),
            Text(
              answeredQuestions.toString(),
              style: TextStyle(fontSize: 13, color: kExamCardText),
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Row(children: [
            Text(
              'Correct Answers : ',
              style: TextStyle(fontSize: 13, color: kBlackGreen600white),
            ),
            Text(
              correctAnswers.toString(),
              style: TextStyle(fontSize: 13, color: kExamCardText),
            ),
          ]),
        ),
        needed
            ? SizedBox(
                height: 20,
              )
            : SizedBox(
                height: 5,
              ),
      ],
    );
  }
}
