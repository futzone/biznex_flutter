import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/settings_button_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/database/app_database/app_screen_database.dart';

class AppSidebar extends HookConsumerWidget {
  final ValueNotifier<int> pageNotifier;

  const AppSidebar(this.pageNotifier, {super.key});

  Widget _buildSidebarItem(BuildContext context, String name, dynamic icon,
      bool selected, onPressed, bool opened) {
    return WebButton(
      onPressed: onPressed,
      builder: (focused) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: context.s(20).all,
          height: context.s(60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? AppColors(isDark: true).mainColor
                : focused
                    ? Colors.black
                    : null,
          ),
          child: opened
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.c,
                  children: [
                    if (icon is String)
                      SvgPicture.asset(
                        icon,
                        height: context.s(24),
                        width: context.s(24),
                        color: selected ? Colors.white : Colors.white70,
                      )
                    else
                      Icon(
                        icon,
                        color: selected ? Colors.white : Colors.white70,
                        size: context.s(24),
                      ),
                    context.w(12).w,
                    Text(
                      name,
                      style: TextStyle(
                          color: Colors.white, fontSize: context.s(14)),
                    ),
                  ],
                )
              : (icon is String)
                  ? SvgPicture.asset(
                      icon,
                      height: context.s(24),
                      width: context.s(24),
                      color: selected ? Colors.white : Colors.white70,
                    )
                  : Icon(
                      icon,
                      color: selected ? Colors.white : Colors.white70,
                      size: context.s(24),
                    ),
        );
      },
    );
  }

  @override
  Widget build(context, ref) {
    final openedValue = useState(true);

    final isAdmin =
        ref.watch(currentEmployeeProvider).roleName.toLowerCase() == 'admin';

    Widget sidebarItemBuilder(dynamic icon, String name, int page) {
      final selected = (page == pageNotifier.value);

      return _buildSidebarItem(
        context,
        name,
        icon,
        selected,
        () {
          if (page == -1) return;
          pageNotifier.value = page;
        },
        openedValue.value,
      );
    }

    return AppStateWrapper(builder: (theme, state) {
      return Container(
        color: theme.sidebarBG,
        width: context.w(openedValue.value ? 320 : 96),
        child: Column(
          crossAxisAlignment: openedValue.value
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisAlignment: openedValue.value
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            SimpleButton(
              onPressed: () {
                openedValue.value = !openedValue.value;
              },
              child: !openedValue.value
                  ? Padding(
                      padding: EdgeInsets.only(top: context.h(36)),
                      child: Icon(
                        Iconsax.menu_1,
                        color: Colors.white,
                        size: context.s(32),
                      ),
                    )
                  : Padding(
                      padding: Dis.only(
                          top: context.h(36),
                          left: context.w(24),
                          right: context.w(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (openedValue.value)
                            SvgPicture.asset(
                              "assets/icons/logo-text.svg",
                              color: theme.mainColor,
                              height: context.s(32),
                            ),
                          if (openedValue.value)
                            Container(
                              height: context.s(32),
                              width: context.s(32),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: context.s(20),
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            if (openedValue.value)
              state.whenProviderData(
                  provider: appExpireProvider,
                  builder: (data) {
                    log(data.toString());
                    if (data <= 3) {
                      return Container(
                        margin: Dis.only(top: 24, lr: 24),
                        padding: Dis.only(lr: 16, tb: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.amber),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            Icon(
                              Ionicons.warning_outline,
                              color: theme.amber,
                              size: 32,
                            ),
                            Expanded(
                              child: Text(
                                AppLocales.subscriptionPaymentText.tr(),
                                style: TextStyle(
                                  fontFamily: mediumFamily,
                                  color: theme.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return 32.h;
                  }),
            24.h,
            Expanded(
              child: SingleChildScrollView(
                padding: Dis.only(lr: context.w(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // sidebarItemBuilder("assets/icons/pie.svg", AppLocales.overview.tr(), 0),
                    // sidebarItemBuilder("assets/icons/shopping.svg", AppLocales.set.tr(), 1),
                    sidebarItemBuilder(Iconsax.bag, AppLocales.orders.tr(), 2),

                    if(isAdmin)
                    sidebarItemBuilder(
                        Iconsax.card, AppLocales.transactions.tr(), 9),
                    sidebarItemBuilder(
                        Iconsax.reserve, AppLocales.meals.tr(), 4),

                    if(isAdmin)
                    sidebarItemBuilder("assets/svg/warehouse.svg",
                        AppLocales.warehouse.tr(), 12),


                    sidebarItemBuilder(
                        Iconsax.grid_3, AppLocales.categories.tr(), 3),
                    // sidebarItemBuilder("assets/icons/verified.svg", AppLocales.promos.tr(), 3),

                    if(isAdmin)
                    sidebarItemBuilder("assets/icons/dining-table.svg",
                        AppLocales.places.tr(), 10),
                    // sidebarItemBuilder(Iconsax.info_circle, AppLocales.productInformation.tr(), 5),

                    if(isAdmin)
                    sidebarItemBuilder(
                        Iconsax.setting_4, AppLocales.productParams.tr(), 6),
                    // sidebarItemBuilder("assets/icons/hanger.svg", AppLocales.productSizes.tr(), 6),

                    if(isAdmin)
                    sidebarItemBuilder(
                        Iconsax.chart_square, AppLocales.reports.tr(), 7),

                    if(isAdmin)
                    sidebarItemBuilder(
                        Iconsax.user_square, AppLocales.employees.tr(), 8),

                    sidebarItemBuilder(Iconsax.profile_2user_copy,
                        AppLocales.customers.tr(), 13),


                    if(isAdmin)
                    if (!state.offline)
                      sidebarItemBuilder(
                          Iconsax.cloud_copy, AppLocales.cloudData.tr(), 11),
                    SimpleButton(
                      onPressed: () async {
                        final isFullScreen = await ScreenDatabase.get();
                        await FullScreenWindow.setFullScreen(!isFullScreen)
                            .then((_) async {
                          await ScreenDatabase.set();
                        });
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: sidebarItemBuilder("assets/icons/fullscreen.svg",
                            AppLocales.fullScreen.tr(), -1),
                      ),
                    ),

                    SimpleButton(
                      onPressed: () async {
                        AppRouter.open(context, OnboardPage());
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: sidebarItemBuilder(
                            Iconsax.logout_copy, AppLocales.logout.tr(), -1),
                      ),
                    ),
                    // sidebarItemBuilder("assets/icons/printer-svgrepo-com.svg", AppLocales.printing.tr(), 9),
                    // sidebarItemBuilder("assets/icons/delivery.svg", AppLocales.delivery.tr(), 10),
                  ],
                ),
              ),
            ),
            // 24.w,

            if(isAdmin)
            SimpleButton(
              onPressed: () {
                pageNotifier.value = 0;
              },
              child: SettingsButtonScreen(
                theme: theme,
                model: state,
                opened: openedValue.value,
                selected: pageNotifier.value == 0,
              ),
            ),
          ],
        ),
      );
    });
  }
}
