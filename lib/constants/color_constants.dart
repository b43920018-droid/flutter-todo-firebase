import 'package:flutter/material.dart';

class ColorConstants {
  static const Color themeColor = Color(0xFFF5E8C7);
  static const MaterialColor materialThemeColor =
      MaterialColor(0xFFF5E8C7, <int, Color>{
        50: Color.fromRGBO(245, 232, 199, .1),
        100: Color.fromRGBO(245, 232, 199, .2),
        200: Color.fromRGBO(245, 232, 199, .3),
        300: Color.fromRGBO(245, 232, 199, .4),
        400: Color.fromRGBO(245, 232, 199, .5),
        500: Color.fromRGBO(245, 232, 199, .6),
        600: Color.fromRGBO(245, 232, 199, .7),
        700: Color.fromRGBO(245, 232, 199, .8),
        800: Color.fromRGBO(245, 232, 199, .9),
        900: Color.fromRGBO(245, 232, 199, 1),
      });
  static const Color primaryColor = Color(0xFF333333);
  static const Color accentColor = Color(0xFFC5E1A5);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF2C2C2C);
  static const Color greyColor = Color(0xFF888888);
  static const Color greyColor2 = Color(0xFFF5F5F5);
  static const Color softBorder = Color(0xFFCCCCCC);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color completedTaskColor = Color(0xFFE8F5E9);
  static const Color incompleteTaskColor = Color(0xFFFFEBEE);
}
