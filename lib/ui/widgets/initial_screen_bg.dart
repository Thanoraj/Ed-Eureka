import 'package:flutter/material.dart';

class InitialScreenBackGround extends StatelessWidget {
  const InitialScreenBackGround({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF000029),
          Color(0xff0a0a46),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    );
  }
}
