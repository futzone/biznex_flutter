import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/order_controller.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';

final ordersProvider = FutureProvider.family((ref, String placeId) async {
  return await OrderController.getCurrentOrder(placeId);
});
