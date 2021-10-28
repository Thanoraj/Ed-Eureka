import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'water_marker_text.dart';

class WaterMarker extends StatelessWidget {
  const WaterMarker({
    Key key,
    @required this.loggedInUser,
  }) : super(key: key);

  final User loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MediaQuery.of(context).orientation == Orientation.portrait
          ? Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              WaterMarkText(loggedInUser: loggedInUser),
              WaterMarkText(loggedInUser: loggedInUser),
              WaterMarkText(loggedInUser: loggedInUser),
            ])
          : Center(
              child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WaterMarkText(loggedInUser: loggedInUser),
                    WaterMarkText(loggedInUser: loggedInUser),
                    WaterMarkText(loggedInUser: loggedInUser),
                  ]),
            ),
    );
  }
}
