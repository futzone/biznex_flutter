import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_extension.dart';
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
  open;
}

class LoggerService {
  static final Isar _isar = IsarDatabase.instance.isar;
  static final EmployeeDatabase _employeeDatabase = EmployeeDatabase();

  Future<List<AuditLogIsar>> getLogs({int page = 0, int limit = 20}) async {
    final queryData = await _isar.auditLogIsars
        .where()
        .sortByCreatedDateDesc()
        .offset(page * limit)
        .limit(limit)
        .findAll();

    return queryData;
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
