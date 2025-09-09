import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';

class Shopping {
  final String id;
  final DateTime createdDate;
  DateTime updatedDate;
  double totalPrice;
  List<RecipeItem> items;
  String? note;

  Shopping({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.updatedDate,
    required this.createdDate,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'totalPrice': totalPrice,
      'items': items.map((e) => e.toJson()).toList(),
      'note': note,
    };
  }

  factory Shopping.fromMap(map) {
    return Shopping(
      id: map['id'] as String,
      createdDate: DateTime.parse(map['createdDate'] as String),
      updatedDate: DateTime.parse(map['updatedDate'] as String),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      items: List<RecipeItem>.from(
        (map['items'] as List).map(
          (x) => RecipeItem.fromMap(x),
        ),
      ),
      note: map['note'] as String?,
    );
  }
}
