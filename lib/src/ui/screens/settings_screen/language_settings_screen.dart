import 'dart:io';

import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';

import '../../../../biznex.dart';
import '../../widgets/custom/app_state_wrapper.dart';

class AppLanguageBar extends StatefulWidget {
  const AppLanguageBar({super.key});

  @override
  State<AppLanguageBar> createState() => _AppLanguageBarState();
}

class _AppLanguageBarState extends State<AppLanguageBar> {
  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return Container(
        padding: context.s(20).all,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 24,
          children: [
            Text(
              AppLocales.changeLanguage.tr(),
              style: TextStyle(
                fontSize: context.s(24),
                fontFamily: mediumFamily,
                color: Colors.black,
              ),
            ),
            Row(
              spacing: 24,
              children: [
                Expanded(
                  flex: 3,
                  child: SimpleButton(
                    onPressed: () {
                      context.setLocale(Locale('uz', 'UZ')).then((_) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.scaffoldBgColor,
                      ),
                      padding: Dis.only(lr: 12, tb: 12),
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(
                            (context.locale.languageCode == 'uz' &&
                                    context.locale.countryCode == 'UZ')
                                ? Icons.check_circle_outline
                                : Icons.circle_outlined,
                            color: theme.mainColor,
                          ),
                          Text(
                            "O'zbekcha",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: mediumFamily,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SimpleButton(
                    onPressed: () {
                      context.setLocale(Locale('uz', 'Cyrl')).then((_) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.scaffoldBgColor,
                      ),
                      padding: Dis.only(lr: 12, tb: 12),
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(
                            (context.locale.languageCode == 'uz' &&
                                    context.locale.countryCode == 'Cyrl')
                                ? Icons.check_circle_outline
                                : Icons.circle_outlined,
                            color: theme.mainColor,
                          ),
                          Text(
                            "Ўзбекча",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: mediumFamily,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SimpleButton(
                    onPressed: () {
                      context.setLocale(Locale('ru', 'RU')).then((_) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.scaffoldBgColor,
                      ),
                      padding: Dis.only(lr: 12, tb: 12),
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(
                            context.locale.languageCode == 'ru'
                                ? Icons.check_circle_outline
                                : Icons.circle_outlined,
                            color: theme.mainColor,
                          ),
                          Text(
                            "Русский",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: mediumFamily,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!Platform.isWindows)
              ElevatedButton(
                onPressed: () {
                  AppRouter.close(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocales.close.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: mediumFamily,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
