import 'dart:developer';

import 'package:biznex/src/core/database/employee_database/role_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';

Future<bool> isCashier(Employee emp) async {
  if (emp.roleName.toLowerCase() == 'kassir') return true;

  final RoleDatabase roleDatabase = RoleDatabase();
  final role = await roleDatabase.getRole(emp.roleId);

  if (role == null) return false;
  return role.permissions.any((e) => e.toString().toLowerCase() == 'cashier');
}

bool isCashierSync(Employee emp) {
   if (emp.roleName.toLowerCase() == 'kassir' ||
      emp.roleName.toLowerCase() == 'кассир' ||
      emp.roleName.toLowerCase() == 'cashier') {
    return true;
  }
  return false;
}
