import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../../../biznex.dart';

class TransactionsFilter extends StatelessWidget {
  final void Function() onSelectedDate;
  final DateTime selectedDate;
  final AppColors theme;
  final String? paymentType;
  final void Function(String? pt) onSelectedPaymentType;

  const TransactionsFilter({
    super.key,
    required this.onSelectedDate,
    required this.selectedDate,
    required this.theme,
    this.paymentType,
    required this.onSelectedPaymentType,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(context.s(24)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: context.w(16),
          children: [
            Expanded(
              child: Text(
                AppLocales.transactions.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: mediumFamily,
                  color: Colors.black,
                ),
              ),
            ),
            0.w,
            CustomPopupMenu(
              theme: theme,
              children: [
                CustomPopupItem(
                  onPressed: () {
                    onSelectedPaymentType(null);
                  },
                  title: AppLocales.all.tr(),
                ),
                for (final item in Transaction.values)
                  CustomPopupItem(
                    title: item.tr().capitalize,
                    onPressed: () {
                      onSelectedPaymentType(item);
                    },
                  )
              ],
              child: Container(
                padding: Dis.only(lr: 16),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      paymentType==null?AppLocales.paymentType.tr():paymentType!,
                      style: TextStyle(
                        color: theme.secondaryTextColor,
                        fontSize: context.s(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            0.w,
            SimpleButton(
              onPressed: onSelectedDate,
              child: Container(
                padding: Dis.only(lr: 16),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yyyy, d-MMMM', context.locale.languageCode)
                          .format(selectedDate)
                          .toLowerCase(),
                      style: TextStyle(
                        color: theme.secondaryTextColor,
                        fontSize: context.s(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
