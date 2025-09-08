import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/category_controller.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/providers/printer_devices_provider.dart';
import 'package:biznex/src/ui/pages/category_pages/category_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:printing/printing.dart';

class CategoryCard extends AppStatelessWidget {
  final Category category;
  final int? count;

  const CategoryCard(this.category, {super.key, this.count});

  @override
  Widget builder(BuildContext context, AppColors theme, WidgetRef ref, AppModel state) {
    return Container(
      padding: Dis.only(left: 12, right: 12, tb: 12),
      margin: Dis.only(tb: 8, lr: context.w(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.white,
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.scaffoldBgColor,
              ),
              child: category.icon == null
                  ? Center(
                      child: Text(
                        category.name.initials,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: boldFamily,
                        ),
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        category.icon ?? "",
                      ),
                    )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: mediumFamily,
                  ),
                ),
                Text(
                  "${'productCount'.tr()}: $count",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: regularFamily,
                    color: theme.secondaryTextColor,
                  ),
                )
              ],
            ),
          ),
          SimpleButton(
            onPressed: () {
              CategoryPage.onEditCategory(context, category);
            },
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.scaffoldBgColor,
              ),
              child: Icon(
                Iconsax.edit_copy,
                color: theme.secondaryTextColor,
                size: 20,
              ),
            ),
          ),
          SimpleButton(
            onPressed: () {
              CategoryPage.onDeleteCategory(context, category, state);
            },
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.scaffoldBgColor,
              ),
              child: Icon(
                Iconsax.trash_copy,
                color: theme.red,
                size: 20,
              ),
            ),
          ),
          state.whenProviderData(
            provider: printerDevicesProvider,
            builder: (devices) {
              devices as List<Printer>;
              return CustomPopupMenu(
                theme: theme,
                children: [
                  for (final item in devices)
                    CustomPopupItem(
                      icon: Ionicons.print_outline,
                      title: item.name,
                      onPressed: () {
                        CategoryController cController = CategoryController(context: context, state: state);
                        Category cCategory = category;
                        cCategory.printerParams = {
                          "name": item.name,
                          "model": item.model,
                          "url": item.url,
                        };

                        cController.forceUpdate(cCategory, cCategory.id);
                      },
                    ),
                ],
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.scaffoldBgColor,
                  ),
                  child: Icon(
                    Iconsax.printer_copy,
                    color: theme.secondaryTextColor,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
