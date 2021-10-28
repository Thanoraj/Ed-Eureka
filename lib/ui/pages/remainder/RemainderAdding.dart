import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ed_eureka/theme/config.dart' as config;

class RemainderAddingScreen extends StatefulWidget {
  final Function callBack;
  RemainderAddingScreen({@required this.callBack});

  @override
  _RemainderAddingScreenState createState() => _RemainderAddingScreenState();
}

class _RemainderAddingScreenState extends State<RemainderAddingScreen> {
  TextEditingController remainderTitleTextController = TextEditingController();
  TextEditingController remainderContentTextController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  List dateList = [];
  List monthList = [];
  List yearList = [];
  String selectedDate;
  String selectedMonth;
  String selectedYear;
  String remainderTitle;
  String remainderContent;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  User loggedInUser = FirebaseAuth.instance.currentUser;
  bool isAdding = false;

  @override
  void initState() {
    UserManagement.checkUser(context);
    super.initState();
    listGenerator();
  }

  listGenerator() {
    for (int i = 1; i < 32; i++) {
      dateList.add(i.toString());
    }
    monthList = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    for (int i = 2020; i < 2041; i++) {
      yearList.add(i.toString());
    }
  }

  addRemainder() async {
    String addingTime = DateTime.now().toString();
    String remainderDate =
        '$selectedYear${monthList.indexOf(selectedMonth) + 1 < 10 ? '0' + (monthList.indexOf(selectedMonth) + 1).toString() : monthList.indexOf(selectedMonth) + 1}${int.parse(selectedDate) < 10 ? '0' + selectedDate : selectedDate}';
    await _fireStore
        .collection('User')
        .doc(loggedInUser.uid)
        .collection('Remainders')
        .doc(addingTime)
        .set({
      'RemainderTitle': remainderTitle,
      'RemainderContent': remainderContent,
      'AddedDate': addingTime,
      'RemainderDate': remainderDate,
    });
  }

  DropdownButton dropDown(List dropList, String type) {
    List<DropdownMenuItem> dropdownList = [];
    for (String listItem in dropList) {
      var newItem = DropdownMenuItem(
        child: Text(
          listItem,
          style: TextStyle(color: kBlackGreen600white),
        ),
        value: listItem,
      );
      dropdownList.add(newItem);
    }
    return DropdownButton(
      dropdownColor: kRemainderCardColor,
      value: type == 'date'
          ? selectedDate
          : type == 'month'
              ? selectedMonth
              : selectedYear,
      items: dropdownList,
      onChanged: (value) {
        type == 'date'
            ? selectedDate = value
            : type == 'month'
                ? selectedMonth = value
                : selectedYear = value;
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    remainderTitleTextController.dispose();
    remainderContentTextController.dispose();
    widget.callBack();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyFull,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: kRemainderScreenColor,
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(25),
            elevation: 10,
            child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.9,
                color: kRemainderPopupColor,
                child: ListView(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'Add Todo List',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: kTextFontFamily,
                              color: kBlackGreen600white),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          dropDown(dateList, 'date'),
                          SizedBox(
                            width: 10,
                          ),
                          dropDown(monthList, 'month'),
                          SizedBox(
                            width: 10,
                          ),
                          dropDown(yearList, 'year'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Title',
                        style: TextStyle(
                            color: kBlackGreen600white,
                            fontFamily: kTextFontFamily,
                            fontSize: 16),
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kBlueGreen600White),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: kBlueGreen600White))),
                              style: TextStyle(
                                color: kTextFull,
                              ),
                              onChanged: (value) {
                                remainderTitle = value;
                              },
                              controller: remainderTitleTextController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 10,
                              minLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15.0),
                            child: Text(
                              'Content',
                              style: TextStyle(
                                  color: kBlackGreen600white,
                                  fontFamily: kTextFontFamily,
                                  fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              cursorColor: kTextFull,
                              style: TextStyle(
                                color: kTextFull,
                              ),
                              onChanged: (value) {
                                remainderContent = value;
                              },
                              controller: remainderContentTextController,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 5,
                              maxLines: 10,
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kBlueGreen600White),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: kBlueGreen600White))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: isAdding
                            ? () {}
                            : () async {
                                setState(() {
                                  isAdding = true;
                                });
                                await addRemainder();
                                remainderContentTextController.clear();
                                remainderTitleTextController.clear();
                                Navigator.pop(context);
                              },
                        child: Material(
                          elevation: 7,
                          shadowColor: kBlackGreen600white,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 60,
                            width: 150,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kBlue300Grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isAdding
                                ? Center(child: CircularProgressIndicator())
                                : Center(
                                    child: Text(
                                      'Add Todo',
                                      style: TextStyle(color: kUpdateTextColor),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
