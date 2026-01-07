import 'package:isar/isar.dart';
import '../../model/order_models/order.dart';
part 'audit_log.g.dart';

@collection
class AuditLogIsar {
  Id id = Isar.autoIncrement;
  DateTime? createdDate;
  EmployeeIsar? employee;
  String? logType;
  String? actionType;

  String? itemId;
  String? oldValue;
  String? newValue;
}
