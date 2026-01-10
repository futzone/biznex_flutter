import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/order_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class OrderPercentFee extends HookConsumerWidget {
  final AppColors theme;
  final double? orderPercent;
  final void Function(double? percent) onSavePercent;

  const OrderPercentFee({
    super.key,
    required this.theme,
    this.orderPercent,
    required this.onSavePercent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderPercentController = useTextEditingController(
      text: orderPercent?.toString(),
    );
    return Column(
      spacing: 16,
      children: [
        ///
        AppTextField(
          title: AppLocales.pricePercentHint.tr(),
          controller: orderPercentController,
          theme: theme,
        ),

        ///
        ConfirmCancelButton(
          onCancel: () => AppRouter.close(context),
          onConfirm: () async {
            onSavePercent(double.tryParse(orderPercentController.text.trim()));
            await Future.delayed(Duration(milliseconds: 300)).then((_) {
              AppRouter.close(context);
            });
          },
        ),
      ],
    );
  }
}
