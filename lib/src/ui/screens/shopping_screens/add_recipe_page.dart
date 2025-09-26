import 'package:biznex/src/controllers/recipe_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:biznex/src/ui/screens/shopping_screens/choose_ingredient_screen.dart';
import 'package:biznex/src/ui/screens/shopping_screens/choose_product_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../biznex.dart';

class AddRecipePage extends HookConsumerWidget {
  final Recipe? recipe;

  const AddRecipePage({super.key, this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProduct = useState(recipe?.product);
    final selectedIngredient = useState<Ingredient?>(null);
    final items = useState(<RecipeItem>[...(recipe?.items ?? [])]);
    final priceController = useTextEditingController();
    final totalPriceController = useTextEditingController();
    final amountController = useTextEditingController();
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            AppTextField(
              title: AppLocales.products.tr(),
              controller:
                  TextEditingController(text: selectedProduct.value?.name),
              theme: theme,
              onlyRead: true,
              onTap: () {
                showDesktopModal(
                  context: context,
                  width: 600,
                  body: ChooseProductScreen(
                    theme: theme,
                    onSelectedProduct: (Product product) {
                      selectedProduct.value = product;
                    },
                  ),
                );
              },
            ),
            0.h,
            if (items.value.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: Dis.only(lr: 12, tb: 8),
                child: Row(
                  children: [
                    Expanded(child: Text("")),
                    Expanded(
                      flex: 5,
                      child: Center(child: Text(AppLocales.productName.tr())),
                    ),
                    Expanded(
                        flex: 2,
                        child: Center(child: Text(AppLocales.amount.tr()))),
                    Expanded(
                        flex: 2,
                        child: Center(child: Text(AppLocales.price.tr()))),
                    Expanded(child: Text("")),
                  ],
                ),
              ),
            for (final item in items.value)
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: Dis.only(lr: 12, tb: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AppFileImage(
                            path: item.ingredient.image ?? '',
                            name: item.ingredient.name,
                            size: 36,
                            color: theme.white,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Text(
                          item.ingredient.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          "${item.amount.toMeasure} ${item.ingredient.measure ?? ""}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          "${item.price == null ? '-' : item.price?.priceUZS}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SimpleButton(
                            onPressed: () {
                              items.value = [
                                ...items.value.where((el) =>
                                    el.ingredient.id != item.ingredient.id)
                              ];
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 36,
                              width: 36,
                              child: Icon(
                                Iconsax.trash_copy,
                                color: theme.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            0.h,
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.scaffoldBgColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: 12.all,
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          title: AppLocales.productName.tr(),
                          controller: TextEditingController(
                            text: selectedIngredient.value?.name,
                          ),
                          theme: theme,
                          onlyRead: true,
                          onTap: () {
                            showDesktopModal(
                              context: context,
                              width: 600,
                              body: ChooseIngredientScreen(
                                theme: theme,
                                onSelectedIngredient: (product) {
                                  if (items.value
                                      .where((el) =>
                                          el.ingredient.id == product.id)
                                      .isNotEmpty) {
                                    items.value = [
                                      ...items.value.where((el) =>
                                          el.ingredient.id != product.id),
                                    ];
                                  }

                                  selectedIngredient.value = product;
                                  priceController.text =
                                      product.unitPrice?.toStringAsFixed(2) ??
                                          '';
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: AppTextField(
                          useKeyboard: true,
                          title: AppLocales.amount.tr(),
                          controller: amountController,
                          theme: theme,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (selectedIngredient.value?.measure ?? '')
                                      .toUpperCase(),
                                ),
                              ],
                            ),
                          ),
                          onChanged: (val) {
                            final amountVal = double.tryParse(val.trim());
                            if (amountVal != null) {
                              priceController.text =
                                  ((selectedIngredient.value?.unitPrice ??
                                              0.0) *
                                          (amountVal))
                                      .toStringAsFixed(2);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 16,
                    children: [
                      AppPrimaryButton(
                        theme: theme,
                        onPressed: () {
                          selectedIngredient.value = null;
                          priceController.clear();
                          amountController.clear();
                          totalPriceController.clear();
                        },
                        color: Colors.transparent,
                        border: Border.all(color: theme.red),
                        textColor: theme.red,
                        title: AppLocales.delete.tr(),
                        padding: Dis.only(tb: 8, lr: 24),
                      ),
                      AppPrimaryButton(
                        theme: theme,
                        onPressed: () {
                          if (selectedIngredient.value == null) {
                            return ShowToast.error(
                                context, AppLocales.selectProductError.tr());
                          }

                          if (double.tryParse(amountController.text.trim()) ==
                              null) {
                            return ShowToast.error(
                                context, AppLocales.amountInputError.tr());
                          }

                          items.value.add(
                            RecipeItem(
                              ingredient: selectedIngredient.value!,
                              amount: double.tryParse(
                                      amountController.text.trim()) ??
                                  0.0,
                              price:
                                  double.tryParse(priceController.text.trim()),
                            ),
                          );

                          selectedIngredient.value = null;
                          priceController.clear();
                          amountController.clear();
                          totalPriceController.clear();
                        },
                        title: AppLocales.add.tr(),
                        padding: Dis.only(tb: 8, lr: 24),
                      ),
                    ],
                  )
                ],
              ),
            ),
            16.h,
            ConfirmCancelButton(
              onConfirm: () {
                if (selectedProduct.value == null) {
                  return ShowToast.error(
                      context, AppLocales.selectProductError.tr());
                }

                if (items.value.isEmpty) {
                  return ShowToast.error(
                      context, AppLocales.recipeItemsError.tr());
                }

                RecipeController recipeController =
                    RecipeController(context: context);

                recipeController
                    .saveRecipe(
                      ref: ref,
                      product: selectedProduct.value!,
                      items: items.value,
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
