import 'dart:convert';
import 'dart:developer';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';

class EmployeeDatabase extends AppDatabase {
  final String boxName = 'employees';

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);

    final employee = await getOne(key);
    if (employee == null) return;

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'delete',
        itemId: key,
        data: "${employee.fullname} (${employee.roleName})",
      ),
    );
    await box.delete(key);
  }

  @override
  Future<List<Employee>> get() async {
    final List<Employee> productInfoList = [];

    if ((await connectionStatus()) != null) {
      final response = await getRemote(boxName: boxName);
      if (response != null) {
        for (final item in jsonDecode(response)) {
          productInfoList.add(Employee.fromJson(item));
        }
      }

      return productInfoList;
    }

    final box = await openBox(boxName);
    final boxData = box.values;

    for (final item in boxData) {
      productInfoList.add(Employee.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Employee) return;

    Employee productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'create',
        itemId: productInfo.id,
      ),
    );
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Employee) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'update',
        itemId: key,
      ),
    );
  }

  Future<Employee?> getEmployee(String pincode) async {
    final box = await openBox(boxName);
    final boxData = box.values;
    Employee? employee;
    for (final item in boxData) {
      if (item['pincode'] == pincode) {
        employee = Employee.fromJson(item);
        break;
      }
    }

    return employee;
  }

  Future<Employee?> getOne(String key) async {
    final box = await openBox(boxName);
    final boxData = await box.get(key);
    if (boxData == null) return null;
    return Employee.fromJson(boxData);
  }

  Future<void> clear() async {
    final box = await openBox(boxName);
    await box.clear();
  }
}
