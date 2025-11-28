import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_employees_page.dart';
import 'package:biznex/src/ui/screens/monitoring_screen/monitoring_card_screen.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_products_page.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_orders_page.dart';
import 'package:biznex/src/ui/screens/monitoring_screen/monitoring_page_items.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../controllers/monitoring_controller.dart';
import '../../../core/isolate/time_range_filter.dart';
import '../../../core/model/order_models/order_model.dart';
import '../../screens/chart_screens/monitoring_chart_screen.dart';
import '../../widgets/helpers/app_decorated_button.dart';
import 'monitoring_ingredients_page.dart';
import 'monitoring_payments_page.dart';

class MonitoringPage extends StatefulHookConsumerWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage> {
  final Isar isar = IsarDatabase.instance.isar;

  double _totalShopping = 0.0;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _currentDate;
  double _ordersSumm = 0.0;
  double _totalSumm = 0.0;
  double _percentsSumm = 0.0;
  bool _textForRange = false;
  double _placePrice = 0.0;
  int ordersCount = 0;

  void _onGetShopping() async {
    await ShoppingDatabase()
        .getShoppingStats(_startDate ?? DateTime.now(), end: _endDate)
        .then((v) => setState(() => _totalShopping = v));
  }

  Future<void> _onChooseRange(DateTimeRange? range) async {
    if (range == null) return;

    showAppLoadingDialog(context);

    _onGetShopping();

    _textForRange = true;
    _startDate = range.start;
    _endDate = range.end;

    final orderPercents = await OrderPercentDatabase().get();
    final result =
        await calculateRangeStats(range.start, range.end, orderPercents);

    _ordersSumm = result['ordersSumm'] ?? 0.0;
    _totalSumm = result['totalSumm'] ?? 0.0;
    _percentsSumm = result['percentsSumm'] ?? 0.0;
    _placePrice = result['placePrice'] ?? 0.0;

    setState(() {});

    AppRouter.close(context);
  }

  Future<Map<String, double>> calculateRangeStats(
    DateTime start,
    DateTime end,
    List percentItems,
  ) async {
    const chunkSize = 500;

    double ordersSumm = 0;
    double totalSumm = 0;
    double percentsSumm = 0;
    double placePrice = 0;

    final query = isar.orderIsars.where().filter().createdDateBetween(
          start.toIso8601String(),
          end.toIso8601String(),
        );

    await query.count().then((count) {
      setState(() {
        ordersCount = count;
      });
    });

    int offset = 0;

    while (true) {
      final batch = await query.offset(offset).limit(chunkSize).findAll();

      if (batch.isEmpty) break;

      final converted = batch.map((e) => Order.fromIsar(e)).toList();

      final res = await compute(
        calculateRangeStatsIsolate,
        {
          'orders': converted,
          'percentItems': percentItems,
          'ordersSumm': ordersSumm,
          'totalSumm': totalSumm,
          'percentsSumm': percentsSumm,
          'placePrice': placePrice,
        },
      );

      ordersSumm = res['ordersSumm']!;
      totalSumm = res['totalSumm']!;
      percentsSumm = res['percentsSumm']!;
      placePrice = res['placePrice']!;

      offset += chunkSize;
    }

    return {
      'ordersSumm': ordersSumm,
      'totalSumm': totalSumm,
      'percentsSumm': percentsSumm,
      'placePrice': placePrice,
    };
  }

