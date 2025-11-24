import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_db_repository.dart';

class AppImageProvider extends OrderDatabaseRepository {}

final appImageProvider = FutureProvider.family((Ref ref, String id) async {
  final AppImageProvider imageProvider = AppImageProvider();
  if ((await imageProvider.connectionStatus()) == null) return null;
  final baseUrl = imageProvider.baseUrl;
  return "http://$baseUrl:8080/api/v2/image/$id";
});
