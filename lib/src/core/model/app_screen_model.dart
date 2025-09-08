class AppScreen {
  final int crossAxisCount;
  final double lrPadding;
  final double tbPadding;
  final double buttonHeight;
  final double buttonTBPadding;
  final double buttonLRPadding;
  final int animationDuration;

  const AppScreen({
    this.crossAxisCount = 2,
    this.buttonHeight = 48,
    this.buttonLRPadding = 48,
    this.buttonTBPadding = 12,
    this.lrPadding = 48,
    this.animationDuration = 300,
    this.tbPadding = 16,
  });

  static const appScreen = AppScreen();
}
