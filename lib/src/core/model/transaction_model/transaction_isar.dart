import 'package:isar/isar.dart';

import '../order_models/order.dart';

part 'transaction_isar.g.dart';

@collection
class TransactionIsar {
  Id isarId = Isar.autoIncrement;

  static const String cash = 'cash';
  static const String card = 'card';
  static const String debt = 'debt';
  static const String other = 'other';
  static const String click = 'click';
  static const String payme = 'payme';

  static final List<String> values = [cash, card, debt, other, click, payme];

  late String id;
  late String createdDate;
  late String paymentType;
  late String note;
  late double value;
  EmployeeIsar? employee;
  String? orderId;
  List<PercentIsar> paymentTypes = [];
}

