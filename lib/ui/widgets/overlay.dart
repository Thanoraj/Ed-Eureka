import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/ui/pages/remainder/RemainderAdding.dart';
import 'package:ed_eureka/ui/widgets/card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverlayWidget extends StatefulWidget {
  OverlayWidget({
    Key key,
  }) : super(key: key);

  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  String getStrToday() {
    var today = DateFormat().add_yMMMMd().format(DateTime.now());
    var strDay = today.split(" ")[1].replaceFirst(',', '');
    if (strDay == '1') {
      strDay = strDay + "st";
    } else if (strDay == '2') {
      strDay = strDay + "nd";
    } else if (strDay == '3') {
      strDay = strDay + "rd";
    } else {
      strDay = strDay + "th";
    }
    var strMonth = today.split(" ")[0].substring(0, 4);
    var strYear = today.split(" ")[2];
    return "$strDay $strMonth $strYear";
  }

  final List names = [
    'Revision - Kinematics',
    '3D Geometry',
    'Revision - Organic Bonds',
    'Plants and Life'
  ];

  final List times = ['5pm-6pm', '6pm-7pm', '7pm-8pm', '8pm-9pm'];

  final List colors = [
    Color(0xFFFF0000),
    Color(0xFF0000FF),
    Color(0xFFFFFF00),
    Color(0xFF00FF00)
  ];

  String selectedDate;

  String selectedMonth;

  String selectedYear;
  bool showAddReminder = false;
  User loggedInUser = FirebaseAuth.instance.currentUser;
  bool showDelete = false;
  bool showAlert = false;
  int selectedIndex;

  @override
  void initState() {
    super.initState();
    getRemainder();
  }

  List<Map> remainderList = [];

  getRemainder() async {
    var dateFormat = DateTime.now().toString().split('-');
    var date = dateFormat[2].split(' ');
    remainderList = [];
    await FirebaseFirestore.instance
        .collection('User')
        .doc(loggedInUser.uid)
        .collection('Remainders')
        .where('RemainderDate',
            isEqualTo: '${dateFormat[0]}${dateFormat[1]}${date[0]}')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        remainderList.add({
          'RemainderTitle': element['RemainderTitle'],
          'RemainderContent': element['RemainderContent'],
          'RemainderDate': element['RemainderDate'],
          'AddedDate': element['AddedDate'],
        });
      });
    });
    setState(() {});
  }

  deleteRemainder(addedDate) async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(loggedInUser.uid)
        .collection('Remainders')
        .doc(addedDate)
        .delete();
    getRemainder();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Material(
        child: Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: kOverlayColor,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 48.0, horizontal: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Today",
                          style: TextStyle(
                              fontFamily: 'Red Hat Display',
                              fontSize: 24,
                              color: kRemainderToday,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          getStrToday(),
                          style: TextStyle(
                              fontFamily: 'Red Hat Display',
                              fontSize: 24,
                              color: kRemainderToday,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    itemCount: remainderList.length + 2,
                    itemBuilder: (context, index) {
                      return index == remainderList.length + 1
                          ? SizedBox(
                              height: 90,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showDelete = false;
                                  });
                                },
                                child: Center(
                                  child: Visibility(
                                    visible: showDelete,
                                    child: Material(
                                      elevation: 7,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: kRemainderCancelButton,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: kUpdateTextColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : index == remainderList.length
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 14),
                                  child: CardWidget(
                                    color: kWhiteGrey,
                                    func: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RemainderAddingScreen(
                                                    callBack: () {
                                                      getRemainder();
                                                    },
                                                  )));
                                      setState(() {});
                                    },
                                    gradient: false,
                                    button: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              BoxIcons.bx_plus,
                                              color: kBlackGreen600white,
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            "Add Todo",
                                            style: TextStyle(
                                                fontFamily: 'Red Hat Display',
                                                fontSize: 18,
                                                color: kBlackGreen600white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    height: 80,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 14),
                                  child: GestureDetector(
                                    onLongPress: () {
                                      setState(() {
                                        showDelete = true;
                                      });
                                    },
                                    child: CardWidget(
                                      func: () {},
                                      gradient: false,
                                      button: false,
                                      child: Container(
                                        color: kRemainderCardColor,
                                        child: Row(
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 2),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.75,
                                                    child: Text(
                                                      "${remainderList[index]['RemainderTitle']}",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Red Hat Display',
                                                          fontSize: 18,
                                                          color:
                                                              kRemainderTitleColor),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 2, 8, 8),
                                                  child: Text(
                                                    "${remainderList[index]['RemainderContent']}",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Red Hat Display',
                                                        fontSize: 14,
                                                        color:
                                                            kRemainderTitleColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: showDelete,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedIndex = index;
                                                    showAlert = true;
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      kRemainderButtonColor,
                                                  child: Icon(Icons.delete),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      height: 80,
                                    ),
                                  ),
                                );
                    },
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
      Visibility(
        visible: showAlert,
        child: AlertDialog(
          backgroundColor: kAlertDialogColor,
          title: Center(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Do you want to Delete?'))),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
                'Are you sure to delete this todo. You may need to re add this if you want it again'),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                deleteRemainder(remainderList[selectedIndex]['AddedDate']);
                setState(() {
                  showAlert = false;
                });
              },
              child: Container(child: Text('Ok')),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showAlert = false;
                });
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text('Cancel')),
            )
          ],
        ),
      )
    ]);
  }
}
