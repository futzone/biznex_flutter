import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/ui/pages/order_pages/menu_page.dart';
import 'package:biznex/src/ui/screens/order_screens/order_detail_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../../core/extensions/color_generator.dart';
import '../../../core/model/order_models/order_model.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final AppColors theme;
  final Color? color;

  const OrderCard(
      {super.key, this.color, required this.order, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color ?? Colors.white,
      ),
      padding: Dis.all(context.s(16)),
      child: Column(
        // spacing: context.h(16),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: context.w(16),
            children: [
              Container(
                height: context.s(56),
                width: context.s(56),
                decoration: BoxDecoration(
                  color: generateColorFromString(order.employee.id),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    order.employee.fullname.initials,
                    style: TextStyle(
                      fontSize: context.s(23),
                      color: Colors.white,
                      fontFamily: mediumFamily,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: context.h(4),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.employee.fullname,
                      style: TextStyle(
                        fontSize: context.s(16),
                        fontWeight: FontWeight.w500,
                        fontFamily: mediumFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ID: ${order.orderNumber}",
                      style: TextStyle(
                        fontSize: context.s(14),
                        fontWeight: FontWeight.w500,
                        fontFamily: regularFamily,
                        color: theme.secondaryTextColor,
                      ),
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              Container(
                padding: Dis.all(context.s(12)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorFromStatus(order.status.toString()),
                  ),
                  color: colorFromStatus(order.status.toString())
                      .withValues(alpha: 0.1),
                ),
                child: Text(
                  order.status.toString().tr(),
                  style: TextStyle(
                    fontSize: context.s(14),
                    color: colorFromStatus(order.status.toString()),
                    fontFamily: mediumFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd.MM.yyyy')
                    .format(DateTime.parse(order.createdDate)),
                style: TextStyle(
                  fontSize: context.s(12),
                  fontFamily: mediumFamily,
                  color: Colors.blueGrey.shade500,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(DateTime.parse(order.createdDate)),
                style: TextStyle(
                  fontSize: context.s(12),
                  fontFamily: mediumFamily,
                  color: Colors.blueGrey.shade500,
                ),
              )
            ],
          ),
          Container(
              height: 1, color: Colors.grey.shade200, width: double.infinity),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocales.productName.tr(),
                style: TextStyle(
                  fontSize: context.s(12),
                  fontFamily: mediumFamily,
                  color: Colors.blueGrey.shade400,
                ),
              ),
              Text(
                AppLocales.price.tr(),
                style: TextStyle(
                  fontSize: context.s(12),
                  fontFamily: mediumFamily,
                  color: Colors.blueGrey.shade400,
                ),
              )
            ],
          ),
          for (int i = 0;
              i < (order.products.length > 3 ? 3 : order.products.length);
              i++)
            Row(
              spacing: context.w(12),
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.products[i].product.name,
                    style: TextStyle(
                      fontSize: context.s(14),
                      fontFamily: mediumFamily,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ),
                Text(
                  "${order.products[i].amount.toMeasure} x ${order.products[i].product.price.priceUZS}",
                  style: TextStyle(
                    fontSize: context.s(14),
                    fontFamily: mediumFamily,
                    color: Colors.blueGrey.shade400,
                  ),
                )
              ],
            ),
          Container(
              height: 1, color: Colors.grey.shade200, width: double.infinity),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${AppLocales.total.tr()}: ",
                style: TextStyle(
                  fontSize: context.s(16),
                  fontFamily: mediumFamily,
                  // color: Colors.blueGrey.shade400,
                ),
              ),
              Text(
                order.price.priceUZS,
                style: TextStyle(
                  fontSize: context.s(16),
                  fontFamily: boldFamily,
                  // color: Colors.blueGrey.shade400,
                ),
              )
            ],
          ),
          Row(
            spacing: context.w(16),
            children: [
              Expanded(
                flex: 2,
                child: WebButton(
                  onPressed: () {
                    OrderDetail.show(context, order);
                  },
                  builder: (focused) {
                    return Container(
                      padding: Dis.tb(context.h(12)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                        color: focused
                            ? theme.mainColor.withValues(alpha: 0.2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          AppLocales.about.tr(),
                          style: TextStyle(
                            fontSize: context.s(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: mediumFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (order.status != Order.completed)
                Expanded(
                  flex: 3,
                  child: SimpleButton(
                    onPressed: () {
                      AppRouter.go(context, MenuPage(place: order.place));
                    },
                    child: Container(
                      padding: Dis.tb(context.h(12)),
                      decoration: BoxDecoration(
                        color: theme.mainColor,
                        border: Border.all(color: theme.mainColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        spacing: context.w(8),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocales.products.tr(),
                            style: TextStyle(
                              fontSize: context.s(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: mediumFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Icon(
                          //   Iconsax.monitor_recorder,
                          //   color: Colors.white,
                          //   size: context.s(24),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
              // Container(),
            ],
          )
        ],
      ),
    );
  }
}
