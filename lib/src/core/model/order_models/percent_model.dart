class Percent {
  String id;
  String name;
  double percent;

  Percent({this.id = '', required this.name, required this.percent});

  factory Percent.fromJson(json) {
    return Percent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      percent: json['percent']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'percent': percent};
  }
}
