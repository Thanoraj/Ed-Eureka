import 'package:ed_eureka/constants.dart';
import 'package:ed_eureka/theme/box_icons_icons.dart';
import 'package:ed_eureka/services/user_management.dart';
import 'package:ed_eureka/ui/widgets/water_marker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class VideoPage extends StatefulWidget {
  VideoPage({this.videoDetail});
  final videoDetail;
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  User loggedInUser = FirebaseAuth.instance.currentUser;
  String videoId;
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    videoId = YoutubePlayer.convertUrlToId(widget.videoDetail['videoURL']);
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
    //secureScreen();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      UserManagement.checkUser(context);
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        YoutubePlayerBuilder(
          onExitFullScreen: () {
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          },
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _controller.metadata.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
              UserManagement.checkUser(context);
            },
          ),
          builder: (context, player) => Scaffold(
            appBar: AppBar(
              foregroundColor: kBlueGreen600,
              backgroundColor: kBodyFull,
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
            body: Material(
              child: Container(
                color: kBodyFull,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: player),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 10, 8, 8.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 4,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(500),
                                        color: kVideoPAgeTextColor),
                                    child: Text(""),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        widget.videoDetail['title'],
                                        style: TextStyle(
                                            color: kVideoPAgeTextColor,
                                            fontFamily: 'Red Hat Display',
                                            fontSize: 24),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Icon(BoxIcons.bx_bar_chart_alt_2,
                                        size: 20, color: kVideoPagelvlText),
                                  ),
                                  Text(
                                    widget.videoDetail['level'],
                                    style: TextStyle(
                                        color: kVideoPagelvlText,
                                        fontFamily: 'Red Hat Display',
                                        fontSize: 14),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${widget.videoDetail['length']} mins",
                                    style: TextStyle(
                                        color: kVideoPagelvlText,
                                        fontFamily: 'Red Hat Display',
                                        fontSize: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Icon(BoxIcons.bx_timer,
                                        size: 20, color: kVideoPagelvlText),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                                padding: EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Text(
                                  widget.videoDetail['text'],
                                  style: TextStyle(
                                      color: kVideoPAgeTextColor,
                                      fontFamily: 'Red Hat Display',
                                      fontSize: 16),
                                ))
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
        //WaterMarker(loggedInUser: loggedInUser),
      ]),
    );
  }
}
