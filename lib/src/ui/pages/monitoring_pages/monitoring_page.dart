import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_transactions_page.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_employees_page.dart';
import 'package:biznex/src/ui/screens/monitoring_screen/monitoring_card_screen.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_products_page.dart';
import 'package:biznex/src/ui/pages/monitoring_pages/monitoring_orders_page.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/model/order_models/order_model.dart';

class MonitoringPage extends StatefulHookConsumerWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage> {
  final _filter = OrderFilterModel();
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _currentDate;
  double _ordersSumm = 0.0;
  double _totalSumm = 0.0;
  double _percentsSumm = 0.0;
  bool _textForRange = false;

  void _onChooseRange(DateTimeRange? range, List<Order> orders) {
    if (range == null) return;

    _textForRange = true;

    _ordersSumm = 0.0;
    _totalSumm = 0.0;
    _percentsSumm = 0.0;
    _startDate = range.start;
    _endDate = range.end;

    final ordersList = orders.where((order) {
      final createdDate = DateTime.parse(order.createdDate);
      return _startDate!.isBefore(createdDate) && _endDate!.isAfter(createdDate);
    }).toList();

    final percent = (ref.watch(orderPercentProvider).value ?? []).fold(0.0, (perc, item) => perc += item.percent);

    for (final order in ordersList) {
      final productOldPrice = order.products.fold(0.0, (value, product) {
        final kPrice = (product.amount * (product.product.price * (1 - (100 / (100 + product.product.percent)))));

        return value += kPrice;
      });

      _ordersSumm += order.price;
      _totalSumm += productOldPrice;
      if (!order.place.percentNull) {
        _percentsSumm += (order.price * (1 - (100 / (100 + percent))));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final data = ref.watch(ordersFilterProvider(_filter)).value ?? [];
    final percent = (ref.watch(orderPercentProvider).value ?? []).fold(0.0, (perc, item) => perc + item.percent);

    final ordersList = data.where((order) {
      final createdDate = DateTime.parse(order.createdDate);
      return date.day == createdDate.day && date.month == createdDate.month && date.year == createdDate.year;
    }).toList();

    double ordersSumm = 0.0;
    double totalSumm = 0.0;
    double percentsSumm = 0.0;

    double getOrdersSumm() {
      if (_currentDate == null && _startDate == null) return ordersSumm;
      return _ordersSumm;
    }

    double getTotalSumm() {
      if (_currentDate == null && _startDate == null) return totalSumm;
      return _totalSumm;
    }

    double getPercentsSumm() {
      if (_currentDate == null && _startDate == null) return percentsSumm;
      return _percentsSumm;
    }

    double getTotalProfit() {
      return getTotalSumm() + getPercentsSumm();
    }

    for (final order in ordersList) {
      final productOldPrice = order.products.fold(0.0, (value, product) {
        final kPrice = (product.amount * (product.product.price * (1 - (100 / (100 + product.product.percent)))));
        return value + kPrice;
      });

      ordersSumm += order.price;
      totalSumm += productOldPrice;
      if (!order.place.percentNull) {
        percentsSumm += (order.price * (1 - (100 / (100 + percent))));
      }
    }

    return AppStateWrapper(
      builder: (theme, state) {
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
                    ],
                  ),
                ),
              ),
              state.whenProviderDataSliver(
                provider: ordersFilterProvider(_filter),
                builder: (data) {
                  return SliverToBoxAdapter(
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
                                  DateFormat('yyyy, dd-MMMM', context.locale.languageCode).format(_startDate ?? DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: boldFamily,
                                  ),
                                ),
                                4.w,
                                Text(
                                  DateFormat('yyyy, dd-MMMM', context.locale.languageCode).format(_endDate ?? DateTime.now()),
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
                                  DateFormat('yyyy, dd-MMMM', context.locale.languageCode).format(_currentDate ?? DateTime.now()),
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
                                  ).then((date) {
                                    if (date == null) return;
                                    _textForRange = false;

                                    _ordersSumm = 0.0;
                                    _totalSumm = 0.0;
                                    _percentsSumm = 0.0;
                                    final ordersList = data.where((order) {
                                      final createdDate = DateTime.parse(order.createdDate);
                                      return date.day == createdDate.day && date.month == createdDate.month && date.year == createdDate.year;
                                    }).toList();

                                    final percent = (ref.watch(orderPercentProvider).value ?? []).fold(0.0, (perc, item) => perc += item.percent);

                                    for (final order in ordersList) {
                                      order as Order;
                                      final productOldPrice = order.products.fold(0.0, (value, product) {
                                        final kPrice = (product.amount * (product.product.price * (1 - (100 / (100 + product.product.percent)))));

                                        return value += kPrice;
                                      });

                                      _ordersSumm += order.price;
                                      _totalSumm += productOldPrice;
                                      if (!order.place.percentNull) {
                                        _percentsSumm += (order.price * (1 - (100 / (100 + percent))));
                                      }
                                    }

                                    _currentDate = date;

                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: 12.all,
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Icon(Iconsax.calendar_1_copy),
                                      Text(
                                        AppLocales.date.tr(),
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
                                  ).then((val) {
                                    _onChooseRange(val, data);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: 12.all,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${AppLocales.totalOrderSumm.tr()}: ${getOrdersSumm().priceUZS}",
                                  style: TextStyle(fontSize: 20, fontFamily: boldFamily),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${AppLocales.totalProfit.tr()}: ${getTotalProfit().priceUZS}",
                                  style: TextStyle(fontSize: 20, fontFamily: boldFamily),
                                ),
                              ),
                            ],
                          ),
                          8.h,
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${AppLocales.profitFromProducts.tr()}: ${getTotalSumm().priceUZS}",
                                  style: TextStyle(fontSize: 20, fontFamily: boldFamily),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${AppLocales.profitFromPercents.tr()}: ${getPercentsSumm().priceUZS}",
                                  style: TextStyle(fontSize: 20, fontFamily: boldFamily),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              SliverPadding(
                  padding: Dis.only(lr: context.w(24)),
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
                                        width: MediaQuery.of(context).size.width * 0.8,
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
                                        width: MediaQuery.of(context).size.width * 0.8,
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
                                provider: ordersFilterProvider(_filter),
                                builder: (ord) {
                                  return MonitoringCard(
                                    count: ord.length,
                                    icon: Iconsax.bag_happy,
                                    theme: theme,
                                    title: AppLocales.orders.tr(),
                                    onPressed: () {
                                      showDesktopModal(
                                        width: MediaQuery.of(context).size.width * 0.8,
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
                                provider: transactionProvider,
                                builder: (trs) {
                                  return MonitoringCard(
                                    icon: Iconsax.send_sqaure_2,
                                    theme: theme,
                                    title: AppLocales.transactions.tr(),
                                    onPressed: () {
                                      showDesktopModal(
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        context: context,
                                        body: MonitoringTransactionsPage(),
                                      );
                                    },
                                    count: trs.length,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
