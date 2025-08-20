import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/helpers/app_custom_padding.dart';

class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? leadingImage;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onPressed;
  final void Function()? onInfoPressed;
  final AppColors theme;
  final EdgeInsets? margin;
  final Color? iconColor;
  final double? height;
  final String? trailingText;

  const AppListTile({
    super.key,
    this.margin,
    this.trailingIcon,
    this.onDelete,
    this.onEdit,
    this.onPressed,
    required this.title,
    this.leadingIcon,
    this.leadingImage,
    this.height,
    this.subtitle,
    required this.theme,
    this.iconColor,
    this.onInfoPressed,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleButton(
      onPressed: onPressed,
      child: Container(
        height: height,
        padding: Dis.only(left: 12, right: 12, tb: 12),
        margin: margin ?? Dis.only(tb: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.scaffoldBgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (leadingIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  leadingIcon,
                  color: iconColor ?? theme.textColor,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: theme.textColor, fontSize: 15)),
                  if (subtitle != null) 8.h,
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
                      maxLines: 2,
                    ),
                ],
              ),
            ),
            if (trailingText != null) const SizedBox(width: 16),
            if (trailingText != null)
              Center(
                child: Text(trailingText ?? ''),
              ),
            const SizedBox(width: 16),
            if (onDelete != null)
              Center(
                child: SimpleButton(
                  onPressed: onDelete,
                  child: Container(
                    padding: 8.all,
                    decoration: BoxDecoration(
                      color: theme.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Iconsax.trash_copy, color: theme.red, size: 20),
                  ),
                ),
              ),
            if (onEdit != null) const SizedBox(width: 16),
            if (onEdit != null)
              Center(
                child: SimpleButton(
                  onPressed: onEdit,
                  child: Container(
                    padding: 8.all,
                    decoration: BoxDecoration(
                      color: theme.secondaryTextColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit, color: theme.textColor, size: 20),
                  ),
                ),
              ),
            if (trailingIcon != null) const SizedBox(width: 16),
            if (trailingIcon != null)
              Center(
                child: SimpleButton(
                  onPressed: onInfoPressed,
                  child: Icon(trailingIcon, color: theme.textColor, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
