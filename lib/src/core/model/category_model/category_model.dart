import 'dart:convert';
import 'dart:developer';

import '../order_models/order.dart';

class Category {
  int index;
  String name;
  String id;
  String? parentId;
  Map<dynamic, dynamic>? printerParams;
  List<Category>? subcategories;
  String? icon;
  String updatedDate;

  Category({
    this.updatedDate = '',
    required this.name,
    this.id = '',
    this.parentId,
    this.subcategories,
    this.printerParams,
    this.icon,
    required this.index,
  });

  factory Category.fromJson(json) {
    return Category(
      name: json['name'],
      index: json['index'] ?? 9999,
      parentId: json['parentId'],
      id: json['id'] ?? '',
      printerParams: json['printerParams'] ?? {},
      icon: json['icon'],
      updatedDate: json['updatedDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "parentId": parentId,
        "printerParams": printerParams,
        "icon": icon,
        "updatedDate": updatedDate,
        "index": index,
      };

  factory Category.fromIsar(CategoryIsar isar) {
    return Category(
      name: isar.name,
      id: isar.id,
      parentId: isar.parentId,
      printerParams: jsonDecode(isar.printerParams ?? '{}'),
      subcategories:
          isar.subcategories?.map((e) => Category.fromIsar(e)).toList(),
      icon: isar.icon,
      index: isar.index ?? 9999,
    );
  }
}
