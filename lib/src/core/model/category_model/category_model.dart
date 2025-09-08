import 'dart:convert';

import '../order_models/order.dart';

class Category {
  String name;
  String id;
  String? parentId;
  Map<dynamic, dynamic>? printerParams;
  List<Category>? subcategories;
  String? icon;

  Category({required this.name, this.id = '', this.parentId, this.subcategories, this.printerParams, this.icon});

  factory Category.fromJson(json) {
    return Category(
      name: json['name'],
      parentId: json['parentId'],
      id: json['id'] ?? '',
      printerParams: json['printerParams'] ?? {},
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "parentId": parentId,
        "printerParams": printerParams,
        "icon": icon,
      };

  factory Category.fromIsar(CategoryIsar isar) {
    return Category(
      name: isar.name,
      id: isar.id,
      parentId: isar.parentId,
      printerParams: jsonDecode(isar.printerParams ?? '{}'),
      subcategories: isar.subcategories?.map((e) => Category.fromIsar(e)).toList(),
      icon: isar.icon,
    );
  }
}
