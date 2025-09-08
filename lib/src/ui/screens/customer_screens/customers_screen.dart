import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/customer_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/providers/customer_provider.dart';
import 'package:biznex/src/ui/screens/customer_screens/add_customer_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

class CustomersScreen extends ConsumerWidget {
  final void Function(Customer customer)? onSelected;

  const CustomersScreen({super.key, this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(
      builder: (theme, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SimpleButton(
                  onPressed: () => AppRouter.close(context),
                  child: Icon(Icons.arrow_back_ios_new),
                ),
                16.w,
                AppText.$18Bold(AppLocales.customers.tr()),
                Spacer(),
                AppPrimaryButton(
                  padding: Dis.only(lr: 24, tb: 8),
                  theme: theme,
                  onPressed: () {
                    showDesktopModal(context: context, body: AddCustomerScreen());
                  },
                  title: AppLocales.add.tr(),
                ),
              ],
            ),
            12.h,
            Expanded(
              child: state.whenProviderData(
                provider: customerProvider,
                builder: (customers) {
                  customers as List<Customer>;
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];

                      return AppListTile(
                        onPressed: () {
                          if (onSelected != null) {
                            onSelected!(customer);
                            AppRouter.close(context);
                          }
                        },
                        title: "${customer.name}, ${customer.phone}",
                        theme: theme,
                        leadingIcon: Icons.person_outline,
                        onDelete: () {
                          CustomerController cController = CustomerController(context: context, state: state);
                          cController.delete(customer.id);
                        },
                        onEdit: () => showDesktopModal(context: context, body: AddCustomerScreen(customer: customer)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
