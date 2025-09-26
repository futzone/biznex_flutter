import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';

class RecipeDetailPage extends StatelessWidget {
  final AppColors theme;
  final Recipe recipe;

  const RecipeDetailPage(
      {super.key, required this.theme, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 16,
          children: [
            AppBackButton(),
            AppText.$18Bold(recipe.product.name),
            Spacer(),
            AppText.$18Bold(
              "${AppLocales.unitPrice.tr()}:",
              style: TextStyle(
                fontSize: 18,
                fontFamily: regularFamily,
              ),
            ),
            AppText.$18Bold(
              recipe.items
                  .fold(
                    0.0,
                    (a, b) => a += (b.amount * (b.ingredient.unitPrice ?? 0.0)),
                  )
                  .priceUZS,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [

              ],
            ),
          ),
        ),
      ],
    );
  }
}
