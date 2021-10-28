import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/widgets/continue_button.dart';
import 'package:ed_eureka/ui/widgets/initial_screen_bg.dart';
import 'package:ed_eureka/ui/widgets/landing_page_widget.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/user_management.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController controller = PageController(initialPage: 2);
  int pageNumber;
  List widgets = [];
  bool notConnected = false;

  @override
  void initState() {
    pageNumber = 0;
    super.initState();
    UserManagement.checkUser(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void createWidgets() {
    widgets.addAll([
      LandPageWidget(
        context: context,
        controller: controller,
        imageName: '5',
        content: kBoardingPage1,
      ),
      LandPageWidget(
        context: context,
        controller: controller,
        imageName: '6',
        content: kBoardingPage2,
      ),
      SafeArea(
        child: Stack(alignment: Alignment.center, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 150,
                  height: 150,
                  child: Image.asset('assets/images/logo2.png'),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  kAppName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Red Hat Display',
                      fontSize: 28,
                      color: Color(0xFFFFFFFF)),
                ),
              ),
              Container(
                child: Text(
                  'A learning tool for your mind...',
                  style: TextStyle(
                      fontFamily: "DancingScript",
                      color: Colors.white,
                      fontSize: 15),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: 200,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              ContinueButton(
                callBack: (val) {
                  notConnected = val;
                  setState(() {});
                },
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              child: Row(children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/images/logo.png'),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        'Powered By :',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: Text(
                        'Eureka Innovations',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    createWidgets();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          InitialScreenBackGround(),
          Align(
            alignment: Alignment.center,
            child: PageView.builder(
                controller: controller,
                onPageChanged: (value) {
                  setState(() {
                    pageNumber = value;
                  });
                },
                itemCount: 3,
                itemBuilder: (context, index) => widgets[index]),
          ),
          NotConnectedAlert(notConnected: notConnected),
        ],
      ),
    );
  }
}
