import 'package:biznex/biznex.dart';
 import 'package:biznex/src/controllers/product_size_controller.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
 import 'package:biznex/src/core/model/product_params_models/product_size.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductSize extends HookWidget {
  final ProductSize? productSize;

  const AddProductSize({super.key, this.productSize});

  @override
  Widget build(BuildContext context) {
    final sizeController = useTextEditingController(text: productSize?.name);
    final descriptionController = useTextEditingController(text: productSize?.description);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.productSizeLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.productSizeHint.tr(),
              controller: sizeController,
              theme: theme,
            ),
            AppText.$18Bold(AppLocales.productSizeDescriptionLabel.tr(), padding: 24.top),
            AppTextField(
              title: AppLocales.productSizeDescriptionHint.tr(),
              controller: descriptionController,
              theme: theme,
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () async {
                ProductSizeController controller = ProductSizeController(context: context, state: state);
                if (productSize == null) {
                  return controller.create(
                    ProductSize(name: sizeController.text, description: descriptionController.text),
                  );
                }

                controller.update(
                  ProductSize(name: sizeController.text, description: descriptionController.text, id: productSize!.id),
                  productSize!.id,
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
