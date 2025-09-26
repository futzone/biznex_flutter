class Percent {
  String id;
  String name;
  double percent;

  String updatedDate;

  Percent({
    this.id = '',
    required this.name,
    required this.percent,
    this.updatedDate = '',
  });

  factory Percent.fromJson(json) {
    return Percent(
      id: json['id'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
      name: json['name'] ?? '',
      percent: json['percent']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percent': percent,
      'updatedDate': updatedDate,
    };
  }
}
