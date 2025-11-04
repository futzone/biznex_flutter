import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';

final transactionProvider = FutureProvider((ref) async {
  TransactionsDatabase transactionsDatabase = TransactionsDatabase();
  final list = await transactionsDatabase.get();
  // list.sort((a, b) {
  //   final dateA = DateTime.parse(a.createdDate.isNotEmpty ? a.createdDate : DateTime(2025).toIso8601String());
  //   final dateB = DateTime.parse(b.createdDate.isNotEmpty ? b.createdDate : DateTime(2025).toIso8601String());
  //   return dateB.compareTo(dateA);
  // });

  return list;
});
