import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/widgets/next_button.dart';
import 'package:flutter/material.dart';

class LandPageWidget extends StatelessWidget {
  const LandPageWidget({
    Key key,
    @required this.context,
    @required this.controller,
    this.imageName,
    this.content,
  }) : super(key: key);

  final BuildContext context;
  final PageController controller;
  final String imageName;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                'assets/images/$imageName.jpeg',
                fit: BoxFit.fitHeight,
              ),
            )),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.025,
        ),
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 0),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  kBoardingPage1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Red Hat Display',
                      fontSize: 14,
                      color: Color(0xFFFFFFFF)),
                ),
              ),
              NextButton(controller: controller)
            ])
      ],
    );
  }
}
