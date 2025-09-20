import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import '../../../core/model/product_models/shopping_model.dart';
import '../../../core/utils/date_utils.dart';
import 'ingredient_daily_stats.dart';
import 'ingredient_food_screen.dart';

class IngredientChartsScreen extends ConsumerWidget {
  final Ingredient ingredient;
  final List<IngredientTransaction> transactions;

  const IngredientChartsScreen({
    super.key,
    required this.ingredient,
    required this.transactions,
  });

  List<ChartData> _buildMealsList() {
    final List<ChartData> mealsDataList = [];
    final dataMap = {};
    for (final item in transactions) {
      if (dataMap[item.product.id] == null) {
        dataMap[item.product.id] = {
          'product': item,
          'amount': item.amount,
        };
      } else {
        dataMap[item.product.id]['amount'] += item.amount;
      }
    }

    for (final item in dataMap.values) {
      mealsDataList.add(
        ChartData(item['product'].product.name, item['amount']),
      );
    }

    return mealsDataList;
  }

  List<SalesData> _buildSalesData() {
    final List<SalesData> salesData = [];
    for (final date in AppDateUtils().last7Days()) {
      double amount = transactions.fold(0.0, (total, element) {
        final created = DateTime.parse(element.createdDate);
        if (created.year == date.year &&
            date.month == created.month &&
            date.day == created.day) {
          return total + element.amount;
        }

        return total;
      });

      salesData.add(SalesData(date, amount));
    }

    return salesData;
  }

  List<SalesData> _buildShoppingData(List<Shopping> shoppingData) {
    final List<SalesData> salesData = [];
    for (final date in AppDateUtils().last7Days()) {
      final amount = shoppingData.fold(0.0, (total, element) {
        final created = element.createdDate;
        if (created.year == date.year &&
            date.month == created.month &&
            date.day == created.day) {
          return total += element.getTotalAmount(ingredient.id);
        }

        return total;
      });

      salesData.add(SalesData(date, amount));
    }

    return salesData;
  }

  @override
  Widget build(BuildContext context, ref) {
    final shoppingData = ref.watch(shoppingProvider).value ?? [];
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          spacing: 24,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: IngredientFoodScreen(
                chartData: _buildMealsList(),
                ingredient: ingredient,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: IngredientDailyStats(
                ingredient: ingredient,
                salesData: _buildSalesData(),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: IngredientDailyStats(
                ingredient: ingredient,
                shopping: true,
                salesData: _buildShoppingData(shoppingData),
              ),
            )
          ],
        ),
      );
    });
  }
}
