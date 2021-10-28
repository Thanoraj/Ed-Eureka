import 'dart:async';
import 'dart:io';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/config.dart' as config;
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final List keyWords;
  final List correctKeyWords;
  final selectedBook;
  final theme;
  final bool tutorial;

  PdfViewer({
    this.selectedBook,
    this.keyWords,
    this.correctKeyWords,
    this.theme,
    this.tutorial,
  });
  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  PdfViewerController _pdfViewerController = PdfViewerController();
  PdfTextSearchResult _searchResult;
  bool hasNoResults = false;
  Timer timer;
  bool showTextField = false;
  TextEditingController searchTextController = TextEditingController();
  String searchedText;
  String selected;

  @override
  void initState() {
    _searchResult = PdfTextSearchResult();
    selectedKeyWord = widget.correctKeyWords.length == 0
        ? null
        : widget.correctKeyWords[0].toString();
    checkState(selectedKeyWord);

    super.initState();
  }

  File filePath;

  String selectedKeyWord;

  @override
  void dispose() {
    timer != null ? timer.cancel() : null;
    super.dispose();
  }

  searchKeyWords() async {
    _searchResult = await _pdfViewerController.searchText(selectedKeyWord,
        searchOption: null);
    if (_searchResult.totalInstanceCount == 0) {
      hasNoResults = true;
    }
    setState(() {});
  }

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
      iconEnabledColor: kGrey600Green600,
      dropdownColor: kRemainderCardColor,
      underline: SizedBox(),
      value: selectedKeyWord,
      items: dropdownList,
      onChanged: (value) {
        selectedKeyWord = value;
        checkState(selectedKeyWord);
        hasNoResults = false;
        setState(() {});
      },
    );
  }

  bool isSwitched = false;
  String selectedTheme = 'Light';

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      isSwitched = true;
      selectedTheme = 'Dark';
    } else {
      isSwitched = false;
      selectedTheme = 'Light';
    }
    initializeTheme();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: kUpdateTextColor,
          ),
        ),
        backgroundColor: kBlueBlack87,
        title: Visibility(
          visible: !widget.tutorial,
          child: TextField(
            style: TextStyle(color: kTextFull),
            decoration: InputDecoration(
                hintText: 'Search your own keywords',
                hintStyle: TextStyle(color: kText70)),
            controller: searchTextController,
            onChanged: (val) {
              searchedText = val;
            },
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible: !widget.tutorial,
            child: GestureDetector(
              onTap: () {
                hasNoResults = false;
                checkState(searchedText);
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.search,
                  color: kUpdateTextColor,
                ),
              ),
            ),
          ),
          Container(
            child: Transform.scale(
                scale: 1,
                child: Switch(
                  onChanged: toggleSwitch,
                  value: isSwitched,
                  activeColor: Colors.green[900],
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.blue[900],
                  inactiveTrackColor: Colors.white,
                )),
          ),
        ],
      ),
      body: Stack(children: [
        Container(
          child: ColorFiltered(
            colorFilter: selectedTheme == 'Dark'
                ? ColorFilter.matrix(
                    [
                      //R  G   B    A  Const
                      -1, 0, 0, 0, 255, //
                      0, -1, 0, 0, 255, //
                      0, 0, -1, 0, 255, //
                      0, 0, 0, 1, 0, //
                    ],
                  )
                : ColorFilter.matrix([
                    1, 0, 0, 0, 0, //
                    0, 1, 0, 0, 0, //
                    0, 0, 1, 0, 0, //
                    0, 0, 0, 1, 0, //
                  ]),
            child: SfPdfViewer.memory(
              widget.selectedBook,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) async {},
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                AlertDialog(
                  title: Text(details.error),
                  content: Text(details.description),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Visibility(
            visible: hasNoResults,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xfffafff5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('No results Found...'),
              ),
            )),
        Visibility(
          visible: !widget.tutorial,
          child: Positioned(
            top: MediaQuery.of(context).size.height * 4 / 7,
            right: 20,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: ColorTheme().waves,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: dropDown(widget.correctKeyWords)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _searchResult.previousInstance();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          gradient: config.ColorTheme().waves,
                          borderRadius: BorderRadius.circular(25)),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: kUpdateTextColor,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _searchResult.nextInstance();
                },
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        gradient: config.ColorTheme().waves,
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: kUpdateTextColor,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  checkState(searchText) async {
    UserManagement.checkUser(context);
    String searchWord;
    if (_pdfViewerController != null && selectedKeyWord != null) {
      if (widget.correctKeyWords.contains(searchText)) {
        searchWord =
            widget.keyWords[widget.correctKeyWords.indexOf(selectedKeyWord)];
      } else {
        searchWord = searchText;
      }
      _searchResult = await _pdfViewerController.searchText(searchWord,
          searchOption: TextSearchOption.caseSensitive);
      if (_searchResult.totalInstanceCount == 0) {
        hasNoResults = true;
      }
      timer != null ? timer.cancel() : null;
      setState(() {});
    }
  }
}
