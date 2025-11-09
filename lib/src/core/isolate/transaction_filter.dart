import '../model/transaction_model/transaction_model.dart';

List<Transaction> sortTransactions(List<Transaction> list) {
  list.sort((a, b) {
    final dateA = DateTime.parse(
      a.createdDate.isNotEmpty ? a.createdDate : DateTime.now().toIso8601String(),
    );
    final dateB = DateTime.parse(
      b.createdDate.isNotEmpty ? b.createdDate : DateTime.now().toIso8601String(),
    );
    return dateB.compareTo(dateA);
  });

  return list;
}
