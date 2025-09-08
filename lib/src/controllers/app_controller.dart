import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';

abstract class AppController {
  AppModel state;
  BuildContext context;
  void Function()? onSuccess;
  void Function()? onError;

  AppController({
    required this.context,
    required this.state,
    this.onSuccess,
    this.onError,
  });

  Future<void> create(dynamic data);

  Future<void> update(dynamic data, dynamic key);

  Future<void> delete(dynamic key);

  void closeLoading() => AppRouter.close(context);

  void error(String message) {
    ShowToast.error(context, message);
  }
}
