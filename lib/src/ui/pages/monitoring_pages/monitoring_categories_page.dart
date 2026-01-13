import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../../core/model/category_model/category_model.dart';
import '../../../core/services/warehouse_printer_services.dart';
import '../../../providers/employee_orders_provider.dart';
import '../../../providers/product_order_provider.dart';
import '../../widgets/custom/app_error_screen.dart';
import '../../widgets/helpers/app_back_button.dart';
import '../../widgets/helpers/app_loading_screen.dart';

class MonitoringCategoriesPage extends HookConsumerWidget {
  final AppColors theme;

  const MonitoringCategoriesPage(this.theme, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final style = TextStyle(fontFamily: mediumFamily, fontSize: context.s(14));

    final selectedDate = useState<DateTime>(DateTime.now());
    final orders = ref.watch(dayOrdersProvider(selectedDate.value)).value ?? [];
    final employee = useMemoized(
      () => Employee(
        fullname: AppLocales.categories.tr(),
        roleId: '',
        roleName: AppLocales.reports.tr(),
      ),
      [],
    );

    final filter = useMemoized(() {
      return ProductOrderFilter(
          day: selectedDate.value, orders: orders, employee: employee);
    }, [selectedDate.value, orders, employee]);

    final productMapListener = ref.watch(categoryOrdersProvider(filter));

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
                  AppLocales.categories.tr(),
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
