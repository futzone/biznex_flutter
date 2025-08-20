import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

class OrderCompleteScreen extends HookConsumerWidget {
  const OrderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final orders = ref.watch(orderSetProvider);
    final customer = useState<Customer?>(null);
    final employee = useState<Employee?>(null);
    final printing = useState(true);
    final realPrice = useState(0.0);
    final priceController = useTextEditingController();

    useEffect(() {
      double newValuePrice = orders.fold(0, (oldValue, element) => oldValue += (element.customPrice ?? (element.amount * element.product.price)));
      realPrice.value = orders.fold(0, (oldValue, element) => oldValue += (element.amount * element.product.price));

      if (priceController.text != (newValuePrice).price) {
        final cursorPosition = priceController.selection.baseOffset;
        priceController.text = "${(newValuePrice).price} UZS";

        priceController.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition.clamp(0, priceController.text.length)),
        );
      }
      return null;
    }, [orders]);

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        spacing: 16,
        children: [
          24.h,
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.accentColor,
                  ),
                  padding: 12.all,
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocales.totalOrderSumm.tr(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: realPrice.value.priceUZS),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.textColor),
                        cursorHeight: 16,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: Dis.only(tb: 12),
                          // constraints: const BoxConstraints(maxWidth: 64),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.accentColor,
                  ),
                  padding: 12.all,
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocales.totalSumm.tr(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      TextField(
                        controller: priceController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.textColor),
                        cursorHeight: 16,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: Dis.only(tb: 12),
                          // constraints: const BoxConstraints(maxWidth: 64),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(14),
                            ),
                            borderSide: BorderSide(color: theme.mainColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.accentColor,
                  ),
                  padding: 8.all,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.person_outline),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (customer.value == null) Text(AppLocales.addCustomer.tr()),
                          if (customer.value != null)
                            Text(
                              AppLocales.customer.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: regularFamily,
                                color: theme.secondaryTextColor,
                              ),
                            ),
                          if (customer.value != null) 4.h,
                          if (customer.value != null) AppText.$14Bold(customer.value!.name),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.accentColor,
                  ),
                  padding: 8.all,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.admin_panel_settings_outlined),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (employee.value == null) Text(AppLocales.selectSeller.tr()),
                          if (employee.value != null)
                            Text(
                              AppLocales.seller.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: regularFamily,
                                color: theme.secondaryTextColor,
                              ),
                            ),
                          if (employee.value != null) 4.h,
                          if (employee.value != null) AppText.$14Bold(employee.value!.fullname),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SimpleButton(
                  onPressed: () {
                    printing.value = !printing.value;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.accentColor,
                    ),
                    padding: 8.all,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(Icons.print_outlined),
                        AppText.$14Bold(AppLocales.printing.tr()),
                        if (printing.value) Icon(Icons.check_circle, color: theme.mainColor) else Icon(Icons.circle_outlined)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConfirmCancelButton(
            cancelIcon: Ionicons.time_outline,
            confirmIcon: Ionicons.checkmark_done,
            cancelText: AppLocales.scheduleOrder.tr(),
            confirmText: AppLocales.createOrder.tr(),
          ),
          1.h,
        ],
      );
    });
  }
}
