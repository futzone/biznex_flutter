import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
 import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
 import 'package:flutter_hooks/flutter_hooks.dart';

class SimpleButton extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final Widget child;

  const SimpleButton({
    super.key,
    this.onLongPress,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onPressed,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: child,
    );
  }
}

class WebButton extends HookWidget {
  final void Function()? onPressed;
  final void Function()? onEnter;
  final void Function()? onExit;
  final Widget Function(bool focused) builder;

  const WebButton({
    super.key,
    this.onPressed,
    required this.builder,
    this.onEnter,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    return MouseRegion(
      onEnter: (_) {
        focused.value = true;
        if (onEnter != null) onEnter!();
      },
      onExit: (_) {
        focused.value = false;
        if (onExit != null) onExit!();
      },
      child: SimpleButton(onPressed: onPressed, child: builder(focused.value)),
    );
  }
}

class AppSimpleButton extends AppStatelessWidget {
  final double radius;
  final Color? color;
  final Color? textColor;
  final EdgeInsets? padding;
  final String? text;
  final IconData? icon;
  final Widget? child;
  final void Function()? onPressed;

  const AppSimpleButton({
    super.key,
    this.radius = 14,
    this.padding,
    this.color,
    this.text,
    this.icon,
    this.child,
    this.textColor,
    this.onPressed,
  });

  @override
  Widget builder(BuildContext context, AppColors theme, WidgetRef ref, AppModel state) {
    return WebButton(
      onPressed: onPressed,
      builder: (focused) {
        if (!state.isDesktop) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: textColor ?? (!focused ? Colors.white : theme.mainColor),
            ),
          );
        }

        return AnimatedContainer(
          duration: theme.animationDuration,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: focused ? theme.mainColor : color,
            border: Border.all(color: color ?? theme.mainColor),
          ),
          padding: padding ?? Dis.only(lr: 24, tb: 11),
          child: child ??
              Row(
                children: [
                  if (text != null)
                    Text(
                      text ?? '',
                      style: TextStyle(
                        color: textColor ?? (focused ? Colors.white : theme.mainColor),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (text != null && icon != null) 12.w,
                  if (icon != null) Icon(icon, size: 20, color: textColor ?? (focused ? Colors.white : theme.mainColor)),
                ],
              ),
        );
      },
    );
  }
}
