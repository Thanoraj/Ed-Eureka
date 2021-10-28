import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:flutter/material.dart';

class QuestionNavigationButton extends StatefulWidget {
  QuestionNavigationButton(
      {@required this.buttonText,
      this.colour,
      @required this.onTap,
      @required this.long});
  final buttonText;
  final colour;
  final onTap;
  final bool long;

  @override
  _QuestionNavigationButtonState createState() =>
      _QuestionNavigationButtonState();
}

class _QuestionNavigationButtonState extends State<QuestionNavigationButton>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 10,
      ),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, right: 20),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _tapDown,
        onTapUp: _tapUp,
        child: Transform.scale(
          scale: _scale,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 10,
            child: Container(
              width: 120,
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Text(
                widget.buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kBlackGreen600,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              )),
              decoration: BoxDecoration(
                gradient: ColorTheme().waves,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
