import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../biznex.dart';
import '../../../../core/config/router.dart';
import '../../../pages/waiter_pages/waiter_page.dart';

class AddOrderBtn extends StatelessWidget {
  final AppColors theme;

  const AddOrderBtn({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return WebButton(
      onPressed: () {
        AppRouter.go(context, WaiterPage(haveBack: true));
      },
      builder: (focused) => AnimatedContainer(
        duration: theme.animationDuration,
        height: focused ? 80 : 64,
        width: focused ? 80 : 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xff5CF6A9), width: 2),
          color: theme.mainColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(3, 3),
            )
          ],
        ),
        child: Center(
          child: Icon(Iconsax.add_copy,
              color: Colors.white, size: focused ? 40 : 32),
        ),
      ),
    );
  }
}
