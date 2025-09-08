import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/ui/pages/places_pages/place_children_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../controllers/place_controller.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import 'add_place.dart';

class PlacesPage extends HookConsumerWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const PlacesPage(this.floatingActionButton, {super.key, required this.appbar});

  @override
  Widget build(BuildContext context, ref) {
    final filteredCategories = useState([]);
    final searchController = useTextEditingController();
    final controller = useScrollController();
    final pinned = useState(false);

    useEffect(() {
      controller.addListener(() {
        pinned.value = controller.offset > 50;
      });
      return () {};
    });

    return AppStateWrapper(
      builder: (theme, state) {
        return state.whenProviderData(
          provider: placesProvider,
          builder: (categories) {
            categories as List<Place>;

            return Scaffold(
              floatingActionButton: WebButton(
                onPressed: () {
                  showDesktopModal(context: context, body: AddPlace());
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
                    child: Icon(Iconsax.add_copy, color: Colors.white, size: focused ? 40 : 32),
                  ),
                ),
              ),
              body: categories.isEmpty
                  ? AppEmptyWidget()
                  : CustomScrollView(
                      controller: controller,
                      slivers: [
                        SliverPinnedHeader(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.scaffoldBgColor,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 2),
                                  color: !pinned.value
                                      ? Colors.transparent
                                      : theme.secondaryTextColor.withValues(alpha: 0.5),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            padding: Dis.only(lr: context.w(24), tb: context.h(24)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: context.w(16),
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocales.places.tr(),
                                    style: TextStyle(
                                      fontSize: context.s(24),
                                      fontFamily: mediumFamily,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                0.w,
                                SizedBox(
                                  width: context.w(400),
                                  child: AppTextField(
                                    prefixIcon: Icon(Iconsax.search_normal_copy),
                                    title: AppLocales.search.tr(),
                                    controller: searchController,
                                    onChanged: (str) {
                                      filteredCategories.value = categories.where((ctg) {
                                        return (ctg.name.toLowerCase().contains(str.toLowerCase()));
                                      }).toList();
                                    },
                                    theme: theme,
                                    fillColor: Colors.white,
                                    // useBorder: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (filteredCategories.value.isEmpty && searchController.text.trim().isNotEmpty)
                          SliverPadding(
                            padding: 80.all,
                            sliver: SliverToBoxAdapter(
                              child: Center(child: AppEmptyWidget()),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: filteredCategories.value.isNotEmpty
                                  ? filteredCategories.value.length
                                  : categories.length,
                              (context, index) {
                                Place category = (filteredCategories.value.isNotEmpty
                                    ? filteredCategories.value
                                    : categories)[index];
                                /*  return AppListTile(
                          title: category.name,
                          theme: theme,
                          onEdit: () {
                            showDesktopModal(context: context, body: AddPlace(editCategory: category));
                          },
                          trailingIcon: Ionicons.add_circle_outline,
                          onDelete: () {
                            PlaceController placeController = PlaceController(context: context, state: state);
                            placeController.delete(category.id);
                          },
                          onPressed: () {
                            showDesktopModal(context: context, body: PlaceChildrenPage(category));
                          },
                        );*/

                                return WebButton(
                                  onPressed: () {
                                    showDesktopModal(context: context, body: PlaceChildrenPage(category));
                                  },
                                  builder: (focused) => Container(
                                    margin: Dis.only(lr: context.w(24), tb: 8),
                                    padding: 12.all,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: focused ? theme.mainColor.withValues(alpha: 0.1) : Colors.white,
                                    ),
                                    child: Row(
                                      spacing: 16,
                                      children: [
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: theme.scaffoldBgColor,
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
                                            showDesktopModal(context: context, body: AddPlace(editCategory: category));
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
                                            PlaceController placeController =
                                                PlaceController(context: context, state: state);
                                            placeController.delete(category.id, ref: ref);
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
