import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/excel_models/employee_excel_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/helpers/app_back_button.dart';

class MonitoringEmployeesPage extends HookConsumerWidget {
  MonitoringEmployeesPage({super.key});

  final OrderFilterModel orderFilterModel = OrderFilterModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime?>(null);
    final filterType = useState<String>('all');
    final percents = (ref.watch(orderPercentProvider).value ?? []).fold(0.0, (kf, element) {
      return kf += element.percent;
    });

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.employees.tr(),
                style: TextStyle(fontSize: context.s(24), fontFamily: mediumFamily, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (final item in ['all', 'daily', 'monthly'])
                    CustomPopupItem(
                      title: item.tr(),
                      onPressed: () {
                        filterType.value = item;
                        selectedDate.value = null;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        filterType.value.tr(),
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
                  showDatePicker(context: context, firstDate: DateTime(2025, 1), lastDate: DateTime.now()).then((date) {
                    if (date != null) selectedDate.value = date;
                  });
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        selectedDate.value == null
                            ? 'all'.tr()
                            : DateFormat(filterType.value == 'monthly' ? 'MMMM' : 'd-MMMM', context.locale.languageCode).format(selectedDate.value!),
                        style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Ionicons.calendar_outline, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onPressed: () {
                  showAppLoadingDialog(context);
                  final orders = ref.watch(ordersFilterProvider(orderFilterModel)).value ?? [];
                  final employees = ref.watch(employeeProvider).value ?? [];

                  List<EmployeeExcel> list = [];
                  for (final employee in employees) {
                    final employeeId = employee.id;

                    final double ordersSumm = orders.fold(0.0, (value, element) {
                      if (selectedDate.value != null && filterType.value == 'monthly') {
                        if (element.employee.id == employeeId && AppDateUtils.isMonthOrder(selectedDate.value!, element.createdDate)) {
                          return value += element.price;
                        }

                        return value;
                      }

                      if (selectedDate.value != null && filterType.value == 'daily') {
                        if (element.employee.id == employeeId && AppDateUtils.isTodayOrder(selectedDate.value!, element.createdDate)) {
                          return value += element.price;
                        }

                        return value;
                      }

                      if (element.employee.id == employeeId) return value += element.price;
                      return value;
                    });

                    final int ordersCount = orders.fold(0, (value, element) {
                      if (selectedDate.value != null && filterType.value == 'monthly') {
                        if (element.employee.id == employeeId && AppDateUtils.isMonthOrder(selectedDate.value!, element.createdDate)) {
                          return value += 1;
                        }

                        return value;
                      }

                      if (selectedDate.value != null && filterType.value == 'daily') {
                        if (element.employee.id == employeeId && AppDateUtils.isTodayOrder(selectedDate.value!, element.createdDate)) {
                          return value += 1;
                        }

                        return value;
                      }

                      if (element.employee.id == employeeId) return value += 1;
                      return value;
                    });

                    final EmployeeExcel excel = EmployeeExcel(
                      ordersCount: ordersCount,
                      ordersSumm: ordersSumm,
                      dateTime: selectedDate.value == null
                          ? 'all'.tr()
                          : DateFormat(filterType.value == 'monthly' ? 'MMMM' : 'd-MMMM', context.locale.languageCode).format(selectedDate.value!),
                      employeeName: employee.fullname,
                      employeeRole: employee.roleName,
                    );

                    list.add(excel);
                  }

                  AppRouter.close(context);
                  EmployeeExcel.saveFileDialog(list);
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
              provider: employeeProvider,
              builder: (employees) {
                return state.whenProviderData(
                  provider: ordersFilterProvider(orderFilterModel),
                  builder: (orders) {
                    orders as List<Order>;
                    employees as List<Employee>;

                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employeeId = employees[index].id;

                        final double ordersSumm = orders.fold(0.0, (value, element) {
                          if (selectedDate.value != null && filterType.value == 'monthly') {
                            if (element.employee.id == employeeId && AppDateUtils.isMonthOrder(selectedDate.value!, element.createdDate)) {
                              return value += element.price;
                            }

                            return value;
                          }

                          if (selectedDate.value != null && filterType.value == 'daily') {
                            if (element.employee.id == employeeId && AppDateUtils.isTodayOrder(selectedDate.value!, element.createdDate)) {
                              return value += element.price;
                            }

                            return value;
                          }

                          if (element.employee.id == employeeId) return value += element.price;
                          return value;
                        });

                        final double salarySumm = orders.fold(0.0, (value, element) {
                          if (selectedDate.value != null && filterType.value == 'monthly') {
                            if (element.employee.id == employeeId && AppDateUtils.isMonthOrder(selectedDate.value!, element.createdDate)) {
                              final t = element.price * (1 - (100 / (100 + percents)));
                              if (element.place.percentNull) return value;
                              return value += t;
                            }

                            return value;
                          }

                          if (selectedDate.value != null && filterType.value == 'daily') {
                            if (element.employee.id == employeeId && AppDateUtils.isTodayOrder(selectedDate.value!, element.createdDate)) {
                              final t = element.price * (1 - (100 / (100 + percents)));
                              if (element.place.percentNull) return value;
                              return value += t;
                            }

                            return value;
                          }

                          if (element.employee.id == employeeId) {
                            final t = element.price * (1 - (100 / (100 + percents)));
                            if (element.place.percentNull) return value;
                            return value += t;
                          }
                          return value;
                        });

                        final int ordersCount = orders.fold(0, (value, element) {
                          if (selectedDate.value != null && filterType.value == 'monthly') {
                            if (element.employee.id == employeeId && AppDateUtils.isMonthOrder(selectedDate.value!, element.createdDate)) {
                              return value += 1;
                            }

                            return value;
                          }

                          if (selectedDate.value != null && filterType.value == 'daily') {
                            if (element.employee.id == employeeId && AppDateUtils.isTodayOrder(selectedDate.value!, element.createdDate)) {
                              return value += 1;
                            }

                            return value;
                          }

                          if (element.employee.id == employeeId) return value += 1;
                          return value;
                        });

                        return Container(
                          margin: 16.bottom,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.accentColor,
                          ),
                          padding: 18.all,
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    Icon(Iconsax.user, color: theme.mainColor),
                                    Text(employees[index].fullname, style: TextStyle(fontSize: 16, fontFamily: boldFamily))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(Iconsax.briefcase, color: theme.mainColor),
                                    Text(employees[index].roleName, style: TextStyle(fontSize: 16, fontFamily: boldFamily)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(Iconsax.bag, color: theme.mainColor),
                                    Text("${AppLocales.orders.tr()}: $ordersCount", style: TextStyle(fontSize: 16, fontFamily: boldFamily)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(Iconsax.percentage_circle, color: theme.mainColor),
                                    Text(salarySumm.priceUZS, style: TextStyle(fontSize: 16, fontFamily: boldFamily))
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
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
