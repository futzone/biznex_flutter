import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:isar/isar.dart';

final FutureProvider<List<Customer>> customerProvider =
    FutureProvider((ref) async {
  CustomerDatabase customerDatabase = CustomerDatabase();
  return await customerDatabase.get();
});

final customerOrdersProvider = FutureProvider.family((ref, String id) async {
  final Isar isar = IsarDatabase.instance.isar;
  final ordersData = await isar.orderIsars
      .filter()
      .customer((c) => c.idEqualTo(id))
      .sortByCreatedDateDesc()
      .findAll();

  return ordersData;
});

final customerDebtProvider = FutureProvider.family((ref, String id) async {
  final Isar isar = IsarDatabase.instance.isar;
  final ordersData = await isar.orderIsars
      .filter()
      .customer((c) => c.idEqualTo(id))
      .paymentTypesElement((pt) => pt.nameEqualTo('debt'))
      .sortByCreatedDateDesc()
      .findAll();

  return ordersData;
});
