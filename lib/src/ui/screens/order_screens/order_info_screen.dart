import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/transaction_controller.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/services/printer_services.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/screens/order_screens/order_item_card.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

import '../../../providers/employee_provider.dart';

class OrderInfoScreen extends HookConsumerWidget {
  final Order order;

  const OrderInfoScreen(this.order, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final currentEmployee = ref.watch(currentEmployeeProvider);

    return AppStateWrapper(builder: (theme, state) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              2.h,
              AppText.$18Bold(AppLocales.orderItems.tr()),
              for (final item in order.products) OrderItemCardNew(item: item, theme: theme, infoView: true),
              0.h,
              Row(
                children: [
                  Text("${AppLocales.status.tr()}: ", style: TextStyle(fontSize: 16)),
                  AppText.$18Bold(order.status?.tr() ?? ''),
                  Spacer(),
                  Text("${AppLocales.total.tr()}: ", style: TextStyle(fontSize: 16)),
                  AppText.$18Bold(order.price.priceUZS),
                ],
              ),
              0.h,
              Row(
                children: [
                  Text("${AppLocales.place.tr()}: ", style: TextStyle(fontSize: 16)),
                  AppText.$18Bold((order.place.father == null || order.place.father!.name.isEmpty) ? order.place.name : "${order.place.father?.name}, ${order.place.name}"),
                  Spacer(),
                  Text("${order.employee.roleName}: ", style: TextStyle(fontSize: 16)),
                  AppText.$18Bold(order.employee.fullname),
                ],
              ),
              0.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (order.customer != null) Text("${AppLocales.customer.tr()}: ", style: TextStyle(fontSize: 16)),
                  if (order.customer != null) AppText.$18Bold(order.customer!.name),
                  Spacer(),
                  AppPrimaryButton(
                    color: theme.accentColor,
                    padding: Dis.only(lr: 20, tb: 8),
                    theme: theme,
                    child: Row(
                      spacing: 8,
                      children: [
                        Icon(Ionicons.print_outline),
                        Text(AppLocales.print.tr()),
                      ],
                    ),
                    onPressed: () {
                      PrinterServices printerServices = PrinterServices(order: order, model: state);
                      printerServices.printOrderCheck();
                    },
                  ),
                ],
              ),
              0.h,
              if (order.note != null && order.note!.isNotEmpty)
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocales.orderNote.tr()}: ", style: TextStyle(fontSize: 16)),
                    Text(order.note ?? '', style: TextStyle(fontSize: 16, fontFamily: boldFamily)),
                  ],
                ),
              16.h,
              ConfirmPaymentScreen(order: order),
            ],
          ),
        ),
      );
    });
  }
}

class ConfirmPaymentScreen extends HookConsumerWidget {
  final Order? order;

  const ConfirmPaymentScreen({super.key, this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showInputs = useState(false);
    final priceController = useTextEditingController();
    final selectedMethod = useState(Transaction.cash);
    return AppStateWrapper(builder: (theme, state) {
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!showInputs.value)
            AppPrimaryButton(
              theme: theme,
              onPressed: () => showInputs.value = true,
              title: AppLocales.confirmPayment.tr(),
            ),
          if (showInputs.value) AppText.$18Bold(AppLocales.confirmPayment.tr()),
          if (showInputs.value)
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppTextField(
                    title: AppLocales.summ.tr(),
                    controller: priceController,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: CustomPopupMenu(
                    children: [
                      for (final item in Transaction.values)
                        CustomPopupItem(
                          title: item.tr(),
                          onPressed: () => selectedMethod.value = item,
                        )
                    ],
                    theme: theme,
                    child: IgnorePointer(
                      ignoring: true,
                      child: AppTextField(
                        onlyRead: true,
                        title: AppLocales.paymentType.tr(),
                        controller: TextEditingController(text: selectedMethod.value.tr()),
                        theme: theme,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AppPrimaryButton(
                    theme: theme,
                    onPressed: () {
                      TransactionController transactionController = TransactionController(context: context, state: state);
                      Transaction transaction = Transaction(
                        value: double.tryParse(priceController.text.trim()) ?? 0.0,
                        paymentType: selectedMethod.value,
                        order: order,
                        employee: ref.watch(currentEmployeeProvider),
                      );

                      transactionController.create(transaction);
                      priceController.clear();
                    },
                    title: AppLocales.add.tr(),
                  ),
                ),
                SimpleButton(
                  onPressed: () => showInputs.value = false,
                  child: Icon(
                    Ionicons.close_circle_outline,
                    size: 32,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          state.whenProviderData(
            provider: transactionProvider,
            builder: (transactions) {
              transactions as List<Transaction>;

              final list = transactions.where((el) => el.order?.id == order?.id);

              return Column(
                children: [
                  for (final item in list)
                    AppListTile(
                      title: item.value.priceUZS,
                      theme: theme,
                      trailingText: item.paymentType.tr(),
                      onDelete: () {},
                    )
                ],
              );
            },
          )
        ],
      );
    });
  }
}
