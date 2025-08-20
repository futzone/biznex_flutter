class ProductMeasure {
  String id;
  String name;

  ProductMeasure({required this.name, this.id = ''});

  factory ProductMeasure.fromJson(Map<dynamic, dynamic> json) {
    return ProductMeasure(id: json['id'] ?? '', name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
