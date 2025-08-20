import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_info_controller.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductInfo extends HookWidget {
  final ProductInfo? productInfo;

  const AddProductInfo({super.key, this.productInfo});

  @override
  Widget build(BuildContext context) {
    final keyController = useTextEditingController(text: productInfo?.name);
    final valueController = useTextEditingController(text: productInfo?.data);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.productInfoKeyLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.productInfoKeyHint.tr(),
              controller: keyController,
              theme: theme,
            ),
            AppText.$18Bold(AppLocales.productInfoValueLabel.tr(), padding: 24.top),
            AppTextField(
              title: AppLocales.productInfoValueHint.tr(),
              controller: valueController,
              theme: theme,
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () async {
                ProductInfoController controller = ProductInfoController(context: context, state: state);
                if (productInfo != null) {
                  controller.update(ProductInfo(id: productInfo!.id, name: keyController.text, data: valueController.text), productInfo?.id);
                  return;
                }
                controller.create(ProductInfo(id: '', name: keyController.text, data: valueController.text));
              },
            ),
          ],
        ),
      );
    });
  }
}
