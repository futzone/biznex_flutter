class ProductSize {
  String id;
  String name;
  String? description;

  ProductSize({required this.name, this.id = '', this.description});

  factory ProductSize.fromJson(Map<dynamic, dynamic> json) {
    return ProductSize(
      id: json['id'] ?? '',
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
