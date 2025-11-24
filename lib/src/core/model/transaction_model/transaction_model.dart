import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_isar.dart';
import 'package:isar/isar.dart';

class Transaction {
  static const String cash = 'cash';
  static const String card = 'card';
  static const String debt = 'debt';
  static const String other = 'other';
  static const String oson = 'oson';
  static const String uzum = 'uzum';
  static const String click = 'click';
  static const String payme = 'payme';
  static const String yandex = 'yandex';
  static const String wolt = 'wolt';

  static final List<String> values = [
    cash,
    card,
    debt,
    click,
    payme,
    oson,
    uzum,
    yandex,
    wolt,
    other,
  ];

  String id;
  String createdDate;
  String paymentType;
  String note;
  double value;
  Employee? employee;
  Order? order;
  List<Percent>? paymentTypes;

  Transaction({
    this.id = '',
    required this.value,
    this.order,
    this.employee,
    this.createdDate = '',
    this.note = '',
    this.paymentType = Transaction.cash,
    this.paymentTypes,
  });

  factory Transaction.fromJson(json) {
    return Transaction(
      id: json['id'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      createdDate: (json['createdDate'] ?? '').toString().isEmpty
          ? DateTime.now().toIso8601String()
          : json['createdDate'],
      paymentType: json['paymentType'] ?? 'cash',
      note: json['note'] ?? '',
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      paymentTypes:
          json['paymentTypes']?.map((e) => Percent.fromJson(e)).toList(),
    );
  }

  factory Transaction.fromIsar(TransactionIsar isar) {
    OrderIsar? orderIsar = (isar.orderId == null
        ? null
        : IsarDatabase.instance.isar.orderIsars
            .filter()
            .idEqualTo(isar.orderId ?? '_')
            .findFirstSync());
    return Transaction(
        id: isar.id,
        value: isar.value,
        createdDate: isar.createdDate,
        paymentType: isar.paymentType,
        note: isar.note,
        employee: isar.employee != null
            ? Employee(
                fullname: isar.employee?.fullname ?? '',
                roleId: isar.employee?.roleId ?? '',
                roleName: isar.employee?.roleName ?? '',
                id: isar.employee?.id ?? '',
                createdDate: isar.employee?.createdDate ?? '',
              )
            : null,
        order: orderIsar == null ? null : Order.fromIsar(orderIsar),
        paymentTypes: [
          for (final item in isar.paymentTypes)
            Percent(name: item.name, percent: item.amount)
        ]);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'createdDate':
          createdDate.isEmpty ? DateTime.now().toIso8601String() : createdDate,
      'paymentType': paymentType,
      'note': note,
      'employee': employee?.toJson(),
      'order': order?.toJson(),
      'paymentTypes': [for (final item in (paymentTypes ?? [])) item.toJson()]
    };
  }
}

class CloudTransaction {
  String id;
  String clientId;
  String orderId;
  String employeeId;
  String note;
  String createdAt;
  String updatedAt;
  num amount;

  CloudTransaction({
    this.id = '',
    this.clientId = '',
    this.orderId = '',
    this.employeeId = '',
    this.note = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.amount = 0,
  });

  factory CloudTransaction.fromJson(Map<String, dynamic> json) {
    return CloudTransaction(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      orderId: json['order_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      note: json['note'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'order_id': orderId,
      'employee_id': employeeId,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'amount': amount,
    };
  }
}
