import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/order_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/extensions/for_ref.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/order_screens/order_item_card.dart';
import 'package:biznex/src/ui/screens/order_screens/order_payment_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/price_percent_provider.dart';

class OrderItemsPage extends HookConsumerWidget {
  final Place place;
  final AppColors theme;
  final AppModel state;
  final bool minimalistic;

  const OrderItemsPage({
    super.key,
    this.minimalistic = false,
    required this.place,
    required this.theme,
    required this.state,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mobile = getDeviceType(context) == DeviceType.mobile;
    // final orderItems = ref.watch(orderSetProvider);
    // final orderNotifier = ref.read(orderSetProvider.notifier);
    final currentEmployee = ref.watch(currentEmployeeProvider);

    final scheduledTime = useState<DateTime?>(null);
    final useCheck = useState(true);
    final paymentType = useState(AppLocales.useCash);
    final percents = ref.read(orderPercentProvider).value ?? [];

    // final placeOrderItems = useMemoized(
    //   () => orderItems.where((e) => e.placeId == place.id).toList(),
    //   [orderItems, place.id],
    // );
    //
    // final totalPrice = placeOrderItems.fold<double>(
    //   0,
    //   (sum, item) => sum + (item.customPrice ?? item.amount * item.product.price),
    // );

    useEffect(() {
      Future.microtask(() {
        ref.read(orderSetProvider.notifier).loadOrderForPlace(place.id);
      });
      return null;
    }, [place.id]);

    final orderItems = ref.watch(orderSetProvider);

    final orderAsyncValue = ref.watch(ordersProvider(place.id));

    final placeOrderItems = useMemoized(
      () => orderItems.where((e) => e.placeId == place.id).toList(),
      [orderItems, place.id],
    );

    final totalPrice = placeOrderItems.fold<double>(
      0,
      (sum, item) =>
          sum + (item.customPrice ?? item.amount * item.product.price),
    );

    final totalPercents = percents.fold(0.0, (a, b) {
      return a += b.percent;
    });

    return orderAsyncValue.when(
      loading: () => AppLoadingScreen(),
      error: RefErrorScreen,
      data: (order) {
        final percentSum =
            (totalPrice + (order?.place.price ?? 0.0)) * (totalPercents / 100);
        final finalPrice = totalPrice +
            (place.percentNull ? 0 : percentSum) +
            (order?.place.price ?? 0.0);
        final noteController = useTextEditingController(text: order?.note);
        final customerNotifier = useState<Customer?>(order?.customer);
        final addressController =
            useTextEditingController(text: order?.customer?.name);
        final phoneController =
            useTextEditingController(text: order?.customer?.phone);
        final paymentTypes =
            useState(<Percent>[...(order?.paymentTypes ?? [])]);

        return Expanded(
          flex: getDeviceType(context) == DeviceType.tablet ? 6 : 4,
          child: placeOrderItems.isEmpty
              ? AppEmptyWidget()
              : Container(
                  margin: mobile
                      ? Dis.only()
                      : Dis.only(right: context.w(32), top: context.h(24)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: mobile ? null : Colors.white,
                  ),
                  padding: mobile ? null : 16.tb,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        for (final item in placeOrderItems)
                          OrderItemCardNew(
                            employee: currentEmployee,
                            item: item,
                            theme: theme,
                            order: order,
                          ),
                        // OrderDetailsScreen(
                        //   theme: theme,
                        //   noteController: noteController,
                        //   customerNotifier: customerNotifier,
                        // ),
                        // OrderParamButtons(
                        //   scheduleNotifier: scheduledTime,
                        //   theme: theme,
                        //   state: state,
                        //   onScheduleOrder: onSchedule,
                        //   onOpenSettings: () {
                        //     showDesktopModal(context: context, body: OrderSettingsScreen(state));
                        //   },
                        //   onClearAll: order != null ? null : () => orderNotifier.clear(),
                        // ),

                        // Container(
                        //   height: 1,
                        //   margin: 16.tb,
                        //   color: theme.accentColor,
                        // ),

                        Padding(
                          padding: Dis.only(lr: 16, top: 16),
                          // padding: const EdgeInsets.all(16),
                          child: AppTextField(
                            prefixIcon: Icon(Iconsax.note_1_copy),
                            title: AppLocales.enterNoteForOrder.tr(),
                            controller: noteController,
                            theme: theme,

                            // useBorder: true,
                            fillColor: theme.accentColor,
                          ),
                        ),
                        0.h,

                        Container(
                          margin: Dis.only(top: context.h(16)),
                          padding:
                              Dis.only(tb: context.h(24), lr: context.w(16)),
                          decoration: minimalistic
                              ? null
                              : BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: theme.scaffoldBgColor,
                                      width: 2,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 8,
                            children: [
                              SimpleButton(
                                onPressed: () {
                                  log("${order?.toJson().toString()}");
                                },
                                child: Text(
                                  "${AppLocales.paymentType.tr()}:",
                                  style: TextStyle(
                                    fontSize: context.s(16),
                                    fontFamily: mediumFamily,
                                  ),
                                ),
                              ),

                              AppTextField(
                                onTap: () {
                                  showDesktopModal(
                                    context: context,
                                    width: 560,
                                    body: OrderPaymentScreen(
                                      percentList: [...paymentTypes.value],
                                      theme: theme,
                                      state: state,
                                      totalSumm: finalPrice,
                                      onComplete: (payments) async {
                                        if (order == null) {
                                          ShowToast.error(context,
                                              AppLocales.firstSaveOrder.tr());
                                          return;
                                        }

                                        paymentTypes.value = payments;
                                        OrderController oc = OrderController(
                                          model: state,
                                          place: place,
                                          employee: ref
                                              .watch(currentEmployeeProvider),
                                        );

                                        await oc.saveOrderPayments(
                                            context, ref, payments, order);

                                        try {
                                          await Future.delayed(
                                              Duration(milliseconds: 300));

                                          await ref
                                              .refresh(ordersProvider(place.id)
                                                  .future)
                                              .then((order) {
                                            if (order != null) {
                                              ref
                                                  .read(
                                                      orderSetProvider.notifier)
                                                  .clearPlaceItems(place.id);
                                              Future.delayed(
                                                  Duration(milliseconds: 100));
                                              ref
                                                  .read(
                                                      orderSetProvider.notifier)
                                                  .addMultiple(
                                                    order.products,
                                                    context,
                                                    order: order,
                                                  );
                                            } else {
                                              // ref.read(orderSetProvider.notifier).clear();
                                            }
                                          });
                                        } catch (_) {}
                                      },
                                    ),
                                  );
                                },
                                prefixIcon: Icon(Iconsax.wallet_1_copy),
                                suffixIcon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                title: AppLocales.paymentType.tr(),
                                controller: TextEditingController(
                                  text: paymentTypes.value.isEmpty
                                      ? ''
                                      : paymentTypes.value
                                          .map((el) => el.name.tr().capitalize)
                                          .join(", "),
                                ),
                                onlyRead: true,
                                theme: theme,
                                // useBorder: true,
                                fillColor: theme.accentColor,
                              ),
                              // Wrap(
                              //   crossAxisAlignment: WrapCrossAlignment.start,
                              //   runAlignment: WrapAlignment.start,
                              //   spacing: 16,
                              //   runSpacing: Platform.isWindows ? 16 : 8,
                              //   children: [
                              //     ...[
                              //       AppLocales.useCash,
                              //       AppLocales.useDebt,
                              //       AppLocales.useCard,
                              //       AppLocales.payme,
                              //       AppLocales.click,
                              //     ].map((type) {
                              //       return ChoiceChip(
                              //         backgroundColor: theme.scaffoldBgColor,
                              //         selectedColor: theme.mainColor,
                              //         padding: Dis.only(),
                              //         checkmarkColor: paymentType.value == type
                              //             ? Colors.white
                              //             : Colors.black,
                              //         label: Text(
                              //           type.tr(),
                              //           style: TextStyle(
                              //             color: paymentType.value == type
                              //                 ? Colors.white
                              //                 : Colors.black,
                              //             fontSize: context.s(14),
                              //           ),
                              //         ),
                              //         selected: paymentType.value == type,
                              //         onSelected: (_) {
                              //           paymentType.value = type;
                              //         },
                              //       );
                              //     }),
                              //   ],
                              // ),

                              Container(
                                height: 1,
                                margin: 16.tb,
                                color: theme.accentColor,
                              ),

                              AppTextField(
                                prefixIcon: Icon(Iconsax.call_copy),
                                title: AppLocales.customerPhone.tr(),
                                controller: phoneController,
                                theme: theme,
                                // useBorder: true,
                                fillColor: theme.accentColor,
                              ),
                              0.h,
                              AppTextField(
                                prefixIcon: Icon(Iconsax.location_copy),
                                title: AppLocales.deliveryAddress.tr(),
                                controller: addressController,
                                theme: theme,
                                fillColor: theme.accentColor,
                              ),
                              Container(
                                height: 1,
                                margin: 16.tb,
                                color: theme.accentColor,
                              ),

                              if (order?.place.price != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      "${order?.place.price?.priceUZS}",
                                      style: TextStyle(
                                        fontSize: context.s(16),
                                        fontFamily: mediumFamily,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              if (order != null && !order.place.percentNull)
                                ref.whenProviderData(
                                  provider: orderPercentProvider,
                                  builder: (percents) {
                                    // percents as List<Percent>;
                                    // final total = percents

                                    percents as List<Percent>;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        for (final item in percents)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${item.name}: ${item.percent.toMeasure} %",
                                                style: TextStyle(
                                                  fontSize: context.s(16),
                                                  fontFamily: mediumFamily,
                                                  color:
                                                      theme.secondaryTextColor,
                                                ),
                                              ),
                                              Text(
                                                ((totalPrice +
                                                            (order.place
                                                                    .price ??
                                                                0.0)) *
                                                        (item.percent / 100))
                                                    .priceUZS,
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

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${AppLocales.total.tr()}:",
                                    style: TextStyle(
                                      fontSize: context.s(16),
                                      fontFamily: mediumFamily,
                                    ),
                                  ),
                                  Text(
                                    finalPrice.priceUZS,
                                    style: TextStyle(
                                      fontSize: context.s(20),
                                      fontFamily: boldFamily,
                                    ),
                                  ),
                                ],
                              ),
                              8.h,
                              AppPrimaryButton(
                                theme: theme,
                                onPressed: () async {
                                  showAppLoadingDialog(context);
                                  OrderController orderController =
                                      OrderController(
                                    model: state,
                                    place: place,
                                    employee:
                                        ref.watch(currentEmployeeProvider),
                                  );

                                  if (order == null) {
                                    orderController.openOrder(
                                      context,
                                      ref,
                                      placeOrderItems,
                                      // note: noteController.text.trim(),
                                      message: noteController.text.trim(),
                                      customer: Customer(
                                        name: addressController.text,
                                        phone: phoneController.text,
                                      ),
                                      scheduledDate: scheduledTime.value,
                                    );
                                    AppRouter.close(context);
                                    return;
                                  }

                                  await orderController.addItems(
                                    context,
                                    message: noteController.text.trim(),
                                    ref,
                                    placeOrderItems,
                                    order,
                                    // note: noteController.text.trim(),
                                    customer: Customer(
                                      name: addressController.text,
                                      phone: phoneController.text,
                                    ),
                                    scheduledDate: scheduledTime.value,
                                  );
                                  try {
                                    await Future.delayed(
                                        Duration(milliseconds: 300));

                                    await ref
                                        .refresh(
                                            ordersProvider(place.id).future)
                                        .then((order) {
                                      if (order != null) {
                                        ref
                                            .read(orderSetProvider.notifier)
                                            .clearPlaceItems(place.id);
                                        Future.delayed(
                                            Duration(milliseconds: 100));
                                        ref
                                            .read(orderSetProvider.notifier)
                                            .addMultiple(
                                              order.products,
                                              context,
                                              order: order,
                                            );
                                      } else {
                                        // ref.read(orderSetProvider.notifier).clear();
                                      }
                                    });
                                  } catch (_) {}

                                  ///
                                  ///
                                  ///
                                  noteController.clear();
                                  AppRouter.close(context);
                                },
                                title: AppLocales.add.tr(),
                              ),


                                8.h,


                              if (order != null)
                                AppPrimaryButton(
                                  // padding: Dis.only(tb: 16),
                                  theme: theme,
                                  onPressed: () async {
                                    OrderController orderController =
                                    OrderController(
                                      model: state,
                                      place: place,
                                      employee:
                                      ref.watch(currentEmployeeProvider),
                                    );
                                    await orderController
                                        .printCheck(order.id);
                                  },
                                  textColor: theme.mainColor,
                                  border: Border.all(color: theme.mainColor),
                                  color: theme.white,
                                  // title: AppLocales.print.tr(),
                                  // icon: Icons.close,
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    spacing: 16,
                                    children: [
                                      Icon(
                                        Ionicons.print_outline,
                                        color: theme.mainColor,
                                      ),
                                      Text(
                                        AppLocales.print.tr(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: mediumFamily,
                                            color: theme.mainColor),
                                      ),
                                    ],
                                  ),
                                ),
                              // AppPrimaryButton(
                              //   theme: theme,
                              //   onPressed: () async {
                              //     OrderController orderController =
                              //         OrderController(
                              //       model: state,
                              //       place: place,
                              //       employee:
                              //           ref.watch(currentEmployeeProvider),
                              //     );
                              //
                              //     await orderController.closeOrder(
                              //       context,
                              //       ref,
                              //       // note: noteController.text.trim(),
                              //       customer: Customer(
                              //         name: addressController.text,
                              //         phone: phoneController.text,
                              //       ),
                              //       scheduledDate: scheduledTime.value,
                              //       paymentType: paymentType.value,
                              //       useCheck: useCheck.value,
                              //       phone: phoneController.text,
                              //       address: addressController.text,
                              //     );
                              //
                              //     noteController.clear();
                              //     customerNotifier.value = null;
                              //
                              //     paymentType.value = '';
                              //     paymentTypes.value = [];
                              //   },
                              //   textColor: Colors.white,
                              //   border: Border.all(color: Colors.blue),
                              //   color: Colors.blue,
                              //   title: AppLocales.close.tr(),
                              //   // icon: Icons.close,
                              // ),
                              // ConfirmCancelButton(
                              //   onlyConfirm: true,
                              //   cancelColor: theme.scaffoldBgColor,
                              //   padding: Dis.only(tb: 20),
                              //   spacing: 16,
                              //   onConfirm: () async {
                              //     OrderController orderController = OrderController(
                              //       model: state,
                              //       place: place,
                              //       employee: ref.watch(currentEmployeeProvider),
                              //     );
                              //
                              //     log((place.father == null).toString());
                              //
                              //     if (order == null) {
                              //       orderController.openOrder(
                              //         context,
                              //         ref,
                              //         placeOrderItems,
                              //         note: noteController.text.trim(),
                              //         customer: customerNotifier.value,
                              //         scheduledDate: scheduledTime.value,
                              //       );
                              //       return;
                              //     }
                              //
                              //     orderController.addItems(
                              //       context,
                              //       ref,
                              //       placeOrderItems,
                              //       order!,
                              //       note: noteController.text.trim(),
                              //       customer: customerNotifier.value,
                              //       scheduledDate: scheduledTime.value,
                              //     );
                              //
                              //     ///
                              //     ///
                              //   },
                              //   onCancel: () async {
                              //     OrderController orderController = OrderController(
                              //       model: state,
                              //       place: place,
                              //       employee: ref.watch(currentEmployeeProvider),
                              //     );
                              //
                              //     await orderController.closeOrder(
                              //       context,
                              //       ref,
                              //       note: noteController.text.trim(),
                              //       customer: customerNotifier.value,
                              //       scheduledDate: scheduledTime.value,
                              //     );
                              //
                              //     noteController.clear();
                              //     customerNotifier.value = null;
                              //   },
                              // ),

                              if (mobile) 100.h
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

