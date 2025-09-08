import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/place_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/ui/pages/places_pages/add_place.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PlaceChildrenPage extends ConsumerWidget {
  final Place place;

  const PlaceChildrenPage(this.place, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(builder: (theme, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.$18Bold(place.name),
              AppPrimaryButton(
                padding: Dis.only(tb: 6, lr: 16),
                theme: theme,
                onPressed: () {
                  showDesktopModal(
                    context: context,
                    body: AddPlace(addSubcategoryTo: place),
                  );
                },
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white),
                    Text(AppLocales.addPlace.tr(), style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: place.children == null || place.children!.isEmpty
                ? AppEmptyWidget()
                : ListView.builder(
                    itemCount: place.children == null ? 0 : place.children?.length,
                    itemBuilder: (context, index) {
                      final category = place.children![index];
                      return Container(
                        margin: Dis.only(tb: 8),
                        padding: 12.all,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.scaffoldBgColor,
                        ),
                        child: Row(
                          spacing: 16,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.white,
                              ),
                              padding: 8.all,
                              child: SvgPicture.asset(
                                "assets/icons/dining-table.svg",
                                color: theme.secondaryTextColor,
                              ),
                            ),
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
                                    "${AppLocales.places.tr()}: ${category.children == null ? 0 : category.children?.length}",
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
                                showDesktopModal(
                                  context: context,
                                  body: AddPlace(
                                    editCategory: category,
                                    addSubcategoryTo: place,
                                  ),
                                );
                              },
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.white,
                                ),
                                child: Icon(
                                  Iconsax.edit_copy,
                                  color: theme.secondaryTextColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            SimpleButton(
                              onPressed: () async {
                                PlaceController placeController = PlaceController(context: context, state: state);
                                await placeController.delete(category.id, father: place, ref: ref).then((_) {});
                              },
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.white,
                                ),
                                child: Icon(
                                  Iconsax.trash_copy,
                                  color: theme.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
