import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/order_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/services/printer_services.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/ui/screens/order_screens/order_payment_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/extensions/color_generator.dart';
import '../../../core/model/order_models/percent_model.dart';

class OrderDetail extends ConsumerWidget {
  final Order order;

  const OrderDetail({super.key, required this.order});

  static show(BuildContext context, Order order) {
    showDesktopModal(
      context: context,
      body: OrderDetail(order: order),
      width: MediaQuery.of(context).size.width * 0.5,
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final employee = ref.watch(currentEmployeeProvider);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        padding: Dis.all(context.s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: context.h(12),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: context.w(16),
              children: [
                Container(
                  height: context.s(68),
                  width: context.s(68),
                  decoration: BoxDecoration(
                    color: generateColorFromString(order.employee.id),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      order.employee.fullname.initials,
                      style: TextStyle(
                        fontSize: 23,
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
                          fontSize: context.s(12),
                          fontWeight: FontWeight.w500,
                          fontFamily: regularFamily,
                          color: theme.secondaryTextColor,
                        ),
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
                      fontSize: context.s(12),
                      color: colorFromStatus(order.status.toString()),
                      fontFamily: mediumFamily,
                    ),
                  ),
                ),
                if (employee.roleName.toLowerCase() == 'admin')
                  CustomPopupMenu(
                    theme: theme,
                    children: [
                      CustomPopupItem(
                        title: AppLocales.delete.tr(),
                        icon: Icons.delete_outline,
                        onPressed: () {
                          showConfirmDialog(
                            context: context,
                            title: AppLocales.deleteOrderQuestion.tr(),
                            onConfirm: () {
                              OrderController.onDeleteOrder(order.id, context)
                                  .then((_) => AppRouter.close(context));
                            },
                          );
                        },
                      ),
                      CustomPopupItem(
                          title: AppLocales.paymentType.tr(),
                          icon: Icons.payments_outlined,
                          onPressed: () {
                            showDesktopModal(
                              context: context,
                              body: OrderPaymentScreen(
                                theme: theme,
                                state: state,
                                percentList: order.paymentTypes,
                                totalSumm: order.price,
                                onComplete: (list) {
                                  Order newOrder = order;
                                  newOrder.paymentTypes = list;
                                  newOrder.updatedDate =
                                      DateTime.now().toIso8601String();
                                  OrderController.onUpdateOrder(
                                          newOrder, context)
                                      .then((_) => AppRouter.close(context));
                                },
                              ),
                            );
                          }),
                    ],
                    child: Container(
                      padding: Dis.all(context.s(12)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorFromStatus(order.status.toString()),
                        ),
                        color: colorFromStatus(order.status.toString())
                            .withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Iconsax.edit_2_copy,
                        size: 20,
                        color: theme.mainColor,
                      ),
                    ),
                  ),
              ],
            ),
            0.h,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(order.createdDate)),
                  style: TextStyle(
                    fontSize: context.s(16),
                    fontFamily: mediumFamily,
                    color: Colors.black,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(DateTime.parse(order.createdDate)),
                  style: TextStyle(
                    fontSize: context.s(16),
                    fontFamily: mediumFamily,
                    color: Colors.black,
                  ),
                )
              ],
            ),
            0.h,
            Container(
                height: 1, color: Colors.grey.shade200, width: double.infinity),
            0.h,
            Text(
              AppLocales.orderProducts.tr(),
              style: TextStyle(
                fontSize: context.s(18),
                fontFamily: mediumFamily,
                color: Colors.black,
              ),
            ),
            0.h,
            for (final item in order.products)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.accentColor,
                ),
                padding: Dis.all(context.s(12)),
                child: Row(
                  spacing: context.w(16),
                  children: [
                    AppFileImage(
                      name: item.product.name,
                      path: item.product.images?.firstOrNull.toString(),
                      size: context.s(96),
                      color: Colors.white,
                      radius: 10,
                    ),
                    Expanded(
                      child: Column(
                        spacing: context.h(4),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontSize: context.s(18),
                              fontFamily: mediumFamily,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "${item.amount.toMeasure} x ${item.product.price.priceUZS}",
                            style: TextStyle(
                              fontSize: context.s(16),
                              fontFamily: mediumFamily,
                              color: theme.secondaryTextColor,
                            ),
                          ),
                          if (item.product.category != null)
                            Text(
                              item.product.category!.name,
                              style: TextStyle(
                                fontSize: context.s(16),
                                fontFamily: mediumFamily,
                                color: theme.mainColor,
                              ),
                            )
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        (item.amount * item.product.price).priceUZS,
                        style: TextStyle(
                            fontFamily: mediumFamily,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            0.h,
            Container(
              height: 1,
              color: Colors.grey.shade200,
              width: double.infinity,
            ),
            0.h,
            if (order.customer != null && order.customer!.name.isNotEmpty) ...[
              Container(
                height: 1,
                color: Colors.grey.shade200,
                width: double.infinity,
              ),
              0.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocales.customer.tr(),
                    style: TextStyle(
                      fontSize: context.s(18),
                      fontFamily: mediumFamily,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  Text(
                    "${order.customer?.name}, ${order.customer?.phone}",
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              0.h,
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocales.place.tr(),
                  style: TextStyle(
                    fontSize: context.s(18),
                    fontFamily: mediumFamily,
                    color: theme.secondaryTextColor,
                  ),
                ),
                Text(
                  order.place.name +
                      ((order.place.father?.name == null ||
                              order.place.father!.name.isEmpty)
                          ? ''
                          : ', ${order.place.father!.name}'),
                  style: TextStyle(
                    fontSize: context.s(16),
                    fontFamily: mediumFamily,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            0.h,
            Container(
                height: 1, color: Colors.grey.shade200, width: double.infinity),
            0.h,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocales.total.tr(),
                  style: TextStyle(
                    fontSize: context.s(18),
                    fontFamily: mediumFamily,
                    color: theme.secondaryTextColor,
                  ),
                ),
                Text(
                  order.products.fold(0.0, (tot, el) {
                    return tot += (el.amount * el.product.price);
                  }).priceUZS,
                  style: TextStyle(
                    fontSize: context.s(16),
                    fontFamily: mediumFamily,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            if (order.place.price != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocales.placePrice.tr(),
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  Text(
                    "${order.place.price?.priceUZS}",
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            if (!order.place.percentNull && (order.place.percent ?? 0) > 0)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${AppLocales.placePercent.tr()} (${order.place.percent}%)",
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  Text(
                    (order.products.fold(0.0, (oldValue, element) {
                              return oldValue +
                                  (element.amount * element.product.price);
                            }) *
                            (order.place.percent ?? 0) *
                            0.01)
                        .priceUZS,
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            if (!order.place.percentNull)
              state.whenProviderData(
                provider: orderPercentProvider,
                builder: (percents) {
                  percents as List<Percent>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (final item in percents)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: context.s(16),
                                fontFamily: mediumFamily,
                                color: theme.secondaryTextColor,
                              ),
                            ),
                            Text(
                              "${item.percent.toStringAsFixed(2)} %",
                              style: TextStyle(
                                fontSize: context.s(16),
                                fontFamily: mediumFamily,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            if (order.paymentTypes.isNotEmpty) ...[
              Container(
                height: 1,
                color: Colors.grey.shade200,
                width: double.infinity,
              ),
              for (final item in order.paymentTypes)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name.tr().capitalize,
                      style: TextStyle(
                        fontSize: context.s(16),
                        fontFamily: mediumFamily,
                        color: theme.secondaryTextColor,
                      ),
                    ),
                    Text(
                      item.percent.priceUZS,
                      style: TextStyle(
                        fontSize: context.s(16),
                        fontFamily: mediumFamily,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
            Container(
              height: 1,
              color: Colors.grey.shade200,
              width: double.infinity,
            ),
            0.h,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocales.total.tr(),
                  style: TextStyle(
                    fontSize: context.s(24),
                    fontFamily: mediumFamily,
                    color: Colors.black,
                  ),
                ),
                Text(
                  order.price.priceUZS,
                  style: TextStyle(
                    fontSize: context.s(24),
                    fontFamily: boldFamily,
                    color: theme.mainColor,
                  ),
                ),
              ],
            ),
            0.h,
            ConfirmCancelButton(
              confirmIcon: Iconsax.printer_copy,
              confirmText: AppLocales.print.tr(),
              // onCancel: (){},
              onlyClose: !Platform.isWindows,
              onConfirm: () {
                PrinterServices printerServices =
                    PrinterServices(order: order, model: state);
                printerServices.printOrderCheck();
              },
            ),
          ],
        ),
      );
    });
  }
}
