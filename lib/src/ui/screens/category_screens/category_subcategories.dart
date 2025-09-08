import 'dart:developer';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/ui/screens/category_screens/add_category_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import '../../../../biznex.dart';
import 'category_card.dart';

class CategorySubcategories extends AppStatelessWidget {
  final Category category;

  const CategorySubcategories({super.key, required this.category});

  @override
  Widget builder(context, theme, ref, state) {
    return state.whenProviderData(
      provider: allCategoryProvider,
      builder: (categories) {
        categories as List<Category>;
        final categorySubcategories = categories.where((ctg) {
          return ctg.parentId == category.id;
        }).toList();
        return Column(
          children: [
            if (categorySubcategories.isEmpty) Expanded(child: AppEmptyWidget()),
            Expanded(
              child: ListView.builder(
                itemCount: (categorySubcategories).length,
                padding: Dis.only(lr: 24),
                itemBuilder: (context, index) {
                  final subcategory = (categorySubcategories)[index];
                  return CategoryCard(subcategory);
                },
              ),
            ),
            ConfirmCancelButton(
              onConfirm: () {
                showDesktopModal(
                  context: context,
                  body: AddCategoryScreen(addSubcategoryTo: category),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
