import 'package:biznex/biznex.dart';

import '../helpers/app_custom_padding.dart';

class AppText {
  static Widget $14Bold(String text, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(text, style: style ?? TextStyle(fontSize: 14, fontFamily: boldFamily)),
    );
  }

  static Widget $16Bold(String text, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(text, style: style ?? TextStyle(fontSize: 16, fontFamily: boldFamily)),
    );
  }

  static Widget $18Bold(String text, {EdgeInsets? padding, TextStyle? style, int? maxlines}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(text, style: style ?? TextStyle(fontSize: 18, fontFamily: mediumFamily), maxLines: maxlines),
    );
  }

  static Widget $24Bold(String text, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(text, style: style ?? TextStyle(fontSize: 24, fontFamily: boldFamily)),
    );
  }

  static Widget $32Bold(String text, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(text, style: style ?? TextStyle(fontSize: 20, fontFamily: boldFamily)),
    );
  }

  static Widget subtitle(String text, AppModel state, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(
        text,
        style: style ??
            TextStyle(
              fontSize: state.isMobile
                  ? 12
                  : state.isTablet
                      ? 14
                      : 16,
              fontFamily: boldFamily,
            ),
      ),
    );
  }

  static Widget title(String text, AppModel state, {EdgeInsets? padding, TextStyle? style}) {
    return Padding(
      padding: padding ?? Dis.only(),
      child: Text(
        text,
        style: style ??
            TextStyle(
              fontSize: state.isMobile
                  ? 18
                  : state.isTablet
                      ? 20
                      : 24,
              fontFamily: boldFamily,
            ),
      ),
    );
  }
}
