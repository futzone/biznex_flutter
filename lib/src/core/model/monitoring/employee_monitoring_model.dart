import 'package:biznex/src/core/model/employee_models/employee_model.dart';

class EM {
  Employee employee;
  double totalSumm;
  int ordersCount;
  double percentSumm;

  EM({
    required this.employee,
    required this.ordersCount,
    required this.percentSumm,
    required this.totalSumm,
  });
}
