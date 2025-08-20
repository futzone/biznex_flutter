class CloudMonitoring {
  String id;
  String clientId;
  Map<String, CloudMonitoringItem> data;
  String createdAt;
  String updatedAt;
  bool isProduct;

  CloudMonitoring({
    required this.updatedAt,
    required this.clientId,
    required this.createdAt,
    required this.data,
    required this.id,
    this.isProduct = true,
  });

  factory CloudMonitoring.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as Map<String, dynamic>? ?? {};
    final parsedData = rawData.map((key, value) => MapEntry(key, CloudMonitoringItem.fromJson(value)));

    return CloudMonitoring(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      data: parsedData,
      isProduct: json['is_product'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'data': data.map((key, value) => MapEntry(key, value.toJson())),
      'is_product': isProduct,
    };
  }
}

class CloudMonitoringItem {
  String day;
  int orders;
  double total;
  double? amount;

  CloudMonitoringItem({
    required this.day,
    this.amount,
    required this.orders,
    required this.total,
  });

  factory CloudMonitoringItem.fromJson(Map<String, dynamic> json) {
    return CloudMonitoringItem(
      day: json['day'] ?? '',
      orders: json['orders'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'orders': orders,
      'total': total,
      if (amount != null) 'amount': amount,
    };
  }
}
