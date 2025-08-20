import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class TransactionController extends AppController {
  TransactionController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as Transaction;
    showAppLoadingDialog(context);
    TransactionsDatabase sizeDatabase = TransactionsDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(transactionProvider);
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteTransactionQuestionText.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        TransactionsDatabase sizeDatabase = TransactionsDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(transactionProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Transaction;
    showAppLoadingDialog(context);
    TransactionsDatabase sizeDatabase = TransactionsDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(transactionProvider);
      closeLoading();
    });
  }
}
