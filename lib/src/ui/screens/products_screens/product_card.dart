import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/screens/products_screens/product_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/extensions/device_type.dart';

class ProductCard extends HookConsumerWidget {
  final Product product;
  final bool miniMode;

  const ProductCard(this.product, {super.key, this.miniMode = false});

  @override
  Widget build(BuildContext context, ref) {
    final orderNotifier = ref.read(orderSetProvider.notifier);
    return AppStateWrapper(builder: (theme, state) {
      return WebButton(
        onPressed: () {
          // orderNotifier.addItem(OrderItem(product: product, amount: amount, placeId: placeId))
          ShowToast.success(context, AppLocales.productAddedToSet.tr());
        },
        builder: (focused) => AnimatedContainer(
          duration: theme.animationDuration,
          margin: 8.tb,
          padding: Dis.only(lr: 16, tb: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: focused ? theme.mainColor : theme.accentColor),
            color:
                focused ? theme.mainColor.withOpacity(0.1) : theme.accentColor,
          ),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.scaffoldBgColor,
                      image:
                          (product.images != null && product.images!.isNotEmpty)
                              ? DecorationImage(
                                  image: FileImage(File(product.images!.first)),
                                  fit: BoxFit.cover)
                              : null,
                    ),
                    child: !(product.images == null || product.images!.isEmpty)
                        ? null
                        : Center(
                            child: Text(
                              product.name.trim()[0],
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: 24,
                                fontFamily: boldFamily,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                    child: Text(product.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
              ),
              Expanded(
                  flex: 1, child: Center(child: Text(product.price.priceUZS))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                          "${product.amount.price} ${product.measure ?? ''}"))),
              Expanded(
                  flex: 1, child: Center(child: Text(product.size ?? ' - '))),
              if (!miniMode)
                Expanded(
                    flex: 1,
                    child: Center(child: Text(product.barcode ?? ' - '))),
              if (!miniMode)
                Expanded(
                    flex: 1,
                    child: Center(child: Text(product.tagnumber ?? ' - '))),
              if (!miniMode)
                Expanded(
                  flex: 1,
                  child: Row(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton.outlined(
                        onPressed: () {
                          showDesktopModal(
                            width: MediaQuery.of(context).size.width * 0.4,
                            context: context,
                            body: ProductScreen(product),
                          );
                        },
                        icon: Icon(Icons.visibility_outlined),
                        color: theme.textColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class ProductCardNew extends StatelessWidget {
  final Product product;
  final AppColors colors;
  final void Function() onPressed;
  final bool minimalistic;
  final bool have;

  const ProductCardNew({
    super.key,
    this.minimalistic = false,
    this.have = false,
    required this.product,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = getDeviceType(context) == DeviceType.mobile;

    return SimpleButton(
      onPressed: onPressed,
      child: Container(
        padding: minimalistic ? null : EdgeInsets.all(context.s(8)),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(context.s(12)),
          border: have
              ? Border.all(
                  color: AppColors(isDark: false).mainColor,
                )
              : null,
        ),
        child: minimalistic
            ? Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: !mobile
                          ? Dis.only(top: context.s(28))
                          : const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: context.s(mobile ? 16 : 20),
                          fontFamily: boldFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.mainColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(context.s(12)),
                          bottomLeft: Radius.circular(context.s(12)),
                        ),
                      ),
                      padding: Dis.only(lr: context.w(12), tb: context.h(8)),
                      child: Text(
                        product.price.priceUZS,
                        style: TextStyle(
                          fontSize: context.s(14),
                          color: Colors.white,
                          fontFamily: mediumFamily,
                        ),
                      ),
                    ),
                  ),
                  if (!mobile)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: product.amount == 0
                              ? colors.red
                              : colors.secondaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(context.s(12)),
                            bottomRight: Radius.circular(context.s(12)),
                          ),
                        ),
                        padding: Dis.only(lr: context.w(12), tb: context.h(8)),
                        child: Text(
                          product.amount == 0
                              ? AppLocales.productEnded.tr()
                              : "${product.amount.toMeasure} ${product.measure ?? ''}",
                          style: TextStyle(
                            fontSize: context.s(14),
                            color: product.amount == 0
                                ? colors.white
                                : Colors.black,
                            fontFamily: mediumFamily,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                spacing: context.h(8),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (minimalistic)
                    ...[]
                  else ...[
                    Expanded(
                      child: Stack(
                        children: [
                          AppFileImage(
                            name: product.name,
                            path: product.images?.firstOrNull,
                            color: colors.scaffoldBgColor,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: context.s(8).all,
                              margin: context.s(8).all,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withValues(alpha: 0.36),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: context.w(8),
                                children: [
                                  Icon(Iconsax.reserve_copy,
                                      color: Colors.white, size: context.s(24)),
                                  Text(
                                    "${product.amount.toMeasure} ${product.measure ?? ''}",
                                    style: TextStyle(
                                      fontSize: context.s(16),
                                      fontFamily: mediumFamily,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: context.s(mobile ? 16 : 20),
                              fontFamily: mediumFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        12.w,
                        Text(
                          product.price.priceUZS,
                          style: TextStyle(
                            fontSize: context.s(mobile ? 12 : 16),
                            fontFamily: mediumFamily,
                            color: colors.mainColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    if (product.description != null &&
                        (product.description ?? '').isNotEmpty)
                      Text(
                        product.description ?? '',
                        style: TextStyle(
                          fontSize: context.s(12),
                          fontFamily: regularFamily,
                          color: colors.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Row(
                      spacing: context.w(8),
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.scaffoldBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: context.s(8).all,
                            child: Row(
                              spacing: context.w(4),
                              children: [
                                Icon(Icons.numbers,
                                    size: context.s(18), color: Colors.black),
                                Expanded(
                                  child: Text(
                                    product.barcode.toString(),
                                    style: TextStyle(
                                        fontFamily: mediumFamily,
                                        color: Colors.black,
                                        fontSize: context.s(14)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.scaffoldBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: context.s(8).all,
                          child: Row(
                            spacing: context.w(4),
                            children: [
                              Icon(Ionicons.receipt_outline,
                                  size: context.s(18), color: Colors.black),
                              Text(
                                product.tagnumber.toString(),
                                style: TextStyle(
                                  fontFamily: mediumFamily,
                                  color: Colors.black,
                                  fontSize: context.s(14),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
      ),
    );
  }
}
