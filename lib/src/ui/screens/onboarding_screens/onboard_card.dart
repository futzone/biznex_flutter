import 'dart:ui';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OnboardCard extends StatelessWidget {
  final String roleName;
  final String fullname;
  final void Function() onPressed;
  final AppColors theme;

  const OnboardCard({super.key, required this.roleName, required this.fullname, required this.onPressed, required this.theme});

  @override
  Widget build(BuildContext context) {
    return WebButton(
      onPressed: onPressed,
      builder: (focused) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaY: 56,
              sigmaX: 56,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: context.s(2),
                ),
              ),
              // duration: theme.animationDuration,
              padding: context.s(12).all,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: context.h(16),
                children: [
                  Container(
                    // padding: 10.all,
                    height: context.s(44),
                    width: context.s(44),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.44),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Iconsax.security_user_copy,
                        color: Colors.white,
                        size: context.s(24),
                      ),
                    ),
                  ),
                  Text(
                    fullname,
                    style: TextStyle(
                      fontFamily: mediumFamily,
                      fontSize: context.s(20),
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: context.w(16),
                      children: [
                        Text(
                          roleName,
                          style: TextStyle(
                            fontFamily: mediumFamily,
                            fontSize: context.s(16),
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          AppLocales.login.tr(),
                          style: TextStyle(
                            fontFamily: mediumFamily,
                            fontSize: context.s(16),
                            color: theme.mainColor,
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_1_copy,
                          color: theme.mainColor,
                          size: context.s(24),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
