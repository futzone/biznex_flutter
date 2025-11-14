import '../../../../../biznex.dart';

class OrderPinnedWidget extends StatelessWidget {
  final AppColors theme;
  const OrderPinnedWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryTextColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
