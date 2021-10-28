import 'dart:convert';

import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/theme/config.dart';
import 'package:ed_eureka/ui/pages/video.dart';
import 'package:ed_eureka/ui/widgets/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final bool long;
  final videoDetail;
  const VideoCard({
    @required this.long,
    this.videoDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CardWidget(
        func: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VideoPage(videoDetail: videoDetail),
            ),
          );
        },
        gradient: false,
        button: true,
        width: long ? 270 : 180,
        child: Container(
          color: kBody87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: long ? 360 : 180,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    videoDetail['thumbnail'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: 180,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  videoDetail['title'],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: kVideoCardTitleColor,
                      fontFamily: 'Red Hat Display',
                      fontSize: 16),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      BoxIcons.bx_bar_chart_alt_2,
                      size: 16,
                      color: kTextFull,
                    ),
                    Text(
                      videoDetail['level'],
                      style: TextStyle(
                          color: kVideoDetailsColor,
                          fontFamily: 'Red Hat Display',
                          fontSize: 10),
                    ),
                    Spacer(),
                    Text(
                      "${videoDetail['length']} mins",
                      style: TextStyle(
                          color: kVideoDetailsColor,
                          fontFamily: 'Red Hat Display',
                          fontSize: 10),
                    ),
                    Icon(
                      BoxIcons.bx_timer,
                      size: 16,
                      color: kTextFull,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 14, 0, 14),
                  decoration: BoxDecoration(color: kBlue300Grey
                      //gradient: ColorTheme().waves
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(BoxIcons.bx_play_circle, color: kUpdateTextColor),
                      Text(
                        "Watch Lecture",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Red Hat Display',
                            fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
