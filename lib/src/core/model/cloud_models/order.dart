import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';

class CloudOrderItem {
  String productId;
  num amount;

  CloudOrderItem({
    this.productId = '',
    this.amount = 0,
  });

  factory CloudOrderItem.fromJson(Map<String, dynamic> json) {
    return CloudOrderItem(
      productId: json['product_id'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'amount': amount,
    };
  }
}

class CloudOrderPercent {
  String name;
  num percent;

  CloudOrderPercent({
    this.name = '',
    this.percent = 0,
  });

  factory CloudOrderPercent.fromJson(Map<String, dynamic> json) {
    return CloudOrderPercent(
      name: json['name'] ?? '',
      percent: json['percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percent': percent,
    };
  }
}

class CloudOrder {
  String id;
  String clientId;
  List<CloudOrderItem> items;
  List<CloudOrderPercent> percents;
  String paymentType;
  String employeeId;
  String createdAt;
  String updatedAt;
  String note;
  String customer;
  String place;
  String status;
  num price;
  CloudEmployee? employee;
  List<CloudProduct> products;

  CloudOrder({
    this.id = '',
    this.clientId = '',
    this.items = const [],
    this.percents = const [],
    this.paymentType = '',
    this.employeeId = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.note = '',
    this.customer = '',
    this.place = '',
    this.status = '',
    this.price = 0,
    this.employee,
    this.products = const [],
  });

  factory CloudOrder.fromJson(Map<String, dynamic> json) {
    return CloudOrder(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      items: [],
      percents: (json['percents'] as List<dynamic>?)?.map((p) => CloudOrderPercent.fromJson(p)).toList() ?? [],
      paymentType: json['payment_type'] ?? '',
      employeeId: json['employee_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      note: json['note'] ?? '',
      customer: json['customer'] ?? '',
      place: json['place'] ?? '',
      status: json['status'] ?? '',
      price: json['price'] ?? 0,
      products: (json['items'] as List<dynamic>?)?.map((e) => CloudProduct.fromJson(e)).toList() ?? [],
      employee: json['employee'] != null ? CloudEmployee.fromJson(json['employee']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'items': items.map((item) => item.toJson()).toList(),
      'percents': percents.map((p) => p.toJson()).toList(),
      'payment_type': paymentType,
      'employee_id': employeeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'note': note,
      'customer': customer,
      'place': place,
      'status': status,
      'price': price,
    };
  }
}
