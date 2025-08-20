import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_measure_controller.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/product_params_models/product_measure.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductMeasure extends HookWidget {
  final ProductMeasure? productMeasure;

  const AddProductMeasure({super.key, this.productMeasure});

  @override
  Widget build(BuildContext context) {
    final sizeController = useTextEditingController(text: productMeasure?.name);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.productMeasureLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.productMeasureHint.tr(),
              controller: sizeController,
              theme: theme,
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () async {
                ProductMeasureController controller = ProductMeasureController(context: context, state: state);
                if (productMeasure == null) {
                  return controller.create(ProductMeasure(name: sizeController.text));
                }
                controller.update(ProductMeasure(name: sizeController.text, id: productMeasure!.id), productMeasure?.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
