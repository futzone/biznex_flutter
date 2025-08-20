import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/customer_controller.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class AddCustomerScreen extends HookConsumerWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: customer?.name);
    final phoneController = useTextEditingController(text: customer?.phone);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.customerName.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.enterCustomerName.tr(),
              controller: nameController,
              theme: theme,
            ),
            20.h,
            AppText.$18Bold(AppLocales.customerPhone.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.enterCustomerPhone.tr(),
              controller: phoneController,
              theme: theme,
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () {
                CustomerController customerController = CustomerController(context: context, state: state);
                Customer newCustomer = Customer(name: nameController.text.trim(), phone: phoneController.text.trim());
                if (customer == null) {
                  customerController.create(newCustomer);
                  return;
                }
                customer!.name = nameController.text.trim();
                customer!.phone = phoneController.text.trim();
                customerController.update(customer, customer!.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
