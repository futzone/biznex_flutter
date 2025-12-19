import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../widgets/helpers/app_text_field.dart';

class OrderDeliveryScreen extends HookWidget {
  final AppColors theme;
  final String? phone;
  final String? address;
  final void Function(String address, String phone) onConfirm;

  const OrderDeliveryScreen({
    super.key,
    required this.theme,
    required this.onConfirm,
    this.address,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final phoneController = useTextEditingController(text: phone);
    final addressController = useTextEditingController(text: address);
    return Column(
      spacing: 16,
      children: [
        AppTextField(
          prefixIcon: Icon(Iconsax.call_copy),
          title: AppLocales.customerPhone.tr(),
          controller: phoneController,
          theme: theme,
          // useBorder: true,
          fillColor: theme.accentColor,
        ),
        AppTextField(
          prefixIcon: Icon(Iconsax.location_copy),
          title: AppLocales.deliveryAddress.tr(),
          controller: addressController,
          theme: theme,
          fillColor: theme.accentColor,
        ),
        0.h,
        AppPrimaryButton(
          title: AppLocales.save.tr(),
          theme: theme,
          onPressed: () {
            onConfirm(
              addressController.text.trim(),
              phoneController.text.trim(),
            );

            AppRouter.close(context);
          },
        ),
      ],
    );
  }
}
