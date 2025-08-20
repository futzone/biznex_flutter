import 'dart:async';
import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/main.dart';
import 'package:biznex/src/controllers/changes_controller.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/core/release/auto_update.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // onPointerHover va PointerEnterEvent uchun kerak
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  Timer? _inactivityTimer;
  late final FocusNode _focusNode;
  final Duration _inactivityTimeout = const Duration(seconds: 3000);
  final ValueNotifier<AppUpdate> updateNotifier = ValueNotifier(AppUpdate(text: AppLocales.chekingForUpdates.tr()));
  final ValueNotifier<String> lastVersion = ValueNotifier(appVersion);

  OverlayEntry? _logoOverlayEntry;

  void _resetInactivityTimer() {
    _hideInactivityOverlay();

    if (_inactivityTimer?.isActive ?? false) {
      _inactivityTimer!.cancel();
    }
    _inactivityTimer = Timer(_inactivityTimeout, () {
      if (mounted) {
        _showInactivityOverlay();
      }
    });
  }

  void _showInactivityOverlay() {
    if (_logoOverlayEntry != null) return;

    _logoOverlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _resetInactivityTimer(),
          onPanDown: (_) => _resetInactivityTimer(),
          onTapDown: (_) => _resetInactivityTimer(),
          child: SvgPicture.asset(
            'assets/icons/biznex-logo.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_logoOverlayEntry!);
    }
  }

  void _hideInactivityOverlay() {
    _logoOverlayEntry?.remove();
    _logoOverlayEntry = null;
  }

  void _onUserInteraction(PointerEvent event) {
    _resetInactivityTimer();
  }

  void _onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _resetInactivityTimer();
    }
  }

  void _onMouseEnter(PointerEnterEvent event) {
    _resetInactivityTimer();
  }

  void _autoUpdateCall() async => await checkAndUpdate(updateNotifier, lastVersion, widget.ref);

  void _localChangesSync() async {
    if (!(await Network().isConnected())) return;
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
    _autoUpdateCall();
    _localChangesSync();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
        _resetInactivityTimer();
      }
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _hideInactivityOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  final theme = AppColors(isDark: false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      builder: (context, AppUpdate value, child) {
        if (value.haveUpdate) {
          return Scaffold(
            body: Center(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.text.tr(),
                    style: TextStyle(
                      fontSize: context.s(40),
                      fontFamily: boldFamily,
                    ),
                  ),

                  if (value.step != AppUpdate.updatingStep)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: LinearProgressIndicator(
                        color: theme.mainColor,
                        backgroundColor: theme.white,
                        minHeight: 8,
                      ),
                    ),
                  // if(value.step == AppUpdate.updatingStep)

                  if (value.step == AppUpdate.updatingStep)
                    SizedBox(
                      width: context.s(100),
                      height: context.s(100),
                      child: CircularProgressIndicator(
                        color: theme.mainColor,
                        backgroundColor: theme.white,
                        strokeWidth: 8,
                        // value: value.progress * 0.01,
                      ),
                    ),
                  24.h,
                  SizedBox(
                    width: 400,
                    child: AppPrimaryButton(
                      onPressed: () async {
                        skipUpdates(lastVersion).then((_) {
                          updateNotifier.value = AppUpdate(
                            text: AppLocales.skip.tr(),
                            haveUpdate: false,
                            step: AppUpdate.checkingStep,
                          );
                        });
                      },
                      theme: theme,
                      title: AppLocales.skip.tr(),
                      textColor: Colors.black,
                      color: theme.white,
                      border: Border.all(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          );
        }

        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _onKeyEvent,
          autofocus: true,
          child: MouseRegion(
            onEnter: _onMouseEnter,
            child: Listener(
              onPointerDown: _onUserInteraction,
              onPointerMove: _onUserInteraction,
              onPointerHover: _onUserInteraction,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
