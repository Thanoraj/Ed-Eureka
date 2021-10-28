import 'package:flutter/material.dart';
import 'package:ed_eureka/theme/theme.dart';

enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = kLightTheme;
  ThemeType themeType = ThemeType.Dark;

  ThemeModel(this.currentTheme, this.themeType);

  returnTheme() {
    return themeType;
  }
}
