import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/pages/onboarding1.dart';
import 'package:ed_eureka/ui/pages/undefinedScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ed_eureka/routes/router.dart' as router;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';
import 'services/shared_prefs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

SharedPreferences prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeTheme();
  SharedPreferences.getInstance().then((prefs) async {
    runApp(
      RestartWidget(
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void getLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> secureScreen() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void initState() {
    getLoginStatus();
    //secureScreen();
    super.initState();
  }

  bool granted;

  getPermission() async {
    if (!kIsWeb) {
      granted = await LocalUserData.getPermission();
      if (granted == null) {
        var status = await Permission.storage.request();
        LocalUserData.savePermission(status == PermissionStatus.granted);
        getPermission();
      }
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var build = await deviceInfoPlugin.androidInfo;
      if (build.isPhysicalDevice) {
        granted = granted;
      } else {
        granted = null;
      }
    } else {
      granted = true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: router.generateRoute,
      onUnknownRoute: (settings) => CupertinoPageRoute(
        builder: (context) => UndefinedScreen(
          name: settings.name,
        ),
      ),
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: getPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return granted == true
                ? OnBoarding()
                : granted == false
                    ? Center(
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 5,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Column(
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.close),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 30, bottom: 25),
                                        child: Text(
                                          'Permission Needed',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ]),
                                Divider(
                                  thickness: 0.75,
                                  indent: 15,
                                  endIndent: 15,
                                  color: Colors.black,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 25,
                                    left: 25,
                                    right: 25,
                                  ),
                                  child: Text(
                                    'Storage Permission is needed to use our App',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    PermissionStatus status =
                                        await Permission.storage.request();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 20),
                                    child: Text('Ok'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  askPermission() async {
    await Permission.storage.request();
    //setState(() {});
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
