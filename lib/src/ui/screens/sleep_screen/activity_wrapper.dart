import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/changes_controller.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/network/ingredient_network.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:isar/isar.dart';
import '../../../core/model/cloud_models/client.dart';
import '../../../core/network/network_base.dart';

class ActivityWrapper extends StatefulWidget {
  final Widget child;
  final WidgetRef ref;

  const ActivityWrapper({super.key, required this.child, required this.ref});

  @override
  State<ActivityWrapper> createState() => _ActivityWrapperState();
}

class _ActivityWrapperState extends State<ActivityWrapper> {
  final ChangesDatabase _changesDatabase = ChangesDatabase();
  final AppStateDatabase stateDatabase = AppStateDatabase();

  final Isar isar = IsarDatabase.instance.isar;

  void _localChangesSync() async {
    log("sync changes working");
    if (!(await Network().isConnected(skipPassword: true))) return;

    final app = await stateDatabase.getApp();

    if (app.apiUrl != null || (app.apiUrl ?? '').isNotEmpty) return;
    final changesList = await _changesDatabase.get();
    for (final item in changesList) {
      try {
        ChangesController changesController = ChangesController(item);
        await changesController.saveStatus();
        await _changesDatabase.delete(key: item.id);
      } catch (_) {}
    }

    IngredientNetwork ingredientNetwork = IngredientNetwork();
    await ingredientNetwork.init(false);

    try {
      NetworkServices networkServices = NetworkServices();
      final client = await widget.ref.watch(clientStateProvider.future);
      if (client == null) return;
      Client neClient = client;
      neClient.updatedAt = DateTime.now().toIso8601String();
      networkServices.updateClient(neClient).then((_) {
        widget.ref.invalidate(clientStateProvider);
      });
    } catch (_) {}
  }

  void _onListenChanges() async {
    isar.orderIsars.watchLazy().listen((_) {
      try {
        _localChangesSync();
      } catch (_) {}
    });
  }

  @override
  void initState() {
    super.initState();
    _localChangesSync();
    _onListenChanges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
