import 'dart:developer';
import 'dart:io';

import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/pages/main_pages/main_page.dart';
import 'package:biznex/src/ui/pages/order_pages/menu_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/employee_settings_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../biznex.dart';
import '../../../core/model/order_models/order_model.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import '../../widgets/helpers/app_back_button.dart';
import '../waiter_pages/mobile_drawer.dart';
import 'employee_orders_page.dart';

class TableChooseScreen extends HookConsumerWidget {
  final void Function(Place place)? onSelected;

  const TableChooseScreen({super.key, this.onSelected});

  Widget _buildHorCursi(BuildContext context) {
    return Container(
      height: context.h(12),
      width: context.w(56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors(isDark: false)
                .secondaryTextColor
                .withValues(alpha: 0.4),
            width: 2),
      ),
    );
  }

  Widget _buildVerCursi(BuildContext context) {
    return Container(
      height: context.h(56),
      width: context.w(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors(isDark: false)
                .secondaryTextColor
                .withValues(alpha: 0.4),
            width: 2),
      ),
    );
  }

  Widget _buildTable({
    required AppColors theme,
    required String name,
    required String? employee,
    required double? price,
    required String status,
    required BuildContext context,
  }) {
    final cColor = status == 'free'
        ? theme.mainColor.withValues(alpha: 0.8)
        : theme.secondaryTextColor;
    final textColor = status == 'free' ? theme.mainColor : theme.textColor;

    return Column(
      spacing: context.h(12),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHorCursi(context),
        Expanded(
          child: Row(
            spacing: context.w(12),
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVerCursi(context),
              Expanded(
                child: Container(
                  padding: context.s(12).all,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cColor,
                    border: Border.all(
                        color: theme.secondaryTextColor.withValues(alpha: 0.4)),
                  ),
                  child: Container(
                    padding: context.s(8).all,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: context.s(20),
                              color: textColor,
                              fontFamily: mediumFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (price != null && price != 0.0)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: context.w(4),
                              children: [
                                Icon(
                                  Ionicons.wallet_outline,
                                  size: context.s(16),
                                  color: theme.secondaryTextColor,
                                ),
                                Text(
                                  price.priceUZS,
                                  style: TextStyle(
                                    fontSize: context.s(12),
                                    color: theme.secondaryTextColor,
                                    fontFamily: mediumFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          if (employee != null && employee.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              // spacing: 8,
                              spacing: context.w(4),
                              children: [
                                Icon(
                                  Iconsax.user_copy,
                                  size: context.s(16),
                                  color: theme.secondaryTextColor,
                                ),
                                Text(
                                  employee,
                                  style: TextStyle(
                                    fontSize: context.s(12),
                                    color: theme.secondaryTextColor,
                                    fontFamily: mediumFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildVerCursi(context),
            ],
          ),
        ),
        _buildHorCursi(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(currentEmployeeProvider);
    final selectedPlace = useState<Place?>(null);
    final fatherPlace = useState<Place?>(null);
    final places = ref.watch(placesProvider).value ?? [];
    final mobile = getDeviceType(context) == DeviceType.mobile;
    return PopScope(
      canPop: ((fatherPlace.value == null) && (selectedPlace.value == null)),
      onPopInvokedWithResult: (status, dy) {
        fatherPlace.value = null;
        selectedPlace.value = null;
      },

      // onWillPop: () {  },
      child: AppStateWrapper(
        builder: (theme, state) {
          return Scaffold(
            drawer: MobileDrawer(theme),
            appBar: !mobile
                ? null
                : AppBar(
                    // leading: Icon(Ionicons.menu_outline),
                    title: Text(AppLocales.places.tr()),
                    actions: [
                      Row(
                        spacing: context.w(16),
                        children: [
                          CustomPopupMenu(
                            theme: theme,
                            children: [
                              CustomPopupItem(
                                title: AppLocales.all.tr(),
                                onPressed: () => selectedPlace.value = null,
                                iconColor: theme.textColor,
                                icon: Icons.list,
                              ),
                              for (final item in places)
                                CustomPopupItem(
                                  title: item.name,
                                  onPressed: () => selectedPlace.value = item,
                                  icon: Icons.present_to_all,
                                  iconColor: theme.textColor,
                                ),
                            ],
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: context.w(8),
                              children: [
                                Text(
                                  selectedPlace.value == null
                                      ? AppLocales.choosePlace.tr()
                                      : selectedPlace.value!.name,
                                  style: TextStyle(
                                    fontSize: context.s(16),
                                    fontFamily: mediumFamily,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(Iconsax.arrow_down_1_copy,
                                    size: context.s(20)),
                                16.w,
                              ],
                            ),
                          ),
                          // CustomPopupMenu(
                          //   theme: theme,
                          //   children: [
                          //     CustomPopupItem(
                          //         title: AppLocales.all.tr(), onPressed: () => selectedFilter.value = null, icon: Ionicons.list_outline),
                          //     CustomPopupItem(
                          //         title: AppLocales.freeTables.tr(),
                          //         onPressed: () {
                          //           selectedFilter.value = AppLocales.freeTables;
                          //           if (selectedPlace.value != null && selectedPlace.value?.children != null) {
                          //             filteredPlaces.value = selectedPlace.value.children.where((el)=> ).toList();
                          //           }
                          //         }),
                          //     CustomPopupItem(
                          //       title: AppLocales.bronTables.tr(),
                          //     ),
                          //   ],
                          //   child: Container(
                          //     height: context.h(52),
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(8),
                          //       color: Colors.white,
                          //       border: Border.all(color: theme.secondaryTextColor.withValues(alpha: 0.4)),
                          //     ),
                          //     padding: Dis.only(lr: context.w(14), tb: context.h(8)),
                          //     child: Row(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       spacing: 8,
                          //       children: [
                          //         Text(
                          //           AppLocales.all.tr(),
                          //           style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                          //         ),
                          //         Icon(Iconsax.arrow_down_1_copy, size: 20),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
            body: RefreshIndicator(
              color: theme.mainColor,
              onRefresh: () async {
                ref.refresh(placesProvider);
                ref.invalidate(placesProvider);
                ref.invalidate(ordersProvider);
                log("refresh");
                return await Future.value();
              },
              child: state.whenProviderData(
                provider: placesProvider,
                builder: (places) {
                  places as List<Place>;
                  if (places.isEmpty) {
                    return Column(
                      children: [
                        Padding(
                          padding: 32.all,
                          child: Row(
                            children: [
                              if (onSelected == null)
                                AppBackButton(
                                  onPressed: () {
                                    AppRouter.open(context, OnboardPage());
                                  },
                                ),
                            ],
                          ),
                        ),
                        Expanded(child: AppEmptyWidget()),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (onSelected == null && !mobile)
                        Container(
                          color: Colors.white,
                          padding:
                              Dis.only(lr: context.w(32), tb: context.h(24)),
                          child: Row(
                            spacing: context.w(16),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AppBackButton(
                                onPressed: () {
                                  if (ref
                                          .watch(currentEmployeeProvider)
                                          .roleName
                                          .toLowerCase() ==
                                      'admin') {
                                    AppRouter.open(context, MainPage());
                                    return;
                                  }
                                  AppRouter.open(context, OnboardPage());
                                },
                              ),
                              0.w,
                              SvgPicture.asset(
                                'assets/images/Vector.svg',
                                height: context.h(mobile ? 20 : 36),
                              ),
                              Spacer(),
                              WebButton(
                                onPressed: () {
                                  ref.invalidate(ordersProvider);
                                  ref.invalidate(ordersProvider(
                                      selectedPlace.value?.id ?? ""));
                                  ref.invalidate(ordersProvider(
                                      fatherPlace.value?.id ?? ""));
                                },
                                builder: (focused) {
                                  return Container(
                                    height: context.s(48),
                                    width: context.s(48),
                                    decoration: BoxDecoration(
                                      color: focused
                                          ? theme.mainColor
                                              .withValues(alpha: 0.1)
                                          : null,
                                      borderRadius: BorderRadius.circular(48),
                                      border: Border.all(
                                          color: theme.secondaryTextColor),
                                    ),
                                    child: Icon(Ionicons.refresh,
                                        size: context.s(24)),
                                  );
                                },
                              ),
                              WebButton(
                                onPressed: () {
                                  showDesktopModal(
                                    context: context,
                                    body: EmployeeOrdersPage(),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                  );
                                },
                                builder: (focused) {
                                  return Container(
                                    height: context.s(48),
                                    width: context.s(48),
                                    decoration: BoxDecoration(
                                      color: focused
                                          ? theme.mainColor
                                              .withValues(alpha: 0.1)
                                          : null,
                                      borderRadius: BorderRadius.circular(48),
                                      border: Border.all(
                                          color: theme.secondaryTextColor),
                                    ),
                                    child: Icon(Ionicons.list_outline,
                                        size: context.s(24)),
                                  );
                                },
                              ),
                              WebButton(
                                onPressed: () {
                                  showDesktopModal(
                                      context: context,
                                      body: EmployeeSettingsScreen());
                                },
                                builder: (focused) {
                                  return Container(
                                    height: context.s(48),
                                    width: context.s(48),
                                    decoration: BoxDecoration(
                                      color: focused
                                          ? theme.mainColor
                                              .withValues(alpha: 0.1)
                                          : null,
                                      borderRadius: BorderRadius.circular(48),
                                      border:
                                          Border.all(color: theme.mainColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        employee.fullname.initials,
                                        style: TextStyle(
                                          fontSize: context.s(20),
                                          fontFamily: boldFamily,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      if (mobile)
                        Container(
                          color: theme.scaffoldBgColor,
                          padding:
                              Dis.only(lr: context.w(32), tb: context.h(24)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: context.w(16),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (onSelected != null) AppBackButton(),
                                if (!mobile)
                                  Text(
                                    AppLocales.choosePlace.tr(),
                                    style: TextStyle(
                                      fontFamily: mediumFamily,
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.s(24),
                                    ),
                                  ),
                                Row(
                                  spacing: context.w(16),
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: Colors.white,
                                      ),
                                      padding: context.s(12).all,
                                      child: Row(
                                        spacing: context.w(12),
                                        children: [
                                          Icon(Icons.circle,
                                              color: theme.mainColor,
                                              size: context.s(16)),
                                          Text(
                                            AppLocales.freeTables.tr(),
                                            style: TextStyle(
                                              fontSize: context.s(16),
                                              fontFamily: mediumFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: Colors.white,
                                      ),
                                      padding: context.s(12).all,
                                      child: Row(
                                        spacing: context.w(8),
                                        children: [
                                          Icon(Icons.circle,
                                              color: theme.secondaryTextColor,
                                              size: context.s(16)),
                                          Text(
                                            AppLocales.bronTables.tr(),
                                            style: TextStyle(
                                              fontSize: context.s(16),
                                              fontFamily: mediumFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(99),
                                    //     color: Colors.white,
                                    //   ),
                                    //   padding: 12.all,
                                    //   child: Row(
                                    //     spacing: 8,
                                    //     children: [
                                    //       Icon(Icons.circle, color: Colors.blue, size: 16),
                                    //       Text(
                                    //         AppLocales.bandTables.tr(),
                                    //         style: TextStyle(
                                    //           fontSize: 16,
                                    //           fontFamily: mediumFamily,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                if (!mobile)
                                  Row(
                                    spacing: context.w(16),
                                    children: [
                                      CustomPopupMenu(
                                        theme: theme,
                                        children: [
                                          CustomPopupItem(
                                              title: AppLocales.all.tr(),
                                              onPressed: () =>
                                                  selectedPlace.value = null,
                                              icon: Icons.list),
                                          for (final item in places)
                                            CustomPopupItem(
                                              title: item.name,
                                              onPressed: () =>
                                                  selectedPlace.value = item,
                                              icon: Icons.present_to_all,
                                            ),
                                        ],
                                        child: Container(
                                          height: context.h(52),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                            border: Border.all(
                                                color: theme.secondaryTextColor
                                                    .withValues(alpha: 0.4)),
                                          ),
                                          padding: Dis.only(
                                              lr: context.w(14),
                                              tb: context.h(8)),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            spacing: context.w(8),
                                            children: [
                                              Text(
                                                selectedPlace.value == null
                                                    ? AppLocales.choosePlace
                                                        .tr()
                                                    : selectedPlace.value!.name,
                                                style: TextStyle(
                                                    fontSize: context.s(16),
                                                    fontFamily: mediumFamily),
                                              ),
                                              Icon(Iconsax.arrow_down_1_copy,
                                                  size: context.s(20)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // CustomPopupMenu(
                                      //   theme: theme,
                                      //   children: [
                                      //     CustomPopupItem(
                                      //         title: AppLocales.all.tr(), onPressed: () => selectedFilter.value = null, icon: Ionicons.list_outline),
                                      //     CustomPopupItem(
                                      //         title: AppLocales.freeTables.tr(),
                                      //         onPressed: () {
                                      //           selectedFilter.value = AppLocales.freeTables;
                                      //           if (selectedPlace.value != null && selectedPlace.value?.children != null) {
                                      //             filteredPlaces.value = selectedPlace.value.children.where((el)=> ).toList();
                                      //           }
                                      //         }),
                                      //     CustomPopupItem(
                                      //       title: AppLocales.bronTables.tr(),
                                      //     ),
                                      //   ],
                                      //   child: Container(
                                      //     height: context.h(52),
                                      //     decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.circular(8),
                                      //       color: Colors.white,
                                      //       border: Border.all(color: theme.secondaryTextColor.withValues(alpha: 0.4)),
                                      //     ),
                                      //     padding: Dis.only(lr: context.w(14), tb: context.h(8)),
                                      //     child: Row(
                                      //       crossAxisAlignment: CrossAxisAlignment.center,
                                      //       mainAxisAlignment: MainAxisAlignment.center,
                                      //       spacing: 8,
                                      //       children: [
                                      //         Text(
                                      //           AppLocales.all.tr(),
                                      //           style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                                      //         ),
                                      //         Icon(Iconsax.arrow_down_1_copy, size: 20),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Container(
                          padding: mobile
                              ? Dis.only(lr: 16)
                              : Dis.only(lr: context.w(40)),
                          margin: mobile
                              ? Dis.only(lr: 0)
                              : Dis.only(lr: context.w(32)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border.all(
                                color: theme.secondaryTextColor
                                    .withValues(alpha: 0.4)),
                            color: Colors.white,
                          ),
                          child: GridView.builder(
                            padding: Dis.only(tb: context.h(40)),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: mobile ? 2 : 5,
                              mainAxisSpacing: context.s(mobile ? 16 : 80),
                              crossAxisSpacing: context.s(mobile ? 16 : 80),
                              childAspectRatio: Platform.isWindows ? 1.25 : 2,
                            ),
                            itemCount: selectedPlace.value == null
                                ? places.length
                                : selectedPlace.value?.children == null
                                    ? 0
                                    : selectedPlace.value?.children?.length,
                            itemBuilder: (context, index) {
                              final place = selectedPlace.value == null
                                  ? places[index]
                                  : selectedPlace.value?.children == null
                                      ? null
                                      : selectedPlace.value?.children![index];

                              return state.whenProviderData(
                                provider: ordersProvider(place?.id ?? ''),
                                builder: (order) {
                                  order as Order?;
                                  return SimpleButton(
                                    onPressed: () {
                                      if (order != null &&
                                          order.employee.id != employee.id &&
                                          employee.roleName.toLowerCase() !=
                                              'admin') {
                                        ShowToast.error(context,
                                            AppLocales.otherEmployeeOrder.tr());
                                        return;
                                      }
                                      selectedPlace.value = place;

                                      if (place == null) {
                                        Place kPlace = places[index];
                                        kPlace.father = fatherPlace.value;
                                        try {
                                          ref.invalidate(
                                              ordersProvider(kPlace.id));
                                          ref.refresh(
                                              ordersProvider(kPlace.id));
                                        } catch (_) {}

                                        if (onSelected != null) {
                                          onSelected!(kPlace);
                                          return;
                                        }

                                        AppRouter.go(
                                                context,
                                                MenuPage(
                                                    place: kPlace,
                                                    fatherPlace:
                                                        fatherPlace.value))
                                            .then((_) {
                                          fatherPlace.value = null;
                                          selectedPlace.value = null;
                                        });
                                        return;
                                      }

                                      if (place.children == null ||
                                          place.children!.isEmpty) {
                                        Place kPlace = place;
                                        kPlace.father = fatherPlace.value;

                                        try {
                                          ref.invalidate(
                                              ordersProvider(place.id));
                                          ref.refresh(ordersProvider(place.id));
                                        } catch (_) {}

                                        if (onSelected != null) {
                                          onSelected!(kPlace);
                                          return;
                                        }

                                        AppRouter.go(
                                          context,
                                          MenuPage(
                                              place: kPlace,
                                              fatherPlace: fatherPlace.value),
                                        ).then((_) {
                                          fatherPlace.value = null;
                                          selectedPlace.value = null;
                                        });
                                        return;
                                      }

                                      fatherPlace.value = place;
                                    },
                                    child: mobile
                                        ? Container(
                                            padding: 4.all,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: order == null
                                                  ? theme.mainColor
                                                  : theme.accentColor,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  place?.name ?? '',
                                                  style: TextStyle(
                                                    fontFamily: boldFamily,
                                                    color: order == null
                                                        ? Colors.white
                                                        : theme.textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                if (place != null &&
                                                    place.price != null &&
                                                    place.price != 0.0)
                                                  Text(
                                                    place.price!.priceUZS,
                                                    style: TextStyle(
                                                      fontFamily: mediumFamily,
                                                      color: order == null
                                                          ? Colors.white
                                                          : theme.textColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                if (order != null &&
                                                    order.employee.fullname
                                                        .isNotEmpty)
                                                  Text(
                                                    order.employee.fullname,
                                                    style: TextStyle(
                                                      fontFamily: mediumFamily,
                                                      color: theme.textColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          )
                                        : _buildTable(
                                            context: context,
                                            theme: theme,
                                            name: (place?.name ?? '') +
                                                (order != null
                                                    ? "\n${order.employee.fullname}"
                                                    : ''),
                                            status:
                                                order == null ? 'free' : 'bron',
                                            employee: order?.employee.fullname,
                                            price: place?.price,
                                          ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
