import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/pages/topics/question_domain_screen.dart';
import 'package:flutter/material.dart';

enum modeTypes { Instance, Collection }
enum questionNos { five, ten, thirty }
enum SingingCharacter { lafayette, jefferson }

class SubTopicScreen extends StatefulWidget {
  SubTopicScreen({
    this.topic,
    this.serverId,
    this.subscriptionList,
  });
  final List topic;
  final String serverId;
  final subscriptionList;

  @override
  _SubTopicScreenState createState() => _SubTopicScreenState();
}

class _SubTopicScreenState<T extends SubTopicScreen> extends State<T> {
  bool showAlert = false;
  String selected;
  bool showSubList = false;
  String selectedMode = 'Instance';
  int selectedQuestionNo = 1;

  buildSubTopicTile(BuildContext context) {
    UserManagement.checkUser(context);
    List<Widget> tileList = [];
    int i = 0;
    for (String subTopic in widget.topic[1]) {
      tileList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selected = subTopic;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDomainScreen(
                    prefix: widget.topic[4],
                    serverId: widget.serverId,
                    subTopic: selected,
                    topic: widget.topic[0],
                    subscriptionList: widget.subscriptionList,
                  ),
                ),
              );
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
                  //gradient: ColorTheme().waves,
                ),
                height: 65,
                child: Row(children: [
                  widget.topic[3][i] != ''
                      ? Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          height: 55,
                          width: 55,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.topic[3][i],
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      subTopic,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Red Hat Display',
                          color: kBlackGreen600white),
                    ),
                  ),
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
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: kHomeMaterialColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: kBottomAppBarColor,
              pinned: false,
              snap: false,
              floating: false,
              leading: null,
              automaticallyImplyLeading: false,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  padding: EdgeInsets.only(left: 50, bottom: 10),
                  child: Text(
                    widget.topic[0].split('(')[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                buildSubTopicTile(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
