import 'dart:io';

import 'package:biznex/src/controllers/recipe_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/constants/measures.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../biznex.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';

class AddIngredientScreen extends HookConsumerWidget {
  final Ingredient? ingredient;

  const AddIngredientScreen({super.key, this.ingredient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: ingredient?.name);
    final priceController = useTextEditingController(
        text: ingredient?.unitPrice?.toStringAsFixed(1));
    final amountController =
        useTextEditingController(text: ingredient?.quantity.toStringAsFixed(2));
    final caloryController =
        useTextEditingController(text: ingredient?.calory?.toStringAsFixed(2));
    final image = useState(ingredient?.image ?? '');
    final measure = useState(ingredient?.measure ?? '');
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            if (ingredient != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ingredient?.name ?? '',
                    style: TextStyle(fontSize: 20),
                  ),
                  SimpleButton(
                    onPressed: () {
                      showConfirmDialog(
                        context: context,
                        title: AppLocales.deleteProductQuestion.tr(),
                        onConfirm: () {
                          RecipeDatabase()
                              .deleteIngredient(ingredient?.id)
                              .then((_) {
                            ref.invalidate(ingredientsProvider);
                            AppRouter.close(context);
                          });
                        },
                      );
                    },
                    child: Container(
                      height: context.s(36),
                      width: context.s(36),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.scaffoldBgColor,
                      ),
                      padding: Dis.all(context.s(8)),
                      child: Icon(
                        Iconsax.trash_copy,
                        size: context.s(20),
                        color: theme.red,
                      ),
                    ),
                  ),
                ],
              ),
            AppTextField(
              title: AppLocales.productName.tr(),
              controller: nameController,
              theme: theme,
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppTextField(
                    useKeyboard: true,
                    title: AppLocales.amount.tr(),
                    controller: amountController,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    useKeyboard: true,
                    title: AppLocales.price.tr(),
                    controller: priceController,
                    theme: theme,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: () {
                      ImagePicker()
                          .pickImage(source: ImageSource.gallery)
                          .then((img) {
                        if (img != null) image.value = img.path;
                      });
                    },
                    child: Container(
                      height: context.h(400),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.scaffoldBgColor),
                        image: image.value.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(image.value)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: image.value.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(Ionicons.cloud_upload_outline, size: 32),
                                Text(AppLocales.uploadImage.tr()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    image.value = '';
                                  },
                                  icon: Icon(
                                    Iconsax.trash_copy,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 16,
                    children: [
                      AppTextField(
                        useKeyboard: true,
                        title: AppLocales.calory.tr(),
                        controller: caloryController,
                        theme: theme,
                      ),
                      CustomPopupMenu(
                        theme: theme,
                        children: [
                          for (final item in measures)
                            CustomPopupItem(
                              title: item,
                              onPressed: () => measure.value = item,
                            ),
                        ],
                        child: IgnorePointer(
                          ignoring: true,
                          child: AppTextField(
                            onlyRead: true,
                            title: AppLocales.measureNameHint.tr(),
                            controller: TextEditingController(
                              text: measure.value.tr(),
                            ),
                            theme: theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            0.h,
            ConfirmCancelButton(
              onConfirm: () {
                RecipeController recipeController =
                    RecipeController(context: context);

                recipeController
                    .saveIngredient(
                      ref: ref,
                      name: nameController.text.trim(),
                      image: image.value,
                      price: double.tryParse(priceController.text.trim()),
                      quantity: double.tryParse(amountController.text.trim()),
                      calory: double.tryParse(caloryController.text.trim()),
                      id: ingredient?.id,
                      measure: measure.value,
                    )
                    .then((_) => AppRouter.close(context));
              },
              // onCancel: (){},
            ),
          ],
        ),
      );
    });
  }
}
