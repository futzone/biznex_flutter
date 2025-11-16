import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/services/warehouse_printer_services.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/product_order_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/model/category_model/category_model.dart';

class EmployeeMonitoringPage extends HookConsumerWidget {
  final AppColors theme;
  final Employee employee;

  EmployeeMonitoringPage(this.theme, this.employee, {super.key});

  // Map _calculateProductOrder(DateTime day, List<Order> orders) {
  //   final Map<String, dynamic> categoryMap = {};
  //
  //   for (final order in orders) {
  //     final created = DateTime.parse(order.createdDate);
  //
  //     if (created.day == day.day &&
  //         created.month == day.month &&
  //         created.year == day.year &&
  //         _checkOwner(order.employee)) {
  //       for (final item in order.products) {
  //         final category = item.product.category;
  //         final categoryId = category?.id ?? 'others';
  //
  //         if (!categoryMap.containsKey(categoryId)) {
  //           categoryMap[categoryId] = {
  //             'category': category ?? Category(name: AppLocales.others.tr()),
  //             'products': {},
  //           };
  //         }
  //
  //         final productsMap = categoryMap[categoryId]['products'];
  //
  //         if (productsMap.containsKey(item.product.id)) {
  //           productsMap[item.product.id]['amount'] =
  //               productsMap[item.product.id]['amount'] + item.amount;
  //         } else {
  //           productsMap[item.product.id] = {
  //             'product': item.product,
  //             'amount': item.amount,
  //           };
  //         }
  //       }
  //     }
  //   }
  //
  //   return categoryMap;
  // }

