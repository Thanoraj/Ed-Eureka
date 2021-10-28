import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/onboarding1.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserManagement {
  static checkUser(context) async {
    if (!kIsWeb) {
      User loggedInUser = FirebaseAuth.instance.currentUser;
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var build = await deviceInfoPlugin.androidInfo;
      String id = build.androidId;
      String deviceId;
      if (loggedInUser != null) {
        deviceId = loggedInUser.photoURL;
        if (deviceId != id) {
          return SignOutEvent();
        }
      }
    }
  }

  static signOut(context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    await LocalUserData.saveLoggedInKey(false);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => OnBoarding()),
        (Route<dynamic> route) => false);
  }
}
