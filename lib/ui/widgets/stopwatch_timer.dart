import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/services/check_user.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StopWatchTimer extends StatefulWidget {
  final duration;
  final attempts;
  final func;
  final link;
  final endTime;
  StopWatchTimer(
      {this.duration, this.func, this.link, this.attempts, this.endTime});
  @override
  _StopWatchTimerState createState() => _StopWatchTimerState();
}

class _StopWatchTimerState extends State<StopWatchTimer> {
  //static var countdownDuration;
  Duration duration;
  Timer timer;
  bool countDown = true;
  Map attempts;

  @override
  void initState() {
    var difference2 =
        -DateTime.now().difference(DateTime.parse(widget.endTime));
    duration = Duration(seconds: widget.attempts[widget.link]['timeRemaining']);
    if (widget.attempts[widget.link]['lastTime'].length != 0) {
      var difference = DateTime.now()
          .difference(DateTime.parse(widget.attempts[widget.link]['lastTime']));
      duration = Duration(seconds: duration.inSeconds - difference.inSeconds);
    } else {
      var difference2 =
          -DateTime.now().difference(DateTime.parse(widget.endTime));
      duration =
          duration.inSeconds > difference2.inSeconds ? difference2 : duration;
    }
    super.initState();
    startTimer();
    //reset();
  }

  @override
  void dispose() async {
    timer.isActive ? timer.cancel() : null;
    UserManagement.checkUser(context);
    var date = DateTime.now().toString();
    widget.attempts[widget.link]['attempts']++;
    widget.attempts[widget.link]['timeRemaining'] = duration.inSeconds;
    widget.attempts[widget.link]['lastTime'] = date;
    LocalUserData.saveAttemptTimes(jsonEncode(widget.attempts));
    User loggedInUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('User').doc(loggedInUser.uid).update({
      'attempts': widget.attempts,
    });
    super.dispose();
  }

  DateTime time;
  DateTime time2;
  var difference = 0;
  var elapsed = 0;
  var oldDuration = 0;
  void startTimer() async {
    time = DateTime.now();
    timer = Timer.periodic(Duration(milliseconds: 500), (_) => addTime());
  }

  void addTime() async {
    time2 = DateTime.now();
    elapsed = time.difference(time2).inMilliseconds - difference;
    difference = time.difference(time2).inMilliseconds;
    final addSeconds = countDown ? elapsed : 1;
    final seconds = duration.inMilliseconds + addSeconds;
    if (seconds > 0) {
      duration = Duration(milliseconds: seconds);
      if (oldDuration != duration.inSeconds) {
        setState(() {});
      }
      oldDuration = duration.inMilliseconds;
    } else {
      widget.func();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: buildTime(),
        ),
      );

  String hours;
  String minutes;
  String seconds;

  buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    hours = twoDigits(duration.inHours);
    minutes = twoDigits(duration.inMinutes.remainder(60));
    seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours == '00' && minutes == '00' && seconds == '00') {
      timer.cancel();
      widget.func();
    } else {
      return Text(
        hours + ':' + minutes + ':' + seconds,
        style: TextStyle(
            fontSize: 17,
            color: int.parse(hours) < 1 && int.parse(minutes) < 5
                ? Colors.red
                : Colors.white),
      );
    }
  }
}
