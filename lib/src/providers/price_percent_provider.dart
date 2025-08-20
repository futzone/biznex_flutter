import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';

final orderPercentProvider = FutureProvider((ref) async {
  final OrderPercentDatabase database = OrderPercentDatabase();

  return await database.get();
});
