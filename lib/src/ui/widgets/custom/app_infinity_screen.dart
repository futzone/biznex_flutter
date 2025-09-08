import 'package:biznex/biznex.dart';

class AppInfinityScreen extends StatelessWidget {
  final Widget child;

  const AppInfinityScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1600,
        // height: 1080,
        child: child,
      ),
    );
  }
}
