import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/file_management.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/widgets/Llabeled_radio_button.dart';
import 'package:ed_eureka/ui/widgets/topBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'pdf_viewer.dart';
import 'questions.dart';

enum modeTypes { Instance, Collection }
enum questionNos { five, ten, thirty }

class QuestionDomainScreen extends StatefulWidget {
  QuestionDomainScreen(
      {this.subTopic,
      this.prefix,
      this.serverId,
      this.topic,
      this.subscriptionList});
  final prefix;
  final serverId;
  final subTopic;
  final topic;
  final subscriptionList;
  @override
  _QuestionDomainScreenState createState() => _QuestionDomainScreenState();
}

class _QuestionDomainScreenState<T extends QuestionDomainScreen>
    extends State<T> {
  bool showAlert = false;
  String selected;
  bool showSubList = false;
  String selectedMode = 'Instance';
  int selectedQuestionNo = 1;
  modeTypes _modeType = modeTypes.Instance;
  questionNos _questionNos = questionNos.five;
  bool isUploading = false;
  bool isdownloading = false;
  bool flashCardUploading = false;

  buildSubTopicTile(BuildContext context) {
    List<Widget> tileList = [];
    for (String Domain in kDomainList) {
      tileList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selected = Domain;
                showAlert = true;
              });
            },
            child: Material(
              borderOnForeground: true,
              borderRadius: BorderRadius.circular(15),
              elevation: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  //gradient: ColorTheme().waves,
                ),
                height: 65,
                child: Text(
                  Domain,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Red Hat Display',
                      color: kBlackGreen600white),
                ),
              ),
            ),
          ),
        ),
      );
    }
    for (List subscription in subscriptionBooks) {
      if (subscription[0] == 'Ed-Eureka' || subscription.length > 1) {
        tileList.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookListScreen(
                              bookInfo: subscription,
                              subscription: subscription[0] == 'Ed-Eureka'
                                  ? 'Ed-Eureka'
                                  : subscription[0]['name'],
                            )));
              },
              child: Material(
                borderOnForeground: true,
                borderRadius: BorderRadius.circular(15),
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    //gradient: ColorTheme().waves,
                  ),
                  height: 65,
                  child: Text(
                    '${subscription[0] == 'Ed-Eureka' ? 'Ed-Eureka' : subscription[0]['name']} Tutorials and Notes ',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Red Hat Display',
                        color: kBlackGreen600white),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    tileList.add(SizedBox(
      height: tileList.length == 2
          ? 180
          : tileList.length == 3
              ? 90
              : 20,
    ));
    tileList.add(
      widget.subscriptionList != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                          decoration: BoxDecoration(
                            //gradient: ColorTheme().waves,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: dropDown(bookNameList)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: bookNameList
                                .contains('${widget.subTopic}_guide.pdf')
                            ? () {}
                            : () async {
                                setState(() {
                                  isdownloading = true;
                                });
                                final downloadStarted = SnackBar(
                                  content: Text('Downloading...'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(downloadStarted);
                                String fileName =
                                    '${widget.subTopic}_guide.pdf';

                                Directory appDocDir =
                                    await getApplicationDocumentsDirectory();
                                File downloadToFile =
                                    File('${appDocDir.path}/$fileName');

                                try {
                                  await FirebaseStorage.instance
                                      .ref(
                                        'App_resources/$selectedSubject/${widget.subTopic}/$fileName',
                                      )
                                      .writeToFile(downloadToFile)
                                      .whenComplete(() {
                                    bookNameList[0] == 'No Books'
                                        ? bookNameList = []
                                        : bookNameList = bookNameList;
                                    bookNameList.add(fileName);
                                    selectBook = bookNameList[0];
                                  }).catchError((e) {});
                                } on FirebaseException catch (e) {}
                                await FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(loggedInUser.uid)
                                    .update({
                                  selectedSubject: {
                                    widget.subTopic: bookNameList
                                  }
                                }).whenComplete(() {
                                  isdownloading = false;
                                  final downloadCompleted = SnackBar(
                                    content: Text('Download Completed'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(downloadCompleted);
                                });
                                setState(() {});
                              },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      // gradient: ColorTheme().waves,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        isdownloading
                                            ? CircularProgressIndicator()
                                            : Icon(
                                                Icons.download,
                                                size: 30,
                                                color: kBlackGreen600white,
                                              ),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                width: 50,
                                child: Center(
                                  child: Text(
                                    bookNameList.contains(
                                            '${widget.subTopic}_guide.pdf')
                                        ? 'Downloaded'
                                        : 'Download Guide Book',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 8, color: kTextFull),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final uploadStart = SnackBar(
                            content: Text('Uploading Started'),
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(uploadStart);

                          files = [];
                          files = await FileManagement.pickFiles();
                          if (files.length != 0) {
                            Directory appDocDir =
                                await getApplicationDocumentsDirectory();

                            for (File file in files) {
                              String fileName =
                                  '${widget.subTopic}_${(bookNameList[0] == 'No Books' ? 0 : bookNameList.length).toString()}';
                              String filePath = '${appDocDir.path}/$fileName';
                              File pickedFile = File(filePath);
                              var bytes =
                                  await _readFileByte(file.path, 'path');
                              pickedFile.writeAsBytesSync(bytes);

                              bookNameList[0] == 'No Books'
                                  ? bookNameList = []
                                  : bookNameList = bookNameList;
                              bookNameList.add(fileName);
                              selectBook = bookNameList[0];
                            }
                            await FirebaseFirestore.instance
                                .collection('User')
                                .doc(loggedInUser.uid)
                                .update({
                              selectedSubject: {
                                widget.subTopic: bookNameList,
                              }
                            });
                            final uploadFinished = SnackBar(
                              content: Text('Uploading Completed'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(uploadFinished);
                          } else {
                            final selectionCanceled = SnackBar(
                              margin: EdgeInsets.only(bottom: 100),
                              content: Text('Selection Cancelled'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(selectionCanceled);
                          }
                          setState(() {
                            isUploading = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Material(
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        //gradient: ColorTheme().waves,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          isUploading
                                              ? CircularProgressIndicator()
                                              : Icon(
                                                  Icons.add,
                                                  size: 40,
                                                  color: kBlackGreen600white,
                                                ),
                                        ]),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Add Theory',
                                    style: TextStyle(
                                        fontSize: 8, color: kTextFull),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            flashCardUploading = true;
                          });
                          final uploadStart = SnackBar(
                            content: Text('Uploading Started'),
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(uploadStart);

                          File file;
                          file = await FileManagement.pickImage();
                          if (file != null) {
                            Directory appDocDir =
                                await getApplicationDocumentsDirectory();

                            String imageName = '${basename(file.path)}';
                            String filePath = '${appDocDir.path}/$imageName';
                            File pickedFile = File(filePath);
                            var bytes = await _readFileByte(file.path, 'path');
                            pickedFile.writeAsBytesSync(bytes);
                            List<String> flashCardList = [];
                            List<String> list =
                                await LocalUserData.getFlashCardList(
                                    '${widget.subTopic}_flashCards');
                            flashCardList = list == null ? [] : list;
                            flashCardList.add(imageName);
                            LocalUserData.saveFlashCard(
                                '${widget.subTopic}_flashCards', flashCardList);
                            final uploadFinished = SnackBar(
                              content: Text('Uploading Completed'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(uploadFinished);
                          } else {
                            setState(() {
                              flashCardUploading = false;
                            });
                            final selectionCanceled = SnackBar(
                              content: Text('Selection Cancelled'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(selectionCanceled);
                          }
                          setState(() {
                            flashCardUploading = false;
                          });
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      //gradient: ColorTheme().waves,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        flashCardUploading
                                            ? CircularProgressIndicator()
                                            : Icon(
                                                Icons.image,
                                                size: 30,
                                                color: kBlackGreen600white,
                                              ),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Add Flashcard',
                                  style:
                                      TextStyle(fontSize: 8, color: kTextFull),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                  SizedBox(height: 100),
                ])
          : SizedBox(),
    );

    return tileList;
  }

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  User loggedInUser = FirebaseAuth.instance.currentUser;
  List referenceList = [];
  List bookNameList = ['No Books'];
  Map lastLeaders = {};

  String selectBook;
  Map pathMap = {};

  getReferences() async {
    UserManagement.checkUser(context);
    if (widget.subscriptionList != null) {
      await _fireStore
          .collection('User')
          .doc(loggedInUser.uid)
          .get()
          .then((value) {
        bookNameList = value[selectedSubject][widget.subTopic] == null
            ? ['No Books']
            : value[selectedSubject][widget.subTopic];
      }).catchError((e) {
        print(e);
        bookNameList = ['No Books'];
      });
      bookNameList == null
          ? bookNameList = ['No Books']
          : bookNameList = bookNameList;
      if (selectBook == 'No Books') {
        selectBook = bookNameList[0];
      }
      await getSubscription();
      return bookNameList;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.subscriptionList != null ? selectBook = bookNameList[0] : null;
  }

  Future<Uint8List> _readFileByte(filePath, type) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/$filePath';
    Uri myUri = Uri.parse(type == 'path' ? filePath : path);
    File pdf = new File.fromUri(myUri);
    Uint8List bytes;
    await pdf.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
    }).catchError((onError) {});
    return bytes;
  }

  List<List<dynamic>> subscriptionBooks = [];

  getSubscription() async {
    int i = 0;
    subscriptionBooks = [];
    subscriptionBooks.add([
      {
        'name': 'Ed-Eureka',
        'topic': selectedSubject,
        'subtopic': widget.subTopic,
      }
    ]);
    lastLeaders = {};
    await _fireStore
        .collection('subscriptions')
        .doc('Ed-Eureka')
        .collection('book_$selectedSubject')
        .doc(widget.subTopic)
        .get()
        .then((element) {
      subscriptionBooks[i].add(element['books']);
      lastLeaders = element['lastLeaders'];
    }).catchError((e) {
      print(e);
    });
    i++;
    for (var subscription in widget.subscriptionList) {
      if (subscription != 'Ed-Eureka') {
        if (subscription['subject'] == selectedSubject) {
          subscriptionBooks.add([subscription]);
          await _fireStore
              .collection('subscriptions')
              .doc(subscription['name'])
              .collection('book_${subscription['batch']}_${selectedSubject}')
              .doc(widget.subTopic)
              .get()
              .then((element) {
            subscriptionBooks[i].add(element['books']);
          }).catchError((e) {});
          i++;
        }
      }
    }
  }

  List<File> files = [];

  DropdownButton dropDown(List dropList) {
    List<DropdownMenuItem> dropdownList = [];
    for (String listItem in dropList) {
      var newItem = DropdownMenuItem(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            listItem.toString(),
            style: TextStyle(color: kBlackGreen600white),
          ),
        ),
        value: listItem,
      );
      dropdownList.add(newItem);
    }
    return DropdownButton(
      dropdownColor: kRemainderCardColor,
      underline: SizedBox(),
      value: selectBook,
      items: dropdownList,
      onChanged: (value) {
        selectBook = value;
        LocalUserData.saveLastBook('${widget.subTopic}_lastBook', selectBook);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getReferences(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                color: kHomeMaterialColor,
                child: Stack(children: [
                  Column(
                    children: [
                      Container(
                        color: kBottomAppBarColor,
                        width: MediaQuery.of(context).size.width,
                        height: 130,
                        child: Center(
                          child: Text(
                            widget.subTopic,
                            style: TextStyle(
                                fontSize: 25, color: kUpdateTextColor),
                          ),
                        ),
                      ),
                      ListView(
                        shrinkWrap: true,
                        children: buildSubTopicTile(context),
                      ),
                    ],
                  ),
                  showAlert
                      ? Container(
                          color: Colors.black54,
                          child: Center(
                            child: Column(children: [
                              Spacer(),
                              Container(
                                height: showSubList ? 400 : 300,
                                decoration: BoxDecoration(
                                    color: kBodyFull,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 250,
                                child: Material(
                                  color: kSectionHeaderColor,
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: Container(
                                          child: Text(
                                            'Select a Mode',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: kBlackGreen600white,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: [
                                            LabeledRadioButton(
                                              label: 'Individual Explorer',
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              groupValue: _modeType,
                                              value: modeTypes.Instance,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _modeType = newValue;
                                                  showSubList = false;
                                                  selectedMode = 'Instance';
                                                  selectedQuestionNo = 1;
                                                });
                                              },
                                            ),
                                            LabeledRadioButton(
                                              label: 'Collective Explorer',
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              groupValue: _modeType,
                                              value: modeTypes.Collection,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _modeType = newValue;
                                                  showSubList = true;
                                                  selectedMode = 'Collection';
                                                  selectedQuestionNo = 5;
                                                });
                                              },
                                            ),
                                            showSubList
                                                ? Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    child: Column(
                                                      children: [
                                                        LabeledRadioButton(
                                                          label: '5',
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          groupValue:
                                                              _questionNos,
                                                          value:
                                                              questionNos.five,
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              _questionNos =
                                                                  newValue;
                                                              selectedQuestionNo =
                                                                  5;
                                                            });
                                                          },
                                                        ),
                                                        LabeledRadioButton(
                                                          label: '10',
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          groupValue:
                                                              _questionNos,
                                                          value:
                                                              questionNos.ten,
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              _questionNos =
                                                                  newValue;
                                                              selectedQuestionNo =
                                                                  10;
                                                            });
                                                          },
                                                        ),
                                                        LabeledRadioButton(
                                                          label: '30',
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          groupValue:
                                                              _questionNos,
                                                          value: questionNos
                                                              .thirty,
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              _questionNos =
                                                                  newValue;
                                                              selectedQuestionNo =
                                                                  30;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    showAlert = false;
                                                  });
                                                  var selectedBook;
                                                  if (selectBook !=
                                                      'No Books') {
                                                    selectedBook =
                                                        await _readFileByte(
                                                            selectBook, 'name');
                                                  } else {
                                                    selectedBook = 'No Books';
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Question(
                                                                lastLeaders:
                                                                    lastLeaders,
                                                                collection:
                                                                    'Subjects',
                                                                prefix: widget
                                                                    .prefix,
                                                                serverId: widget
                                                                    .serverId,
                                                                questionNumber:
                                                                    selectedQuestionNo,
                                                                mode:
                                                                    selectedMode,
                                                                topic: widget
                                                                    .topic,
                                                                subTopic: widget
                                                                    .subTopic,
                                                                domain:
                                                                    selected,
                                                                selectedBook:
                                                                    selectedBook,
                                                              )));
                                                },
                                                child: Text(
                                                  'Ok',
                                                  style: TextStyle(
                                                      color:
                                                          kBlueGreen600White),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    showAlert = false;
                                                  });
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color:
                                                          kBlueGreen600White),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                            ]),
                          ),
                        )
                      : Container(),
                ]),
              ),
            );
          } else {
            return Container(
              color: kBodyFull,
              child: Center(
                child: CircularProgressIndicator(
                  color: kBlue300Grey900,
                ),
              ),
            );
          }
        });
  }
}

