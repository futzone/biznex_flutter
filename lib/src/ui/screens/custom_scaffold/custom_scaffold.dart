import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AppScaffold extends HookWidget {
  final ValueNotifier<AppBar> appbar;
  final List<Widget> actions;
  final String title;
  final ValueNotifier<FloatingActionButton?> floatingActionButtonNotifier;
  final FloatingActionButton? floatingActionButton;
  final Widget body;
  final AppModel state;

  const AppScaffold({
    super.key,
    required this.appbar,
    required this.state,
    required this.actions,
    required this.title,
    required this.floatingActionButton,
    required this.floatingActionButtonNotifier,
    required this.body,
  });

  AppColors get theme => AppColors(isDark: state.isDark);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (state.isDesktop) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appbar.value = AppBar(
          title: Text(title),
          actions: [...actions, 8.w],
        );

        floatingActionButtonNotifier.value = floatingActionButton;
      });

      return null;
    }, []);

    if (!state.isDesktop) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: TextStyle(fontSize: 20, fontFamily: boldFamily)),
              ),
              64.w,
              ...actions,
              8.w,
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
