import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/pages/shopping_pages/ingredients_page.dart';
import 'package:biznex/src/ui/pages/shopping_pages/market_page.dart';
import 'package:biznex/src/ui/pages/shopping_pages/recipe_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../widgets/helpers/app_text_field.dart';

class ShoppingPage extends HookConsumerWidget {
  const ShoppingPage({super.key});

  Widget buildBody(currentPage, theme, WidgetRef ref) {
    if (currentPage.value == 0) {
      return ref.watch(ingredientsProvider).when(
            data: (data) => IngredientsPage(theme, ingredients: data),
            error: RefErrorScreen,
            loading: RefLoadingScreen,
          );
    }

    if (currentPage.value == 1) {
      return ref.watch(recipesProvider).when(
            data: (data) => RecipePage(theme: theme, recipe: data),
            error: RefErrorScreen,
            loading: RefLoadingScreen,
          );
    }

    return ref.watch(shoppingProvider).when(
          data: (data) => MarketPage(theme, shoppingList: data),
          error: RefErrorScreen,
          loading: RefLoadingScreen,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = useState(0);
    final searchController = useTextEditingController();
    return AppStateWrapper(
      builder: (theme, state) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: Dis.all(context.w(24)),
                child: Row(
                  spacing: 16,
                  children: [
                    WebButton(
                      onPressed: () {
                        currentPage.value = 0;
                      },
                      builder: (focused) => Container(
                        padding: Dis.only(lr: 16, tb: 12),
                        decoration: BoxDecoration(
                          color: currentPage.value == 0
                              ? theme.mainColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: focused
                              ? Border.all(color: theme.mainColor)
                              : Border.all(
                                  color: currentPage.value == 0
                                      ? theme.mainColor
                                      : Colors.white,
                                ),
                        ),
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage('assets/images/healthy-food.png'),
                              color: currentPage.value == 0
                                  ? Colors.white
                                  : theme.textColor,
                            ),
                            12.w,
                            Text(
                              AppLocales.products.tr(),
                              style: TextStyle(
                                color: currentPage.value == 0
                                    ? Colors.white
                                    : theme.textColor,
                                fontSize: context.s(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WebButton(
                      onPressed: () {
                        currentPage.value = 1;
                      },
                      builder: (focused) => Container(
                        padding: Dis.only(lr: 16, tb: 12),
                        decoration: BoxDecoration(
                          color: currentPage.value == 1
                              ? theme.mainColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: focused
                              ? Border.all(color: theme.mainColor)
                              : Border.all(
                                  color: currentPage.value == 1
                                      ? theme.mainColor
                                      : Colors.white,
                                ),
                        ),
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage('assets/images/chef.png'),
                              color: currentPage.value == 1
                                  ? Colors.white
                                  : theme.textColor,
                            ),
                            12.w,
                            Text(
                              AppLocales.recipes.tr(),
                              style: TextStyle(
                                color: currentPage.value == 1
                                    ? Colors.white
                                    : theme.textColor,
                                fontSize: context.s(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WebButton(
                      onPressed: () {
                        currentPage.value = 2;
                      },
                      builder: (focused) => Container(
                        padding: Dis.only(lr: 16, tb: 12),
                        decoration: BoxDecoration(
                          color: currentPage.value == 2
                              ? theme.mainColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: focused
                              ? Border.all(color: theme.mainColor)
                              : Border.all(
                                  color: currentPage.value == 2
                                      ? theme.mainColor
                                      : Colors.white,
                                ),
                        ),
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage("assets/images/shopping-cart.png"),
                              color: currentPage.value == 2
                                  ? Colors.white
                                  : theme.textColor,
                            ),
                            12.w,
                            Text(
                              AppLocales.shopping.tr(),
                              style: TextStyle(
                                color: currentPage.value == 2
                                    ? Colors.white
                                    : theme.textColor,
                                fontSize: context.s(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              prefixIcon: Icon(Iconsax.search_normal_copy),
                              title: AppLocales.search.tr(),
                              controller: searchController,
                              onChanged: (_) {},
                              theme: theme,
                              fillColor: Colors.white,
                              // useBorder: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: buildBody(currentPage, theme, ref)),
            ],
          ),
        );
      },
    );
  }
}
