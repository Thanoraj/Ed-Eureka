import 'package:ed_eureka/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 0),
      alignment: Alignment.topCenter,
      child: CupertinoButton(
        child: Icon(
          BoxIcons.bx_chevron_right,
          color: Color(0xFFFFFFFF),
          size: 30,
        ),
        onPressed: () {
          controller.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        },
      ),
    );
  }
}
