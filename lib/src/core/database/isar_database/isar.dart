import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:isar/isar.dart';

class IsarDatabase {
  static final IsarDatabase instance = IsarDatabase._internal();

  factory IsarDatabase() => instance;

  IsarDatabase._internal();

  late Isar isar;

  Future<Isar> init(String dir) async {
    isar = await Isar.open(
      [OrderIsarSchema],
      inspector: true,
      directory: dir,
    );

    OrderDatabase orderDatabase = OrderDatabase();
    await orderDatabase.migrateFromHiveDatabase();

    return isar;
  }
}
