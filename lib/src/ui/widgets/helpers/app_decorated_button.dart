import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:flutter/material.dart';

import 'app_simple_button.dart';

class AppPrimaryButton extends StatelessWidget {
  final AppColors theme;
  final String? title;
  final void Function() onPressed;
  final void Function()? onLongPressed;
  final Color? color;
  final Color? cancelColor;
  final Color? textColor;
  final double radius;
  final EdgeInsets? padding;
  final IconData? icon;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppPrimaryButton({
    super.key,
    this.onLongPressed,
    this.cancelColor,
    this.padding,
    this.child,
    this.radius = 14,
    required this.theme,
    this.title,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleButton(
      onLongPress: onLongPressed ?? () {},
      onPressed: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          color: color ?? theme.mainColor,
          border: border ?? Border.all(color: theme.mainColor),
        ),
        child: Center(
          child: child ??
              (icon != null
                  ? Icon(
                      icon,
                      color: textColor ?? Colors.white,
                      size: 20,
                    )
                  : Text(
                      title ?? '',
                      style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontFamily: 'Medium',
                          fontSize: context.s(14)),
                    )),
        ),
      ),
    );
  }
}

class ConfirmCancelButton extends AppStatelessWidget {
  final void Function()? onConfirm;
  final void Function()? onCancel;
  final String? confirmText;
  final String? cancelText;
  final IconData? confirmIcon;
  final IconData? cancelIcon;
  final double? spacing;
  final EdgeInsets? padding;
  final Color? cancelColor;
  final bool onlyClose;
  final bool onlyConfirm;

  const ConfirmCancelButton({
    super.key,
    this.spacing,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.confirmIcon,
    this.cancelIcon,
    this.padding,
    this.onlyClose = false,
    this.onlyConfirm = false,
    this.cancelColor,
  });

  @override
  Widget builder(context, theme, ref, state) {
    return Row(
      children: [
        if (onlyConfirm) Expanded(child: SizedBox()),
        if (!onlyConfirm)
          Expanded(
            child: AppPrimaryButton(
              cancelColor: cancelColor ?? theme.white,
              padding: padding,
              border: Border.all(color: Colors.black),
              theme: theme,
              onPressed: () {
                if (onCancel == null) {
                  AppRouter.close(context);
                  return;
                }

                onCancel!();
              },
              title: cancelText ?? AppLocales.close.tr(),
              textColor: theme.textColor,
              color: cancelColor ?? theme.white,
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cancelIcon != null)
                    Icon(
                      cancelIcon,
                      size: 20,
                      color: theme.textColor,
                    ),
                  Text(cancelText ?? AppLocales.close.tr())
                ],
              ),
            ),
          ),
        if (!onlyClose)
          if (spacing == null) state.getSpacing.w else spacing!.w,
        if (!onlyClose)
          Expanded(
            child: AppPrimaryButton(
              border: Border.all(color: theme.mainColor),
              padding: padding,
              theme: theme,
              onPressed: () {
                if (onConfirm == null) {
                  AppRouter.close(context);
                  return;
                }

                onConfirm!();
              },
              title: confirmText ?? AppLocales.add.tr(),
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (confirmIcon != null)
                    Icon(
                      confirmIcon,
                      size: 20,
                      color: Colors.white,
                    ),
                  Text(
                    confirmText ?? AppLocales.add.tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}