class BookListScreen extends QuestionDomainScreen {
  BookListScreen({
    this.bookInfo,
    this.subscription,
  }) : super(subTopic: subscription);
  final bookInfo;
  final subscription;
  @override
  BookListScreenState createState() => BookListScreenState();
}

class BookListScreenState extends _QuestionDomainScreenState<BookListScreen> {
  bool isDownloading = false;

  @override
  void initState() {
    getLocalBooks();
    super.initState();
  }

  List<String> bookList = [];

  getLocalBooks() async {
    bookList = await LocalUserData.getBookList(widget.subscription);
    bookList == null ? bookList = [] : bookList = bookList;
  }

  download(context, book) async {
    setState(() {
      isDownloading = true;
    });
    final downloadStarted = SnackBar(
      content: Text('Downloading...'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadStarted);
    String fileName = book['name'];

    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/$fileName');

    try {
      String ref = widget.subscription == 'Ed-Eureka'
          ? 'App_resources/Tutorials and Notes/${widget.bookInfo[0]['topic']}/${widget.bookInfo[0]['subtopic']}/sample.pdf'
          : 'subscriptions/${widget.bookInfo[0]['name']}/${widget.bookInfo[0]['batch']}_${widget.bookInfo[0]['subject']}/$fileName';
      await FirebaseStorage.instance
          .ref(ref)
          .writeToFile(downloadToFile)
          .whenComplete(() {
        bookList.add(fileName);
      }).catchError((e) {});
    } on FirebaseException catch (e) {
      bookList.remove(fileName);
    }
    LocalUserData.saveBookList(widget.subscription, bookList);
    isDownloading = false;
    final downloadCompleted = SnackBar(
      content: Text('Download Completed'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadCompleted);
    setState(() {});
  }

  delete(context, book) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/${book['name']}';
    Uri myUri = Uri.parse(path);
    File pdf = new File.fromUri(myUri);
    await pdf.delete().catchError((e) {});
    bookList.remove(book['name']);
    await LocalUserData.saveBookList(widget.subscription, bookList);
    final downloadCompleted = SnackBar(
      content: Text('Successfully Deleted'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadCompleted);
  }

  @override
  buildSubTopicTile(BuildContext context) {
    List<Widget> tileList = [];
    int i = 0;
    for (Map book in widget.bookInfo[1]) {
      tileList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: GestureDetector(
            onTap: () async {
              if (bookList.contains(book['name'])) {
                var selectedBook =
                    await super._readFileByte(book['name'], 'name');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewer(
                      selectedBook: selectedBook,
                      keyWords: [],
                      correctKeyWords: [],
                      tutorial: true,
                    ),
                  ),
                );
              }
            },
            child: Material(
              borderOnForeground: true,
              borderRadius: BorderRadius.circular(15),
              elevation: 5,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: ColorTheme().waves,
                ),
                height: 65,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          book['name'],
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Red Hat Display',
                              color: kBlackGreen600white),
                        ),
                      ),
                      Center(
                          child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isDownloading = true;
                          });
                          bookList.contains(book['name'])
                              ? delete(context, book)
                              : download(context, book);
                          setState(() {
                            isDownloading = false;
                          });
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      gradient: ColorTheme().waves,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: isDownloading
                                      ? CircularProgressIndicator()
                                      : Icon(
                                          bookList.contains(book['name'])
                                              ? Icons.delete
                                              : Icons.download,
                                          size: 30,
                                          color: kUpdateTextColor,
                                        ),
                                ),
                              ),
                            ]),
                      ))
                    ]),
              ),
            ),
          ),
        ),
      );
    }
    return tileList;
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}

