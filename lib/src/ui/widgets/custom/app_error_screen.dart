import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

Widget RefErrorScreen(Object error, StackTrace stackTrace) {
  log("RefErrorScreen saying: ", error: error, stackTrace: stackTrace);
  return AppErrorScreen();
}

class AppErrorScreen extends AppStatelessWidget {
  final String? message;
  final FutureProvider? provider;
  final void Function()? onTryFix;

  const AppErrorScreen({super.key, this.message, this.provider, this.onTryFix});

  @override
  Widget builder(context, theme, ref, state) {
    log(message.toString());
    return Column(
      spacing: 16,
      children: [
        AppText.$16Bold(AppLocales.sorryErrorText.tr()),
        AppPrimaryButton(
          title: AppLocales.tryAgain.tr(),
          theme: theme,
          onPressed: () {
            if (provider != null) {
              try {
                ref.refresh(provider!);
                ref.invalidate(provider!);
              } catch (error) {
                ///
              }
            }

            if (onTryFix != null) onTryFix!();
          },
        ),
      ],
    );
  }
}
