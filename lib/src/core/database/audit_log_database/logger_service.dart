import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_extension.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../model/employee_models/employee_model.dart';
import 'audit_log.dart';

enum LogType {
  order,
  product,
  employee,
  app,
  transaction,
  place,
  percent,
  recipe,
  ingredient,
  printer,
  other;
}

enum ActionType {
  enter,
  delete,
  create,
  update,
  view,
  close,
  fail,
  open;
}

Color getActionColor(String action) {
  if (action == ActionType.enter.name || action == ActionType.view.name) {
    return Colors.blue;
  }

  if (action == ActionType.create.name || action == ActionType.open.name) {
    return Colors.green;
  }

  if (action == ActionType.update.name || action == ActionType.close.name) {
    return Colors.orange;
  }

  if (action == ActionType.delete.name) return Colors.red;

  if (action == ActionType.fail.name) return Colors.black;

  return Colors.black12;
}

class LoggerService {
  static final Isar _isar = IsarDatabase.instance.isar;
  static final EmployeeDatabase _employeeDatabase = EmployeeDatabase();

  static Future<List<AuditLogIsar>> getLogs({
    int page = 0,
    int limit = 20,
    String? logType,
    DateTime? date,
    String? employeeId,
    String? actionType,
  }) async {
    // Using explicit dynamic type to bypass QueryBuilder type issues for now during debug
    var query = _isar.auditLogIsars.where().filter().idGreaterThan(-1);

    if (logType != null && logType.isNotEmpty) {
      query = query.logTypeEqualTo(logType);
    }

    if (actionType != null && actionType.isNotEmpty) {
      query = query.actionTypeEqualTo(actionType);
    }

    // Checking if employee filter is causing the crash
    /*
    if (employeeId != null && employeeId.isNotEmpty) {
       query = query.employee((q) => q.idEqualTo(employeeId));
    }
    */

    // Checking if date filter is causing the crash
    /*
    if (date != null) {
      final start = date.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      final end = date.copyWith(
          hour: 23,
          minute: 59,
          second: 59,
          millisecond: 999,
          microsecond: 999);
      query = query.createdDateBetween(start, end);
    }
    */

    return await query
        .sortByCreatedDateDesc()
        .offset(page * limit)
        .limit(limit)
        .findAll();
  }

  static Future<void> save({
    required LogType logType,
    required ActionType actionType,
    String? itemId,
    String? oldValue,
    String? newValue,
  }) async {
    final String employeeId = await EmployeeDatabase.getCurrent();
    Employee? employee = await _employeeDatabase.getOne(employeeId);
    employee ??= Employee(fullname: 'Admin', roleId: '-1', roleName: 'admin');

    AuditLogIsar auditLog = AuditLogIsar()
      ..employee = employee.toIsar()
      ..createdDate = DateTime.now()
      ..actionType = actionType.name
      ..logType = logType.name
      ..itemId = itemId
      ..oldValue = oldValue
      ..newValue = newValue;

    _isar.writeTxn(() async {
      await _isar.auditLogIsars.put(auditLog);
    });
  }
}
