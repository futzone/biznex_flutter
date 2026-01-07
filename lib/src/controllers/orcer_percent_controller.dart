import 'dart:convert';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';

class OrderPercentController extends AppController {
  final void Function()? onCompleted;

  OrderPercentController(
      {required super.context, this.onCompleted, required super.state});

  @override
  Future<void> create(data) async {
    data as Percent;
    if (data.name.isEmpty) return error(AppLocales.percentNameInputError.tr());
    if (data.percent == 0) return error(AppLocales.percentInputError.tr());
    showAppLoadingDialog(context);
    OrderPercentDatabase sizeDatabase = OrderPercentDatabase();
    await sizeDatabase.set(data: data).then((_) async {
      await LoggerService.save(
        logType: LogType.percent,
        actionType: ActionType.create,
        itemId: data.id,
        newValue: jsonEncode(data.toJson()),
      );
      state.ref!.invalidate(orderPercentProvider);
      closeLoading();
      onCompleted != null ? onCompleted!() : () {};
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteOrderPercentQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        OrderPercentDatabase sizeDatabase = OrderPercentDatabase();
        await sizeDatabase.delete(key: key).then((_) async {
          await LoggerService.save(
            logType: LogType.percent,
            actionType: ActionType.delete,
            itemId: key,
          );
          state.ref!.invalidate(orderPercentProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Percent;
    if (data.name.isEmpty) return error(AppLocales.percentNameInputError.tr());
    if (data.percent == 0) return error(AppLocales.percentInputError.tr());

    showAppLoadingDialog(context);
    OrderPercentDatabase sizeDatabase = OrderPercentDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) async {
      await LoggerService.save(
        logType: LogType.percent,
        actionType: ActionType.update,
        itemId: data.id,
        newValue: jsonEncode(data.toJson()),
      );
      state.ref!.invalidate(orderPercentProvider);
      closeLoading();
      closeLoading();
    });
  }
}
