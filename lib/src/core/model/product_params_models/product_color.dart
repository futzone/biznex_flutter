class ProductColor {
  String id;
  String name;
  String? code;

  ProductColor({this.id = '', required this.name, this.code});

  factory ProductColor.fromJson(json) {
    return ProductColor(name: json['name'], id: json['id'] ?? '', code: json['code']);
  }

  Map<String, dynamic> toJson() => {"id": id, "code": code, "name": name};
}
