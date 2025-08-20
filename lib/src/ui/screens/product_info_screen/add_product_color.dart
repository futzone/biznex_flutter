import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_color_controller.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/product_params_models/product_color.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide ColorPicker;
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductColor extends HookWidget {
  final ProductColor? productColor;

  const AddProductColor({super.key, this.productColor});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: productColor?.name);
    final selected = useState(productColor?.code);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.productColorLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.productColorHint.tr(),
              controller: nameController,
              theme: theme,
            ),
            AppText.$18Bold(AppLocales.chooseColor.tr(), padding: 16.top),
            ColorPicker(
              onColorChanged: (color) {
                selected.value = colorToHex(color);
              },
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () async {
                ProductColorController controller = ProductColorController(context: context, state: state);
                if (productColor == null) {
                  ProductColor productColor = ProductColor(name: nameController.text.trim(), code: selected.value);
                  controller.create(productColor);
                  return;
                }

                ProductColor newColor = productColor!;
                newColor.name = nameController.text.trim();
                newColor.code = selected.value;

                controller.update(newColor, productColor?.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
