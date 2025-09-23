import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

class ShowToast {
  static int get _closeDuration => Platform.isWindows ? 3 : 2;

  static void error(BuildContext context, String message,
      {Alignment? alignment}) {
    toastification.show(
      type: ToastificationType.error,
      context: context,
      alignment: alignment,
      title: Text(message),
      autoCloseDuration: Duration(seconds: _closeDuration),
    );
  }

  static void warning(BuildContext context, String message) {
    toastification.show(
      type: ToastificationType.warning,
      context: context,
      title: Text(message),
      autoCloseDuration: Duration(seconds: _closeDuration),
    );
  }

  static void success(BuildContext context, String message,
      {AlignmentGeometry? alignment}) {
    toastification.show(
      type: ToastificationType.success,
      context: context,
      title: Text(message),
      alignment: alignment,
      autoCloseDuration: Duration(seconds: _closeDuration),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      type: ToastificationType.info,
      context: context,
      title: Text(message),
      autoCloseDuration: Duration(seconds: _closeDuration),
    );
  }
}
