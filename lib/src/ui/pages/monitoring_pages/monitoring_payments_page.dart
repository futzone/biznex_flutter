import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../../core/model/transaction_model/transaction_model.dart';
import '../../widgets/custom/app_custom_popup_menu.dart';
import '../../widgets/helpers/app_back_button.dart';

class MonitoringPaymentsPage extends HookConsumerWidget {
  final AppColors theme;

  const MonitoringPaymentsPage(this.theme, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    return ref.watch(dayPaymentsProvider(selectedDate.value)).when(
          error: RefErrorScreen,
          loading: RefLoadingScreen,
          data: (paymentData) {
            return Column(
              children: [
                Row(
                  children: [
                    AppBackButton(),
                    16.w,
                    Text(
                      AppLocales.payments.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: mediumFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
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
                              style: TextStyle(
                                  fontFamily: mediumFamily, fontSize: 16),
                            ),
                            8.w,
                            Icon(Ionicons.calendar_outline, size: 20)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                16.h,
                for (final item in Transaction.values)
                  Container(
                    padding: Dis.only(lr: 16, tb: 12),
                    margin: 16.bottom,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.tr().capitalize,
                            style: TextStyle(
                                fontSize: 16, fontFamily: mediumFamily),
                          ),
                        ),
                        Text(
                          (paymentData[item] ?? 0.0).priceUZS,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: boldFamily,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
  }
}
