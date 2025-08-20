
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/config/router.dart';
import '../../../core/constants/app_locales.dart';

showAppSuccessDialog({required BuildContext context, required String message}) {
  showDialog(
    context: context,
    builder: (context) {
      return _ShowDialogScreen(message);
    },
  );
}

class _ShowDialogScreen extends StatelessWidget {
  final String message;

  const _ShowDialogScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AppStateWrapper(builder: (theme, state) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: theme.scaffoldBgColor,
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: 16.all,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Ionicons.checkmark_done_circle_sharp,
                  color: theme.mainColor,
                  size: 64,
                ),
                16.h,
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: state.boldFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.h,
                AppPrimaryButton(
                  theme: theme,
                  onPressed: () => AppRouter.close(context),
                  title: AppLocales.close.tr(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
