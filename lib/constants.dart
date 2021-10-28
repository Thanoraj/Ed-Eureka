import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:flutter/material.dart';

const kAppName = "Ed-Eureka";

const kBoardingPage1 =
    "Instantly find answers and explanations for all questions from your own text books";

const kBoardingPage2 =
    "Watch videos, complete exams win cash prizes and dominate the leaderboard.";

const kButtonTextColour = Colors.white;

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your password',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kProfileScreenFactor = 0.3;
const kProfileScreenAvatarRadius = 60.0;

const kTextFontFamily = 'Red Hat Display';

const kMediumList = ['', 'தமிழ்', 'English'];
const kStreamList = ['', 'Bio', 'Maths'];
const kDomainList = ['Past Paper', 'Model Paper'];

const kMathsStream = [
  'Physics',
  'Chemistry',
];
const kBioStream = [
  'Biology',
  'Physics',
  'Chemistry',
];

String theme;
String textColor;

initializeTheme() async {
  theme = await LocalUserData.getTheme();
  textColor = await LocalUserData.getTextColor();
  if (theme == null) {
    theme = 'Dark';
    textColor = 'green';
  }
  setColors(theme, textColor);
}

setColors(theme, textColor) {
  if (theme == 'Dark') {
    kTextColor = Colors.white70;
    kSectionHeaderColor = Colors.black;
    kHomeMaterialColor = Color(0xE8000000);
    kTextFull = Colors.white;
    kText70 = Colors.white70;
    kBodyFull = Colors.black87;
    kBody87 = Colors.black54;
    kCardWidgetContainer = Colors.black;
    kVideoCardTitleColor = Colors.white;
    kVideoDetailsColor = Colors.white70;
    kWaveThemeColors = [
      Colors.grey[900],
      Colors.black,
    ];
    kBottomAppBarColor = Colors.black;
    kCardElevationColor = Colors.green[700];
    kRemainderButtonShadow = Colors.green;
    kTopBarUSerNameColor = Colors.teal;
    kOverlayColor = Colors.black;
    kRemainderCardColor = Colors.grey[900];
    kRemainderScreenColor = Colors.grey[900];
    kRemainderPopupColor = Colors.black;
    kRemainderButtonColor = Colors.grey[900];
    kRemainderCancelButton = Colors.grey[700];
    kAlertDialogColor = Colors.grey[600];
    kBlackGreen600 = Colors.green[600];
    kBlueGreen600 = Colors.green[600];
    kBlue100Black = Colors.black;
    kBlueGreen900 = Colors.green[900];
    kBlue300Grey = Colors.grey[900];
    kWhiteBlack = Colors.black;
    kBlue300Grey900 = Colors.grey[900];
    kVideoPAgeTextColor = Colors.white70;
    kVideoPagelvlText = Color(0xFFADADAD);
    kVideoShadow = Colors.green[300];
    kProfileBackGround = [Colors.grey[900], Colors.black];
    kStaticCardBackGround = Colors.black;
    kGrey600Green600 = Colors.green[600];
    kBlueBlack87 = Colors.black87;
    kLeadersList = Colors.teal;
    kTopBarColor = Colors.black;
    kWhite54Black = Colors.black;
    kBlue600Green600 = Colors.green[600];
    kExamCardGradient = LinearGradient(
      colors: [Colors.grey[900], Colors.black],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );
    kWhiteBlack54 = Colors.black54;
    kGreyGrey100 = Colors.grey[700];
    kGrey100Black = Colors.black;
    kWhiteGrey = Colors.grey[800];
    kThemeLightBlueGrey900 = Colors.grey[900];
    kBlue300Grey800 = Colors.grey[800];
    kWhitef5Black = Colors.black;
    if (textColor == 'green') {
      kBlackTeal = Colors.teal;
      kBlue900Green = Colors.green;
      kWhiteGreen600White = Colors.green[600];
      kBottomBarIconColors = Colors.green[600];
      kSectionHeaderArrowColor = Colors.green[600];
      kUpdateTextColor = Colors.green[600];
      kRemainderToday = Colors.green[400];
      kAddRemainderText = Colors.green[600];
      kRemainderTitleColor = Colors.green[600];
      kBlackGreen600white = Colors.green[600];
      kBlueGreen600White = Colors.green[600];
      kGrey600Green600white70 = Colors.green[600];
      kPlayButton = [Colors.green[500], Colors.green[800]];
      kExamCardText = Colors.green[700];
      kDisabledTextColor = Colors.green[300];
      kWhite54Green400White54 = Colors.green[200];
      kWhite70Green400White70 = Colors.green[400];
    } else {
      kBlackTeal = Colors.white;
      kBlue900Green = Colors.white;
      kWhiteGreen600White = Colors.white;
      kBottomBarIconColors = Colors.white;
      kSectionHeaderArrowColor = Colors.white;
      kUpdateTextColor = Colors.white;
      kRemainderToday = Colors.white;
      kAddRemainderText = Colors.white;
      kRemainderTitleColor = Colors.white;
      kBlackGreen600white = Colors.white;
      kBlueGreen600White = Colors.white;
      kGrey600Green600white70 = Colors.white70;
      kExamCardText = Colors.white70;
      kPlayButton = [
        Color(0xFFABDCFF),
        Color(0xFF0396FF),
      ];
      kDisabledTextColor = Colors.white54;
      kWhite54Green400White54 = Colors.white54;
      kWhite70Green400White70 = Colors.white70;
    }
  } else {
    kWhiteGrey = Colors.white;
    kSectionHeaderColor = Colors.white;
    kBodyFull = Colors.white;
    kHomeMaterialColor = Color(0xfff5f5f5);
    kTextColor = Colors.black;
    kTextFull = Colors.black;
    kText70 = Colors.black87;
    kBodyFull = Colors.white70;
    kBody87 = Colors.white54;
    kSectionHeaderTextColor = Colors.black;
    kCardWidgetContainer = Color(0x1A636363);
    kVideoCardTitleColor = Color(0xFF535353);
    kVideoDetailsColor = Color(0xFFADADAD);
    kWaveThemeColors = [Color(0xFF0396FF), Color(0xFFABDCFF)];
    kUpdateTextColor = Colors.white;
    kBottomAppBarColor = Color(0xff0a0a46);
    kBottomBarIconColors = Colors.grey[200];
    kCardElevationColor = Colors.white;
    kRemainderButtonShadow = Color(0xFF03A9F4);
    kSectionHeaderArrowColor = Color(0xFF0a0a46);
    kTopBarUSerNameColor = Color(0xFF343434);
    kOverlayColor = Color(0xFFEDEDED);
    kRemainderToday = Color(0xFF343434);
    kAddRemainderText = Color(0xFFFFFFFF);
    kRemainderCardColor = Colors.white;
    kRemainderTitleColor = Color(0xFF585858);
    kRemainderScreenColor = Colors.black12;
    kRemainderPopupColor = Colors.white;
    kRemainderButtonColor = Colors.blue;
    kRemainderCancelButton = Colors.grey[400];
    kAlertDialogColor = Colors.white;
    kBlackGreen600 = Colors.black;
    kBlueGreen600 = Colors.blue[200];
    kBlue100Black = Colors.blue[100];
    kBlueGreen900 = Colors.blue;
    kBlue900Green = Color(0xff9b9a6e);
    kBlue300Grey = Color(0xff0a0a46);
    kBlue300Grey800 = Color(0xff0a0a46);
    kWhiteBlack = Colors.white;
    kBlue300Grey900 = Colors.blue[300];
    kVideoPAgeTextColor = Color(0xFF343434);
    kVideoPagelvlText = Color(0xFFADADAD);
    kVideoShadow = Color(0xFF03A9F4);
    kPlayButton = [
      Color(0xFFABDCFF),
      Color(0xFF0396FF),
    ];
    kProfileBackGround = [
      Colors.blue[900],
      Color(0xff0b0b53),
    ];
    kStaticCardBackGround = Color(0xFFABDCFF);
    kBlackTeal = Colors.black;
    kGrey600Green600 = Colors.grey;
    kBlueBlack87 = Colors.blue;
    kLeadersList = Color(0xFF585858);
    kTopBarColor = Color(0xFF0a0a46);
    kWhite54Black = Colors.white54;
    kBlue600Green600 = Color(0xFF0a0a46);
    kBlackGreen600white = Colors.black;
    kBlueGreen600White = Color(0xFF0a0a46);
    kGrey600Green600white70 = Colors.grey[600];
    kWhiteBlack54 = Colors.white;
    kExamCardGradient = LinearGradient(
      colors: [Colors.blue[300], Colors.blue[50]],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );
    kExamCardText = Colors.black54;
    kGreyGrey100 = Colors.blueGrey;
    kDisabledTextColor = Colors.grey;
    kGrey100Black = Colors.grey[100];
    kWhiteGreen600White = Colors.white;
    kThemeLightBlueGrey900 = Color(0xff3c3072);
    kWhite54Green400White54 = Colors.white54;
    kWhitef5Black = Color(0xFF0a0a46);
    kWhite70Green400White70 = Colors.white70;
  }
}

