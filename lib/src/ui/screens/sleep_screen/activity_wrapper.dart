import 'dart:async';
import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/cloud/cloud_controller.dart';
import 'package:biznex/src/core/utils/font_utils.dart';

class ActivityWrapper extends StatefulWidget {
  final Widget child;
  final WidgetRef ref;
  final BuildContext context;

  const ActivityWrapper({
    super.key,
    required this.child,
    required this.ref,
    required this.context,
  });

  @override
  State<ActivityWrapper> createState() => _ActivityWrapperState();
}

class _ActivityWrapperState extends State<ActivityWrapper> {
  Timer? _timer;
  final BiznexCloudController _cloudController = BiznexCloudController();

  void _syncUpdates() async {
     if (_timer == null || !(_timer?.isActive ?? false)) {
      _timer = Timer.periodic(Duration(seconds: 60), (_) async {
        try {
          await _cloudController.sync();
        } catch (error, st) {
          log('sync error: $error', error: error, stackTrace: st);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FontUtils.instance.saveContext(widget.context);
    _initFonts();
    _syncUpdates();
  }

  void _initFonts() async => await FontUtils.instance.init();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
