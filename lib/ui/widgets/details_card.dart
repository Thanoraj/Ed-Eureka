import 'package:flutter/material.dart';
import 'package:ed_eureka/constants.dart';

class DetailsCard extends StatelessWidget {
  DetailsCard({this.title, this.text});
  final title;
  final text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: TextStyle(
                color: kText70,
                fontSize: 12,
                fontFamily: kTextFontFamily,
                fontWeight: FontWeight.w200),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            title == 'Name'
                ? text.toString().substring(0, 1).toUpperCase() +
                    text.toString().substring(1, text.toString().length)
                : text,
            style: TextStyle(
                color: kBlackGreen600white,
                fontSize: 20,
                fontFamily: kTextFontFamily,
                fontWeight: FontWeight.w400),
          ),
        ),
        Divider(
          thickness: 1,
          color: kGrey600Green600white70,
          indent: 20,
          endIndent: 20,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
