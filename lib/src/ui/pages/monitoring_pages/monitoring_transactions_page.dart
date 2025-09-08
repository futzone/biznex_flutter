import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/excel_models/orders_excel_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MonitoringTransactionsPage extends HookConsumerWidget {
  MonitoringTransactionsPage({super.key});

  final OrderFilterModel orderFilterModel = OrderFilterModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = useState<int>(DateTime.now().month);
    final filterType = useState<int>(DateTime.now().year);
    final paymentType = useState('all');

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.transactions.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: mediumFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (final item in Transaction.values)
                    CustomPopupItem(
                      title: item.tr().toString(),
                      onPressed: () {
                        paymentType.value = item;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        paymentType.value.tr().toString(),
                        style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Iconsax.arrow_down_1_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (final item in [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1])
                    CustomPopupItem(
                      title: item.toString(),
                      onPressed: () {
                        filterType.value = item;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        filterType.value.toString(),
                        style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Iconsax.arrow_down_1_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (int i = 1; i < 13; i++)
                    CustomPopupItem(
                      title: AppDateUtils.getMonth(i),
                      onPressed: () {
                        selectedMonth.value = i;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        AppDateUtils.getMonth(selectedMonth.value),
                        style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Iconsax.arrow_down_1_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onPressed: () {
                  showAppLoadingDialog(context);
                  final orders = ref.watch(transactionProvider).value ?? [];
                  final List<OrdersExcelModel> list = [];
                  for (final day in AppDateUtils.getAllDaysInMonth(filterType.value, selectedMonth.value)) {
                    final double ordersSumm = orders.fold(0.0, (value, element) {
                      final createdDate = DateTime.parse(element.createdDate);
                      if (paymentType.value != 'all') {
                        if (createdDate.year == day.year &&
                            createdDate.month == day.month &&
                            createdDate.day == day.day &&
                            element.paymentType == paymentType.value) {
                          return value += element.value;
                        }
                        return value;
                      }

                      if (createdDate.year == day.year && createdDate.month == day.month && createdDate.day == day.day) return value += element.value;
                      return value;
                    });

                    final int ordersCount = orders.fold(0, (value, element) {
                      final createdDate = DateTime.parse(element.createdDate);
                      if (paymentType.value != 'all') {
                        if (createdDate.year == day.year &&
                            createdDate.month == day.month &&
                            createdDate.day == day.day &&
                            element.paymentType == paymentType.value) {
                          return value += 1;
                        }
                        return value;
                      }

                      if (createdDate.year == day.year && createdDate.month == day.month && createdDate.day == day.day) return value += 1;
                      return value;
                    });

                    OrdersExcelModel excel = OrdersExcelModel(
                      ordersCount: ordersCount,
                      ordersSumm: ordersSumm,
                      dateTime: DateFormat('d-MMMM, yyyy', context.locale.languageCode).format(day),
                      day: DateFormat('EEEE', context.locale.languageCode).format(day),
                    );

                    list.add(excel);
                  }
                  AppRouter.close(context);

                  OrdersExcelModel.saveTransactionsFileDialog(list, paymentType.value.tr());
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.mainColor),
                  child: Row(
                    children: [
                      Text(
                        AppLocales.export.tr(),
                        style: TextStyle(fontFamily: mediumFamily, fontSize: 16, color: Colors.white),
                      ),
                      8.w,
                      Icon(Iconsax.document_download, size: 20, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ],
          ),
          16.h,
          Expanded(
            child: state.whenProviderData(
              provider: transactionProvider,
              builder: (orders) {
                orders as List<Transaction>;

                return ListView.builder(
                  itemCount: AppDateUtils.getAllDaysInMonth(filterType.value, selectedMonth.value).length,
                  itemBuilder: (context, index) {
                    final day = AppDateUtils.getAllDaysInMonth(filterType.value, selectedMonth.value)[index];

                    final double ordersSumm = orders.fold(0.0, (value, element) {
                      final createdDate = DateTime.parse(element.createdDate);

                      if (paymentType.value != 'all') {
                        if (createdDate.year == day.year &&
                            createdDate.month == day.month &&
                            createdDate.day == day.day &&
                            element.paymentType == paymentType.value) {
                          return value += element.value;
                        }
                        return value;
                      }

                      if (createdDate.year == day.year && createdDate.month == day.month && createdDate.day == day.day) return value += element.value;
                      return value;
                    });

                    final int ordersCount = orders.fold(0, (value, element) {
                      final createdDate = DateTime.parse(element.createdDate);

                      if (paymentType.value != 'all') {
                        if (createdDate.year == day.year &&
                            createdDate.month == day.month &&
                            createdDate.day == day.day &&
                            element.paymentType == paymentType.value) {
                          return value += 1;
                        }
                        return value;
                      }

                      if (createdDate.year == day.year && createdDate.month == day.month && createdDate.day == day.day) return value += 1;
                      return value;
                    });

                    return Container(
                      margin: 16.bottom,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.accentColor,
                      ),
                      padding: 18.all,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 8,
                              children: [
                                Icon(Iconsax.calendar, color: theme.mainColor),
                                Text(
                                  DateFormat('d-MMMM, yyyy', context.locale.languageCode).format(day),
                                  style: TextStyle(fontSize: 16, fontFamily: boldFamily),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(Iconsax.calendar_1, color: theme.mainColor),
                                Text(
                                  DateFormat('EEEE', context.locale.languageCode).format(day).capitalize,
                                  style: TextStyle(fontSize: 16, fontFamily: boldFamily),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(Iconsax.send_sqaure_2, color: theme.mainColor),
                                Text("${AppLocales.transactions.tr()}: $ordersCount", style: TextStyle(fontSize: 16, fontFamily: boldFamily)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              spacing: 8,
                              children: [
                                Icon(Iconsax.wallet, color: theme.mainColor),
                                Text(ordersSumm.priceUZS, style: TextStyle(fontSize: 16, fontFamily: boldFamily))
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
