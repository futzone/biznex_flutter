import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/transaction_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import '../../widgets/custom/app_state_wrapper.dart';

class AddTransactionPage extends HookConsumerWidget {
  final Transaction? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceController = useTextEditingController(text: transaction?.value.toString());
    final noteController = useTextEditingController(text: transaction?.note);
    final selectedMethod = useState(transaction?.paymentType ?? Transaction.cash);
    final negative = useState(true);
    final selectedEmployee = useState<Employee?>(null);

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              SimpleButton(
                child: Icon(Icons.arrow_back_ios),
                onPressed: () => AppRouter.close(context),
              ),
              16.w,
              AppText.$18Bold(AppLocales.addTransactionLabel.tr())
            ],
          ),
          0.h,
          AppTextField(
            title: AppLocales.addNote.tr(),
            controller: noteController,
            theme: theme,
            maxLines: 3,
          ),
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
                      maxLines: 1,
                      onlyRead: true,
                      title: AppLocales.paymentType.tr(),
                      controller: TextEditingController(text: selectedMethod.value.tr()),
                      theme: theme,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: context.w(16),
            children: [
              Expanded(
                child: SimpleButton(
                  onPressed: () => negative.value = true,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: Dis.only(lr: 12),
                    child: Row(
                      spacing: 12,
                      children: [
                        if (negative.value)
                          Icon(Icons.check_circle_outline, color: theme.mainColor)
                        else
                          Icon(Icons.circle_outlined, color: Colors.black),
                        Text(AppLocales.exitSumm.tr(), style: TextStyle(fontFamily: mediumFamily))
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SimpleButton(
                  onPressed: () => negative.value = false,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: Dis.only(lr: 12),
                    child: Row(
                      spacing: 12,
                      children: [
                        if (!negative.value)
                          Icon(Icons.check_circle_outline, color: theme.mainColor)
                        else
                          Icon(Icons.circle_outlined, color: Colors.black),
                        Text(AppLocales.enterSumm.tr(), style: TextStyle(fontFamily: mediumFamily))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          state.whenProviderData(
            provider: employeeProvider,
            builder: (employees) {
              return CustomPopupMenu(
                children: [
                  CustomPopupItem(
                    title: AppLocales.clearAll.tr(),
                    onPressed: () => selectedEmployee.value = null,
                  ),
                  for (Employee emp in employees)
                    CustomPopupItem(
                      title: emp.fullname,
                      onPressed: () => selectedEmployee.value = emp,
                    ),
                ],
                theme: theme,
                child: IgnorePointer(
                  child: AppTextField(
                    title: AppLocales.employees.tr(),
                    controller: TextEditingController(text: selectedEmployee.value?.fullname ?? ''),
                    theme: theme,
                    onlyRead: true,
                  ),
                ),
              );
            },
          ),
          Spacer(),
          ConfirmCancelButton(
            cancelColor: Colors.white,
            confirmText: AppLocales.add.tr(),
            onConfirm: () {
              TransactionController transactionController = TransactionController(context: context, state: state);
              Transaction kTransaction = Transaction(
                value: (negative.value ? -1 : 1) * (double.tryParse(priceController.text.trim()) ?? 0.0),
                employee: selectedEmployee.value ?? ref.watch(currentEmployeeProvider),
                paymentType: selectedMethod.value,
                note: noteController.text.trim(),
              );

              if (transaction == null) {
                transactionController.create(kTransaction).then((_) {
                  AppRouter.close(context);
                });

                return;
              }

              kTransaction.paymentType = selectedMethod.value;
              kTransaction.note = noteController.text.trim();
              kTransaction.value = (negative.value ? -1 : 1) * (double.tryParse(priceController.text.trim()) ?? 0.0);
              kTransaction.createdDate = DateTime.now().toIso8601String();
              kTransaction.employee = selectedEmployee.value ?? ref.watch(currentEmployeeProvider);
              transactionController.update(kTransaction, transaction?.id).then((_) {
                AppRouter.close(context);
              });
            },
          ),
        ],
      );
    });
  }
}
