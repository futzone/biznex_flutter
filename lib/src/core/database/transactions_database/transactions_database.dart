import 'dart:developer';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_transaction.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_isar.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:isar/isar.dart';
import '../../cloud/local_changes_db.dart';

class TransactionsDatabase extends AppDatabase {
  final String _boxName = 'transactions';
  final String boxName = 'transactions';

  final Isar isar = IsarDatabase.instance.isar;

  Future<void> clear() async {
    final box = await openBox(_boxName);
    await box.clear();

    await isar.writeTxn(() async {
      await isar.transactionIsars.clear();
    });
  }

  Future<List<Transaction>> getDayTransactions(DateTime day) async {
    final List<Transaction> productInfoList = [];
    final orders = await isar.transactionIsars
        .filter()
        .createdDateStartsWith(day.toIso8601String().split('T').first)
        .sortByCreatedDateDesc()
        .findAll();
    for (final order in orders) {
      try {
        productInfoList.add(Transaction.fromIsar(order));
      } catch (error) {
        log("Error on Transaction <-> TransactionIsar:", error: error);
      }
    }

    log("${productInfoList.length} ta transactions");

    return productInfoList;
  }

  Future<void> migrateFromHive() async {
    final box = await Hive.openBox(boxName);
    if (box.isEmpty) return;

    final transactions = box.values
        .map((value) => Transaction.fromJson(value).toIsar())
        .toList();

    await isar.writeTxn(() async {
      await isar.transactionIsars.putAll(transactions);
    });

    await clear();

    log("transaction migrated to Isar");
  }

  @override
  Future delete({required String key}) async {
    final transaction = await getTransactionById(key);
    log("founded: $transaction");
    if (transaction == null) return;

    final old = await isar.transactionIsars.filter().idEqualTo(key).findFirst();
    if (old != null) {
      await LocalChanges.instance.saveChange(
        event: TransactionEvent.TRANSACTION_DELETED,
        entity: Entity.TRANSACTION,
        objectId: key,
      );

      await isar.writeTxn(() async {
        await isar.transactionIsars.delete(old.isarId);
      });
    }
  }

  @override
  Future<List<Transaction>> get() async {
    final List<Transaction> productInfoList = [];
    final DateTime now = DateTime.now();
    final orders = await isar.transactionIsars
        .filter()
        .createdDateStartsWith(now.toIso8601String().split('T').first)
        .sortByCreatedDateDesc()
        .findAll();
    for (final order in orders) {
      try {
        productInfoList.add(Transaction.fromIsar(order));
      } catch (_) {}
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Transaction) return;

    Transaction productInfo = data;

    productInfo.id = generateID;
    productInfo.createdDate = DateTime.now().toIso8601String();
    await isar.writeTxn(() async {
      await isar.transactionIsars.put(productInfo.toIsar());
    });

    await LocalChanges.instance.saveChange(
      event: TransactionEvent.TRANSACTION_CREATED,
      entity: Entity.TRANSACTION,
      objectId: productInfo.id,
    );
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Transaction) return;

    final old = await isar.transactionIsars.filter().idEqualTo(key).findFirst();
    if (old == null) return;
    TransactionIsar transactionIsar = data.toIsar();
    transactionIsar.isarId = old.isarId;

    await isar.writeTxn(() async {
      await isar.transactionIsars.put(transactionIsar);
    });

    await LocalChanges.instance.saveChange(
      event: TransactionEvent.TRANSACTION_UPDATED,
      entity: Entity.TRANSACTION,
      objectId: key,
    );
  }

  Future<Transaction?> getTransactionById(String id) async {
    final transaction =
        await isar.transactionIsars.filter().idEqualTo(id).findFirst();
    if (transaction == null) return null;
    return Transaction.fromIsar(transaction);
  }

  Future<Transaction?> getOrderTransaction(String orderId) async {
    final transaction = await isar.transactionIsars
        .filter()
        .orderIdEqualTo(orderId)
        .findFirst();
    if (transaction == null) return null;
    return Transaction.fromIsar(transaction);
  }
}