  Widget buildMobile(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime>(DateTime.now());
    final orders = ref.read(dayOrdersProvider(selectedDate.value)).value ?? [];
    final filter = useMemoized(
        () => ProductOrderFilter(
              day: selectedDate.value,
              orders: orders,
              employee: employee,
            ),
        [selectedDate.value, orders, employee]);

    final productMapListener = ref.watch(productOrdersProvider(filter));

    final style = TextStyle(fontFamily: mediumFamily, fontSize: context.s(14));
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.monitoring.tr()),
        actions: [
          IconButton(
            onPressed: () {
              showDatePicker(
                context: context,
                firstDate: DateTime(2025, 1),
                lastDate: DateTime.now(),
                initialDate: selectedDate.value,
              ).then((date) {
                if (date != null) {
                  selectedDate.value = date;
                }
              });
            },
            icon: Icon(Iconsax.calendar_1_copy),
          ),
          8.w,
        ],
      ),
      body: productMapListener.when(
        error: RefErrorScreen,
        loading: RefLoadingScreen,
        data: (productMap) {
          return CustomScrollView(
            slivers: [
              SliverPinnedHeader(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.appBarColor,
                    border: Border(
                      top: BorderSide(color: theme.accentColor),
                    ),
                  ),
                  padding: Dis.only(lr: 16, tb: 12),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      AppLocales.productName.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: mediumFamily,
                      ),
                    )),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocales.price.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppLocales.amount.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ],
                    )),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ...productMap.keys.map((key) {
                      final category = productMap[key]['category'] as Category;
                      return Column(
                        children: [
                          16.h,
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: theme.textColor,
                                ),
                              ),
                              Container(
                                padding: Dis.only(lr: 24, tb: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.textColor),
                                ),
                                child: Center(child: Text(category.name)),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: theme.textColor,
                                ),
                              )
                            ],
                          ),
                          8.h,
                          ...(productMap[key]['products'] as Map)
                              .keys
                              .map((id) {
                            final ctgObject = productMap[key]['products'];
                            final product = ctgObject[id]['product'] as Product;
                            final amount = ctgObject[id]['amount'] as num;
                            return Container(
                              padding: Dis.only(
                                  lr: context.w(20), tb: context.h(12)),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: theme.scaffoldBgColor)),
                                color: theme.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Center(
                                          child: Text(product.name,
                                              style: style))),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        product.price.priceUZS,
                                        style: style,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          amount.toMeasure,
                                          style: style.copyWith(
                                              fontFamily: boldFamily),
                                        ),
                                        Text(
                                          (product.measure ?? '').capitalize,
                                          style: style.copyWith(
                                            fontSize: context.s(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      );
                    })
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    if (!Platform.isWindows) return buildMobile(context, ref);
    final style = TextStyle(fontFamily: mediumFamily, fontSize: context.s(14));

    final selectedDate = useState<DateTime>(DateTime.now());
    final orders = ref.read(dayOrdersProvider(selectedDate.value)).value ?? [];

     final filter = useMemoized(
        () => ProductOrderFilter(
              day: selectedDate.value,
              orders: orders,
              employee: employee,
            ),
        [selectedDate.value, orders, employee]);

    final productMapListener = ref.watch(productOrdersProvider(filter));

    return productMapListener.when(
      error: RefErrorScreen,
      loading: RefLoadingScreen,
      data: (productMap) {
        return Column(
          children: [
            Row(
              spacing: 16,
              children: [
                AppBackButton(),
                Text(
                  employee.fullname,
                  style: TextStyle(
                    fontSize: context.s(24),
                    fontFamily: mediumFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                SimpleButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime.now(),
                    ).then((dt) {
                      if (dt != null) selectedDate.value = dt;
                    });
                  },
                  child: Container(
                    padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.accentColor),
                    child: Row(
                      children: [
                        Text(
                          DateFormat("dd-MMMM", context.locale.languageCode)
                              .format(selectedDate.value),
                          style:
                              TextStyle(fontFamily: mediumFamily, fontSize: 16),
                        ),
                        8.w,
                        Icon(Iconsax.calendar_1_copy)
                      ],
                    ),
                  ),
                ),
                SimpleButton(
                  onPressed: () async {
                    await WarehousePrinterServices.printEmployeeFood(
                      employee: employee,
                      productMap: productMap,
                      day: selectedDate.value,
                      context: context,
                    );
                  },
                  child: Container(
                    padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor,
                    ),
                    child: Row(
                      children: [
                        Text(
                          AppLocales.print.tr(),
                          style:
                              TextStyle(fontFamily: mediumFamily, fontSize: 16),
                        ),
                        8.w,
                        Icon(Ionicons.print_outline)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            16.h,
            Container(
              // margin: Dis.only(lr: context.s(24)),
              padding: Dis.only(lr: context.w(16), tb: context.h(12)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
                color: theme.scaffoldBgColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocales.productName.tr(),
                        style: style,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocales.price.tr(),
                        style: style,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocales.amount.tr(),
                        style: style,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocales.totalPrice.tr(),
                        style: style,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: theme.scaffoldBgColor),
                    right: BorderSide(color: theme.scaffoldBgColor),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...productMap.keys.map((key) {
                        final category =
                            productMap[key]['category'] as Category;
                        return Column(
                          children: [
                            16.h,
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: theme.textColor,
                                  ),
                                ),
                                Container(
                                  padding: Dis.only(lr: 24, tb: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.textColor),
                                  ),
                                  child: Center(child: Text(category.name)),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: theme.textColor,
                                  ),
                                )
                              ],
                            ),
                            ...(productMap[key]['products'] as Map)
                                .keys
                                .map((id) {
                              final ctgObject = productMap[key]['products'];
                              final product =
                                  ctgObject[id]['product'] as Product;
                              final amount = ctgObject[id]['amount'] as num;
                              return Container(
                                padding: Dis.only(
                                    lr: context.w(20), tb: context.h(12)),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: theme.scaffoldBgColor)),
                                  color: theme.white,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Center(
                                            child: Text(product.name,
                                                style: style))),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          product.price.priceUZS,
                                          style: style,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 4,
                                        children: [
                                          Text(
                                            amount.toMeasure,
                                            style: style.copyWith(
                                                fontFamily: boldFamily),
                                          ),
                                          Text(
                                            (product.measure ?? '').capitalize,
                                            style: style.copyWith(
                                              fontSize: context.s(12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          (product.price * amount).priceUZS,
                                          style: style,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                          ],
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