  @override
  void initState() {
    super.initState();
    _onGetShopping();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(todayOrdersProvider).value ?? [];
    final percent = (ref.watch(orderPercentProvider).value ?? [])
        .fold(0.0, (perc, item) => perc + item.percent);

    double ordersSumm = 0.0;
    double totalSumm = 0.0;
    double percentsSumm = 0.0;
    double placePrice = 0.0;

    double getOrdersSumm() {
      if (_currentDate == null && _startDate == null) return ordersSumm;
      return _ordersSumm;
    }

    int getOrdersCount() {
      if (_currentDate == null && _startDate == null) return data.length;
      return ordersCount;
    }

    double getTotalSumm() {
      if (_currentDate == null && _startDate == null) return totalSumm;
      return _totalSumm;
    }

    double getPercentsSumm() {
      if (_currentDate == null && _startDate == null) return percentsSumm;
      return _percentsSumm;
    }

    double getPlacePriceSumm() {
      if (_currentDate == null && _startDate == null) return placePrice;
      return _placePrice;
    }

    double getTotalProfit() {
      return getTotalSumm() + getPercentsSumm();
    }

    for (final kOrder in data) {
      final order = Order.fromIsar(kOrder);
      final productOldPrice = order.products.fold(0.0, (value, product) {
        final kPrice = (product.amount *
            (product.product.price *
                (1 - (100 / (100 + product.product.percent)))));
        return value + kPrice;
      });

      ordersSumm += order.price;
      totalSumm += productOldPrice;
      if (!order.place.percentNull) {
        percentsSumm += (order.price * (1 - (100 / (100 + percent))));
      }

      if (order.place.price != null) {
        placePrice += order.place.price!;
      }
    }

    return AppStateWrapper(
      builder: (theme, state) {
        final MonitoringPageItems pageItems = MonitoringPageItems(
          theme,
          context,
        );
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPinnedHeader(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBgColor,
                  ),
                  padding: Dis.only(lr: context.w(24), tb: context.h(24)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: context.w(16),
                    children: [
                      Expanded(
                        child: Text(
                          AppLocales.reports.tr(),
                          style: TextStyle(
                            fontSize: context.s(24),
                            fontFamily: mediumFamily,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      0.w,
                      AppPrimaryButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime.now(),
                          ).then((date) async {
                            if (date == null) return;

                            MonitoringController mc = MonitoringController(
                              state: state,
                              context: context,
                              ref: ref,
                            );
                            await mc.onPrintDayMonitoring(date);
                          });
                        },
                        color: theme.mainColor,
                        // border: Border.all(color: Colors.white),
                        padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                        theme: theme,
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(Iconsax.printer_copy,
                                color: Colors.white, size: 20),
                            Text(
                              AppLocales.monitoringCheckPrint.tr(),
                              style: TextStyle(
                                fontFamily: mediumFamily,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.white,
                  ),
                  margin: Dis.only(lr: context.w(24), bottom: 24),
                  padding: context.s(24).all,
                  // duration: theme.animationDuration,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (_textForRange) ...[
                            Text(
                              DateFormat('yyyy, dd-MMMM',
                                      context.locale.languageCode)
                                  .format(_startDate ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: boldFamily,
                              ),
                            ),
                            4.w,
                            Text(
                              DateFormat('yyyy, dd-MMMM',
                                      context.locale.languageCode)
                                  .format(_endDate ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: boldFamily,
                              ),
                            ),
                            4.w,
                            Text(
                              AppLocales.reportsForRange.tr(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ] else ...[
                            Text(
                              DateFormat('yyyy, dd-MMMM',
                                      context.locale.languageCode)
                                  .format(_currentDate ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: boldFamily,
                              ),
                            ),
                            4.w,
                            Text(
                              AppLocales.reportsForDay.tr(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                          Spacer(),
                          SimpleButton(
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime.now(),
                              ).then((date) async {
                                if (date == null) return;
                                _textForRange = false;

                                _ordersSumm = 0.0;
                                _totalSumm = 0.0;
                                _percentsSumm = 0.0;
                                _placePrice = 0.0;
                                final ordersList =
                                    await OrderDatabase().getDayOrders(date);

                                final percent = (ref
                                            .watch(orderPercentProvider)
                                            .value ??
                                        [])
                                    .fold(0.0,
                                        (perc, item) => perc += item.percent);

                                for (final kItem in ordersList) {
                                  var order = Order.fromIsar(kItem);

                                  final productOldPrice = order.products
                                      .fold(0.0, (value, product) {
                                    final kPrice = (product.amount *
                                        (product.product.price *
                                            (1 -
                                                (100 /
                                                    (100 +
                                                        product.product
                                                            .percent)))));

                                    return value += kPrice;
                                  });

                                  _ordersSumm += order.price;
                                  _totalSumm += productOldPrice;
                                  if (!order.place.percentNull) {
                                    _percentsSumm += (order.price *
                                        (1 - (100 / (100 + percent))));
                                  }

                                  if (order.place.price != null) {
                                    _placePrice += order.place.price!;
                                  }
                                }

                                _currentDate = date;

                                ordersCount = ordersList.length;

                                setState(() {});
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.secondaryColor,
                                border: Border.all(color: theme.mainColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: Dis.only(lr: 16, tb: 8),
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(Iconsax.calendar_1_copy),
                                  Text(
                                    AppLocales.date.tr(),
                                    style: TextStyle(
                                        // color: Colors.white
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          16.w,
                          SimpleButton(
                            onPressed: () {
                              showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime.now(),
                                locale: context.locale,
                              ).then((val) async {
                                await _onChooseRange(val);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.secondaryColor,
                                border: Border.all(color: theme.mainColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: Dis.only(lr: 16, tb: 8),
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(Iconsax.calendar_1_copy),
                                  Text(
                                    AppLocales.dateRange.tr(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...pageItems.buildMonitoringPageItems(
                        getOrdersSumm: getOrdersSumm(),
                        getOrdersCount: getOrdersCount(),
                        getTotalSumm: getTotalSumm(),
                        getPercentsSumm: getPercentsSumm(),
                        getPlacePriceSumm: getPlacePriceSumm(),
                        totalShopping: _totalShopping,
                        getTotalProfit: getTotalProfit(),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MonitoringChartScreen(),
              ),
              SliverPadding(
                padding: Dis.only(lr: context.w(24), bottom: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    spacing: context.h(24),
                    children: [
                      Row(
                        spacing: context.w(24),
                        children: [
                          Expanded(
                            child: state.whenProviderData(
                              provider: employeeProvider,
                              builder: (emp) {
                                return MonitoringCard(
                                  count: emp.length,
                                  icon: Iconsax.profile_2user,
                                  theme: theme,
                                  title: AppLocales.employees.tr(),
                                  onPressed: () {
                                    showDesktopModal(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      context: context,
                                      body: MonitoringEmployeesPage(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: state.whenProviderData(
                              provider: productsProvider,
                              builder: (prd) {
                                return MonitoringCard(
                                  count: prd.length,
                                  icon: Iconsax.reserve,
                                  theme: theme,
                                  title: AppLocales.products.tr(),
                                  onPressed: () {
                                    showDesktopModal(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      context: context,
                                      body: MonitoringProductsPage(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: context.w(24),
                        children: [
                          Expanded(
                            child: state.whenProviderData(
                              provider: orderLengthProvider,
                              builder: (ord) {
                                return MonitoringCard(
                                  count: ord,
                                  icon: Iconsax.bag_happy,
                                  theme: theme,
                                  title: AppLocales.orders.tr(),
                                  onPressed: () {
                                    showDesktopModal(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      context: context,
                                      body: MonitoringOrdersPage(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: state.whenProviderData(
                              provider: ingredientsProvider,
                              builder: (ord) {
                                return MonitoringCard(
                                  count: ord.length,
                                  icon: Icons.set_meal,
                                  theme: theme,
                                  title: AppLocales.ingredients.tr(),
                                  onPressed: () {
                                    showDesktopModal(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      context: context,
                                      body: MonitoringIngredientsPage(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          // Expanded(
                          //   child: state.whenProviderData(
                          //     provider: transactionProvider,
                          //     builder: (trs) {
                          //       return MonitoringCard(
                          //         icon: Iconsax.send_sqaure_2,
                          //         theme: theme,
                          //         title: AppLocales.transactions.tr(),
                          //         onPressed: () {
                          //           showDesktopModal(
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.8,
                          //             context: context,
                          //             body: MonitoringTransactionsPage(),
                          //           );
                          //         },
                          //         count: trs.length,
                          //       );
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      Row(
                        spacing: context.w(24),
                        children: [
                          Expanded(
                            child: state.whenProviderData(
                              provider: todayOrdersProvider,
                              builder: (trs) {
                                return MonitoringCard(
                                  icon: Iconsax.money_2,
                                  theme: theme,
                                  title: AppLocales.payments.tr(),
                                  onPressed: () {
                                    showDesktopModal(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      context: context,
                                      body: MonitoringPaymentsPage(theme),
                                    );
                                  },
                                  count: trs.length,
                                );
                              },
                            ),
                          ),
                          Expanded(child: SizedBox())
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
