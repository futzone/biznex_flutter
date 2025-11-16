import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/excel_models/products_excel_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../widgets/helpers/app_back_button.dart';

class MonitoringProductsPage extends HookConsumerWidget {
  MonitoringProductsPage({super.key});

  final OrderFilterModel orderFilterModel = OrderFilterModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime>(DateTime.now());

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.products.tr(),
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
                  final employees = ref.watch(productsProvider).value ?? [];
                  final orders =
                      ref.watch(dayOrdersProvider(selectedDate.value)).value ??
                          [];

                  List<ProductsExcelModel> list = [];
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

                    final ProductsExcelModel excel = ProductsExcelModel(
                      ordersCount: ordersCount,
                      ordersSumm: ordersSumm,
                      dateTime:
                          DateFormat('d-MMMM', context.locale.languageCode)
                              .format(selectedDate.value),
                      price: employee.price,
                      productName: employee.name,
                    );

                    list.add(excel);
                  }

                  AppRouter.close(context);
                  ProductsExcelModel.saveFileDialog(list);
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
              provider: productsProvider,
              builder: (employees) {
                return state.whenProviderData(
                  provider: dayOrdersProvider(selectedDate.value),
                  builder: (orders) {
                    orders as List<Order>;
                    employees as List<Product>;

                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employeeId = employees[index].id;

                        final double ordersSumm =
                            orders.fold(0.0, (value, element) {
                          if (element.products
                                  .where((el) => el.product.id == employeeId)
                                  .isNotEmpty &&
                              AppDateUtils.isTodayOrder(
                                  selectedDate.value, element.createdDate)) {
                            final kProduct = (element.products.firstWhere(
                                (item) => item.product.id == employeeId));
                            return value +=
                                (kProduct.amount * kProduct.product.price);
                          }

                          return value;
                        });

                        final double ordersCount =
                            orders.fold(0.0, (value, element) {
                          if (element.products
                                  .where((el) => el.product.id == employeeId)
                                  .isNotEmpty &&
                              AppDateUtils.isTodayOrder(
                                  selectedDate.value, element.createdDate)) {
                            return value += (element.products
                                .firstWhere(
                                    (item) => item.product.id == employeeId)
                                .amount);
                          }

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
                                    Icon(Iconsax.reserve,
                                        color: theme.mainColor),
                                    Text(employees[index].name,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(Iconsax.coin_1,
                                        color: theme.mainColor),
                                    Text(employees[index].price.priceUZS,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily)),
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
                                    Text(
                                        "${AppLocales.orders.tr()}: ${ordersCount.toMeasure}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily)),
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
                                    Text(ordersSumm.priceUZS,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily))
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
