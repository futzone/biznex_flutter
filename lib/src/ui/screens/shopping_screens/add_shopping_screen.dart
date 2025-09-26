import 'package:biznex/src/controllers/recipe_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:biznex/src/core/model/product_models/shopping_model.dart';
import 'package:biznex/src/ui/screens/shopping_screens/choose_ingredient_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../biznex.dart';

class AddShoppingScreen extends HookConsumerWidget {
  final Shopping? shopping;

  const AddShoppingScreen({super.key, this.shopping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIngredient = useState<Ingredient?>(null);
    final items = useState(<RecipeItem>[...(shopping?.items ?? [])]);
    final priceController = useTextEditingController();
    final totalPriceController = useTextEditingController();
    final amountController = useTextEditingController();
    final noteController = useTextEditingController(text: shopping?.note ?? '');
    final addTransactions = useState(true);
    final updatePrice = useState(true);
    final customPriceController =
        useTextEditingController(text: (shopping?.totalPrice ?? 0.0).price);

    void onEditCustomPrice() {
      customPriceController.text = items.value
          .fold(0.0, (total, el) => total += (el.amount * (el.price ?? 0.0)))
          .price;
    }

    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
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
                            fontFamily: boldFamily,
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
                            fontFamily: boldFamily,
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
                            fontFamily: boldFamily,
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

                              onEditCustomPrice();
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
            if (items.value.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: Dis.only(lr: 12, tb: 8),
                child: Row(
                  children: [
                    Expanded(
                      // flex: 5,
                      child: Text(
                        "${AppLocales.totalPrice.tr()}: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: mediumFamily,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        useBorder: false,
                        align: TextAlign.end,
                        title: AppLocales.price.tr(),
                        controller: customPriceController,
                        theme: theme,
                        suffixIcon: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("UZS")],
                        ),
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
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      16.w,
                      Expanded(
                        child: AppTextField(
                          // onTap: () {},
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
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: AppTextField(
                          useKeyboard: true,
                          title: AppLocales.price.tr(),
                          controller: priceController,
                          theme: theme,
                          onChanged: (char) {
                            final priceValue = double.tryParse(char.trim());
                            final amountValue =
                                double.tryParse(amountController.text.trim());
                            totalPriceController.text =
                                ((priceValue ?? 0.0) * (amountValue ?? 0.0))
                                    .toStringAsFixed(4);
                          },
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("UZS"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AppTextField(
                          useKeyboard: true,
                          title: AppLocales.totalPrice.tr(),
                          controller: totalPriceController,
                          theme: theme,
                          onChanged: (str) {
                            final totalPriceValue = double.tryParse(str.trim());
                            final amountValue =
                                double.tryParse(amountController.text.trim());

                            if ((amountValue ?? 0.0) != 0.0) {
                              priceController.text = ((totalPriceValue ?? 0.0) /
                                      (amountValue ?? 0.0))
                                  .toStringAsFixed(4);
                            }
                          },
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("UZS"),
                              ],
                            ),
                          ),
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
                          onEditCustomPrice();
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

                          onEditCustomPrice();
                        },
                        title: AppLocales.add.tr(),
                        padding: Dis.only(tb: 8, lr: 24),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // 16.h,
            // Container(
            //   decoration: BoxDecoration(
            //     color: theme.scaffoldBgColor,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   padding: Dis.only(lr: 12, tb: 8),
            //   child: Column(
            //     children: [
            //       SwitchListTile(
            //         activeThumbColor: theme.mainColor,
            //         contentPadding: Dis.only(),
            //         value: addTransactions.value,
            //         onChanged: (v) => addTransactions.value = v,
            //         title: Text(AppLocales.addToTransactions.tr()),
            //       ),
            //       Container(
            //         color: Colors.white,
            //         height: 1,
            //         margin: Dis.only(tb: 8),
            //       ),
            //       SwitchListTile(
            //         activeThumbColor: theme.mainColor,
            //         contentPadding: Dis.only(),
            //         value: updatePrice.value,
            //         onChanged: (v) => updatePrice.value = v,
            //         title: Text(AppLocales.updateIngredientData.tr()),
            //       ),
            //     ],
            //   ),
            // ),
            0.h,
            AppTextField(
              title: AppLocales.note.tr(),
              controller: noteController,
              theme: theme,
              minLines: 3,
            ),
            16.h,
            ConfirmCancelButton(
              onConfirm: () async {
                RecipeController rc = RecipeController(context: context);
                await rc
                    .saveShopping(
                        ref: ref,
                        items: items.value,
                        price: double.tryParse(
                          customPriceController.text.trim().replaceAll(" ", ""),
                        ),
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text,
                        id: shopping?.id)
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
