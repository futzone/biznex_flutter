import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';
import 'package:isar/isar.dart';
import '../../model/order_models/order.dart';

part 'audit_log.g.dart';

@collection
class AuditLogIsar {
  Id id = Isar.autoIncrement;
  late DateTime createdDate;
  late EmployeeIsar employee;
  late String logType;
  late String actionType;

  String? itemId;
  String? oldValue;
  String? newValue;
}
