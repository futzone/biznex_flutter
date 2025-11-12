import 'package:flutter/foundation.dart';

import '../../biznex.dart';
import '../core/database/transactions_database/transactions_database.dart';
import '../core/isolate/transaction_filter.dart';
import '../core/model/transaction_model/transaction_model.dart';

final transactionProvider = FutureProvider.family((ref, DateTime day) async {
  final transactionsDatabase = TransactionsDatabase();
  final list = await transactionsDatabase.getDayTransactions(day);
  return list;
});
