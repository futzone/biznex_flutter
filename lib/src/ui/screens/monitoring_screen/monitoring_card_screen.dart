import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MonitoringCard extends StatelessWidget {
  final AppColors theme;
  final String title;
  final IconData icon;
  final void Function() onPressed;
  final int count;

  const MonitoringCard({
    super.key,
    required this.theme,
    required this.title,
    required this.onPressed,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return WebButton(
      onPressed: onPressed,
      builder: (focused) => AnimatedContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: focused ? theme.mainColor.withValues(alpha: 0.1) : theme.white,
        ),
        padding: context.s(24).all,
        duration: theme.animationDuration,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xffEDFEF5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: 6.all,
              child: Icon(icon, color: theme.mainColor),
            ),
            Text(title, style: TextStyle(fontSize: context.s(20), fontFamily: mediumFamily)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: TextStyle(fontSize: context.s(20), fontFamily: boldFamily, color: theme.mainColor),
                ),
                Text(
                  " ${AppLocales.ta.tr()}",
                  style: TextStyle(fontSize: context.s(20), fontFamily: mediumFamily, color: theme.secondaryTextColor),
                ),
                Spacer(),
                Text(
                  AppLocales.more.tr(),
                  style: TextStyle(fontSize: context.s(20), fontFamily: boldFamily, color: theme.mainColor),
                ),
                8.w,
                Icon(Iconsax.arrow_right_1_copy, color: theme.mainColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
