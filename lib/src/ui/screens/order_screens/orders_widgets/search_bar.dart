import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../biznex.dart';
import '../../../widgets/helpers/app_text_field.dart';

class OrderSearchBar extends StatelessWidget {
  final AppColors theme;
  final TextEditingController controller;
  final void Function(String char) onSearch;

  const OrderSearchBar({
    super.key,
    required this.theme,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocales.orders.tr(),
              style: TextStyle(
                fontFamily: boldFamily,
                fontSize: context.s(24),
                color: Colors.black,
              ),
            ),
          ),
          16.w,
          SizedBox(
            width: 300,
            child: AppTextField(
              title: AppLocales.enterOrderId.tr(),
              controller: controller,
              theme: theme,
              suffixIcon: Icon(Iconsax.search_normal_1_copy),
              fillColor: Colors.white,
              onChanged: onSearch,
            ),
          )
        ],
      ),
    );
  }
}
