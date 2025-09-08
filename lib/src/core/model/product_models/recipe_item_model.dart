import 'ingredient_model.dart';

class RecipeItem {
  Ingredient ingredient;
  double amount;
  double? price;

  RecipeItem({required this.ingredient, required this.amount, this.price});

  factory RecipeItem.fromMap(map) {
    return RecipeItem(
      ingredient: Ingredient.fromMap(map['ingredient']),
      amount: map['amount'],
      price: map['price'],
    );
  }

  toJson() => {
    "amount": amount,
    "ingredient": ingredient.toMap(),
    'price': price,
  };
}
