import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WaterMarkText extends StatelessWidget {
  const WaterMarkText({
    Key key,
    @required this.loggedInUser,
  }) : super(key: key);

  final User loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      height: MediaQuery.of(context).size.height / 4,
      child: Transform.rotate(
        angle: MediaQuery.of(context).orientation == Orientation.portrait
            ? pi / 6
            : pi / 4,
        child: Text(
          loggedInUser.email.toString(),
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black38,
            shadows: [
              Shadow(
                  // bottomLeft
                  offset: Offset(-0.2, -0.2),
                  color: Colors.white54),
              Shadow(
                  // bottomRight
                  offset: Offset(0.2, -0.2),
                  color: Colors.white54),
              Shadow(
                  // topRight
                  offset: Offset(0.2, 0.2),
                  color: Colors.white54),
              Shadow(
                  // topLeft
                  offset: Offset(-0.2, 0.2),
                  color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
