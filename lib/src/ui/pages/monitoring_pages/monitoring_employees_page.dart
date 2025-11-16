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
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/helpers/app_back_button.dart';
import '../employee_pages/employee_monitoring_page.dart';

class MonitoringEmployeesPage extends HookConsumerWidget {
  const MonitoringEmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime>(DateTime.now());
    final percents =
        (ref.watch(orderPercentProvider).value ?? []).fold(0.0, (kf, element) {
      return kf += element.percent;
    });

    final orders = ref.watch(dayOrdersProvider(selectedDate.value)).value ?? [];

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.employees.tr(),
                style: TextStyle(
                    fontSize: context.s(24),
                    fontFamily: mediumFamily,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              16.w,
              SimpleButton(
                onPressed: () {
                  showDatePicker(
                          context: context,
                          firstDate: DateTime(2025, 1),
                          lastDate: DateTime.now())
                      .then((date) {
                    if (date != null) selectedDate.value = date;
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
                        DateFormat('d-MMMM', context.locale.languageCode)
                            .format(selectedDate.value),
                        style:
                            TextStyle(fontFamily: mediumFamily, fontSize: 16),
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

                  final employees = [
                    Employee(fullname: "Admin", roleId: '', roleName: "Admin"),
                    ...(ref.watch(employeeProvider).value ?? [])
                  ];

                  List<EmployeeExcel> list = [];
                  for (final employee in employees) {
                    final employeeId = employee.id;

                    final double ordersSumm =
                        orders.fold(0.0, (value, element) {
                      if (element.employee.id == employeeId &&
                          AppDateUtils.isTodayOrder(
                              selectedDate.value, element.createdDate)) {
                        return value += element.price;
                      }

                      return value;
                    });

                    final int ordersCount = orders.fold(0, (value, element) {
                      if (element.employee.id == employeeId &&
                          AppDateUtils.isTodayOrder(
                              selectedDate.value, element.createdDate)) {
                        return value += 1;
                      }

                      return value;
                    });

                    final EmployeeExcel excel = EmployeeExcel(
                      ordersCount: ordersCount,
                      ordersSumm: ordersSumm,
                      dateTime:
                          DateFormat('d-MMMM', context.locale.languageCode)
                              .format(selectedDate.value),
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
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.mainColor),
                  child: Row(
                    children: [
                      Text(
                        AppLocales.export.tr(),
                        style: TextStyle(
                            fontFamily: mediumFamily,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      8.w,
                      Icon(Iconsax.document_download,
                          size: 20, color: Colors.white)
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
                  provider: dayOrdersProvider(selectedDate.value),
                  builder: (orders) {
                    orders as List<Order>;
                    employees as List<Employee>;

                    return ListView.builder(
                      itemCount: employees.length + 1,
                      itemBuilder: (context, index) {
                        if (index == employees.length) {
                          final adminEmployee = Employee(
                            fullname: "Admin",
                            roleId: "",
                            roleName: "Admin",
                          );

                          final double ordersSumm =
                              orders.fold(0.0, (value, element) {
                            if (element.employee.roleName.toLowerCase() ==
                                    adminEmployee.roleName.toLowerCase() &&
                                AppDateUtils.isTodayOrder(
                                    selectedDate.value, element.createdDate)) {
                              return value += element.price;
                            }

                            if (element.employee.roleName.toLowerCase() ==
                                adminEmployee.roleName.toLowerCase()) {
                              return value += element.price;
                            }
                            return value;
                          });

                          final double salarySumm =
                              orders.fold(0.0, (value, element) {
                            if (element.employee.roleName.toLowerCase() ==
                                    adminEmployee.roleName.toLowerCase() &&
                                AppDateUtils.isTodayOrder(
                                    selectedDate.value, element.createdDate)) {
                              final t = element.price *
                                  (1 - (100 / (100 + percents)));
                              if (element.place.percentNull) return value;
                              return value += t;
                            }

                            return value;
                          });

                          final int ordersCount =
                              orders.fold(0, (value, element) {
                            if (element.employee.roleName.toLowerCase() ==
                                    adminEmployee.roleName.toLowerCase() &&
                                AppDateUtils.isTodayOrder(
                                    selectedDate.value, element.createdDate)) {
                              return value += 1;
                            }

                            return value;
                          });

                          return SimpleButton(
                            onPressed: () {
                              showDesktopModal(
                                width: MediaQuery.of(context).size.width * 0.6,
                                context: context,
                                body: EmployeeMonitoringPage(
                                  theme,
                                  adminEmployee,
                                ),
                              );
                            },
                            child: Container(
                              margin: 16.bottom,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: theme.accentColor,
                              ),
                              padding: Dis.only(lr: 16, tb: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Iconsax.user,
                                          color: theme.mainColor,
                                        ),
                                        Text(
                                          adminEmployee.fullname,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Iconsax.briefcase,
                                          color: theme.mainColor,
                                        ),
                                        Text(
                                          adminEmployee.roleName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Icon(Iconsax.bag,
                                            color: theme.mainColor),
                                        Text(
                                          "${AppLocales.orders.tr()}: $ordersCount",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Iconsax.percentage_circle,
                                          color: theme.mainColor,
                                        ),
                                        Text(
                                          salarySumm.priceUZS,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        Icon(Iconsax.wallet,
                                            color: theme.mainColor),
                                        Text(
                                          ordersSumm.priceUZS,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        IgnorePointer(
                                          ignoring: true,
                                          child: AppPrimaryButton(
                                            // title:,
                                            theme: theme,
                                            onPressed: () {},
                                            padding: Dis.only(lr: 16, tb: 4),
                                            // title:,
                                            radius: 12,
                                            child: Row(
                                              children: [
                                                Text(
                                                  AppLocales.about.tr(),
                                                  style: TextStyle(
                                                    fontFamily: mediumFamily,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                8.w,
                                                Icon(
                                                  Icons.arrow_forward,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final employeeId = employees[index].id;

                        final double ordersSumm =
                            orders.fold(0.0, (value, element) {
                          if (element.employee.id == employeeId &&
                              AppDateUtils.isTodayOrder(
                                  selectedDate.value, element.createdDate)) {
                            return value += element.price;
                          }

                          return value;
                        });

                        final double salarySumm =
                            orders.fold(0.0, (value, element) {
                          if (element.employee.id == employeeId &&
                              AppDateUtils.isTodayOrder(
                                  selectedDate.value, element.createdDate)) {
                            final t =
                                element.price * (1 - (100 / (100 + percents)));
                            if (element.place.percentNull) return value;
                            return value += t;
                          }

                          return value;
                        });

                        final int ordersCount =
                            orders.fold(0, (value, element) {
                          if (element.employee.id == employeeId &&
                              AppDateUtils.isTodayOrder(
                                  selectedDate.value, element.createdDate)) {
                            return value += 1;
                          }

                          return value;
                        });

                        return SimpleButton(
                          onPressed: () {
                            showDesktopModal(
                              width: MediaQuery.of(context).size.width * 0.6,
                              context: context,
                              body: EmployeeMonitoringPage(
                                theme,
                                employees[index],
                              ),
                            );
                          },
                          child: Container(
                            margin: 16.bottom,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.accentColor,
                            ),
                            padding: Dis.only(lr: 16, tb: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Iconsax.user,
                                        color: theme.mainColor,
                                      ),
                                      Text(
                                        employees[index].fullname,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Iconsax.briefcase,
                                        color: theme.mainColor,
                                      ),
                                      Text(
                                        employees[index].roleName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(Iconsax.bag, color: theme.mainColor),
                                      Text(
                                        "${AppLocales.orders.tr()}: $ordersCount",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Iconsax.percentage_circle,
                                        color: theme.mainColor,
                                      ),
                                      Text(
                                        salarySumm.priceUZS,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    spacing: 8,
                                    children: [
                                      Icon(Iconsax.wallet,
                                          color: theme.mainColor),
                                      Text(
                                        ordersSumm.priceUZS,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    spacing: 8,
                                    children: [
                                      IgnorePointer(
                                        ignoring: true,
                                        child: AppPrimaryButton(
                                          // title:,
                                          theme: theme,
                                          onPressed: () {},
                                          padding: Dis.only(lr: 16, tb: 4),
                                          // title:,
                                          radius: 12,
                                          child: Row(
                                            children: [
                                              Text(
                                                AppLocales.about.tr(),
                                                style: TextStyle(
                                                  fontFamily: mediumFamily,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              8.w,
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
