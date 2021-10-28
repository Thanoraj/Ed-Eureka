import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/onboarding1.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserManagement {
  static checkUser(context) async {
    if (!kIsWeb) {
      User loggedInUser = FirebaseAuth.instance.currentUser;
      if (loggedInUser != null) {
        await loggedInUser.reload();
      }
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var build = await deviceInfoPlugin.androidInfo;
      String id = build.androidId;
      String deviceId;
      if (loggedInUser != null) {
        deviceId = loggedInUser.photoURL;
        if (deviceId != id && deviceId != null) {
          await signOut(context);
          try {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignOutEvent()));
          } catch (e) {}
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

  static uploadUserImage(File selectedImage) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    if (selectedImage != null) {
      final Reference _storageRef = FirebaseStorage.instance.ref().child(
          'User files/${_auth.currentUser.uid}/Profile Picture/${_auth.currentUser.uid}');
      await _storageRef.putFile(selectedImage).whenComplete(() async {
        await _storageRef.getDownloadURL().then((value) {
          FirebaseFirestore.instance
              .collection('User')
              .doc(_auth.currentUser.uid)
              .update({
            'imageName': _auth.currentUser.uid,
            'photoURL': value,
          });
        });
      });
    } else {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(_auth.currentUser.uid)
          .set({
        'imageName': _auth.currentUser.uid,
        'photoURL': null,
      });
    }
  }
}
