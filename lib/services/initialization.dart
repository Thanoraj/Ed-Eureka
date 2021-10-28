import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'shared_prefs.dart';

class Initialize {
  static countryCodeGenerator() async {
    List countriesList = [];
    await FirebaseFirestore.instance
        .collection('App Info')
        .doc('Country Code')
        .get()
        .then((value) {
      countriesList = value['countryCode'];
    });
    return countriesList;
  }

  static myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  static getUpdateInfo() async {
    var currentTime = DateTime.now();
    String lastDate = await LocalUserData.getLastDate('update');
    Map updateInfo;
    if (lastDate == null ||
        lastDate == '' ||
        currentTime.difference(DateTime.parse(jsonDecode(lastDate))).inDays >
            1) {
      await FirebaseFirestore.instance
          .collection('App Info')
          .doc('App Update')
          .get()
          .then((element) {
        updateInfo = {
          'updateURL': element['updateURL'],
          'updateName': element['updateName'],
          'updateSubText': element['updateSubText'],
          'minimumVersion': element['minimumVersion'],
          'latestVersion': element['latestVersion'],
        };
      });
      LocalUserData.saveUpdateInfo('updateInfo', jsonEncode(updateInfo));
      LocalUserData.saveLastDate(
          'update', jsonEncode(DateTime.now(), toEncodable: myEncode));
    }
  }

  static getSelectionInfo() async {
    Map selectionDetails = {};
    await FirebaseFirestore.instance
        .collection('App Info')
        .doc('selectionDetails')
        .get()
        .then((value) {
      selectionDetails = {
        'mediumsList': value['mediumList'],
        'streamsList': value['StreamList'],
        'subjectsCollection': value['subjectsCollection'],
      };
    });
    return selectionDetails;
  }
}
