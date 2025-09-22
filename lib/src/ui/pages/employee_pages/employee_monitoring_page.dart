import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/services/warehouse_printer_services.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EmployeeMonitoringPage extends HookConsumerWidget {
  final AppColors theme;
  final Employee employee;

  EmployeeMonitoringPage(this.theme, this.employee, {super.key});

  final OrderFilterModel orderFilter = OrderFilterModel();

  Map _calculateProductOrder(DateTime day, List<Order> orders) {
    final Map<String, dynamic> productMap = {};

    for (final order in orders) {
      final created = DateTime.parse(order.createdDate);

      if (created.day == day.day &&
          created.month == day.month &&
          created.year == day.year &&
          order.employee.id == employee.id) {
        for (final item in order.products) {
          if (productMap.containsKey(item.product.id)) {
            productMap[item.product.id]['amount'] =
                productMap[item.product.id]['amount'] + item.amount;
          } else {
            productMap[item.product.id] = {
              'amount': item.amount,
              'product': item.product,
            };
          }
        }
      }
    }

    return productMap;
  }

  @override
  Widget build(BuildContext context, ref) {
    final selectedDate = useState<DateTime>(DateTime.now());
    final orders = ref.watch(ordersFilterProvider(orderFilter)).value ?? [];
    final productMap = _calculateProductOrder(selectedDate.value, orders);

    final style = TextStyle(fontFamily: mediumFamily, fontSize: context.s(14));

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
                  fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
                    ),
                    8.w,
                    Icon(Iconsax.calendar_1_copy)
                  ],
                ),
              ),
            ),
            SimpleButton(
              onPressed: () async {
                await WarehousePrinterServices.printEmployeeFoodStats(
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
                    color: theme.accentColor),
                child: Row(
                  children: [
                    Text(
                      AppLocales.print.tr(),
                      style: TextStyle(fontFamily: mediumFamily, fontSize: 16),
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
        Expanded(
          child: ListView.builder(
            itemCount: productMap.length,
            itemBuilder: (context, index) {
              final id = productMap.keys.elementAt(index);
              final product = productMap[id]['product'] as Product;
              final amount = productMap[id]['amount'] as num;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.accentColor,
                ),
                padding: Dis.only(lr: 16, tb: 8),
                margin: Dis.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(child: Text(product.name, style: style)),
                    Expanded(
                      child: Center(
                        child: Text(
                          "${product.price.priceUZS}  x  ${amount.toMeasure}  ${product.measure ?? ''}",
                          style: style,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            (product.price * amount).priceUZS,
                            style: style,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
