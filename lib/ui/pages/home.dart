import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/home_page.dart';
import 'package:ed_eureka/ui/widgets/overlay.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/ui/pages/leaderboard.dart';
import 'package:ed_eureka/ui/pages/planner.dart';
import 'package:ed_eureka/ui/pages/videos.dart';
import 'package:ed_eureka/ui/widgets/topBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Home extends StatefulWidget {
  final onMenuTap;

  Home({
    this.onMenuTap,
  });
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool overlayVisible;
  TabController _tabController;
  bool showTopBar = true;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  ScreenshotCallback screenshotCallback;
  bool forcedRefresh = false;
  @override
  void initState() {
    super.initState();
    overlayVisible = false;
    _tabController = new TabController(vsync: this, length: 5);

    checkUpdate();
    if (!kIsWeb) {
      screenshotCallback = ScreenshotCallback();
      screenshotCallback.addListener(() async {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        var build = await deviceInfoPlugin.androidInfo;
        FirebaseFirestore.instance
            .collection('ScreenShotEvents')
            .doc('ScreenShots')
            .update({
          DateTime.now().toString(): [
            loggedInUSer.uid,
            loggedInUSer.email,
            build.model
          ],
        });
      });
    }
  }

  resetData() async {
    await LocalUserData.saveRevisionLectures([]);
    await LocalUserData.saveRecommendedLectures([]);
    await LocalUserData.saveRevisionSubjects('');
    await LocalUserData.saveRecommendedSubjects('');
    await LocalUserData.saveSubscriptions('');
    await LocalUserData.saveAttemptTimes('');
  }

  @override
  void dispose() {
    _tabController.dispose();
    resetData();
    screenshotCallback.dispose();
    super.dispose();
  }

  List userInfo;
  List subjectList;
  List recommendedSubjects;
  List revisionSubjects;
  List subscriptionList;
  DateTime time;

  Future getUser() async {
    User loggedInUser = FirebaseAuth.instance.currentUser;
    await _fireStore.collection('User').doc(loggedInUser.uid).get().then(
      (element) {
        userInfo = element['userInfo'];
        subjectList = element['subjectList'];
        recommendedSubjects = element['recommended'];
        revisionSubjects = element['revision'];
        subscriptionList = element['subscriptionList'];
      },
    ).catchError((e) {
      recommendedSubjects = recommendedSubjects;
      revisionSubjects = revisionSubjects;
      subscriptionList = subscriptionList;
    });

    setState(() {});
  }

  List recommendedLecturesList = [];
  List revisionVideoList = [];

  Map updateInfo;
  int currentVersion = 7;
  bool showUpdate = false;
  bool enableCancel = true;
  checkUpdate() async {
    updateInfo =
        await jsonDecode(await LocalUserData.getUpdateInfo('updateInfo'));
    if (updateInfo != null && currentVersion < updateInfo['latestVersion']) {
      showUpdate = true;
      updateURL = updateInfo['updateURL'];
      updateInfo['updateURL'] = '';
      currentVersion < updateInfo['minimumVersion']
          ? enableCancel = false
          : enableCancel = true;
      setState(() {});
    }
  }

  List zoomLectures = [];
  List examList = [];

  String updateURL;
  String updateName;
  String updateSubText;
  User loggedInUSer = FirebaseAuth.instance.currentUser;
  TextEditingController controller = TextEditingController();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        if (_tabController.index == 0) {
          _tabController.dispose();
          await resetData();
          screenshotCallback.dispose();
          SystemNavigator.pop();
        } else {
          _tabController.animateTo(0);
          currentPageIndex = 0;
          setState(() {});
        }
      },
      child: Material(
        color: kHomeMaterialColor,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            DefaultTabController(
              initialIndex: 0,
              length: 5,
              child: Scaffold(
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    HomePage(
                      time: time,
                      forcedRefresh: forcedRefresh,
                      userDetails: updateInfo,
                      onMenuTap: widget.onMenuTap,
                      callBack: () {
                        forcedRefresh = false;
                      },
                    ),
                    PlanerPage(
                      onMenuTap: widget.onMenuTap,
                      userDetails: updateInfo,
                    ),
                    Container(
                      color: kBodyFull,
                    ),
                    VideosPage(
                      onMenuTap: widget.onMenuTap,
                      userDetails: updateInfo,
                    ),
                    LeaderboardPage(
                      onMenuTap: widget.onMenuTap,
                    ),
                  ],
                ),
                bottomNavigationBar: BottomAppBar(
                  color: kBottomAppBarColor,
                  child: TabBar(
                    indicatorColor: kBottomBarIconColors,
                    labelColor: kBottomBarIconColors,
                    onTap: (val) {
                      currentPageIndex = val;
                      setState(() {});
                    },
                    isScrollable: false,
                    controller: _tabController,
                    tabs: [
                      BottomBarTab(
                        name: 'Home',
                        icon: BoxIcons.bx_home_circle,
                      ),
                      BottomBarTab(
                        name: 'Planner',
                        icon: Icons.bar_chart,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      BottomBarTab(
                        name: 'Videos',
                        icon: BoxIcons.bxs_videos,
                      ),
                      BottomBarTab(
                        name: 'Leader Board',
                        icon: BoxIcons.bx_stats,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            overlayVisible ? OverlayWidget() : Container(),
            Positioned(
                bottom: 20,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff3c3072),
                      //gradient: ColorTheme().waves,
                      /*boxShadow: [
                        BoxShadow(
                            blurRadius: 25,
                            color: kRemainderButtonShadow.withOpacity(0.4),
                            offset: Offset(0, 4))
                      ],*/
                      borderRadius: BorderRadius.circular(500)),
                  child: FloatingActionButton(
                      elevation: 0,
                      highlightElevation: 0,
                      backgroundColor: Color(0xff3c3072),
                      child: overlayVisible
                          ? Icon(
                              Icons.close,
                              color: kCardElevationColor,
                            )
                          : Icon(
                              BoxIcons.bx_pencil,
                              size: 25,
                              color: kCardElevationColor,
                            ),
                      onPressed: () {
                        setState(() {
                          showTopBar = !showTopBar;
                          overlayVisible = !overlayVisible;
                        });
                      }),
                )),
            Visibility(
              visible: showTopBar,
              child: Positioned(
                top: 0,
                child: TopBar(
                  callBack: () {
                    setState(() {
                      forcedRefresh = true;
                      time = DateTime.now();
                    });
                  },
                  controller: controller,
                  expanded: currentPageIndex == 0,
                  onMenuTap: widget.onMenuTap,
                ),
              ),
            ),
            Visibility(
              visible: showUpdate,
              child: AlertDialog(
                title: Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 50, bottom: 20),
                    child: Text(
                      updateInfo != null ? updateInfo['updateName'] : '',
                    ),
                  ),
                ),
                content: Text(
                  updateInfo != null ? updateInfo['updateSubText'] : '',
                ),
                actions: [
                  Visibility(
                    visible: enableCancel,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () {
                          showUpdate = false;
                          setState(() {});
                        },
                        child: Text('Later'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          launch(updateURL);
                        });
                      },
                      child: Text('Update Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBarTab extends StatelessWidget {
  BottomBarTab({@required this.name, @required this.icon});
  final name;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        child: Icon(icon),
      ),
    );
  }
}
