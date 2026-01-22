import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/screens/products_screens/product_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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

class ProductCardNew extends ConsumerWidget {
  final Product product;
  final AppColors colors;
  final void Function() onPressed;
  final bool minimalistic;
  final bool have;
  final String? placeId;

  const ProductCardNew({
    super.key,
    this.minimalistic = false,
    this.have = false,
    required this.product,
    required this.colors,
    required this.onPressed,
    this.placeId,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mobile = getDeviceType(context) == DeviceType.mobile;
    final amountText = ref
        .watch(orderSetProvider.notifier)
        .getThisProduct(placeId, product.id);

    return SimpleButton(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.all(context.s(8)),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(context.s(12)),
          border: have
              ? Border.all(
                  color: AppColors(isDark: false).mainColor,
                )
              : null,
        ),
        child: Column(
          spacing: context.h(8),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ProductImageWrapper(
                    id: product.id,
                    onUrlHasDone: (url) {
                      if (url != null) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:
                            Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Center(
                            child: Text(
                              product.name.initials,
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: boldFamily,
                              ),
                            ),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url ?? '',
                          errorBuilder: (_, __, ___) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),

                              child: Center(
                                child: Text(
                                  product.name.initials,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: boldFamily,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: context.getSize(4, t: 8, d: 8).all,
                      margin: context.getSize(4, t: 8, d: 8).all,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withValues(alpha: 0.36),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: context.getSize(4, t: 8, d: 8),
                        children: [
                          Icon(
                            Iconsax.reserve_copy,
                            color: Colors.white,
                            size: context.getSize(18, t: 20, d: 24),
                          ),
                          Text(
                            "${product.amount.toMeasure} ${product.measure ?? ''}"
                                .toLowerCase(),
                            style: TextStyle(
                              fontSize: context.getSize(14, t: 16, d: 16),
                              fontFamily: boldFamily,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  product.name.capitalize,
                  style: TextStyle(
                    fontSize: context.getSize(14, t: 16, d: 16),
                    fontFamily: boldFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                12.w,
                Text(
                  product.price.priceUZS,
                  style: TextStyle(
                    fontSize: context.getSize(13, t: 16, d: 16),
                    fontFamily: boldFamily,
                    color: colors.mainColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
