// import '../network/ingredient_network.dart';
// import '../network/network_base.dart';
// import 'dart:developer';
import 'dart:async';

class ActionController {
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void add(String value) => _controller.add(value);

  static void dispose() => _controller.close();

  static Future<void> onSyncOwner(bool fromListener) async {
    // try {
    //   final Network network = Network();
    //   if (!(await network.isConnected())) {
    //     log('sync broken. reason:network_fails');
    //     return;
    //   }
    //
    //   IngredientNetwork ingredientNetwork = IngredientNetwork();
    //   await ingredientNetwork.init(fromListener);
    //
    //   ChangesDatabase changesDatabase = ChangesDatabase();
    //   final changesList = await changesDatabase.get();
    //
    //   for (final item in changesList) {
    //     await Future.delayed(const Duration(milliseconds: 300));
    //     try {
    //       log("${item.method} ${item.database}");
    //       ChangesController changesController = ChangesController(item);
    //       final status = await changesController.saveStatus();
    //       if (!status) return;
    //       await changesDatabase.delete(key: item.id);
    //     } catch (_) {}
    //   }
    //
    //   log('main:syncing changes is completed!');
    // } catch (error) {
    //   log("error on main:onSyncOwner", error: error);
    // }
  }
}
