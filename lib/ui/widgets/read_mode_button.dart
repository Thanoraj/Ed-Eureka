import 'package:ed_eureka/constants.dart';
import 'package:flutter/material.dart';

class ReadModeButton extends StatefulWidget {
  @override
  _ReadModeButtonState createState() => _ReadModeButtonState();
  ReadModeButton({
    @required this.onTap,
  });
  final Function onTap;
}

class _ReadModeButtonState extends State<ReadModeButton>
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
    super.dispose();
    _controller.dispose();
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Positioned(
      top: MediaQuery.of(context).size.height - 300,
      left: MediaQuery.of(context).size.width - 100,
      child: Container(
        padding: EdgeInsets.only(right: 20, top: 30),
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _tapDown,
          onTapUp: _tapUp,
          child: Transform.scale(
            scale: _scale,
            child: Material(
              elevation: 7,
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: kBlue600Green600,
                        size: 30,
                      ),
                      Container(
                        child: Text(
                          'Refer Book',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: kBlue600Green600, fontSize: 8),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
