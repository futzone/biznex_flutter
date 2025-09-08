import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../biznex.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../screens/shopping_screens/add_recipe_page.dart';
import '../../widgets/custom/app_empty_widget.dart';
import '../../widgets/custom/app_file_image.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';

class RecipePage extends HookConsumerWidget {
  final List<Recipe> recipe;
  final AppColors theme;

  const RecipePage({super.key, required this.theme, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: WebButton(
        onPressed: () {
          showDesktopModal(context: context, body: AddRecipePage());
        },
        builder: (focused) => AnimatedContainer(
          duration: theme.animationDuration,
          height: focused ? 80 : 64,
          width: focused ? 80 : 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xff5CF6A9), width: 2),
            color: theme.mainColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(3, 3),
              )
            ],
          ),
          child: Center(
            child: Icon(Iconsax.add_copy,
                color: Colors.white, size: focused ? 40 : 32),
          ),
        ),
      ),
      body: recipe.isEmpty
          ? AppEmptyWidget()
          : CustomScrollView(
              slivers: [
                SliverPinnedHeader(
                  child: Container(
                    margin: Dis.only(lr: context.s(24)),
                    padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.20)),
                      color: theme.scaffoldBgColor,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(AppLocales.mealName.tr()),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text("productCount".tr()),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: Text(AppLocales.unitPrice.tr())),
                        ),
                        Expanded(
                          flex: 2,
                          child:
                              Center(child: Text(AppLocales.createdDate.tr())),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Text(AppLocales.updatedDate.tr())],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: recipe.length,
                    (context, index) {
                      final ingredient = recipe[index];
                      return Container(
                        margin: Dis.only(lr: context.s(24)),
                        padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: theme.scaffoldBgColor)),
                          color: theme.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  AppFileImage(
                                    name: ingredient.product.name,
                                    path: ingredient
                                            .product.images?.firstOrNull ??
                                        '',
                                    size: 48,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  Center(child: Text(ingredient.product.name)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "${ingredient.items.length}",
                                  // textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Haaa",
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  DateFormat("yyyy.MM.dd")
                                      .format(ingredient.createdDate),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 8,
                                children: [
                                  Text(
                                    DateFormat("yyyy.MM.dd  HH:mm")
                                        .format(ingredient.updatedDate),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SimpleButton(
                                  onPressed: () {
                                    // showDesktopModal(
                                    //   context: context,
                                    //   body: AddIngredientScreen(
                                    //       ingredient: ingredient),
                                    // );
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
                                      Iconsax.edit_copy,
                                      size: context.s(20),
                                      color: theme.secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(padding: Dis.only(tb: 100)),
              ],
            ),
    );
  }
}
