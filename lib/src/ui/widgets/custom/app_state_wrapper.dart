import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:biznex/src/core/model/app_screen_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateWrapper extends ConsumerWidget {
  final BuildContext? mainContext;
  final Widget Function(AppColors theme, AppModel app) builder;

  const AppStateWrapper({super.key, required this.builder, this.mainContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateProviderListener = ref.watch(appStateProvider);

    return appStateProviderListener.when(
      data: (appStateData) {
        AppModel initialState = appStateData;

        initialState.ref = ref;
        initialState.screen = AppScreen(
          crossAxisCount: initialState.isDesktop
              ? 5
              : initialState.isTablet
                  ? 3
                  : 2,
          lrPadding: initialState.isDesktop ? 24 : 16,
        );

        return builder(AppColors(isDark: appStateData.isDark), appStateData);
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const AppLoadingScreen(),
    );
  }
}
