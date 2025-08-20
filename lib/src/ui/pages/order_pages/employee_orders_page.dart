import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../screens/order_screens/order_card.dart';

class EmployeeOrdersPage extends HookConsumerWidget {
  const EmployeeOrdersPage({super.key});

  bool isToday(DateTime? time) {
    return time == null;
  }

  bool isTodayOrder(dateFilter, order) {
    final orderDate = DateTime.parse(order.createdDate);
    return (orderDate.year == dateFilter.value?.year) && (orderDate.month == dateFilter.value?.month) && (orderDate.day == dateFilter.value?.day);
  }

  @override
  Widget build(BuildContext context, ref) {
    final dateFilter = useState<DateTime?>(null);
    final employeeOrders = ref.watch(employeeOrdersProvider);
    final filterResult = useState(<Order>[]);
    return AppStateWrapper(
      builder: (theme, state) {
        return employeeOrders.when(
          loading: () => AppLoadingScreen(),
          error: (error, stackTrace) => AppErrorScreen(),
          data: (orders) {
            return Column(
              spacing: 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Center(
                      child: IconButton(
                        onPressed: () {
                          AppRouter.close(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                    ),
                    Center(
                      child: AppText.$18Bold(
                        AppLocales.myOrders.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    if (!isToday(dateFilter.value))
                      Center(
                        child: RichText(
                          text: TextSpan(text: "${AppLocales.total.tr()}: ", style: TextStyle(fontSize: 18, color: theme.textColor), children: [
                            TextSpan(
                              text: orders.fold<double>(0, (value, element) {
                                if (isTodayOrder(dateFilter, element)) {
                                  return value += element.price;
                                }

                                return value += 0;
                              }).priceUZS,
                              style: TextStyle(fontSize: 18, color: theme.textColor, fontFamily: boldFamily),
                            ),
                          ]),
                        ),
                      ),
                    24.w,
                    SimpleButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime(2025, 1),
                          lastDate: DateTime.now(),
                          initialDate: dateFilter.value,
                        ).then((date) {
                          if (date != null) {
                            dateFilter.value = date;
                            filterResult.value = [
                              ...orders.where(
                                (order) {
                                  final orderDate = DateTime.parse(order.createdDate);
                                  return (orderDate.year == dateFilter.value?.year) &&
                                      (orderDate.month == dateFilter.value?.month) &&
                                      (orderDate.day == dateFilter.value?.day);
                                },
                              ),
                            ];
                          }
                        });
                      },
                      child: Container(
                        padding: Dis.only(lr: 16, tb: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: theme.accentColor,
                        ),
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(Ionicons.calendar_outline, size: 20),
                            Text(
                              dateFilter.value == null
                                  ? AppLocales.all.tr()
                                  : DateFormat('dd-MMMM', context.locale.languageCode).format(dateFilter.value!),
                              style: TextStyle(fontFamily: mediumFamily),
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.w,
                    SimpleButton(
                      onPressed: () {
                        ref.refresh(employeeOrdersProvider);
                        ref.invalidate(employeeOrdersProvider);
                        log("invalidated");
                      },
                      child: Container(
                        padding: Dis.only(lr: 16, tb: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: theme.accentColor,
                        ),
                        child: Icon(Iconsax.refresh_copy, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: orders.isEmpty
                      ? AppEmptyWidget()
                      : GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: context.w(16),
                            mainAxisSpacing: context.h(16),
                            childAspectRatio: 353 / 363,
                          ),
                          itemCount: dateFilter.value == null ? orders.length : filterResult.value.length,
                          itemBuilder: (context, index) {
                            return OrderCard(
                              order: (dateFilter.value == null ? orders : filterResult.value)[index],
                              theme: theme,
                              color: theme.scaffoldBgColor,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
