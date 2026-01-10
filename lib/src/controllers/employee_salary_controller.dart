import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:isar/isar.dart';

class EmployeeSalary {
  final double totalOrders;
  final double totalSumm;
  final double totalOutcome;
  final double totalIncome;

  EmployeeSalary({
    required this.totalSumm,
    required this.totalOrders,
    required this.totalIncome,
    required this.totalOutcome,
  });
}

class EmployeeSalaryController {
  static final Isar _isar = IsarDatabase.instance.isar;

  Future<EmployeeSalary> calculate(id, {DateTime? start, DateTime? end}) async {
    start ??= DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    end ??= DateTime.now();

    final ordersList = await _isar.orderIsars
        .where()
        .filter()
        .createdDateGreaterThan(start.toIso8601String())
        .createdDateLessThan(end.toIso8601String())
        .employee((e) => e.idEqualTo(id))
        .findAll();



    return EmployeeSalary(
      totalSumm: 0,
      totalOrders: 0,
      totalIncome: 0,
      totalOutcome: 0,
    );
  }
}
