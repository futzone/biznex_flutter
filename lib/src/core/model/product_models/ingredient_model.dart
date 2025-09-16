import 'package:uuid/uuid.dart';

class Ingredient {
  final String id;
  String name;
  String? image;
  double quantity;
  double? calory;
  double? unitPrice;
  final DateTime createdAt;
  DateTime updatedAt;
  String? measure;

  Ingredient({
    required this.id,
    this.image,
    this.calory,
    required this.name,
    required this.quantity,
    this.unitPrice,
    required this.createdAt,
    required this.updatedAt,
    this.measure,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'calory': calory,
      'measure': measure,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Ingredient.fromMap(map) {
    return Ingredient(
      id: map['id'] as String,
      calory: map['calory'],
      measure: map['measure'],
      image: map['image'] as String?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: map['unitPrice'],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
