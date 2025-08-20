import 'dart:io';
import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future showConfirmDialog({
  required BuildContext context,
  required String title,
  required void Function() onConfirm,
  void Function()? onCancel,
}) async {
  if (kIsWeb) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return _CupertinoVersion(
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
          onCancel: () {
            if (onCancel == null) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
              onCancel();
            }
          },
          title: title,
        );
      },
    );
  } else {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return _CupertinoVersion(
            onConfirm: () {
              Navigator.pop(context);
              onConfirm();
            },
            onCancel: () {
              if (onCancel == null) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                onCancel();
              }
            },
            title: title,
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) {
          return _MaterialVersion(
            onConfirm: () {
              Navigator.pop(context);
              onConfirm();
            },
            onCancel: () {
              if (onCancel == null) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                onCancel();
              }
            },
            title: title,
          );
        },
      );
    }
  }
}

class _CupertinoVersion extends StatelessWidget {
  final void Function() onConfirm;
  final void Function() onCancel;
  final String title;

  const _CupertinoVersion({
    required this.onConfirm,
    required this.onCancel,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoAlertDialog(
        content: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            // color: theme.textColor,
          ),
        ),
        title: const Icon(Icons.warning_amber, color: Colors.amber, size: 40),
        actions: [
          SimpleButton(
            onPressed: onCancel,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  "no".tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    // color: theme.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ),
          SimpleButton(
            onPressed: onConfirm,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  "yes".tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppColors(isDark: true).mainColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialVersion extends StatelessWidget {
  final void Function() onConfirm;
  final void Function() onCancel;
  final String title;

  const _MaterialVersion({
    required this.onConfirm,
    required this.onCancel,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AlertDialog(
        // backgroundColor: theme.secondaryBgColor,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            // color: theme.textColor,
            fontSize: 16,
          ),
        ),
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.amber,
          size: 40,
        ),
        content: SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SimpleButton(
                  onPressed: onCancel,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        "no".tr(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          // color: theme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SimpleButton(
                  onPressed: onConfirm,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        "yes".tr(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          // color: theme.mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
