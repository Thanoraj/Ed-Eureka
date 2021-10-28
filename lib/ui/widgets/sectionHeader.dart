import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    Key key,
    @required this.text,
    @required this.onPressed,
    this.isNeeded,
    this.leading,
    this.color,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final isNeeded;
  final leading;
  final color;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        leading == 'yes'
            ? CupertinoButton(
                child: Icon(BoxIcons.bx_chevron_left,
                    color: kSectionHeaderArrowColor),
                onPressed: onPressed,
              )
            : SizedBox(),
        Container(
          height: 20,
          width: 4,
          margin: EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(500), color: kBlue300Grey800),
        ),
        Text(
          text,
          style: TextStyle().copyWith(
            fontSize: text.contains(
              'காணொளிகள்',
            )
                ? 13
                : 15.0,
            fontWeight: FontWeight.bold,
            color: color ?? kBlackGreen600white,
          ),
        ),
        Spacer(),
        CupertinoButton(
          child: isNeeded == 'No'
              ? SizedBox()
              : Icon(BoxIcons.bx_chevron_right,
                  color: kSectionHeaderArrowColor),
          onPressed: onPressed,
        )
      ],
    );
  }
}
