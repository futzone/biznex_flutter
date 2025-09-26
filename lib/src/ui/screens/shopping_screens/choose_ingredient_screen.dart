import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/screens/shopping_screens/add_ingredient_screen.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../../biznex.dart';
import '../../../core/config/router.dart' show AppRouter;
import '../../widgets/custom/app_error_screen.dart';
import '../../widgets/custom/app_file_image.dart';
import '../../widgets/helpers/app_loading_screen.dart';
import '../../widgets/helpers/app_text_field.dart';

class ChooseIngredientScreen extends HookConsumerWidget {
  final void Function(Ingredient ingredient) onSelectedIngredient;
  final AppColors theme;

  const ChooseIngredientScreen({
    super.key,
    required this.theme,
    required this.onSelectedIngredient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchResult = useState(<Ingredient>[]);
    return ref.watch(ingredientsProvider).when(
          error: RefErrorScreen,
          loading: RefLoadingScreen,
          data: (products) {
            return CustomScrollView(
              slivers: [
                SliverPinnedHeader(
                  child: Container(
                    padding: Dis.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.white,
                    ),
                    child: AppTextField(
                      title: AppLocales.searchBarHint.tr(),
                      controller: searchController,
                      theme: theme,
                      onChanged: (char) {
                        searchResult.value.clear();
                        searchResult.value = [
                          ...products.where((el) => el.name
                              .toLowerCase()
                              .contains(char.toLowerCase())),
                        ];
                      },
                      // prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: () {
                          searchController.clear();
                          searchResult.value.clear();
                        },
                        icon: Icon(Ionicons.search),
                      ),
                    ),
                  ),
                ),
                if (searchResult.value.isNotEmpty &&
                    searchController.text.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: searchResult.value.length,
                      (context, index) {
                        final product = searchResult.value[index];
                        return SimpleButton(
                          onPressed: () {
                            onSelectedIngredient(product);
                            AppRouter.close(context);
                          },
                          child: Container(
                            margin: Dis.only(tb: 8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBgColor,
                              borderRadius: BorderRadiusDirectional.circular(8),
                            ),
                            padding: Dis.only(lr: 8, tb: 8),
                            child: Row(
                              spacing: 16,
                              children: [
                                AppFileImage(
                                  size: 40,
                                  color: Colors.white,
                                  name: product.name,
                                  path: product.image ?? '',
                                ),
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: mediumFamily,
                                    ),
                                  ),
                                ),

                                // if()
                                // Icon(Icons.done, color: theme.mainColor),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: products.length,
                      (context, index) {
                        final product = products[index];
                        return SimpleButton(
                          onPressed: () {
                            onSelectedIngredient(product);
                            AppRouter.close(context);
                          },
                          child: Container(
                            margin: Dis.only(tb: 8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBgColor,
                              borderRadius: BorderRadiusDirectional.circular(8),
                            ),
                            padding: Dis.only(lr: 8, tb: 8),
                            child: Row(
                              spacing: 16,
                              children: [
                                AppFileImage(
                                  size: 40,
                                  color: Colors.white,
                                  name: product.name,
                                  path: product.image ?? '',
                                ),
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: mediumFamily,
                                    ),
                                  ),
                                ),

                                // if()
                                // Icon(Icons.done, color: theme.mainColor),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SimpleButton(
                    onPressed: () {
                      showDesktopModal(
                        context: context,
                        body: AddIngredientScreen(),
                      );
                    },
                    child: Container(
                      margin: Dis.only(tb: 8),
                      decoration: BoxDecoration(
                        color: theme.secondaryColor,
                        borderRadius: BorderRadiusDirectional.circular(16),
                      ),
                      padding: Dis.only(lr: 8, tb: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 16,
                        children: [
                          Icon(Icons.add),
                          Text(AppLocales.addBTN.tr())
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
  }
}
