import '../order_models/order.dart';

class Customer {
  String name;
  String phone;
  String id;
  String? address;
  DateTime? updated;
  final DateTime? created;
  String? note;

  Customer({
    this.id = '',
    required this.name,
    required this.phone,
    this.updated,
    this.created,
    this.address,
    this.note,
  });

  factory Customer.fromJson(json) {
    return Customer(
      note: json['note'],
      address: json['address'],
      created: DateTime.tryParse(json['created'] ?? ''),
      updated: DateTime.tryParse(json['updated'] ?? ''),
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'note': note,
      'address': address,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  factory Customer.fromIsar(CustomerIsar isar) {
    return Customer(
      id: isar.id,
      name: isar.name,
      phone: isar.phone,
      created: isar.created,
      updated: isar.updated,
      note: isar.note,
      address: isar.address,
    );
  }
}
