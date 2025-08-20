import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AppStatelessWidget extends ConsumerWidget {
  const AppStatelessWidget({super.key});

  @protected
  Widget builder(BuildContext context, AppColors theme, WidgetRef ref, AppModel state);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(
      builder: (theme, state) {
        return builder(context, theme, ref, state);
      },
    );
  }
}
