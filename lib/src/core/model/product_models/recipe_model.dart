import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';

class Recipe {
  final String id;
  final DateTime createdDate;
  DateTime? updatedDate;
  final Product product;
    List<RecipeItem> items;

  Recipe({
    id,
    required this.items,
    required this.product,
    this.updatedDate,
    DateTime? createdDate,
    // DateTime? updatedDate,
  })  : id = product.id,

        createdDate = DateTime.now();

  factory Recipe.fromJson(map) {
    return Recipe(
      items: [for (final item in map['items']) RecipeItem.fromMap(item)],
      product: Product.fromJson(map['product']),
      createdDate: DateTime.parse(map['createdDate'] as String),
      updatedDate: DateTime.parse(map['updatedDate'] as String),
      id: map['id'] as String,
    );
  }

  toJson() => {
        'id': id,
        'items': [for (final item in items) item.toJson()],
        'product': product.toJson(),
        'createdDate': createdDate.toIso8601String(),
        'updatedDate': updatedDate?.toIso8601String(),
      };
}
