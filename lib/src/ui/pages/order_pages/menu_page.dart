import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/minimalistic_menu_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/pages/order_pages/employee_orders_page.dart';
import 'package:biznex/src/ui/pages/order_pages/table_choose_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/model/order_models/order_model.dart';
import '../../../providers/employee_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../screens/order_screens/order_half_page.dart';
import '../../screens/order_screens/order_items_page.dart';
import '../../screens/settings_screen/employee_settings_screen.dart';
import 'change_order_place.dart';

class MenuPage extends HookConsumerWidget {
  final Place place;
  final Place? fatherPlace;

  const MenuPage({super.key, required this.place, this.fatherPlace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = getDeviceType(context) == DeviceType.mobile;
    final employee = ref.watch(currentEmployeeProvider);
    final minimalistic = ref.watch(minimalisticMenuProvider).value ?? false;
    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        appBar: !mobile
            ? null
            : AppBar(
                title: SimpleButton(
                  onPressed: () {
                    showDesktopModal(
                      context: context,
                      body: ChangeOrderPlace(place),
                      width: MediaQuery.of(context).size.width * 0.96,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        place.name +
                            ((place.father?.name == null || place.father!.name.isEmpty)
                                ? ''
                                : ', ${place.father!.name}'),
                        style: TextStyle(
                          fontSize: context.s(20),
                          fontFamily: boldFamily,
                          color: Colors.white,
                        ),
                      ),
                      8.w,
                      Icon(Icons.edit, color: theme.secondaryTextColor, size: context.s(20))
                    ],
                  ),
                ),
              ),
        floatingActionButton: !mobile
            ? null
            : FloatingActionButton(
                backgroundColor: theme.mainColor,
                child: Icon(Iconsax.add_copy, size: 32, color: Colors.white),
                onPressed: () {
                  AppRouter.go(context, OrderHalfPage(place, minimalistic: minimalistic));
                },
              ),
        body: mobile
            ? RefreshIndicator(
                onRefresh: () async {
                  await ref.refresh(ordersProvider(place.id).future).then((order) {
                    if (order != null) {
                      ref.read(orderSetProvider.notifier).clearPlaceItems(place.id);
                      Future.delayed(Duration(milliseconds: 100));
                      ref.read(orderSetProvider.notifier).addMultiple(order.products);
                    } else {
                      // ref.read(orderSetProvider.notifier).clear();
                    }
                  });

                  return await Future.value();
                },
                child: Column(
                  children: [
                    OrderItemsPage(place: place, theme: theme, state: state),
                  ],
                ),
              )
            : Column(
                children: [
                  if (!mobile)
                    Container(
                      color: Colors.white,
                      padding: Dis.only(lr: context.w(32), tb: context.h(24)),
                      child: Row(
                        spacing: context.w(16),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppBackButton(
                            onPressed: () => AppRouter.open(context, TableChooseScreen()),
                          ),
                          0.w,
                          SvgPicture.asset(
                            'assets/images/Vector.svg',
                            height: context.s(36),
                          ),
                          Spacer(),
                          SimpleButton(
                            onPressed: () {
                              showDesktopModal(
                                context: context,
                                body: ChangeOrderPlace(place),
                                width: MediaQuery.of(context).size.width * 0.96,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  place.name +
                                      ((place.father?.name == null || place.father!.name.isEmpty)
                                          ? ''
                                          : ', ${place.father!.name}'),
                                  style: TextStyle(
                                    fontSize: context.s(20),
                                    fontFamily: boldFamily,
                                    color: Colors.black,
                                  ),
                                ),
                                8.w,
                                Icon(Icons.edit, color: theme.secondaryTextColor, size: 20)
                              ],
                            ),
                          ),
                          Spacer(),
                          WebButton(
                            onPressed: () {
                              AppRouter.open(context, OnboardPage());
                            },
                            builder: (focused) {
                              return Container(
                                height: context.s(48),
                                width: context.s(48),
                                decoration: BoxDecoration(
                                  color: focused ? theme.mainColor.withValues(alpha: 0.1) : null,
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: theme.secondaryTextColor),
                                ),
                                child: Icon(Iconsax.home_copy, size: context.s(24)),
                              );
                            },
                          ),
                          WebButton(
                            onPressed: () async {
                              await ref.refresh(ordersProvider(place.id).future).then((order) {
                                if (order != null) {
                                  ref.read(orderSetProvider.notifier).clearPlaceItems(place.id);
                                  Future.delayed(Duration(milliseconds: 100));
                                  ref.read(orderSetProvider.notifier).addMultiple(order.products);
                                } else {
                                  // ref.read(orderSetProvider.notifier).clear();
                                }
                              });
                              // ref.read(orderSetProvider.notifier).addMultiple(order.products);

                              try {
                                ref.invalidate(productsProvider);
                               } catch (_) {}
                            },
                            builder: (focused) {
                              return Container(
                                height: context.s(48),
                                width: context.s(48),
                                decoration: BoxDecoration(
                                  color: focused ? theme.mainColor.withValues(alpha: 0.1) : null,
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: theme.secondaryTextColor),
                                ),
                                child: Icon(Ionicons.refresh, size: context.s(24)),
                              );
                            },
                          ),
                          WebButton(
                            onPressed: () async => await setMenuMode(ref, !minimalistic),
                            builder: (focused) {
                              return Container(
                                height: context.s(48),
                                width: context.s(48),
                                decoration: BoxDecoration(
                                  color: focused ? theme.mainColor.withValues(alpha: 0.1) : null,
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(
                                    color: minimalistic ? theme.mainColor : theme.secondaryTextColor,
                                  ),
                                ),
                                child: Icon(
                                  Ionicons.grid_outline,
                                  size: context.s(24),
                                  color: minimalistic ? theme.mainColor : null,
                                ),
                              );
                            },
                          ),
                          WebButton(
                            onPressed: () {
                              showDesktopModal(
                                context: context,
                                body: EmployeeOrdersPage(),
                                width: MediaQuery.of(context).size.width * 0.8,
                              );
                            },
                            builder: (focused) {
                              return Container(
                                height: context.s(48),
                                width: context.s(48),
                                decoration: BoxDecoration(
                                  color: focused ? theme.mainColor.withValues(alpha: 0.1) : null,
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: theme.secondaryTextColor),
                                ),
                                child: Icon(Ionicons.list_outline, size: context.s(24)),
                              );
                            },
                          ),
                          WebButton(
                            onPressed: () {
                              showDesktopModal(context: context, body: EmployeeSettingsScreen());
                            },
                            builder: (focused) {
                              return Container(
                                height: context.s(48),
                                width: context.s(48),
                                decoration: BoxDecoration(
                                  color: focused ? theme.mainColor.withValues(alpha: 0.1) : null,
                                  borderRadius: BorderRadius.circular(48),
                                  border: Border.all(color: theme.mainColor),
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
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OrderHalfPage(place, minimalistic: minimalistic),
                        Container(
                          height: double.infinity,
                          width: 2,
                          color: Colors.white,
                          margin: Dis.only(lr: context.w(24)),
                        ),
                        state.whenProviderData(
                          provider: ordersProvider(place.id),
                          builder: (order) {
                            order as Order?;
                            Place? kPlace;

                            kPlace = place;
                            if (fatherPlace != null) {
                              kPlace.father = fatherPlace;
                            }

                            return OrderItemsPage(
                              state: state,
                              theme: theme,
                              place: kPlace,
                              minimalistic: minimalistic,
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
      );
    });
  }
}
