import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;

  AppColors({required this.isDark});

  final Duration animationDuration = const Duration(milliseconds: 300);

  Color get mainColor => const Color(0xff0BC266);

  Color get sidebarBG => const Color(0xff1B2728);

  Color get secondaryColor => const Color(0xff9EFFCE);

  Color get accentColor => isDark ? const Color(0xff2a2a2a) : const Color(0xffEAEAEA).withOpacity(0.7);

  Color get highlightColor => const Color(0xFF65C2F5);

  Color get actionColor => const Color(0xFF09B1EC);

  Color get textColor => isDark ? Colors.white : Colors.black;

  Color get secondaryTextColor => isDark ? const Color(0xffababab) : const Color(0xff969BA7);

  Color get appBarColor => isDark ? scaffoldBgColor : sidebarBG;

  Color get appBarTextColor => Colors.white;

  Color get appBarIconColor => isDark ? Colors.white : Colors.black;

  Color get scaffoldBgColor => isDark ? const Color(0xFF121212) : Color(0xFFF1F3F6);

  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get dividerColor => isDark ? Colors.grey[700]! : Colors.grey[300]!;

  Color get buttonColor => isDark ? actionColor : secondaryColor;

  Color get iconColor => isDark ? Colors.white : Colors.black;

  ThemeData get themeData => ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: mainColor,
        scaffoldBackgroundColor: scaffoldBgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: appBarColor,
          titleTextStyle: TextStyle(color: appBarTextColor, fontSize: 20, fontFamily: "Medium"),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardColor: cardColor,
        dividerColor: dividerColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: iconColor),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor, fontFamily: "Extra-Bold"),
          bodyMedium: TextStyle(color: textColor, fontFamily: "Medium"),
          bodySmall: TextStyle(color: textColor, fontFamily: "Regular"),
        ),
      );

  Color get green => const Color(0xff0BC266);

  Color get red => const Color(0xffD05333);

  get amber => Colors.amber;

  get purple => Colors.purple;

  Color get yellow => Colors.yellow;

  Color get orange => Colors.orange;

  Color get pink => Colors.pink;

  get white => Colors.white;

  get black => Colors.black;
}
