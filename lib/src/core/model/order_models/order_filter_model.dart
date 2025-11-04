import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';

import '../../../../main.dart';

class OrderFilterModel {
  String? employee;
  DateTime? dateTime;
  String? status;
  String? product;
  String? place;
  String? query;
  int limit;
  int page;
  bool forAll;

  bool isActive() =>
      employee != null ||
      dateTime != null ||
      status != null ||
      product != null ||
      place != null ||
      query != null;

  OrderFilterModel({
    this.place,
    this.limit = appPageSize,
    this.page = 1,
    this.product,
    this.dateTime,
    this.employee,
    this.status,
    this.query,
    this.forAll = false,
  });
}
