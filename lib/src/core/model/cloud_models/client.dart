import 'package:biznex/src/core/utils/password_utils.dart';

class Client {
  String id;
  String name;
  String password;
  String createdAt;
  String updatedAt;
  String expiredDate;

  Client({
    required this.id,
    required this.name,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    required this.expiredDate,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expiredDate: json['expired_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'expired_date': expiredDate,
    };
  }

  String get hiddenPassword {
    PasswordEncryptor encryptor = PasswordEncryptor();
    String encrypted = encryptor.encryptPassword(password);
    return encrypted;
  }
}
