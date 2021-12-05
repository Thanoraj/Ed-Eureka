import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/pages/video/all_videos_screen.dart';
import 'package:ed_eureka/ui/widgets/sectionHeader.dart';
import 'package:ed_eureka/ui/widgets/videoCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideosPage extends StatefulWidget {
  VideosPage({
    Key key,
    @required this.userDetails,
    @required this.onMenuTap,
  }) : super(key: key);
  final Map userDetails;
  final Function onMenuTap;

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  TextEditingController controller = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List recommendedLecturesList = [];
  List revisionVideoList = [];

  List userInfo = [];
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  List subjectList = [];

  Future _future;
  @override
  void initState() {
    for (String Subject in subjectList) {
      videoDetailList.add([]);
    }
    super.initState();
  }

  List videoDetailList = [];
  List subscriptionVideos = [];
  User loggedInUser = FirebaseAuth.instance.currentUser;
  List subscriptionList = [];

  videoListGenerator() async {
    await _fireStore
        .collection('User')
        .doc(loggedInUser.uid)
        .get()
        .then((value) {
      subjectList = value['subjectList'];
      userInfo = value['userInfo'];
      subscriptionList = value['subscriptionList'];
    }).catchError((e) {
      print(e);
      subscriptionList = subscriptionList;
    });
    print(subjectList);
    videoDetailList = [];
    int j = 0;
    for (int i = 0; i < subjectList.length; i++) {
      videoDetailList.add([]);
      await _firestore
          .collection('Videos')
          .doc(subjectList[i])
          .collection(subjectList[i])
          .where('url', isNotEqualTo: '')
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((element) {
          String videoId = YoutubePlayer.convertUrlToId(element['url']);

          if (videoId != null) {
            Map details = {
              'title': element['title'],
              'thumbnail': element['thumbnail'],
              'text': element['text'],
              'length': element['length'],
              'level': element['level'],
              'videoURL': element['url'],
            };

            if (!videoDetailList[i].contains(details)) {
              videoDetailList[i].add(details);
            }
          }
        });
      }).catchError((e) {
        print(e);
      });
    }
    //print(videoDetailList);
    subscriptionVideos = [];
    print(subscriptionList);
    for (Map subscription in subscriptionList) {
      await _firestore
          .collection('Videos')
          .doc(subscription['name'])
          .collection(
              '${subscription['subject']}_${subscription['batch']}_${subscription['medium']}')
          .get()
          .then((value) {
        subscriptionVideos.add([]);
        value.docs.forEach((element) {
          String videoId = YoutubePlayer.convertUrlToId(element['url']);
          Map details = {
            'subscription': subscription,
            'title': element['title'],
            'thumbnail': element['thumbnail'],
            'text': element['text'],
            'length': element['length'],
            'level': element['level'],
            'videoURL': element['url'],
          };
          if (!subscriptionVideos[j].contains(details)) {
            subscriptionVideos[j].add(details);
          }
        });
      }).catchError((e) {
        print(e);
      });
      j++;
    }
    print(videoDetailList);
    return videoDetailList;
  }

  videoCardListBuilder() {
    UserManagement.checkUser(context);
    List<Widget> videoList = [
      SliverFixedExtentList(
          delegate: SliverChildListDelegate.fixed([Container()]),
          itemExtent: MediaQuery.of(context).size.height * 0.16),
    ];
    for (int i = 0; i < subjectList.length; i++) {
      videoList.add(
        SliverToBoxAdapter(
          child: SectionHeader(
            text: userInfo[0] == 'தமிழ்'
                ? '${subjectList[i]} காணொளிகள்'
                : 'Best of ${subjectList[i]}',
            onPressed: () {
              videoDetailList != []
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllVideosScreen(
                              title: 'Best of ${subjectList[i]}',
                              videoList: videoDetailList[i])))
                  : null;
            },
          ),
        ),
      );
      if (videoDetailList.length != 0) {
        videoList.add(
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 245,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videoDetailList[i] == []
                    ? 1
                    : videoDetailList[i].length < 6
                        ? videoDetailList[i].length
                        : 5,
                itemBuilder: (context, index) {
                  return videoDetailList[i] == []
                      ? Container()
                      : VideoCard(
                          long: true,
                          videoDetail: videoDetailList[i][index],
                        );
                },
              ),
            ),
          ),
        );
      }
    }
    int j = 0;
    for (int j = 0; j < subscriptionList.length; j++) {
      if (subscriptionVideos[j].length != 0) {
        videoList.add(
          SliverToBoxAdapter(
            child: SectionHeader(
              text: 'Best of ${subscriptionList[j]['name']}',
              onPressed: () {
                subscriptionVideos != []
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllVideosScreen(
                                title: 'Best of ${subscriptionList[j]['name']}',
                                videoList: subscriptionVideos[j - 1])))
                    : null;
              },
            ),
          ),
        );

        try {
          videoList.add(
            SliverToBoxAdapter(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 245,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: subscriptionVideos[j] == []
                      ? 1
                      : subscriptionVideos[j].length < 6
                          ? subscriptionVideos[j].length
                          : 5,
                  itemBuilder: (context, index) {
                    return subscriptionVideos[j] == []
                        ? Container()
                        : VideoCard(
                            long: true,
                            videoDetail: subscriptionVideos[j][index],
                          );
                  },
                ),
              ),
            ),
          );
        } on Exception catch (e) {}
      }
    }
    return videoList;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: videoListGenerator(),
      builder: (context, AsyncSnapshot snapshot) {
        print(snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done);
        print(snapshot.connectionState);
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Material(
            child: CupertinoPageScaffold(
              backgroundColor: kBodyFull,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SafeArea(
                    child: CustomScrollView(
                      slivers: videoCardListBuilder(),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
              color: kBodyFull,
              child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
