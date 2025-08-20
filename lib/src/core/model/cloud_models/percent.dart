class CloudPercent {
  String id;
  String clientId;
  String name;
  String createdAt;
  String updatedAt;
  num percent;

  CloudPercent({
    this.id = '',
    this.clientId = '',
    this.name = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.percent = 0,
  });

  factory CloudPercent.fromJson(Map<String, dynamic> json) {
    return CloudPercent(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      percent: json['percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'percent': percent,
    };
  }
}
