import 'dart:math';
import 'package:biznex/src/core/constants/app_locales.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/config/router.dart';

class CustomCaptchaScreen extends StatefulWidget {
  final void Function() onSuccess;

  // final void Function() onErrorResult;
  const CustomCaptchaScreen({super.key, required this.onSuccess});

  @override
  State<CustomCaptchaScreen> createState() => _CustomCaptchaScreenState();
}

class _CustomCaptchaScreenState extends State<CustomCaptchaScreen> {
  final TextEditingController _controller = TextEditingController();
  int firstNumber = 0;
  int secondNumber = 0;
  int result = 0;
  String action = '';
  final List<String> _actions = ['-', '*', '+'];

  void _initCustomCaptcha() {
    Random random = Random();
    final actionIndex = random.nextInt(_actions.length);
    action = _actions[actionIndex];
    firstNumber = random.nextInt(action == '*' ? 10 : 100);
    secondNumber = random.nextInt(action == '*' ? 10 : 100);
    if (action == '+') {
      result = firstNumber + secondNumber;
    } else if (action == '-') {
      result = firstNumber - secondNumber;
    } else if (action == '*') {
      result = firstNumber * secondNumber;
    }

    _controller.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initCustomCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, app) {
      return Material(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '$firstNumber $action $secondNumber = ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        title: '?',
                        controller: _controller,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(onPressed: _initCustomCaptcha, icon: const Icon(Icons.refresh))
                  ],
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  theme: theme,
                  title: AppLocales.check.tr(),
                  onPressed: () {
                    if (result == int.tryParse(_controller.text.trim())) {
                      widget.onSuccess();
                    } else {
                      ShowToast.error(context, AppLocales.errorResultCaptcha.tr());
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  theme: theme,
                  color: theme.accentColor,
                  textColor: theme.textColor,
                  title: AppLocales.close.tr(),
                  onPressed: () {
                    AppRouter.close(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

void showCustomCaptcha({required BuildContext context, required void Function() onSuccess}) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CustomCaptchaScreen(onSuccess: onSuccess);
      });
}
