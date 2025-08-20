import 'package:biznex/src/controllers/category_controller.dart';
import 'package:biznex/src/core/constants/app_locales.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddCategoryScreen extends HookWidget {
  final Category? editCategory;
  final Category? addSubcategoryTo;

  const AddCategoryScreen({super.key, this.editCategory, this.addSubcategoryTo});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: editCategory?.name);
    return AppStateWrapper(
      builder: (theme, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppText.$18Bold(AppLocales.categoryNameLabel.tr(), padding: 8.bottom),
              AppTextField(
                title: AppLocales.categoryNameHint.tr(),
                controller: nameController,
                theme: theme,
              ),
              24.h,
              ConfirmCancelButton(
                cancelColor: Colors.white,
                onConfirm: () async {
                  CategoryController controller = CategoryController(context: context, state: state);
                  if (editCategory == null) {
                    Category category = Category(name: nameController.text, parentId: addSubcategoryTo?.id);
                    controller.create(category);
                    return;
                  }

                  Category category = editCategory!;
                  category.name = nameController.text;
                  controller.update(category, category.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
