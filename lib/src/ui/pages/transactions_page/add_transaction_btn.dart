import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/ui/pages/transactions_page/add_transaction_page.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';

class AddTransactionBtn extends StatelessWidget {
  final AppColors theme;

  const AddTransactionBtn({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return WebButton(
      onPressed: () {
        showDesktopModal(
          context: context,
          body: AddTransactionPage(),
          width: context.w(600),
        );
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
          child: Icon(
            Iconsax.add_copy,
            color: Colors.white,
            size: focused ? 40 : 32,
          ),
        ),
      ),
    );
  }
}
