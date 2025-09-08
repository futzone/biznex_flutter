import 'package:biznex/src/core/extensions/for_dynamic.dart';

class Change {
  String id;
  String database;
  String method;
  String itemId;
  String data;
  String createdDate;

  Change({
    this.id = '',
    required this.database,
    required this.method,
    required this.itemId,
    this.data = '',
    this.createdDate = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'database': database,
      'method': method,
      'itemId': itemId,
      'data': data,
      'createdDate': createdDate.isEmpty ? DateTime.now().toIso8601String() : createdDate,
    };
  }

  factory Change.fromJson(json) {
    return Change(
      id: json['id'],
      database: json['database'],
      method: json['method'],
      itemId: json['itemId'],
      data: json['data'],
      createdDate: json['createdDate'].toString().notNullOrEmpty(DateTime.now().toIso8601String()),
    );
  }
}
