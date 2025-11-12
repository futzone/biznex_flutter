import 'package:biznex/src/core/model/order_models/percent_model.dart';

Map<String, double> calculateRangeStatsIsolate(Map<String, dynamic> args) {
  final List ordersJson = args['orders'];
  final List percentItems = args['percentItems'];

  double ordersSumm = 0.0;
  double totalSumm = 0.0;
  double percentsSumm = 0.0;
  double placePrice = 0.0;

  final percent = percentItems.fold<double>(0.0, (sum, item) {
    if (item is Map) return sum + (item['percent'] ?? 0);
    if (item is Percent) return sum + item.percent;
    return sum;
  });

  for (final order in ordersJson) {
    final productOldPrice = order.products.fold(0.0, (val, product) {
      final kPrice = (product.amount *
          (product.product.price *
              (1 - (100 / (100 + product.product.percent)))));
      return val + kPrice;
    });

    ordersSumm += order.price;
    totalSumm += productOldPrice;

    if (!order.place.percentNull) {
      percentsSumm += (order.price * (1 - (100 / (100 + percent))));
    }

    if (order.place.price != null) {
      placePrice += order.place.price!;
    }
  }

  return {
    'ordersSumm': ordersSumm,
    'totalSumm': totalSumm,
    'percentsSumm': percentsSumm,
    'placePrice': placePrice,
  };
}
