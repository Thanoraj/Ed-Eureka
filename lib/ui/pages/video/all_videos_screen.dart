import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/ui/widgets/videoCard.dart';
import 'package:flutter/material.dart';

class AllVideosScreen extends StatelessWidget {
  AllVideosScreen({
    @required this.title,
    @required this.videoList,
  });
  final String title;
  final List videoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteBlack54,
      appBar: AppBar(
        backgroundColor: kWhiteBlack,
        toolbarHeight: 80,
        title: Text(
          title,
          style: TextStyle(
            color: kBlueGreen600White,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: kBlueGreen600White,
          ),
        ),
      ),
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 180 / 250,
          children: videoList.map(
            (e) {
              return VideoCard(
                long: false,
                videoDetail: e,
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
