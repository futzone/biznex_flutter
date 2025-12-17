import 'package:biznex/src/controllers/place_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/constants/app_locales.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/utils/product_utils.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddPlace extends HookWidget {
  final Place? editCategory;
  final Place? addSubcategoryTo;

  const AddPlace({super.key, this.editCategory, this.addSubcategoryTo});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: editCategory?.name);
    final percentNull = useState(editCategory?.percentNull ?? false);
    final numberController = useTextEditingController();
    final priceController =
        useTextEditingController(text: editCategory?.price?.toMeasure);
    final percentController =
        useTextEditingController(text: editCategory?.percent?.toMeasure);
    return AppStateWrapper(
      builder: (theme, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppText.$18Bold(AppLocales.placeNameLabel.tr(),
                  padding: 8.bottom),
              AppTextField(
                title: AppLocales.placeNameHint.tr(),
                controller: nameController,
                theme: theme,
              ),
              24.h,
              AppText.$18Bold(AppLocales.placePrice.tr(), padding: 8.bottom),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: AppTextField(
                      title: AppLocales.placePriceHint.tr(),
                      controller: priceController,
                      theme: theme,
                      textInputType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      title: AppLocales.enterPlacePercent.tr(),
                      controller: percentController,
                      theme: theme,
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              24.h,
              AppText.$18Bold(AppLocales.placesCount.tr(), padding: 8.bottom),
              AppTextField(
                title: AppLocales.placesCount.tr(),
                controller: numberController,
                theme: theme,
                textInputType: TextInputType.number,
              ),
              24.h,
              SwitchListTile(
                title: AppText.$18Bold(AppLocales.percentIsNullLabel.tr(),
                    padding: 8.bottom),
                value: percentNull.value,
                onChanged: (v) => percentNull.value = v,
              ),
              24.h,
              ConfirmCancelButton(
                cancelColor: Colors.white,
                onConfirm: () async {
                  final count = int.tryParse(numberController.text.trim());
                  final price = double.tryParse(priceController.text.trim());
                  final percent =
                      double.tryParse(percentController.text.trim());
                  PlaceController controller =
                      PlaceController(context: context, state: state);
                  if (nameController.text.trim().isEmpty) {
                    return controller
                        .error(AppLocales.placeNameInputError.tr());
                  }

                  if (addSubcategoryTo != null && editCategory == null) {
                    Place place = addSubcategoryTo!;
                    place.children ??= [];
                    place.percentNull = percentNull.value;

                    if (count == null) {
                      place.children!.add(
                        Place(
                          price: price,
                          percent: percent,
                          name: nameController.text.tr(),
                          id: ProductUtils.generateID,
                        ),
                      );
                    } else {
                      for (int i = 1; i <= count; i++) {
                        place.children!.add(
                          Place(
                            price: price,
                            percent: percent,
                            name: "$i - ${nameController.text.tr()}",
                            id: ProductUtils.generateID,
                          ),
                        );
                      }
                    }
                    await controller
                        .update(place, place.id)
                        .then((_) => AppRouter.close(context));
                    return;
                  }

                  if (addSubcategoryTo != null && editCategory != null) {
                    Place father = addSubcategoryTo!;
                    Place place = editCategory!;
                    place.name = nameController.text.trim();
                    place.percentNull = percentNull.value;
                    place.price = price;
                    place.percent = percent;
                    father.children ??= [];
                    father.children = [
                      place,
                      ...father.children!
                          .where((el) => el.id != editCategory?.id),
                    ];

                    controller.update(father, father.id);
                    return;
                  }

                  if (editCategory == null) {
                    if (count == null) {
                      Place category = Place(
                        name: nameController.text,
                        percentNull: percentNull.value,
                        father: addSubcategoryTo,
                        price: price,
                        percent: percent,
                      );
                      controller.create(category);
                    } else {
                      for (int i = 1; i <= count; i++) {
                        Place category = Place(
                          name: "$i - ${nameController.text}",
                          percentNull: percentNull.value,
                          father: addSubcategoryTo,
                          price: price,
                          percent: percent,
                        );
                        controller.create(category, multiple: true);
                      }
                    }
                    return;
                  }

                  Place category = editCategory!;
                  category.name = nameController.text;
                  category.price = price;
                  category.percent = percent;
                  category.percentNull = percentNull.value;
                  await controller.update(category, category.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
