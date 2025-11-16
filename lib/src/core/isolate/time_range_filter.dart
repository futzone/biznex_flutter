import '../model/order_models/percent_model.dart';

Map<String, double> calculateRangeStatsIsolate(Map args) {
  final List orders = args['orders'];
  final List percentItems = args['percentItems'];

  double ordersSumm = args['ordersSumm'] ?? 0.0;
  double totalSumm = args['totalSumm'] ?? 0.0;
  double percentsSumm = args['percentsSumm'] ?? 0.0;
  double placePrice = args['placePrice'] ?? 0.0;

  final percent = percentItems.fold<double>(0.0, (sum, item) {
    if (item is Map) return sum + (item['percent'] ?? 0);
    if (item is Percent) return sum + item.percent;
    return sum;
  });

  for (final order in orders) {
    final productOldPrice = order.products.fold(0.0, (val, product) {
      final kPrice = product.amount *
          (product.product.price *
              (1 - (100 / (100 + product.product.percent))));
      return val + kPrice;
    });

    ordersSumm += order.price;
    totalSumm += productOldPrice;

    if (!order.place.percentNull) {
      percentsSumm += order.price * (1 - (100 / (100 + percent)));
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
