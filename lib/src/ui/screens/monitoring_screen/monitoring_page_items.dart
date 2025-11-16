import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';

class MonitoringPageItems {
  AppColors theme;
  BuildContext context;

  MonitoringPageItems(this.theme, this.context);

  List<Widget> buildMonitoringPageItems({
    required double getOrdersSumm,
    required int getOrdersCount,
    required double getTotalSumm,
    required double getPercentsSumm,
    required double getPlacePriceSumm,
    required double totalShopping,
    required double getTotalProfit,
  }) {
    return [
      24.h,
      Row(
        spacing: 24,
        children: [
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.mainColor),
                  gradient: LinearGradient(colors: [
                    theme.secondaryColor.withValues(alpha: 0.2),
                    Colors.greenAccent.withValues(alpha: 0.4),
                  ])),
              child: Row(
                children: [
                  Icon(Iconsax.wallet_copy),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.totalOrderSumm.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    getOrdersSumm.priceUZS,
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                  gradient: LinearGradient(colors: [
                    Colors.blue.withValues(alpha: 0.2),
                    Colors.blueAccent.withValues(alpha: 0.4),
                  ])),
              child: Row(
                children: [
                  Icon(Iconsax.bag_copy),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.totalOrders.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    getOrdersCount.toString(),
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      20.h,
      Row(
        spacing: 24,
        children: [
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                  gradient: LinearGradient(colors: [
                    theme.orange.withValues(alpha: 0.2),
                    Colors.orangeAccent.withValues(alpha: 0.4),
                  ])),
              child: Row(
                children: [
                  Icon(Ionicons.fast_food_outline),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.profitFromProducts.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    getTotalSumm.priceUZS,
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                  gradient: LinearGradient(colors: [
                    theme.purple.withValues(alpha: 0.2),
                    Colors.purpleAccent.withValues(alpha: 0.4),
                  ])),
              child: Row(
                children: [
                  Icon(Iconsax.percentage_circle_copy),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.profitFromPercents.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    getPercentsSumm.priceUZS,
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      20.h,
      Row(
        spacing: 24,
        children: [
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                  gradient: LinearGradient(colors: [
                    Colors.deepPurple.withValues(alpha: 0.2),
                    Colors.deepPurpleAccent.withValues(alpha: 0.4),
                  ])),
              child: Row(
                children: [
                  Icon(Icons.table_restaurant_outlined),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.profitFromPlacePrice.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    getPlacePriceSumm.priceUZS,
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: 12.all,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent),
                gradient: LinearGradient(
                  colors: [
                    theme.red.withValues(alpha: 0.2),
                    Colors.redAccent.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.shopping_cart_copy),
                  8.w,
                  Expanded(
                    child: Text(
                      "${AppLocales.shopping.tr()}: ",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                    ),
                  ),
                  Text(
                    totalShopping.priceUZS,
                    style: TextStyle(fontSize: 18, fontFamily: boldFamily),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      24.h,
      Container(
        padding: 24.all,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.mainColor),
          gradient: LinearGradient(
            colors: [
              theme.mainColor.withValues(alpha: 0.2),
              theme.secondaryColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Ionicons.logo_usd),
                8.w,
                Text(
                  "${AppLocales.totalProfit.tr()}: ",
                  style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                ),
              ],
            ),
            16.h,
            Text(
              getTotalProfit.priceUZS,
              style: TextStyle(
                fontSize: context.s(40),
                fontFamily: boldFamily,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
