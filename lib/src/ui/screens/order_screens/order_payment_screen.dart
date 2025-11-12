import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../../core/model/order_models/percent_model.dart';

class OrderPaymentScreen extends HookConsumerWidget {
  final AppColors theme;
  final AppModel state;
  final void Function(List<Percent> payments) onComplete;
  final double totalSumm;
  final List<Percent> percentList;

  const OrderPaymentScreen({
    super.key,
    required this.theme,
    required this.state,
    required this.percentList,
    required this.totalSumm,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = useState('');
    final payments = useState(<Percent>[...percentList]);

    final initial =
        totalSumm - (payments.value.fold(0.0, (a, b) => a += b.percent));

    final currentSum = useTextEditingController(text: initial.toMeasure);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            "${AppLocales.totalSumm.tr()}: ${totalSumm.priceUZS}",
            style: TextStyle(fontSize: 18, fontFamily: boldFamily),
          ),
          0.h,
          for (final pay in payments.value)
            Container(
              padding: Dis.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.accentColor,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(pay.name.tr().capitalize)),
                  Expanded(
                      child:
                          Center(child: Text(pay.percent.priceUZS.capitalize))),
                  Expanded(
                    child: Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SimpleButton(
                          onPressed: () {
                            payments.value = payments.value
                                .where((element) => element != pay)
                                .toList();

                            currentSum.text = initial.toMeasure;
                          },
                          child: Icon(
                            Iconsax.trash_copy,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // margin: Dis.only(bottom: ),
            ),
          if (initial > 0)
            Container(
              margin: payments.value.isEmpty ? null : Dis.only(tb: 12),
              padding: Dis.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.secondaryTextColor.withValues(alpha: 0.4),
              ),
              child: Column(
                spacing: 16,
                children: [
                  CustomPopupMenu(
                    theme: theme,
                    children: [
                      ...Transaction.values.map((el) {
                        return CustomPopupItem(
                          title: el.tr().capitalize,
                          onPressed: () => currentType.value = el,
                        );
                      })
                    ],
                    child: IgnorePointer(
                      ignoring: true,
                      child: AppTextField(
                        onlyRead: true,
                        title: AppLocales.paymentType.tr(),
                        controller: TextEditingController(
                          text: currentType.value.tr().capitalize,
                        ),
                        theme: theme,
                      ),
                    ),
                  ),
                  AppTextField(
                    title: AppLocales.summ.tr(),
                    controller: currentSum,
                    theme: theme,
                  ),
                  AppPrimaryButton(
                    theme: theme,
                    textColor: Colors.white,
                    title: AppLocales.add.tr(),
                    // child: Text(AppLocales.add.tr()),
                    onPressed: () {
                      if (currentType.value.isEmpty) return;
                      if (double.tryParse(currentSum.text.trim()) == null) {
                        return;
                      }

                      payments.value = [
                        ...payments.value,
                        Percent(
                          name: currentType.value,
                          percent: double.parse(
                            currentSum.text.tr(),
                          ),
                        ),
                      ];

                      currentType.value = '';
                      currentSum.text = (totalSumm -
                              (payments.value
                                  .fold(0.0, (a, b) => a += b.percent)))
                          .toMeasure;
                    },
                  ),
                ],
              ),
            ),
          8.h,
          AppPrimaryButton(
            theme: theme,
            textColor: Colors.white,
            title: AppLocales.save.tr(),
            // child: Text(AppLocales.add.tr()),
            onPressed: () {
              onComplete(payments.value);
              currentType.value = '';
              currentSum.clear();
              AppRouter.close(context);
            },
          ),
        ],
      ),
    );
  }
}
