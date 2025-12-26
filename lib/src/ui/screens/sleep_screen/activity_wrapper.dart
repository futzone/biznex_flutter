import 'package:biznex/biznex.dart';
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
  @override
  void initState() {
    super.initState();
    FontUtils.instance.saveContext(widget.context);
    _initFonts();
  }

  void _initFonts() async => await FontUtils.instance.init();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
