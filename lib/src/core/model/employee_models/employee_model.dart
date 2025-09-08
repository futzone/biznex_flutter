import '../order_models/order.dart';

class Employee {
  String id;
  String fullname;
  String createdDate;
  String? phone;
  String? description;
  String roleId;
  String roleName;
  String pincode;

  Employee({
    this.pincode = '',
    this.id = '',
    this.phone,
    this.description,
    this.createdDate = '',
    required this.fullname,
    required this.roleId,
    required this.roleName,
  });

  factory Employee.fromIsar(EmployeeIsar isar) {
    return Employee(
      id: isar.id,
      fullname: isar.fullname,
      createdDate: isar.createdDate,
      phone: isar.phone,
      description: isar.description,
      roleId: isar.roleId,
      roleName: isar.roleName,
      pincode: isar.pincode,
    );
  }

  factory Employee.fromJson(json) {
    return Employee(
      fullname: json['fullname'],
      createdDate: json['createdDate'],
      description: json['description'],
      phone: json['phone'],
      id: json['id'],
      roleId: json['roleId'],
      roleName: json['roleName'],
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "createdDate": createdDate,
        "description": description,
        "phone": phone,
        "id": id,
        "roleName": roleName,
        "roleId": roleId,
        "pincode": pincode,
      };
}

class CloudEmployee {
  String id;
  String clientId;
  String name;
  String password;
  String createdAt;
  String updatedAt;
  String roleName;

  CloudEmployee({
    this.id = '',
    this.clientId = '',
    this.name = '',
    this.password = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.roleName = '',
  });

  factory CloudEmployee.fromJson(Map<String, dynamic> json) {
    return CloudEmployee(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      roleName: json['role_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'name': name,
      'password': password,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role_name': roleName,
    };
  }
}
