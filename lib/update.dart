import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';

class Update extends StatefulWidget {
  final subjectCollection;
  Update({this.subjectCollection});

  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  TextEditingController uidController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    //getQuestions();
    //updateLastQuestion();
    //screenShots();
    super.initState();
    //addSubtopic();
  }

  // addSubtopic() async {
  //   await _firestore.collection('Papers').doc('Ed-Eureka').collection('பௌதிகவியல்_18-08-2021 8 pm').where('Question Number', )
  // }

  screenShots() async {
    Map details = {};
    await _firestore
        .collection('ScreenShotEvents')
        .doc('ScreenShots')
        .get()
        .then((value) {
      details = value.data();
    });
    List newList = [];
    details.forEach((key1, value) {
      value.forEach((key2, value2) {
        newList.add({
          'time': key1,
          'uid': value2[0],
          'email': value2[1],
          'device': value2[2],
        });
      });
    });
    _firestore
        .collection('ScreenShotEvents')
        .doc('modified')
        .set({'data': newList});
  }

  addSubscription() async {
    await _firestore.collection('User').get().then((value) async {
      value.docs.forEach((element) async {
        await _firestore.collection('User').doc(element['uid']).update({
          'subscriptionList': [
            {
              'batch': '21 tamil',
              'medium': 'tamil',
              'name': 'Kugan Sir',
              'fees': 'paid',
              'subject': 'Physics'
            },
          ],
          'recommended': [],
          'revision': [],
        });
      });
    });
  }

  Future<List> postRequest(String question) async {
    http.Response response = await http.post(
      Uri.parse('http://52.14.106.14:8080/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {"file": 'p1. $question'},
      ),
    );

    if (response.statusCode == 200) {
      String data = response.body;
      List decodedData = jsonDecode(data);
      return decodedData;
    } else {}
  }

  generateExplanation() async {
    for (Map questionData in questionList) {
      //if (questionData['Question'] != ''
      //&& questionData['keyWords'].length == 0
      //) {
      List response = await postRequest(questionData['Question']);
      List<String> keyWords = [];
      for (var value in response[0]) {
        keyWords.add(value.toString());
      }
      response[1].insert(0, 'available');
      questionData['Explanation'] = response[1];
      questionData['keyWords'] = keyWords;
      questionData['CorrectKeyWords'] = response[2];
      _firestore
          .collection('Subjects')
          .doc('Physics')
          .collection('Mechanical Properties of Matter_Model Paper')
          .doc('QuestionNumber_${questionData['Question Number'].toString()}')
          .set({
        'Question Number': int.parse(questionData['Question Number']),
        'Question': questionData['Question'],
        'Answers': questionData['Answers'],
        'Correct Answer': questionData['Correct Answer'],
        'Explanation': questionData['Explanation'],
        'Link': questionData['Link'],
        'Image': questionData['Image'],
        'KeyWords': keyWords,
        'CorrectKeyWords': response[2],
      });
      // }
    }
  }

  List questionList = [];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /*List subjectList = [
    'சடமும் கதிர்ப்பும்',
    'சடத்தின் பொறியியல் இயல்புகள்',
    'இலத்திரனியல்',
    'ஓட்டமின்னியல்',
    'காந்தப்புலம்',
    'நிலைமின்புலம்',
    'ஈர்ப்புப்புலம்',
    'வெப்பப் பௌதிகவியல்',
    'அலைவுகளும் அலைகளும்',
    'பொறியியல்',
    'அளவீடு',
  ];*/

  List subjectList = [
    'Applied Biology',
    'Micro Biology',
    'Environmental Biology',
    'Molecular Biology and Recombinant DNA Technology',
    'Genetics',
    'Animal form and function',
    'Plant form and function',
    'Evolution and Diversity of Organisms',
    'Chemical and Cellular Basis of Life',
    'Introduction to Biology'
  ];

  /*List subjectList = [
    'Industrial Chemistry',
    'Gases',
    'Environmental Chemistry',
    'Physical Chemistry',
    'Organic Chemistry',
    'Inorganic Chemistry',
    'Thermo Chemistry',
    'Basic Chemistry',
    'General Chemistry'
  ];*/

  /*List subjectList = [
    'Matter and Radiation',
    'Mechanical Properties of Matter',
    'Electronics',
    'Current Electricity',
    'Magnetic Field',
    'Electric Field',
    'Gravitational Field',
    'Thermal Physics',
    'Oscillation and waves',
    'Mechanics',
    'Measurement',
  ];*/

  /*List subjectList = [
    'சூழல் இரசாயனம்',
    'கைத்தொழில் இரசாயனம்',
    'சமநிலை இரசாயனம்',
    'சேதன இரசாயனம்',
    'அசேதன இரசாயனம்',
    'சடப்பொருளின் வாயுநிலை',
    'சக்தியியல் இரசாயனம்',
    'அடிப்படை இரசாயனம்',
    'அணுக் கட்டமைப்பு',
  ];*/
  getQuestions() async {
    for (var item in subjectList) {
      questionList = [];
      await _firestore
          .collection('Subjects')
          .doc('பௌதிகவியல்')
          .collection('${item}_Past Paper')
          .orderBy('Question Number')
          .get()
          .then(
            (querySnapshots) => {
              querySnapshots.docs.forEach(
                (element) {
                  questionList.add({
                    'Question Number': element['Question Number'],
                    'Question': element['Question'],
                    'Answers': element['Answers'],
                    'Correct Answer': element['Correct Answer'],
                    'Explanation': element['Explanation'],
                    'Link': element['Link'],
                    'Image': element['Image'],
                    'keyWords': element['KeyWords'],
                    'CorrectKeyWords': element['CorrectKeyWords'],
                  });
                },
              ),
            },
          );
      int i = 1;
      for (Map questionData in questionList) {
        if (questionData['Question'] != '') {
          await _firestore
              .collection('Subjects')
              .doc('பௌதிகவியல்')
              .collection('${item}_Past Paper')
              .doc('QuestionNumber_${i.toString()}')
              .set({
            'Question Number': i,
            'Question': questionData['Question'],
            'Answers': questionData['Answers'],
            'Correct Answer': questionData['Correct Answer'],
            'Explanation': questionData['Explanation'],
            'Link': questionData['Link'],
            'Image': questionData['Image'],
            'KeyWords': questionData['keyWords'],
            'CorrectKeyWords': questionData['CorrectKeyWords'],
          });
          i++;
        }
      }
    }
  }

  updateLastQuestion() async {
    Map lastQuestion = {};
    for (String subtopic in subjectList) {
      var lastQuestionNumber;
      await _firestore
          .collection('Subjects')
          .doc('Biology')
          .collection('${subtopic}_Model Paper')
          .orderBy('Question Number')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          if (element['Question'] != '') {
            lastQuestionNumber = element['Question Number'];
          }
        });
      });
      lastQuestion[subtopic] =
          lastQuestionNumber == null ? 0 : lastQuestionNumber;
      lastQuestionNumber = null;
    }
    _firestore
        .collection('Subjects')
        .doc('Biology')
        .update({'modelLastQuestion': lastQuestion});
  }

  getSubjectList(selectedStream, selectedMedium) {
    return widget.subjectCollection['${selectedMedium}_$selectedStream'];
  }

  getUserInfo() async {
    List selectedSubjectList =
        await getSubjectList(selectedStream, selectedMedium);
    await FirebaseFirestore.instance.collection("User").doc(uid).set({
      'imageName': uidController.text.trim(),
      'userName': userNameController.text.trim(),
      'phoneNumber': '+94${phoneController.text.trim()}',
      'uid': uidController.text.trim(),
      'photoURL': null,
      'subjectList': selectedSubjectList,
      'userInfo': [selectedMedium, selectedStream],
      'email': emailController.text.trim(),
    }).catchError((e) {});
    uidController.clear();
    emailController.clear();
    phoneController.clear();
    userNameController.clear();
  }

  String email;
  String uid;
  String userName;
  String phoneNumber;
  String selectedMedium = 'தமிழ்';
  String selectedStream = 'Bio';

  DropdownButton dropDown(List dropList, String type) {
    List<DropdownMenuItem> dropdownList = [];
    /*type == 'medium'
        ? dropList = ['Tamil', 'English']
        : dropList = ['Maths', 'Bio'];*/
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Material(
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: uidController,
                onChanged: (val) {
                  uid = val;
                },
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'uid',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),
              TextField(
                controller: emailController,
                onChanged: (val) {
                  email = val;
                },
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),
              TextField(
                controller: userNameController,
                onChanged: (val) {
                  userName = val;
                },
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'userName',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),
              TextField(
                controller: phoneController,
                onChanged: (val) {
                  phoneNumber = val;
                },
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'phoneNumber',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),
              dropDown(['Maths', 'Bio'], 'stream'),
              dropDown(['தமிழ்', 'English'], 'medium'),
              ElevatedButton(
                  onPressed: () {
                    getUserInfo();
                  },
                  child: Text('submit'))
              /*TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Medium',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Stream',
                    hintStyle: TextStyle(color: Colors.white54)),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

/*void main() {
  // Extending Equatable
  const credentialsA = Credentials(username: 'Joe', password: 'password123');
  const credentialsB = Credentials(username: 'Bob', password: 'password!');
  const credentialsC = Credentials(username: 'Bob', password: 'password!');

  print(credentialsA == credentialsA); // true
  print(credentialsB == credentialsB); // true
  print(credentialsC == credentialsC); // true
  print(credentialsA == credentialsB); // false
  print(credentialsB == credentialsC); // true
  print(credentialsA.toString()); // Credentials

  // Equatable Mixin
  final dateTimeA = EquatableDateTime(2019);
  final dateTimeB = EquatableDateTime(2019, 2, 20, 19, 46);
  final dateTimeC = EquatableDateTime(2019, 2, 20, 19, 46);

  print(dateTimeA == dateTimeA); // true
  print(dateTimeB == dateTimeB); // true
  print(dateTimeC == dateTimeC); // true
  print(dateTimeA == dateTimeB); // false
  print(dateTimeB == dateTimeC); // true
  print(dateTimeA.toString()); // EquatableDateTime(2019, 1, 1, 0, 0, 0, 0, 0)
}*/
