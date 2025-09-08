import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/constants/app_locales.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/employee_settings_screen.dart';
import 'package:biznex/src/ui/screens/settings_screen/order_settings_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ionicons/ionicons.dart';

class SettingsScreenButton extends HookWidget {
  final AppColors theme;

  const SettingsScreenButton(this.theme, {super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/settings.svg",
      color: Colors.white,
      height: context.s(24),
      width: context.s(24),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  final AppColors theme;
  final void Function() onClose;

  const SettingsScreen({super.key, required this.theme, required this.onClose});

  @override
  Widget build(BuildContext context, ref) {
    return Center(
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        child: AppStateWrapper(builder: (theme, state) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.height * 0.5,
            ),
            padding: context.s(16).all,
            decoration: BoxDecoration(
              color: theme.scaffoldBgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocales.settings.tr(),
                      style: TextStyle(fontSize: context.s(18), fontWeight: FontWeight.bold),
                    ),
                    SimpleButton(
                      onPressed: onClose,
                      child: Icon(Ionicons.close_circle_outline, size: context.s(30)),
                    ),
                  ],
                ),
                Container(
                  margin: 12.tb,
                  height: 1,
                  color: theme.accentColor,
                ),
                AppListTile(
                  title: AppLocales.changeLanguage.tr(),
                  theme: theme,
                  leadingIcon: Ionicons.language_outline,
                  onPressed: () {
                    if (context.locale.languageCode == 'uz') {
                      context.setLocale(const Locale('ru', 'RU'));
                      ShowToast.success(context, AppLocales.languageChangedToRussian.tr());
                    } else {
                      context.setLocale(const Locale('uz', 'UZ'));
                      ShowToast.success(context, AppLocales.languageChangedToUzbek.tr());
                    }
                    if (!kIsWeb) {
                      // AppRouter.open(context, const MaterialHomePage());
                    }
                  },
                ),
                AppListTile(
                  title: AppLocales.changeThemeMode.tr(),
                  theme: theme,
                  leadingIcon: theme.isDark ? Ionicons.sunny_outline : Ionicons.moon_outline,
                  onPressed: () async {
                    showAppLoadingDialog(context);
                    AppStateDatabase stateDatabase = AppStateDatabase();
                    AppModel app = await stateDatabase.getApp();
                    app.isDark = !theme.isDark;
                    stateDatabase.updateApp(app).then((_) {
                      ref.invalidate(appStateProvider);
                      onClose();
                      AppRouter.close(context);
                    });
                  },
                ),
                AppListTile(
                  leadingIcon: Ionicons.settings_outline,
                  title: AppLocales.settings.tr(),
                  theme: theme,
                  onPressed: () async {
                    showDesktopModal(context: context, body: EmployeeSettingsScreen());
                  },
                ),
                AppListTile(
                  leadingIcon: Ionicons.print_outline,
                  title: AppLocales.printing.tr(),
                  theme: theme,
                  onPressed: () async {
                    showDesktopModal(context: context, body: OrderSettingsScreen(state));
                  },
                ),
                AppListTile(
                  leadingIcon: Ionicons.log_out_outline,
                  title: AppLocales.logout.tr(),
                  theme: theme,
                  onPressed: () async {
                    onClose();
                    AppRouter.open(context, OnboardPage());
                  },
                ),
                const Spacer(),
                const Center(child: Text("1.101.1")),
              ],
            ),
          );
        }),
      ),
    );
  }
}
