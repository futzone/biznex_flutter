import 'package:biznex/src/core/model/product_models/product_model.dart';

import 'order.dart';

class OrderItem {
  Product product;
  double amount;
  String placeId;

  OrderItem({
    required this.product,
    required this.amount,
    required this.placeId,
  });

  factory OrderItem.fromIsar(OrderItemIsar isar) {
    return OrderItem(
      product: Product.fromIsar(isar.product ?? ProductIsar()),
      amount: isar.amount,
      placeId: isar.placeId,
    );
  }

  OrderItem copyWith({
    Product? product,
    double? amount,
    String? placeId,
  }) {
    return OrderItem(
      product: product ?? this.product,
      amount: amount ?? this.amount,
      placeId: placeId ?? this.placeId,
    );
  }

  factory OrderItem.fromJson(json) {
    return OrderItem(
      product: Product.fromJson(json['product']),
      amount: (json['amount'] as num).toDouble(),
      placeId: (json['placeId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'product': product.toJson(),
      'amount': amount,
    };
  }
}

class OrderItemModel {
  double amount;
  String productId;

  OrderItemModel({
    required this.amount,
    required this.productId,
  });

  factory OrderItemModel.fromJson(json) {
    return OrderItemModel(
      amount: (json['amount'] as num).toDouble(),
      productId: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'productId': productId};
  }
}

class OrderModel {
  String? note;
  String? id;
  String placeId;
  String? placeFatherId;
  String? customerName;
  String? customerPhone;
  String? scheduledDate;
  List<OrderItemModel> items;

  OrderModel({
    this.note,
    this.id,
    required this.placeId,
    this.customerName,
    this.placeFatherId,
    this.customerPhone,
    this.scheduledDate,
    required this.items,
  });

  factory OrderModel.fromJson(json) {
    return OrderModel(
      note: json['note'],
      id: json['id'],
      placeId: json['placeId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      scheduledDate: json['scheduledDate'],
      placeFatherId: json['placeFatherId'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'id': id,
      'placeFatherId': placeFatherId,
      'placeId': placeId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'scheduledDate': scheduledDate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  static var requestBodyTemplate = {
    "note": "Buyurtma tug'ilgan kun uchun",
    "id": "order_123",
    "placeId": "place_456",
    "placeFatherId": "place_father_456",
    "customerName": "Sardor Abdullayev",
    "customerPhone": "+998901234567",
    "scheduledDate": "2025-04-20T15:30:00",
    "items": [
      {"amount": 2.5, "productId": "product_789"},
      {"amount": 1.0, "productId": "product_321"}
    ]
  };
}