Color kWhitef5Black;
Color kWhite70Green400White70;
Color kWhite54Green400White54;
Color kThemeLightBlueGrey900;
Color kWhiteGreen600White;
Color kGrey100Black;
Color kExamCardText;
Color kWhiteGrey;
Color kWhiteBlack54;
Gradient kExamCardGradient;
Color kGrey600Green600white70;
Color kBlueGreen600White;
Color kBlackGreen600white;
Color kBlue600Green600;
Color kWhite54Black;
Color kTopBarColor;
Color kLeadersList;
Color kBlueBlack87;
Color kGrey600Green600;
Color kBlackTeal;
Color kStaticCardBackGround;
List<Color> kProfileBackGround;
List<Color> kPlayButton;
Color kVideoShadow;
Color kVideoPagelvlText;
Color kVideoPAgeTextColor;
Color kBlue300Grey900;
Color kWhiteBlack;
Color kBlue300Grey;
Color kBlue300Grey800;
Color kGreyGrey100;
Color kBlue900Green;
Color kBlueGreen900;
Color kBlue100Black;
Color kBlueGreen600;
Color kBlackGreen600;
Color kAlertDialogColor;
Color kRemainderCancelButton;
Color kRemainderButtonColor;
Color kRemainderPopupColor;
Color kRemainderScreenColor;
Color kRemainderTitleColor;
Color kRemainderCardColor;
Color kAddRemainderText;
Color kRemainderToday;
Color kOverlayColor;
Color kTopBarUSerNameColor;
Color kSectionHeaderArrowColor;
Color kCardElevationColor;
Color kRemainderButtonShadow;
Color kBottomBarIconColors;
Color kUpdateTextColor;
Color kBottomAppBarColor;
List<Color> kWaveThemeColors;
Color kVideoCardTitleColor;
Color kVideoDetailsColor;
Color kCardWidgetContainer;
Color kBody87;
Color kTextFull;
Color kText70;
Color kBodyFull;
Color kSectionHeaderColor;
Color kHomeMaterialColor;
Color kTextColor = theme == 'Dark' ? Colors.blue : Colors.white;
Color kSectionHeaderTextColor;
Color kDisabledTextColor;
