import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_controller.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/screens/products_screens/product_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';

class ProductCardScreen extends ConsumerWidget {
  final AppColors theme;
  final Product product;
  final AppModel state;
  final void Function() onPressedEdit;

  const ProductCardScreen({
    super.key,
    required this.theme,
    required this.state,
    required this.product,
    required this.onPressedEdit,
  });

  @override
  Widget build(BuildContext context, ref) {
    return WebButton(
      onPressed: () {
        // addOrUpdateOrderItem(ref, OrderItem(product: product, amount: 1, placeId: ''));
        // ShowToast.success(context, AppLocales.productAddedToSet.tr());
      },
      builder: (focused) => AnimatedContainer(
        duration: theme.animationDuration,
        margin: 8.tb,
        padding: Dis.only(lr: 16, tb: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: focused ? theme.mainColor : theme.accentColor),
          color: focused ? theme.mainColor.withOpacity(0.1) : theme.accentColor,
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
                    image: (product.images != null && product.images!.isNotEmpty)
                        ? DecorationImage(image: FileImage(File(product.images!.first)), fit: BoxFit.cover)
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
              child: Center(child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ),
            Expanded(flex: 1, child: Center(child: Text(product.price.priceUZS))),
            if (product.amount < 0)
              Expanded(flex: 1, child: Center(child: Text("${AppLocales.end.tr()}")))
            else
              Expanded(flex: 1, child: Center(child: Text("${product.amount.price} ${product.measure ?? ''}"))),
            Expanded(flex: 1, child: Center(child: Text(product.size ?? ' - '))),
            Expanded(flex: 1, child: Center(child: Text(product.barcode ?? ' - '))),
            Expanded(flex: 1, child: Center(child: Text(product.tagnumber ?? ' - '))),
            Expanded(
              flex: 1,
              child: Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomPopupMenu(
                    theme: theme,
                    children: [
                      CustomPopupItem(
                        title: AppLocales.edit.tr(),
                        icon: Icons.edit,
                        onPressed: () => onPressedEdit(),
                      ),
                      CustomPopupItem(
                        title: AppLocales.viewAll.tr(),
                        icon: Icons.remove_red_eye_outlined,
                        onPressed: () async {
                          showDesktopModal(
                            width: MediaQuery.of(context).size.width * 0.4,
                            context: context,
                            body: ProductScreen(product),
                          );
                        },
                      ),

                      CustomPopupItem(
                        title: product.amount == -1 ? AppLocales.enableSell.tr() : AppLocales.disableSell.tr(),
                        icon: product.amount == -1 ? Icons.done : Icons.close,
                        onPressed: () {
                          ProductController pc = ProductController(context: context, state: state);
                          Product pr = product;
                          if (product.amount != -1) {
                            pr.amount = -1;
                            pc.update(pr, pr.id);
                          } else {
                            pr.amount = 1;
                            pc.update(pr, pr.id);
                          }
                        },
                      ),
                      // CustomPopupItem(title: AppLocales.add.tr(), icon: Icons.add),
                      // CustomPopupItem(title: AppLocales.monitoring.tr(), icon: Icons.bar_chart),
                      CustomPopupItem(
                        title: AppLocales.delete.tr(),
                        icon: Icons.delete_outline,
                        onPressed: () => ProductController.onDeleteProduct(context: context, state: state, id: product.id),
                      ),
                    ],
                    child: IgnorePointer(
                      ignoring: true,
                      child: IconButton.outlined(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert),
                        color: theme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
