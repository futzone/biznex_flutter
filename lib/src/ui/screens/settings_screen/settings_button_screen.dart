import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/ui/screens/settings_screen/settings_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
import 'package:flutter/material.dart';

class SettingsButtonScreen extends StatelessWidget {
  final AppColors theme;
  final AppModel model;
  final bool opened;
  final bool selected;

  const SettingsButtonScreen({
    super.key,
    required this.theme,
    required this.model,
    required this.opened,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Dis.all(context.s(16)),
      padding: Dis.all(context.s(8)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        // border: Border.all(color: theme.accentColor),
        color: selected ? theme.mainColor : Colors.white.withValues(alpha: 0.12),
      ),
      child: !opened
          ? SettingsScreenButton(theme)
          : Row(
              children: [
                Container(
                  margin: context.s(12).right,
                  height: context.s(34),
                  width: context.s(34),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.accentColor,
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.textColor,
                    size: context.s(24),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        model.shopName == null || model.shopName!.isEmpty ? 'Biznex' : model.shopName!,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: context.s(14)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        model.currentEmployee?.fullname ?? 'Admin',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w300,
                          fontSize: context.s(14),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SettingsScreenButton(theme),
              ],
            ),
    );
  }
}