class DownloadButton extends StatefulWidget {
  final subscriptionName;
  final batch;
  final subject;
  final book;
  final List<String> bookList;

  DownloadButton(
      {this.subscriptionName,
      this.batch,
      this.subject,
      this.book,
      this.bookList});
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  download(context) async {
    setState(() {
      isDownloading = true;
    });
    final downloadStarted = SnackBar(
      content: Text('Downloading...'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadStarted);
    String fileName = widget.book['name'];
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/$fileName');

    try {
      await FirebaseStorage.instance
          .ref(
            'subscription/${widget.subscriptionName}/${widget.batch}_${widget.subject}/$fileName',
          )
          .writeToFile(downloadToFile)
          .whenComplete(() {
        widget.bookList.add(fileName);
      }).catchError((e) {});
    } on FirebaseException catch (e) {
      widget.bookList.remove(fileName);
    }
    LocalUserData.saveBookList(widget.subscriptionName, widget.bookList);
    isDownloading = false;
    final downloadCompleted = SnackBar(
      content: Text('Download Completed'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadCompleted);
    setState(() {});
  }

  delete(context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/${widget.book['name']}';
    Uri myUri = Uri.parse(path);
    File pdf = new File.fromUri(myUri);
    await pdf.delete();
    widget.bookList.remove(widget.book['name']);
    await LocalUserData.saveBookList(widget.subscriptionName, widget.bookList);
    final downloadCompleted = SnackBar(
      content: Text('Successfully Deleted'),
    );
    ScaffoldMessenger.of(context).showSnackBar(downloadCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isDownloading = true;
        });
        widget.bookList.contains(widget.book['name'])
            ? delete(context)
            : download(context);
        setState(() {
          isDownloading = false;
        });
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                gradient: ColorTheme().waves,
                borderRadius: BorderRadius.circular(30)),
            child: isDownloading
                ? CircularProgressIndicator()
                : Icon(
                    widget.bookList.contains(widget.book['name'])
                        ? Icons.delete
                        : Icons.download,
                    size: 30,
                    color: kUpdateTextColor,
                  ),
          ),
        ),
      ]),
    );
  }
}
