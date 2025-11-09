import 'package:flutter/foundation.dart';

import '../../biznex.dart';
import '../core/database/transactions_database/transactions_database.dart';
import '../core/isolate/transaction_filter.dart';
import '../core/model/transaction_model/transaction_model.dart';

final transactionProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionsDatabase = TransactionsDatabase();
  final list = await transactionsDatabase.get();
  final sortedList = await compute(sortTransactions, list);

  return sortedList;
});
