import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';

class TransactionsDatabase extends AppDatabase {
  final String boxName = 'transactions';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);

    final transaction = await getTransactionById(key);
    if (transaction == null) return;
    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'delete',
        itemId: transaction.id,
        data: transaction.value.priceUZS,
      ),
    );

    await box.delete(key);
  }

  @override
  Future<List<Transaction>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Transaction> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Transaction.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Transaction) return;

    Transaction productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'create',
        itemId: productInfo.id,
      ),
    );
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Transaction) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'update',
        itemId: key,
      ),
    );
  }

  Future<Transaction?> getTransactionById(String id) async {
    final box = await openBox(boxName);
    final data = box.get(id);
    if (data == null) return null;
    return Transaction.fromJson(data);
  }

  Future<Transaction?> getOrderTransaction(String orderId) async {
    final box = await openBox(boxName);
    final data = box.values.where((el) {
      return (el['order'] != null) && (el['order']['id'] == orderId);
    }).firstOrNull;
    if (data == null) return null;
    return Transaction.fromJson(data);
  }
}
