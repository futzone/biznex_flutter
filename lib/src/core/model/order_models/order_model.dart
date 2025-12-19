import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';

// import 'package:biznex/src/core/model/order_models/percent_model.dart'; // Not used in Order class
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';

import 'order.dart';

// Assuming OrderItem is defined elsewhere, e.g.:
// import 'package:biznex/src/core/model/order_models/order_item_model.dart';

class Order {
  static const String completed = "completed";
  static const String cancelled = "cancelled";
  static const String opened = "opened";
  static const String confirmed = "confirmed";
  String id;
  int? isarId;
  String createdDate;
  String updatedDate;
  String? scheduledDate;
  Customer? customer;
  Employee employee;
  String? status;
  double? realPrice;
  double price;
  String? note;
  Place place;
  String? orderNumber;
  List<OrderItem> products;
  List<Percent> paymentTypes;

  Order({
    this.note,
    required this.place,
    this.id = '',
    this.createdDate = '',
    this.updatedDate = '',
    this.customer,
    required this.employee,
    this.status = 'opened',
    this.realPrice,
    this.scheduledDate,
    required this.price,
    required this.products,
    this.orderNumber,
    this.isarId,
    required this.paymentTypes,
  });

  factory Order.fromIsar(OrderIsar isar) {
    return Order(
      isarId: isar.isarId,
      paymentTypes: isar.paymentTypes
          .map((el) => Percent(name: el.name, percent: el.amount))
          .toList(),
      id: isar.id ?? '',
      createdDate: isar.createdDate ?? '',
      updatedDate: isar.updatedDate ?? '',
      scheduledDate: isar.scheduledDate,
      customer:
          isar.customer != null ? Customer.fromIsar(isar.customer!) : null,
      employee: Employee.fromIsar(isar.employee),
      status: isar.status,
      realPrice: isar.realPrice,
      price: isar.price,
      note: isar.note,
      place: Place.fromIsar(isar.place),
      orderNumber: isar.orderNumber,
      products: isar.products.map((p) => OrderItem.fromIsar(p)).toList(),
    );
  }

  factory Order.fromJson(json) {
    return Order(
      paymentTypes: ((json['paymentTypes'] ?? []) as List)
          .map((el) => Percent.fromJson(el))
          .toList(),
      id: json['id'] ?? '',
      createdDate: json['createdDate'] ?? '',
      isarId: json['isarId'],
      updatedDate: json['updatedDate'] ?? '',
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      employee: Employee.fromJson(json['employee']),
      status: json['status'],
      realPrice: json['realPrice'] != null
          ? (json['realPrice'] as num).toDouble()
          : null,
      price: (json['price'] as num).toDouble(),
      products: (json['products'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      place: Place.fromJson(json['place']),
      note: json['note'],
      scheduledDate: json['scheduledDate'],
      orderNumber:
          json['orderNumber'] ?? '${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isarId': isarId,
      'place': place.toJson(),
      'id': id,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
      'customer': customer?.toJson(),
      'employee': employee.toJson(),
      'status': status,
      'realPrice': realPrice,
      'price': price,
      'note': note,
      'scheduledDate': scheduledDate,
      'products': products.map((e) => e.toJson()).toList(),
      'paymentTypes': paymentTypes.map((e) => e.toJson()).toList(),
      'orderNumber': orderNumber,
    };
  }

  Order copyWith({
    String? id,
    String? createdDate,
    String? updatedDate,
    String? scheduledDate,
    Customer? customer,
    Employee? employee,
    String? status,
    double? realPrice,
    double? price,
    String? note,
    Place? place,
    String? orderNumber,
    List<OrderItem>? products,
    bool? setCustomerToNull,
    bool?
        setScheduledDateToNull, // Helper to explicitly set scheduledDate to null
    bool? setNoteToNull, // Helper to explicitly set note to null
    bool? setRealPriceToNull, // Helper to explicitly set realPrice to null
    bool? setOrderNumberToNull, // Helper to explicitly set orderNumber to null
    List<Percent>? paymentTypes, // Helper to explicitly set orderNumber to null
  }) {
    return Order(
      paymentTypes: paymentTypes ?? this.paymentTypes,
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      scheduledDate: setScheduledDateToNull == true
          ? null
          : scheduledDate ?? this.scheduledDate,
      customer: setCustomerToNull == true ? null : customer ?? this.customer,
      employee: employee ?? this.employee,
      status: status ?? this.status,
      realPrice:
          setRealPriceToNull == true ? null : realPrice ?? this.realPrice,
      price: price ?? this.price,
      note: setNoteToNull == true ? null : note ?? this.note,
      place: place ?? this.place,
      orderNumber:
          setOrderNumberToNull == true ? null : orderNumber ?? this.orderNumber,
      products: products ?? this.products,
      isarId: this.isarId,
    );
  }
}
