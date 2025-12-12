import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/order_controller.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/minimalistic_menu_provider.dart';
import 'package:biznex/src/ui/screens/order_screens/order_item_detail_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/extensions/device_type.dart';
import '../../../core/model/employee_models/employee_model.dart';
import '../../../core/model/order_models/order_model.dart';
import '../../widgets/custom/app_file_image.dart';

class OrderItemCardNew extends HookConsumerWidget {
  final OrderItem item;
  final AppColors theme;
  final bool infoView;
  final Order? order;
  final Employee employee;

  const OrderItemCardNew({
    super.key,
    this.order,
    this.infoView = false,
    required this.item,
    required this.employee,
    required this.theme,
  });

  num? _tryParseNum(String text) {
    return num.tryParse(text.replaceAll(',', '.').replaceAll(' ', ''));
  }

  String _formatDecimal(num value) {
    if (value.isNaN || value.isInfinite) {
      return value.toString();
    }

    num roundedValue = double.parse(value.toStringAsFixed(3));
    String formatted = roundedValue.toString();

    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  void _updateControllerText(TextEditingController controller, num newValue) {
    final newText = _formatDecimal(newValue);
    if (controller.text != newText) {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = getDeviceType(context) == DeviceType.mobile;

    final product = item.product;
    final amountController =
        useTextEditingController(text: _formatDecimal(item.amount));
    final totalPriceController = useTextEditingController(
        text: _formatDecimal(item.amount * product.price));

    final orderNotifier = ref.read(orderSetProvider.notifier);
    final itemIsSaved = useState(false);

    final minimalistic = ref.watch(minimalisticMenuProvider).value ?? false;

    useEffect(() {
      final currentAmount = item.amount;
      final currentTotalPrice = currentAmount * product.price;

      _updateControllerText(amountController, currentAmount);
      _updateControllerText(totalPriceController, currentTotalPrice);

      final originalAmount = order?.products
          .firstWhere(
            (e) => e.product.id == item.product.id,
            orElse: () => item.copyWith(amount: -1),
          )
          .amount;

      itemIsSaved.value =
          originalAmount == -1 || currentAmount != originalAmount;

      return null;
    }, [item.amount, product.price, order]);

    void updateAmount(num newAmount) {
      OrderItem kItem = item;
      kItem.amount = newAmount.toDouble();

      log("${item.amount}");

      if (OrderController.hasNegativeItem(ref,
          savedList: order?.products ?? [], item: kItem)) {
        ShowToast.error(context, AppLocales.doNotDecreaseText.tr());

        amountController.text = item.amount.toMeasure;
        totalPriceController.text =
            (item.amount * item.product.price).toMeasure;

        return;
      }

      if (newAmount <= 0) {
        orderNotifier.deleteItem(item, context, order);
      } else {
        final updatedItem = item.copyWith(amount: newAmount.toDouble());
        orderNotifier.updateItem(updatedItem, context, order: order);
      }
    }

    void updateTotalPrice(num newTotalPrice) {
      if (product.price <= 0) {
        _updateControllerText(
            totalPriceController, item.amount * product.price);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Mahsulot narxi 0, umumiy narxni o'zgartirib bo'lmaydi.")),
        );
        return;
      }
      if (newTotalPrice < 0) {
        _updateControllerText(
            totalPriceController, item.amount * product.price);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Umumiy narx manfiy bo'lishi mumkin emas.")),
        );
        return;
      }
      final newAmount = newTotalPrice / product.price;

      updateAmount(newAmount);
    }

    bool isAdmin = employee.roleName.toLowerCase() == 'admin';

    return AppStateWrapper(builder: (theme, _) {
      if (mobile) {
        return Padding(
          padding: Dis.only(lr: 16, tb: 8),
          child: MaterialButton(
            padding: Dis.all(12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () {
              showDesktopModal(
                width: 600,
                context: context,
                body: Padding(
                  padding: Dis.only(lr: 16, top: 16, bottom: 32),
                  child: OrderItemDetailScreen(
                    product: item,
                    onDeletePressed: () {
                      if (order == null) {
                        orderNotifier.deleteItem(item, context, order);
                      }

                      if (!isAdmin) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());
                        return;
                      }

                      if (OrderController.hasNegativeItem(ref,
                          savedList: order?.products ?? [], item: item)) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());

                        return;
                      }
                      orderNotifier.deleteItem(item, context, order);
                    },
                    onUpdateItemDetails: (amount, price) {
                      OrderItem kOrderItem = item;
                      kOrderItem.amount = amount;
                      kOrderItem.customPrice = price;

                      if (OrderController.hasNegativeItem(ref,
                          savedList: order?.products ?? [], item: kOrderItem)) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());

                        return;
                      } else {
                        orderNotifier.updateItem(kOrderItem, context,
                            order: order);
                      }
                    },
                  ),
                ),
              );
            },
            child: Dismissible(
              onDismissed: (_) {
                if (order == null) {
                  orderNotifier.deleteItem(item, context, order);
                }

                if (!isAdmin) {
                  ShowToast.error(context, AppLocales.doNotDecreaseText.tr());
                  return;
                }

                if (OrderController.hasNegativeItem(ref,
                    savedList: order?.products ?? [], item: item)) {
                  ShowToast.error(context, AppLocales.doNotDecreaseText.tr());

                  return;
                }
                orderNotifier.deleteItem(item, context, order);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Iconsax.trash_copy,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              direction: DismissDirection.endToStart,
              key: Key(item.placeId + item.product.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: mediumFamily,
                    ),
                  ),
                  2.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.price.priceUZS +
                            (product.measure != null
                                ? "/ ${product.measure}"
                                : ""),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: boldFamily,
                        ),
                      ),
                      Text(
                        item.amount.toMeasure +
                            (" ${product.measure != null ? product.measure! : ''}"),
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: boldFamily,
                        ),
                      ),
                    ],
                  ),
                  2.h,
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () {
                          updateAmount(item.amount + 1);
                        },
                        label: Text("1"),
                        style: ElevatedButton.styleFrom(
                          padding: Dis.only(lr: 12, tb: 8),
                          iconSize: 20,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () {
                          updateAmount(item.amount + 0.1);
                        },
                        label: Text("0.1"),
                        style: ElevatedButton.styleFrom(
                          padding: Dis.only(lr: 12, tb: 8),
                          iconSize: 20,
                        ),
                      ),
                      if (!isAdmin)
                        ElevatedButton.icon(
                          icon: Icon(Icons.remove, size: 20),
                          onPressed: () {
                            if (OrderController.hasNegativeItem(ref,
                                savedList: order?.products ?? [], item: item)) {
                              ShowToast.error(
                                  context, AppLocales.doNotDecreaseText.tr());

                              return;
                            }

                            if (item.amount >= 1) updateAmount(item.amount - 1);
                          },
                          label: Text("1"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            padding: Dis.only(lr: 12, tb: 8),
                            iconSize: 20,
                          ),
                        ),
                      if (itemIsSaved.value || isAdmin)
                        ElevatedButton.icon(
                          icon: Icon(Icons.remove, size: 20),
                          onPressed: () {
                            if (OrderController.hasNegativeItem(ref,
                                savedList: order?.products ?? [], item: item)) {
                              ShowToast.error(
                                  context, AppLocales.doNotDecreaseText.tr());

                              return;
                            }

                            if (item.amount >= 0.1) {
                              updateAmount(item.amount - 0.1);
                            }
                          },
                          label: Text("0.1"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            padding: Dis.only(lr: 12, tb: 8),
                            iconSize: 20,
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }

      return SimpleButton(
        onPressed: minimalistic
            ? () {
                showDesktopModal(
                  width: 600,
                  context: context,
                  body: OrderItemDetailScreen(
                    product: item,
                    onDeletePressed: () {
                      if (order == null) {
                        orderNotifier.deleteItem(item, context, order);
                      }

                      if (!isAdmin) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());

                        return;
                      }

                      if (OrderController.hasNegativeItem(ref,
                          savedList: order?.products ?? [], item: item)) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());

                        return;
                      }

                      orderNotifier.deleteItem(item, context, order);
                    },
                    onUpdateItemDetails: (amount, price) {
                      OrderItem kOrderItem = item;
                      kOrderItem.amount = amount;
                      kOrderItem.customPrice = price;
                      if (OrderController.hasNegativeItem(ref,
                          savedList: order?.products ?? [], item: kOrderItem)) {
                        ShowToast.error(
                            context, AppLocales.doNotDecreaseText.tr());

                        return;
                      } else {
                        orderNotifier.updateItem(
                          kOrderItem,
                          context,
                          order: order,
                        );
                      }
                    },
                  ),
                );
              }
            : null,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          margin: minimalistic ? Dis.only() : Dis.only(bottom: context.h(8)),
          padding:
              Dis.only(lr: context.w(16), tb: context.h(minimalistic ? 16 : 8)),
          decoration: BoxDecoration(
            borderRadius:
                infoView ? BorderRadius.circular(infoView ? 8 : 0) : null,
            color: infoView
                ? theme.accentColor
                : itemIsSaved.value
                    ? theme.mainColor.withOpacity(0.2)
                    : theme.white,
            border: minimalistic
                ? BorderDirectional(
                    bottom: BorderSide(
                      color: theme.secondaryTextColor,
                      width: 0.8,
                    ),
                  )
                : null,
          ),
          child: minimalistic
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: context.s(16),
                          fontFamily: boldFamily,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        spacing: context.s(8),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${item.amount.toMeasure} ${product.measure ?? ''}",
                              style: TextStyle(fontSize: context.s(16)),
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (item.amount * product.price).priceUZS,
                              style: TextStyle(fontSize: context.s(16)),
                              maxLines: 1,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppFileImage(
                          name: product.name,
                          path: product.images?.firstOrNull,
                          size: context.s(94),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: context.h(12),
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: context.s(14),
                                      fontFamily: regularFamily),
                                ),
                                if (!infoView)
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextField(
                                      controller: totalPriceController,
                                      textAlign: TextAlign.start,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: TextStyle(color: theme.textColor),
                                      cursorHeight: context.h(16),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        isDense: true,
                                        hintText: "Umumiy narx",
                                        contentPadding: Dis.only(
                                            tb: context.h(8),
                                            lr: context.w(12)),
                                        suffixIcon: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'UZS',
                                              style: TextStyle(
                                                fontSize: context.s(16),
                                                fontFamily: regularFamily,
                                              ),
                                            ),
                                          ],
                                        ),
                                        constraints:
                                            const BoxConstraints(maxWidth: 120),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: theme.mainColor),
                                        ),
                                      ),
                                      onSubmitted: (text) {
                                        final value = _tryParseNum(text);
                                        if (value != null) {
                                          updateTotalPrice(value);
                                        } else {
                                          _updateControllerText(
                                              totalPriceController,
                                              item.amount * product.price);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Noto'g'ri narx kiritildi!")),
                                          );
                                        }
                                      },
                                      onTapOutside: (_) {
                                        final value = _tryParseNum(
                                            totalPriceController.text);
                                        final currentDisplayedPrice =
                                            item.amount * product.price;

                                        if (value != null &&
                                            _formatDecimal(value) !=
                                                _formatDecimal(
                                                    currentDisplayedPrice)) {
                                          updateTotalPrice(value);
                                        } else if (value == null &&
                                            totalPriceController
                                                .text.isNotEmpty) {
                                          _updateControllerText(
                                              totalPriceController,
                                              currentDisplayedPrice);
                                        } else if (value != null &&
                                            _formatDecimal(value) ==
                                                _formatDecimal(
                                                    currentDisplayedPrice)) {
                                          _updateControllerText(
                                              totalPriceController,
                                              currentDisplayedPrice);
                                        }
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (!infoView &&
                                          product.size != null &&
                                          product.size!.isNotEmpty)
                                        Text(product.size ?? '',
                                            style: TextStyle(
                                                color:
                                                    theme.secondaryTextColor)),
                                      if (!infoView &&
                                          product.size != null &&
                                          product.size!.isNotEmpty)
                                        SizedBox(width: 16),
                                      if (!infoView)
                                        SizedBox(
                                          width: context.w(120),
                                          child: TextField(
                                            controller: totalPriceController,
                                            textAlign: TextAlign.center,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            style: TextStyle(
                                                color: theme.textColor),
                                            cursorHeight: context.h(16),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: "Umumiy narx",
                                              contentPadding: Dis.only(
                                                  tb: context.h(8),
                                                  lr: context.w(4)),
                                              constraints: const BoxConstraints(
                                                  maxWidth: 120),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(24)),
                                                borderSide: BorderSide(
                                                    color: theme.mainColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(24)),
                                                borderSide: BorderSide(
                                                    color: theme.mainColor,
                                                    width: 2.0),
                                              ),
                                            ),
                                            onSubmitted: (text) {
                                              final value = _tryParseNum(text);
                                              if (value != null) {
                                                updateTotalPrice(value);
                                              } else {
                                                _updateControllerText(
                                                    totalPriceController,
                                                    item.amount *
                                                        product.price);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Noto'g'ri narx kiritildi!")),
                                                );
                                              }
                                            },
                                            onTapOutside: (_) {
                                              final value = _tryParseNum(
                                                  totalPriceController.text);
                                              final currentDisplayedPrice =
                                                  item.amount * product.price;

                                              if (value != null &&
                                                  _formatDecimal(value) !=
                                                      _formatDecimal(
                                                          currentDisplayedPrice)) {
                                                updateTotalPrice(value);
                                              } else if (value == null &&
                                                  totalPriceController
                                                      .text.isNotEmpty) {
                                                _updateControllerText(
                                                    totalPriceController,
                                                    currentDisplayedPrice);
                                              } else if (value != null &&
                                                  _formatDecimal(value) ==
                                                      _formatDecimal(
                                                          currentDisplayedPrice)) {
                                                _updateControllerText(
                                                    totalPriceController,
                                                    currentDisplayedPrice);
                                              }
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        ),
                                      if (infoView)
                                        Text(
                                          "${_formatDecimal(item.amount)} × ${product.price.priceUZS}",
                                          style: TextStyle(
                                              fontFamily: boldFamily,
                                              fontSize: context.s(16)),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.h,
                    if (infoView)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppLocales.total.tr()}:",
                            style: TextStyle(fontSize: context.s(18)),
                          ),
                          Text(
                            (item.amount * item.product.price).priceUZS,
                            style: TextStyle(
                                fontSize: context.s(18),
                                fontFamily: boldFamily),
                          ),
                        ],
                      ),
                    if (!infoView)
                      Row(
                        spacing: context.w(12),
                        children: [
                          if (isAdmin)
                            SimpleButton(
                              onPressed: () {
                                if (OrderController.hasNegativeItem(ref,
                                    savedList: order?.products ?? [],
                                    item: item)) {
                                  ShowToast.error(context,
                                      AppLocales.doNotDecreaseText.tr());

                                  return;
                                }
                                orderNotifier.deleteItem(item, context, order);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(color: Colors.red),
                                ),
                                height: context.s(40),
                                width: context.s(40),
                                child: Center(
                                  child: Icon(
                                    Iconsax.trash_copy,
                                    color: Colors.red,
                                    size: context.s(24),
                                  ),
                                ),
                              ),
                            ),
                          if (isAdmin || itemIsSaved.value)
                            SimpleButton(
                              onPressed: () {
                                if (OrderController.hasNegativeItem(ref,
                                    savedList: order?.products ?? [],
                                    item: item)) {
                                  ShowToast.error(context,
                                      AppLocales.doNotDecreaseText.tr());

                                  return;
                                }
                                updateAmount(item.amount - 1);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: theme.scaffoldBgColor,
                                  border: Border.all(
                                    color: theme.scaffoldBgColor,
                                  ),
                                ),
                                height: context.s(40),
                                width: context.s(40),
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.black,
                                    size: context.s(24),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: TextStyle(color: theme.textColor),
                              cursorHeight: context.h(16),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                isDense: true,
                                hintText: "Miqdor",
                                contentPadding: Dis.only(
                                    tb: context.h(8), lr: context.w(12)),
                                suffixIcon: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.measure ?? '',
                                      style: TextStyle(
                                        fontSize: context.s(16),
                                        fontFamily: regularFamily,
                                      ),
                                    ),
                                  ],
                                ),
                                constraints:
                                    const BoxConstraints(maxWidth: 120),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: theme.mainColor),
                                ),
                              ),
                              onSubmitted: (text) {
                                final value = _tryParseNum(text);
                                if (value != null) {
                                  updateAmount(value);
                                } else {
                                  _updateControllerText(
                                      amountController, item.amount);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Noto'g'ri miqdor kiritildi!")),
                                  );
                                }
                              },
                              onTapOutside: (_) {
                                final value =
                                    _tryParseNum(amountController.text);

                                if (value != null &&
                                    _formatDecimal(value) !=
                                        _formatDecimal(item.amount)) {
                                  updateAmount(value);
                                } else if (value == null &&
                                    amountController.text.isNotEmpty) {
                                  _updateControllerText(
                                      amountController, item.amount);
                                } else if (value != null &&
                                    _formatDecimal(value) ==
                                        _formatDecimal(item.amount)) {
                                  _updateControllerText(
                                      amountController, item.amount);
                                }
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          SimpleButton(
                            onPressed: () {
                              updateAmount(item.amount + 1);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: theme.mainColor,
                                border: Border.all(color: theme.mainColor),
                              ),
                              height: context.s(40),
                              width: context.s(40),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: context.s(24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Container(
                      margin: Dis.only(top: context.h(16)),
                      height: 1,
                      width: double.infinity,
                      color: theme.accentColor,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
