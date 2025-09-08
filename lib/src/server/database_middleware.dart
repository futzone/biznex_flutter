import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';

class DatabaseMiddleware {
  final String boxName;
  final String pincode;

  DatabaseMiddleware({required this.pincode, required this.boxName});

  Future<Employee?> employeeState() async {
    EmployeeDatabase employeeDatabase = EmployeeDatabase();
    final emp = await employeeDatabase.getEmployee(pincode);
    return emp;
  }

  Future<Box> openBox() async {
    final box = await Hive.openBox(boxName);
    return box;
  }
}
