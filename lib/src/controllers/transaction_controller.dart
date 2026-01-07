import 'package:biznex/biznex.dart';
import 'dart:convert';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';

class TransactionController extends AppController {
  final bool useLoading;

  TransactionController(
      {required super.context, required super.state, this.useLoading = true});

  @override
  Future<void> create(data) async {
    data as Transaction;
    if (useLoading) showAppLoadingDialog(context);
    TransactionsDatabase sizeDatabase = TransactionsDatabase();
    await sizeDatabase.set(data: data).then((_) async {
      try {
        await LoggerService.save(
          logType: LogType.transaction,
          actionType: ActionType.create,
          itemId: data.id,
          newValue: jsonEncode(data.toJson()),
        );
        state.ref!.invalidate(transactionProvider);
        if (useLoading) closeLoading();
      } catch (_) {}
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
        await sizeDatabase.delete(key: key).then((_) async {
          await LoggerService.save(
            logType: LogType.transaction,
            actionType: ActionType.delete,
            itemId: key,
          );
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
    await sizeDatabase.update(data: data, key: data.id).then((_) async {
      await LoggerService.save(
        logType: LogType.transaction,
        actionType: ActionType.update,
        itemId: data.id,
        newValue: jsonEncode(data.toJson()),
      );
      state.ref!.invalidate(transactionProvider);
      closeLoading();
    });
  }
}
