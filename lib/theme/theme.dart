import 'package:flutter/material.dart';
import 'package:ed_eureka/theme/config.dart' as config;

var kLightTheme = ThemeData(
  canvasColor: Colors.transparent,
  primaryColor: Colors.white,
  brightness: Brightness.light,
  accentColor: config.ColorTheme().accentColor(1),
  focusColor: config.ColorTheme().mainColor(1),
  hintColor: config.ColorTheme().secondColor(1),
  accentTextTheme:
      TextTheme(headline6: TextStyle(fontFamily: "Red Hat Display")),
  textTheme: TextTheme(
    button: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xFFFFFFFF),
    ),
    headline5: TextStyle(
      fontSize: 16.0,
      color: Colors.white.withOpacity(1),
      fontFamily: "Red Hat Display",
    ),
    headline4: TextStyle(
        fontSize: 16,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: config.ColorTheme().accentColor(1)),
    headline3: TextStyle(
        fontSize: 20,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.black),
    headline2: TextStyle(
        fontSize: 24,
        fontFamily: "Red Hat Display",
        fontWeight: FontWeight.w500,
        color: Colors.black),
    headline1: TextStyle(
      fontFamily: 'Red Hat Display',
      color: config.ColorTheme().accentColor(1),
      fontSize: 50,
      fontWeight: FontWeight.w600,
    ),
    subtitle1: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: config.ColorTheme().secondColor(1),
      fontFamily: "Roboto",
    ),
    headline6: TextStyle(
      fontSize: 13.0,
      color: Colors.white.withOpacity(.85),
      fontFamily: "Red Hat Display",
    ),
    bodyText2: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(.75),
    ),
    bodyText1: TextStyle(
      fontFamily: 'Red Hat Display',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(1),
    ),
    caption: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: config.ColorTheme().accentColor(1),
    ),
  ),
);
