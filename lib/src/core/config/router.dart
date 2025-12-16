import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/screens/sleep_screen/activity_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static void close(BuildContext context, {String? callback}) =>
      Navigator.pop(context, callback);

  static Future go(BuildContext context, Widget page) async {
    return await Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static void open(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Consumer(
          builder: (context, ref, child) =>
              ActivityWrapper(ref: ref, context: context, child: page),
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  static void openPage(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page,
      ),
      (Route<dynamic> route) => false,
    );
  }
}

class AppContextService {
  static late BuildContext context;

  static void initContext(BuildContext ctx) {
    context = ctx;
    if (context.locale.languageCode == "en") {
      context.setLocale(const Locale("uz", "UZ"));
    }
  }

  static void open(Widget page) {
    AppRouter.open(context, page);
  }

  static void go(Widget page) {
    AppRouter.go(context, page);
  }
}
