import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:sliver_tools/sliver_tools.dart';

class IngredientDetailScreen extends HookConsumerWidget {
  final Ingredient ingredient;
  final AppColors theme;

  const IngredientDetailScreen(this.ingredient, this.theme, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final listener = ref.watch(ingredientTransactionsProvider(ingredient.id));
    return listener.when(
      error: RefErrorScreen,
      loading: RefLoadingScreen,
      data: (transactions) {
        return CustomScrollView(
          slivers: [
            SliverPinnedHeader(
              child: Container(
                color: Colors.white,
                child: Column(
                  spacing: 8,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        SimpleButton(
                          onPressed: () => AppRouter.close(context),
                          child: Icon(
                            Ionicons.close,
                            size: 28,
                          ),
                        ),
                        AppText.$18Bold(ingredient.name),
                      ],
                    ),
                    Divider(height: 1, color: theme.accentColor),
                    Row(
                      children: [
                        Expanded(
                            child: Center(
                                child: Text(AppLocales.productName.tr()))),
                        Expanded(
                            child: Center(child: Text(AppLocales.amount.tr()))),
                        Expanded(
                            child: Center(
                                child: Text(AppLocales.createdDate.tr()))),
                      ],
                    ),
                    Divider(height: 1, color: theme.accentColor),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: transactions.length,
                (context, index) {
                  final transaction = transactions[index];
                  return Container(
                    padding: Dis.only(tb: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "${transaction.fromShopping == true ? '* ' : ''}${transaction.product.name.tr()}",
                              style: TextStyle(
                                fontFamily: mediumFamily,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "${transaction.amount.toMeasure} ${ingredient.measure ?? ""}",
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat("yyyy.MM.dd HH:mm").format(
                                DateTime.parse(transaction.createdDate),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
