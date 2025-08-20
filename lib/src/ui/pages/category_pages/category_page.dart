import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/category_controller.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/ui/screens/category_screens/add_category_screen.dart';
import 'package:biznex/src/ui/screens/category_screens/category_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../providers/products_provider.dart';
import 'package:biznex/src/ui/screens/category_screens/category_subcategories.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class CategoryPage extends HookConsumerWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const CategoryPage(this.floatingActionButton, {super.key, required this.appbar});

  static void onShowSubcategories(BuildContext context, Category category) {
    showDesktopModal(
      width: MediaQuery.of(context).size.width * 0.8,
      context: context,
      body: CategorySubcategories(category: category),
    );
  }

  static void onAddSubcategory(BuildContext context, Category category) {
    showDesktopModal(
      context: context,
      body: AddCategoryScreen(addSubcategoryTo: category),
    );
  }

  static void onEditCategory(BuildContext context, Category category) {
    showDesktopModal(
      context: context,
      body: AddCategoryScreen(editCategory: category),
    );
  }

  static void onDeleteCategory(BuildContext context, Category category, AppModel state) {
    CategoryController controller = CategoryController(context: context, state: state);
    controller.delete(category.id);
  }

  static void onAddProduct(BuildContext context, Category category) {
    showDesktopModal(
      context: context,
      body: AppEmptyWidget(),
    );
  }

  static void onShowProducts(BuildContext context, Category category) {
    showDesktopModal(
      context: context,
      body: AppEmptyWidget(),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final searchController = useTextEditingController();
    final controller = useScrollController();
    final list = useState(<Category>[]);
    final providerListener = ref.watch(productsProvider).value ?? [];
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
          provider: categoryProvider,
          builder: (categories) {
            categories as List<Category>;

            return Scaffold(
              floatingActionButton: WebButton(
                onPressed: () {
                  showDesktopModal(context: context, body: AddCategoryScreen());
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
              body: CustomScrollView(
                controller: controller,
                slivers: [
                  SliverPinnedHeader(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBgColor,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 2),
                            color: !pinned.value ? Colors.transparent : theme.secondaryTextColor.withValues(alpha: 0.5),
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
                              AppLocales.categories.tr(),
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
                              onChanged: (_) {
                                list.value = categories.where((el) {
                                  return el.name.trim().toLowerCase().contains(searchController.text.trim().toLowerCase());
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
                  if (list.value.isEmpty && searchController.text.trim().isNotEmpty)
                    SliverPadding(
                      padding: 80.all,
                      sliver: SliverToBoxAdapter(
                        child: Center(child: AppEmptyWidget()),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: searchController.text.trim().isEmpty ? categories.length : list.value.length,
                      (context, index) {
                        final ctg = searchController.text.trim().isEmpty ? categories[index] : list.value[index];
                        return CategoryCard(ctg, count: providerListener.where((el) => ctg.id == el.category?.id).length);
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
