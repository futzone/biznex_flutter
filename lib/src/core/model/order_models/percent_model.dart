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

  Percent copyWith({
    String? id,
    String? name,
    double? percent,
    String? updatedDate,
  }) {
    return Percent(
      id: id ?? this.id,
      name: name ?? this.name,
      percent: percent ?? this.percent,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

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
