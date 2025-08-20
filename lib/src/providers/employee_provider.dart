import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/employee_database/role_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';

final FutureProvider<List<Employee>> employeeProvider = FutureProvider<List<Employee>>((ref) async {
  EmployeeDatabase employeeDatabase = EmployeeDatabase();
  return await employeeDatabase.get();
});

final roleProvider = FutureProvider<List<Role>>((ref) async {
  RoleDatabase roleDatabase = RoleDatabase();
  return await roleDatabase.get();
});

final currentEmployeeProvider = StateProvider((ref) {
  final model = ref.watch(appStateProvider).value;
  return Employee(fullname: "Admin", roleId: "0", roleName: "Admin", pincode: model?.pincode ?? '0000');
});
