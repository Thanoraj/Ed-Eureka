import 'package:ed_eureka/constants.dart';
import 'package:flutter/material.dart';

class BottomBarButton extends StatefulWidget {
  BottomBarButton({this.icon, this.text, this.onTap, this.state});
  final icon;
  final text;
  final onTap;
  final state;

  @override
  _BottomBarButtonState createState() => _BottomBarButtonState();
}

class _BottomBarButtonState extends State<BottomBarButton>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  bool pressing = false;
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

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
      ),
      width: 80,
      height: 80,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: Colors.blue[900],
        borderRadius: BorderRadius.circular(40),
        onTap: () {},
        child: GestureDetector(
          onTap: widget.state == 'active' ? widget.onTap : () {},
          onTapDown: _tapDown,
          onTapUp: _tapUp,
          child: Transform.scale(
            scale: _scale,
            child: Container(
              height: 80,
              width: 80,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(40)),
              padding: EdgeInsets.all(15),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: pressing ? Colors.white : Colors.transparent,
                  border: Border.all(
                    color: kBlue900Green,
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(widget.icon,
                    size: 30,
                    color: pressing
                        ? Colors.black
                        : widget.state == 'active'
                            ? kBlue900Green
                            : Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
