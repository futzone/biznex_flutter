import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/pages/waiter_pages/waiter_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'order_card.dart';

class OrdersPage extends StatefulHookConsumerWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    final orderFilter = useState(OrderFilterModel());
    final placeFather = useState<Place?>(null);
    final searchController = useTextEditingController();

    final controller = useScrollController();
    final pinned = useState(false);

    useEffect(() {
      controller.addListener(() {
        pinned.value = controller.offset > 40;
      });
      return () {};
    });

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        floatingActionButton: WebButton(
          onPressed: () {
            AppRouter.go(context, WaiterPage(haveBack: true));
          },
          builder: (focused) => AnimatedContainer(
            duration: theme.animationDuration,
            height: focused ? 80 : 64,
            width: focused ? 80 : 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xff5CF6A9), width: 2),
              color: theme.mainColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(3, 3),
                )
              ],
            ),
            child: Center(
              child: Icon(Iconsax.add_copy, color: Colors.white, size: focused ? 40 : 32),
            ),
          ),
        ),
        body: ref.watch(ordersFilterProvider(orderFilter.value)).when(
              loading: () => AppLoadingScreen(),
              error: (error, stackTrace) => AppErrorScreen(),
              data: (orders) {
                return Padding(
                  padding: Dis.only(lr: context.w(24), top: context.h(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: Dis.only(tb: context.h(4), lr: context.w(4)),
                        height: context.h(58),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: Row(
                          spacing: context.w(16),
                          children: [
                            Expanded(
                              child: state.whenProviderData(
                                provider: placesProvider,
                                builder: (places) {
                                  places as List<Place>;

                                  return CustomPopupMenu(
                                    theme: theme,
                                    children: [
                                      CustomPopupItem(
                                        title: AppLocales.all.tr(),
                                        onPressed: () {
                                          placeFather.value = null;
                                          OrderFilterModel filterModel = orderFilter.value;
                                          filterModel.place = null;
                                          orderFilter.value = filterModel;
                                          setState(() {});
                                          ref.invalidate(ordersFilterProvider);
                                        },
                                      ),
                                      for (final pls in places)
                                        CustomPopupItem(
                                          title: pls.name,
                                          onPressed: () {
                                            if (pls.children != null && pls.children!.isNotEmpty) {
                                              placeFather.value = pls;
                                              OrderFilterModel filterModel = orderFilter.value;
                                              filterModel.place = pls.id;
                                              orderFilter.value = filterModel;
                                              setState(() {});
                                              return;
                                            }

                                            placeFather.value = null;
                                            OrderFilterModel filterModel = orderFilter.value;
                                            filterModel.place = pls.id;
                                            orderFilter.value = filterModel;
                                            setState(() {});
                                            ref.invalidate(ordersFilterProvider);
                                          },
                                        )
                                    ],
                                    child: Container(
                                      padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: orderFilter.value.place == null ? null : theme.mainColor,
                                        border: orderFilter.value.place == null ? null : Border.all(color: theme.mainColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          orderFilter.value.place == null
                                              ? AppLocales.places.tr()
                                              : placeFather.value != null
                                                  ? placeFather.value!.name
                                                  : places.firstWhere((el) => el.id == orderFilter.value.place).name,
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: orderFilter.value.place == null ? theme.secondaryTextColor : theme.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: state.whenProviderData(
                                provider: employeeProvider,
                                builder: (places) {
                                  places as List<Employee>;

                                  return CustomPopupMenu(
                                    theme: theme,
                                    children: [
                                      CustomPopupItem(
                                        title: AppLocales.all.tr(),
                                        onPressed: () {
                                          OrderFilterModel filterModel = orderFilter.value;
                                          filterModel.employee = null;
                                          orderFilter.value = filterModel;
                                          setState(() {});
                                          ref.invalidate(ordersFilterProvider);
                                        },
                                      ),
                                      for (final item in places)
                                        CustomPopupItem(
                                            title: item.fullname,
                                            onPressed: () {
                                              OrderFilterModel filterModel = orderFilter.value;
                                              filterModel.employee = item.id;
                                              orderFilter.value = filterModel;
                                              setState(() {});

                                              ref.invalidate(ordersFilterProvider);
                                            }),
                                    ],
                                    child: Container(
                                      padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: orderFilter.value.employee == null ? null : Border.all(color: theme.mainColor),
                                        color: orderFilter.value.employee == null ? null : theme.mainColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          orderFilter.value.employee == null
                                              ? AppLocales.employees.tr()
                                              : places
                                                  .firstWhere(
                                                    (el) => el.id == orderFilter.value.employee,
                                                    orElse: () => Employee(
                                                      fullname: AppLocales.employees.tr(),
                                                      roleId: '',
                                                      roleName: ''
                                                          '',
                                                    ),
                                                  )
                                                  .fullname,
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: orderFilter.value.employee == null ? theme.secondaryTextColor : theme.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: state.whenProviderData(
                                provider: productsProvider,
                                builder: (places) {
                                  places as List<Product>;

                                  return CustomPopupMenu(
                                    theme: theme,
                                    children: [
                                      CustomPopupItem(
                                        title: AppLocales.all.tr(),
                                        onPressed: () {
                                          OrderFilterModel filterModel = orderFilter.value;
                                          filterModel.product = null;
                                          orderFilter.value = filterModel;
                                          setState(() {});
                                          ref.invalidate(ordersFilterProvider);
                                        },
                                      ),
                                      for (int i = 0; i < ((places.length > 100) ? 100 : places.length); i++)
                                        CustomPopupItem(
                                          title: places[i].name,
                                          onPressed: () {
                                            OrderFilterModel filterModel = orderFilter.value;
                                            filterModel.product = places[i].id;
                                            orderFilter.value = filterModel;
                                            setState(() {});

                                            ref.invalidate(ordersFilterProvider);
                                          },
                                        )
                                    ],
                                    child: Container(
                                      padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: orderFilter.value.product == null ? null : theme.mainColor,
                                        border: orderFilter.value.product == null ? null : Border.all(color: theme.mainColor),
                                      ),
                                      child: Center(
                                        child: Text(
                                          orderFilter.value.product == null
                                              ? AppLocales.products.tr()
                                              : places
                                                  .firstWhere(
                                                    (el) => el.id == orderFilter.value.product,
                                                    orElse: () => Product(name: AppLocales.products.tr(), price: 0),
                                                  )
                                                  .name,
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: orderFilter.value.product == null ? theme.secondaryTextColor : theme.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: SimpleButton(
                                onPressed: () {
                                  showDatePicker(context: context, firstDate: DateTime(2025, 1), lastDate: DateTime.now()).then((date) {
                                    if (date != null) {
                                      OrderFilterModel filterModel = orderFilter.value;
                                      filterModel.dateTime = date;
                                      orderFilter.value = filterModel;
                                      setState(() {});

                                      ref.invalidate(ordersFilterProvider);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    // color: theme.accentColor,
                                    border: orderFilter.value.dateTime == null ? null : Border.all(color: theme.mainColor),
                                    color: orderFilter.value.dateTime == null ? null : theme.mainColor,
                                  ),
                                  child: Center(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          orderFilter.value.dateTime == null
                                              ? AppLocales.date.tr()
                                              : DateFormat('d-MMMM').format(orderFilter.value.dateTime!),
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: orderFilter.value.dateTime == null ? theme.secondaryTextColor : theme.white,
                                          ),
                                        ),
                                        if (orderFilter.value.dateTime != null) 16.w,
                                        if (orderFilter.value.dateTime != null)
                                          SimpleButton(
                                            onPressed: () {
                                              OrderFilterModel filterModel = orderFilter.value;
                                              filterModel.dateTime = null;
                                              orderFilter.value = filterModel;
                                              setState(() {});
                                              ref.invalidate(ordersFilterProvider);
                                            },
                                            child: Icon(
                                              Ionicons.close_circle_outline,
                                              color: Colors.red,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      16.h,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocales.orders.tr(),
                              style: TextStyle(
                                fontFamily: boldFamily,
                                fontSize: context.s(24),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: AppTextField(
                              title: AppLocales.enterOrderId.tr(),
                              controller: searchController,
                              theme: theme,
                              suffixIcon: Icon(Iconsax.search_normal_1_copy),
                              fillColor: Colors.white,
                              onChanged: (char) {
                                OrderFilterModel filterModel = orderFilter.value;
                                filterModel.query = char;
                                orderFilter.value = filterModel;
                                setState(() {});
                                ref.invalidate(ordersFilterProvider);
                              },
                            ),
                          )
                        ],
                      ),
                      16.h,
                      if (pinned.value)
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                          color: theme.secondaryTextColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),

                      Expanded(
                        child: orders.isEmpty
                            ? AppEmptyWidget()
                            : GridView.builder(
                          padding: 120.bottom,
                                controller: controller,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: context.w(16),
                                  mainAxisSpacing: context.h(16),
                                  childAspectRatio: 353 / 363,
                                ),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return OrderCard(order: orders[index], theme: theme);
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
      );
    });
  }
}
