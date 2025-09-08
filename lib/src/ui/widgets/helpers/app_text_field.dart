import 'package:biznex/src/core/config/theme.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppTextField extends StatelessWidget {
  final bool hideBorder;
  final AppColors theme;
  final String title;
  final Widget? suffix;
  final bool onlyRead;
  final TextEditingController controller;
  final int? minLines;
  final bool autofocus;
  final int? maxLines;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final TextInputType? textInputType;
  final void Function(String text)? onChanged;
  final void Function(String text)? onSubmitted;
  final void Function()? onTap;
  final double radius;
  final Color fillColor;
  final Color? enabledColor;
  final bool useBorder;
  final int? maxLength;

  const AppTextField({
    this.suffix,
    this.hideBorder = false,
    super.key,
    this.maxLength,
    this.fillColor = Colors.transparent,
    this.radius = 14,
    required this.title,
    required this.controller,
    this.minLines,
    this.suffixIcon,
    this.maxLines,
    this.onChanged,
    this.useBorder = true,
    this.onlyRead = false,
    this.textInputAction,
    this.prefixIcon,
    this.enabledColor,
    this.onSubmitted,
    this.onTap,
    this.textInputType,
    required this.theme,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      textInputAction: textInputAction,
      onSubmitted: (String text) {
        if (onSubmitted != null) onSubmitted!(text);
      },
      autofocus: autofocus,
      keyboardType: textInputType,
      readOnly: onlyRead,
      onTap: () {
        if (onTap != null) onTap!();
      },
      onChanged: (str) {
        if (onChanged != null) onChanged!(str);
      },
      maxLines: maxLines,
      minLines: minLines,
      controller: controller,
      style: TextStyle(fontWeight: FontWeight.w400, color: theme.textColor, fontSize: (14)),
      cursorColor: theme.mainColor,
      decoration: InputDecoration(
        // constraints: BoxConstraints(maxWidth: 100),
        hintText: title,
        hintStyle: TextStyle(
          color: theme.secondaryTextColor,
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        hintMaxLines: 1,
        filled: true,
        fillColor: fillColor == Colors.transparent ? theme.scaffoldBgColor : fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: !useBorder ? Colors.transparent : theme.mainColor,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.w(16),
          vertical: context.h(12),
        ),
        suffixIcon: !onlyRead
            ? suffixIcon
            : controller.text.isEmpty
                ? Icon(
                    Iconsax.arrow_down_1_copy,
                    color: theme.textColor,
                    size: context.s(24),
                  )
                : Icon(
                    Icons.done,
                    color: theme.mainColor,
                    size: context.s(20),
                  ),
        suffix: suffix,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
