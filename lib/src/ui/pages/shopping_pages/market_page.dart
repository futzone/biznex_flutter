import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/product_models/shopping_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../../biznex.dart';
import '../../screens/shopping_screens/add_shopping_screen.dart';

class MarketPage extends HookConsumerWidget {
  final AppColors theme;
  final List<Shopping> shoppingList;

  const MarketPage(this.theme, {super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: WebButton(
        onPressed: () {
          showDesktopModal(context: context, body: AddShoppingScreen());
        },
        builder: (focused) => AnimatedContainer(
          duration: theme.animationDuration,
          height: focused ? 80 : 64,
          width: focused ? 80 : 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xff5CF6A9), width: 2),
            color: theme.mainColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(3, 3),
              )
            ],
          ),
          child: Center(
            child: Icon(Iconsax.add_copy,
                color: Colors.white, size: focused ? 40 : 32),
          ),
        ),
      ),
      body: shoppingList.isEmpty
          ? AppEmptyWidget()
          : CustomScrollView(
              slivers: [
                SliverPinnedHeader(
                  child: Container(
                    margin: Dis.only(lr: context.s(24)),
                    padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.20)),
                      color: theme.scaffoldBgColor,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text("productCount".tr()),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(AppLocales.price.tr()),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Center(child: Text(AppLocales.note.tr())),
                        ),
                        Expanded(
                          flex: 2,
                          child:
                              Center(child: Text(AppLocales.createdDate.tr())),
                        ),
                        Expanded(
                          flex: 2,
                          child:
                              Center(child: Text(AppLocales.updatedDate.tr())),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: shoppingList.length,
                    (context, index) {
                      final shopping = shoppingList[index];
                      return Container(
                        margin: Dis.only(lr: context.s(24)),
                        padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: theme.scaffoldBgColor)),
                          color: theme.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(shopping.items.length.toString()),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  shopping.totalPrice.priceUZS,
                                  // textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Center(
                                child: Text(
                                  shopping.note ?? "-",
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  DateFormat("yyyy.MM.dd")
                                      .format(shopping.createdDate),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  DateFormat("yyyy.MM.dd  HH:mm")
                                      .format(shopping.updatedDate),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SimpleButton(
                                  onPressed: () {
                                    showDesktopModal(
                                        context: context,
                                        body: AddShoppingScreen(
                                            shopping: shopping));
                                  },
                                  child: Container(
                                    height: context.s(36),
                                    width: context.s(36),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: theme.scaffoldBgColor,
                                    ),
                                    padding: Dis.all(context.s(8)),
                                    child: Icon(
                                      Iconsax.edit_copy,
                                      size: context.s(20),
                                      color: theme.secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(padding: Dis.only(tb: 100)),
              ],
            ),
    );
  }
}
