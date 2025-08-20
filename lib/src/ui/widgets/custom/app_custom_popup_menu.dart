import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
import 'package:flutter/material.dart';

class CustomPopupMenu extends StatelessWidget {
  final Widget child;
  final AppColors theme;
  final List<CustomPopupItem> children;

  const CustomPopupMenu({super.key, required this.child, required this.theme, required this.children});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      menuPadding: Dis.only(),
      padding: Dis.all(0),
      color: theme.scaffoldBgColor,
      child: child,
      itemBuilder: (context) {
        return [
          for (final item in children) item.build(context),
        ];
      },
    );
  }
}

class CustomPopupItem {
  final String title;
  final IconData? icon;
  final void Function()? onPressed;
  final Color? iconColor;

  const CustomPopupItem({this.iconColor, required this.title, this.icon, this.onPressed});

  PopupMenuItem build(BuildContext context) {
    return PopupMenuItem(
      onTap: () => (onPressed != null) ? onPressed!() : () {},
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 20, color: iconColor),
          if (icon != null) const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)),
        ],
      ),
    );
  }
}
