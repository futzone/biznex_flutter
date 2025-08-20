import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/ui/screens/chart_screens/chart_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:ionicons/ionicons.dart';

import '../../screens/chart_screens/chart_screens.dart';

class OverviewPage extends StatefulWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const OverviewPage({super.key, required this.appbar, required this.floatingActionButton});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final List _demoItems = [
    {'title': AppLocales.totalSales.tr(), 'total': 890, 'icon': Icons.sell_outlined},
    {'title': AppLocales.totalCompletedOrders.tr(), 'total': 851, 'icon': Icons.done_all},
    {'title': AppLocales.totalPendingOrders.tr(), 'total': 39, 'icon': Icons.timelapse_outlined},
    {'title': AppLocales.cancelledOrders.tr(), 'total': 0, 'icon': Icons.cancel_outlined},
  ];

  final List _demoTransactions = [
    {'title': AppLocales.totalProfit.tr(), 'total': 124940907.priceUZS, 'icon': Icons.attach_money},
    {'title': AppLocales.totalComeInPrice.tr(), 'total': 87655000.priceUZS, 'icon': Icons.account_balance_wallet_outlined},
    {'title': AppLocales.useCard.tr(), 'total': 74964544.priceUZS, 'icon': Ionicons.card_outline},
    {'title': AppLocales.useCash.tr(), 'total': 49976363.priceUZS, 'icon': Ionicons.cash_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return AppScaffold(
        appbar: widget.appbar,
        state: state,
        actions: [],
        title: AppLocales.overview.tr(),
        floatingActionButton: null,
        floatingActionButtonNotifier: widget.floatingActionButton,
        body: SingleChildScrollView(
          padding: 24.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (final item in _demoItems)
                    Expanded(
                      child: OrderStatsCard(
                        title: item['title'],
                        stats: item['total'].toString(),
                        badge: Icon(item['icon']),
                        subWidget: Text('Batafsil', style: TextStyle(color: theme.mainColor)),
                        theme: theme,
                      ),
                    ),
                ],
              ),
              24.h,
              AppText.$18Bold("Moliyaviy hisobotlar: kirim va chiqimlar"),
              8.h,
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (final item in _demoTransactions)
                    Expanded(
                      child: OrderStatsCard(
                        title: item['title'],
                        stats: item['total'].toString(),
                        badge: Icon(item['icon']),
                        subWidget: Text('Batafsil', style: TextStyle(color: theme.mainColor)),
                        theme: theme,
                      ),
                    ),
                ],
              ),
              24.h,
              AppText.$18Bold("Moliyaviy hisobotlar: kirim va chiqimlar"),
              8.h,
              Row(
                spacing: 16,
                children: [
                  Expanded(child: ChartScreen1()),
                  Expanded(child: ChartScreen2()),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}

class OrderStatsCard extends StatelessWidget {
  final String title;
  final String stats;
  final Widget badge;
  final Widget subWidget;
  final AppColors theme;

  const OrderStatsCard({super.key, required this.title, required this.stats, required this.badge, required this.subWidget, required this.theme});

  @override
  Widget build(BuildContext context) {
    return WebButton(
      builder: (focused) {
        return AnimatedContainer(
          padding: focused ? 20.all : 16.all,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: focused ? theme.mainColor : theme.accentColor),
          ),
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: theme.secondaryTextColor, fontSize: 16)),
                        4.h,
                        Text(
                          stats,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.w,
                  badge,
                ],
              ),
              16.h,
              subWidget,
            ],
          ),
        );
      },
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final Widget badge;
  final String stats;
  final AppColors theme;

  const StatsCard({
    super.key,
    required this.title,
    required this.stats,
    required this.badge,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return WebButton(
      builder: (focused) {
        return AnimatedContainer(
          padding: focused ? 20.all : 16.all,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: focused ? theme.mainColor : theme.accentColor),
          ),
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: theme.secondaryTextColor, fontSize: 16)),
                        4.h,
                        Text(
                          stats,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.w,
                  badge,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
