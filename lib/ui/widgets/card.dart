import 'package:ed_eureka/constants.dart';
import 'package:flutter/cupertino.dart';

import 'package:ed_eureka/theme/config.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final bool gradient;
  final bool button;
  final Color color;
  final double width;
  final double height;
  final Widget child;
  final int duration;
  final Border border;
  final func;
  CardWidget({
    @required this.gradient,
    @required this.button,
    this.color,
    this.width,
    this.height,
    @required this.child,
    this.duration,
    @required this.func,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      shadowColor: kCardElevationColor,
      borderRadius: BorderRadius.circular(10.25),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                blurRadius: 10,
                color: kUpdateTextColor.withOpacity(0.4),
                offset: Offset(0, 4))
          ],
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: duration ?? 500),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: kBodyFull,
              gradient: gradient
                  ? ColorTheme().waves
                  : LinearGradient(colors: [
                      color ?? ColorTheme().mainColor(1),
                      color ?? ColorTheme().mainColor(1)
                    ]),
            ),
            child: button
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      child: child,
                      onPressed: func,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}
