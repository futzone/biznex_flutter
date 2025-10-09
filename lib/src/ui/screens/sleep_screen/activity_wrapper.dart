 import 'dart:developer';
import 'package:biznex/biznex.dart';
 import 'package:biznex/src/controllers/changes_controller.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
 import 'package:biznex/src/core/network/network_services.dart';
 import 'package:biznex/src/providers/app_state_provider.dart';
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

  void _localChangesSync() async {
    // await _backupDatabase.syncLocalData();

    if (!(await Network().isConnected())) return;

    if (widget.ref.watch(appStateProvider).value?.apiUrl != null) return;
    log('syncing saved changes');
    final changesList = await _changesDatabase.get();
    for (final item in changesList) {
      log("${item.method} ${item.database}");
      ChangesController changesController = ChangesController(item);
      await changesController.saveStatus();
      await _changesDatabase.delete(key: item.id);
    }

    NetworkServices networkServices = NetworkServices();
    final client = await widget.ref.watch(clientStateProvider.future);
    if (client == null) return;
    Client neClient = client;
    neClient.updatedAt = DateTime.now().toIso8601String();
    networkServices.updateClient(neClient).then((_) {
      widget.ref.invalidate(clientStateProvider);
    });

    log('syncing changes is completed!');
  }

  @override
  void initState() {
    super.initState();
    _localChangesSync();
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
