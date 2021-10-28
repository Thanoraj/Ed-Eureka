import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/widgets/stopwatch_timer.dart';
import 'package:ed_eureka/ui/widgets/water_marker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebViewExample extends StatefulWidget {
  final link;
  final waterMarkerNeeded;
  final attempts;
  final duration;
  final startTime;
  final endTime;
  WebViewExample(
      {this.link,
      this.waterMarkerNeeded,
      this.attempts,
      this.duration,
      this.startTime,
      this.endTime});
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController _webViewController;
  User loggedInUser = FirebaseAuth.instance.currentUser;
  Timer timer;

  @override
  void initState() {
    super.initState();
    UserManagement.checkUser(context);
    if (!kIsWeb) {
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    }

    checkExam();
  }

  bool startExam = false;

  checkExam() {
    timer = Timer.periodic(
      Duration(seconds: 1),
      (_) {
        if (DateTime.now().isAfter(DateTime.parse(widget.startTime)) &&
            !DateTime.now().isAfter(DateTime.parse(widget.endTime)) &&
            widget.attempts[widget.link]['timeRemaining'] >= 2) {
          startExam = true;
          timer.cancel();
          if (mounted) setState(() {});
        } else {}
      },
    );
  }

  @override
  void dispose() {
    timer.isActive ? timer.cancel() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTopBarColor,
        title: const Text(''),
        actions: [
          Visibility(
            visible: startExam,
            child: StopWatchTimer(
              endTime: widget.endTime,
              link: widget.link,
              attempts: widget.attempts,
              duration: widget.duration,
              func: () {
                startExam = false;
                setState(() {});
              },
            ),
          )
        ],
      ),
      body: Stack(children: [
        Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: widget.link,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) async {
              _webViewController = webViewController;
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            onPageStarted: (url) async {},
            gestureNavigationEnabled: true,
            /* gestureRecognizers: Set()..add(Factory < VerticalDragGestureRecognizer > (
                    () => VerticalDragGestureRecognizer()))..add(Factory < ScaleGestureRecognizer > (
                    () => ScaleGestureRecognizer())), ))*/
          );
        }),
        Visibility(
            visible: widget.waterMarkerNeeded == true ? true : false,
            child: WaterMarker(loggedInUser: loggedInUser)),
        Visibility(
            visible: !startExam,
            child: Container(
              color: Colors.black45,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )),
      ]),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          UserManagement.checkUser(context);
        });
  }
}
