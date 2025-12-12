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
    final addressController = useTextEditingController(text: customer?.address);
    final noteController = useTextEditingController(text: customer?.note);
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
            20.h,
            AppText.$18Bold(AppLocales.address.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.enterAddress.tr(),
              controller: addressController,
              theme: theme,
            ),
            20.h,
            AppText.$18Bold(AppLocales.note.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.addNote.tr(),
              controller: noteController,
              theme: theme,
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () {
                CustomerController customerController =
                    CustomerController(context: context, state: state);
                Customer newCustomer = Customer(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  note: noteController.text.trim(),
                  updated: DateTime.now(),
                  created: DateTime.now(),
                );
                if (customer == null) {
                  // newCustomer.created = DateTime.now();
                  customerController.create(newCustomer);
                  return;
                }
                customer!.address = addressController.text.trim();
                customer!.note = noteController.text.trim();
                customer!.name = nameController.text.trim();
                customer!.phone = phoneController.text.trim();
                customer!.updated = DateTime.now();
                customerController.update(customer, customer!.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
