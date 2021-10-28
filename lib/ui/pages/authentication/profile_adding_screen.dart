import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/services/file_management.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/home.dart';
import 'package:ed_eureka/ui/widgets/network_error_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ProfileAddingScreen extends StatefulWidget {
  ProfileAddingScreen(
      {this.userName,
      this.email,
      this.phoneNumber,
      this.streamList,
      this.mediumList,
      this.subjectCollection});
  final userName;
  final email;
  final phoneNumber;
  final mediumList;
  final streamList;
  final subjectCollection;
  @override
  _ProfileAddingScreenState createState() => _ProfileAddingScreenState();
}

class _ProfileAddingScreenState extends State<ProfileAddingScreen> {
  File selectedImage;
  bool canShowUploadButton = false;
  String uploadButtonText = 'Upload';
  bool photoSelected = false;

  String selectedMedium = 'English';
  String selectedStream = 'Bio';
  bool notConnected = false;

  User loggedInUser = FirebaseAuth.instance.currentUser;

  uploadImage(List subjectList) async {
    setState(() {
      uploadButtonText = 'Uploading ...';
    });
    if (!kIsWeb) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var build = await deviceInfoPlugin.androidInfo;
      String id = build.androidId;
      loggedInUser.updatePhotoURL(id);
      await loggedInUser.reload();
    }

    final Reference _storageRef = FirebaseStorage.instance.ref().child(
        'User files/${loggedInUser.uid}/Profile Picture/${loggedInUser.uid}');

    if (selectedImage != null) {
      await _storageRef.putFile(selectedImage).whenComplete(() async {
        await _storageRef.getDownloadURL().then((value) {
          loggedInUser.updateDisplayName(widget.userName);
          FirebaseFirestore.instance
              .collection('User')
              .doc(loggedInUser.uid)
              .set({
            'email': widget.email,
            'userName': widget.userName,
            'uid': loggedInUser.uid,
            'imageName': loggedInUser.uid,
            'photoURL': photoSelected ? value : null,
            'userInfo': [selectedMedium, selectedStream],
            'phoneNumber': widget.phoneNumber,
            'subjectList': subjectList,
            'subscriptionList': ['Ed-Eureka'],
          });
        });
      });
    } else {
      loggedInUser.updateDisplayName(widget.userName);
      await FirebaseFirestore.instance
          .collection('User')
          .doc(loggedInUser.uid)
          .set({
        'userName': widget.userName,
        'email': widget.email,
        'uid': loggedInUser.uid,
        'imageName': loggedInUser.uid,
        'phoneNumber': widget.phoneNumber,
        'photoURL': null,
        'userInfo': [selectedMedium, selectedStream],
        'subjectList': subjectList,
        'subscriptionList': ['Ed-Eureka'],
      });
    }
    uploadButtonText = 'upload';
    canShowUploadButton = false;
  }

  DropdownButton dropDown(List dropList, String type) {
    List<DropdownMenuItem> dropdownList = [];
    for (String listItem in dropList) {
      var newItem = DropdownMenuItem(
        child: Text(
          listItem,
          style: TextStyle(color: Colors.white),
        ),
        value: listItem,
      );
      dropdownList.add(newItem);
    }
    return DropdownButton(
      dropdownColor: Colors.blueGrey,
      value: type == 'medium' ? selectedMedium : selectedStream,
      items: dropdownList,
      onChanged: (value) {
        type == 'medium' ? selectedMedium = value : selectedStream = value;
        setState(() {});
        selectedMedium != '' || selectedStream != ''
            ? canShowUploadButton = true
            : photoSelected
                ? canShowUploadButton = true
                : canShowUploadButton = false;
      },
    );
  }

  User user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    super.dispose();
  }

  String userName = '';
  String email = '';
  String updateURL = '';
  String updateName = '';
  String updateSubText = '';
  int minimumVersion = 0;
  int latestVersion = 0;

  Future getUser() async {
    await FirebaseFirestore.instance
        .collection('App Info')
        .doc('App Update')
        .get()
        .then((element) {
      updateURL = element['updateURL'];
      updateName = element['updateName'];
      updateSubText = element['updateSubText'];
      minimumVersion = element['minimumVersion'];
      latestVersion = element['latestVersion'];
    });
  }

  getSubjectList(selectedStream, selectedMedium) {
    return widget.subjectCollection['${selectedMedium}_$selectedStream'];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF000029),
              Color(0xFF0a0a46),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        Container(
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      selectedImage = await FileManagement.pickImage();
                      setState(() {
                        canShowUploadButton = true;
                        photoSelected = true;
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(10)),
                      child: selectedImage == null
                          ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add),
                                    Text('Add Your Profile Picture')
                                  ]),
                            )
                          : Image.file(
                              selectedImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.only(left: 50, right: 10),
                        child: Text(
                          'Language :',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      dropDown(widget.mediumList, 'medium'),
                    ]),
                  ),
                  Row(children: [
                    Container(
                      padding: EdgeInsets.only(left: 50, right: 25),
                      child: Text(
                        'Stream :',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    dropDown(widget.streamList, 'stream'),
                  ]),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: () async {
                          List selectedSubjectList = await getSubjectList(
                              selectedStream, selectedMedium);
                          if (canShowUploadButton) {
                            await uploadImage(selectedSubjectList);
                          } else {
                            await uploadImage(selectedSubjectList);
                          }
                          await getUser();
                          if (latestVersion != null) {
                            Map userDetails = {
                              'updateURL': updateURL,
                              'updateName': updateName,
                              'updateSubText': updateSubText,
                              'latestVersion': latestVersion,
                              'minimumVersion': minimumVersion,
                            };
                            LocalUserData.saveLoggedInKey(true);
                            LocalUserData.saveUserNameKey(userName);
                            LocalUserData.saveUserUidKey(loggedInUser.uid);
                            await loggedInUser.reload();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          } else {
                            notConnected = true;
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue[900],
                          ),
                          child: Center(
                              child: Text(
                            canShowUploadButton ? uploadButtonText : 'Skip',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                  )
                ]),
          ),
        ),
        NotConnectedAlert(notConnected: notConnected),
      ]),
    );
  }
}
