class CloudReportModel {
  String clientId;
  String createdAt;
  String updatedAt;
  Map<String, CloudReportItem> data;

  CloudReportModel({
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });

  factory CloudReportModel.fromJson(Map<String, dynamic> json) {
    return CloudReportModel(
      clientId: json['client_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      data: (json['data'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CloudReportItem.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'data': data.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class CloudReportItem {
  String day;
  double totalOrdersSumm;
  double totalProfit;
  double totalProfitPercents;
  double totalProfitProducts;
  int employeeCount;
  int orderCount;
  int productCount;
  int transactionCount;

  CloudReportItem({
    this.day = '',
    this.totalOrdersSumm = 0.0,
    this.totalProfit = 0.0,
    this.totalProfitPercents = 0.0,
    this.totalProfitProducts = 0.0,
    this.employeeCount = 0,
    this.orderCount = 0,
    this.productCount = 0,
    this.transactionCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'totalOrdersSumm': totalOrdersSumm,
      'totalProfit': totalProfit,
      'totalProfitPercents': totalProfitPercents,
      'totalProfitProducts': totalProfitProducts,
      'employeeCount': employeeCount,
      'orderCount': orderCount,
      'productCount': productCount,
      'transactionCount': transactionCount,
    };
  }

  factory CloudReportItem.fromJson(Map<String, dynamic> json) {
    return CloudReportItem(
      day: json['day'] ?? '',
      totalOrdersSumm: json['totalOrdersSumm']?.toDouble() ?? 0.0,
      totalProfit: json['totalProfit']?.toDouble() ?? 0.0,
      totalProfitPercents: json['totalProfitPercents']?.toDouble() ?? 0.0,
      totalProfitProducts: json['totalProfitProducts']?.toDouble() ?? 0.0,
      employeeCount: json['employeeCount']?.toInt() ?? 0,
      orderCount: json['orderCount']?.toInt() ?? 0,
      productCount: json['productCount']?.toInt() ?? 0,
      transactionCount: json['transactionCount']?.toInt() ?? 0,
    );
  }
}
