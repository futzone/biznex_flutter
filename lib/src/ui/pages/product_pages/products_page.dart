import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/pages/product_pages/add_product_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../screens/products_screens/product_card.dart';

class ProductsPage extends HookConsumerWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const ProductsPage(this.floatingActionButton, {super.key, required this.appbar});

  @override
  Widget build(BuildContext context, ref) {
    final isAddProduct = useState(false);
    final isUpdateProduct = useState(false);
    final currentProduct = useState<Product?>(null);
    final searchController = useTextEditingController();
    final searchResultList = useState(<Product>[]);
    final providerListener = ref.watch(productsProvider).value ?? [];
    final controller = useScrollController();
    final pinned = useState(false);
    final selectedCategory = useState('');

    useEffect(() {
      controller.addListener(() {
        pinned.value = controller.offset > 100;
      });
      return () {};
    });

    void onSearchChanges(String char) {
      searchResultList.value = providerListener.where((item) {
        return item.name.toLowerCase().contains(char.toLowerCase());
      }).toList();
    }

    int getProductCount(ctg) {
      if (ctg == 0) return providerListener.length;
      return providerListener.where((el) => ctg == el.category?.id).length;
    }

    List<Product> buildFilterResult() {
      if (searchController.text.trim().isNotEmpty && selectedCategory.value.isEmpty) {
        return searchResultList.value;
      }

      if (searchController.text.trim().isNotEmpty && selectedCategory.value.isNotEmpty) {
        return searchResultList.value.where((e) {
          return e.category?.id == selectedCategory.value;
        }).toList();
      }

      if (selectedCategory.value.isEmpty) return providerListener;
      return providerListener.where((e) {
        return e.category?.id == selectedCategory.value;
      }).toList();
    }
    // void onFilterChanged(String filter) {
    //   if (filter.isEmpty) {
    //     filterList.value = [];
    //     filterResultList.value = [];
    //     return;
    //   }
    //
    //   if (filterList.value.contains(filter)) {
    //     filterList.value.remove(filter);
    //   } else {
    //     filterList.value.add(filter);
    //   }
    //
    //   final products = ref.watch(productsProvider).value ?? [];
    //
    //   List<Product> sorted = List.from(products);
    //
    //   if (filterList.value.contains("price")) {
    //     sorted.sort((a, b) => b.price.compareTo(a.price));
    //   }
    //
    //   if (filterList.value.contains("updated")) {
    //     sorted.sort((a, b) {
    //       final dateA = DateTime.tryParse(a.updatedDate ?? '') ?? DateTime(2025);
    //       final dateB = DateTime.tryParse(b.updatedDate ?? '') ?? DateTime(2025);
    //       return dateB.compareTo(dateA);
    //     });
    //   }
    //
    //   if (filterList.value.contains("created")) {
    //     sorted.sort((a, b) {
    //       final dateA = DateTime.tryParse(a.cratedDate ?? '') ?? DateTime(2025);
    //       final dateB = DateTime.tryParse(b.cratedDate ?? '') ?? DateTime(2025);
    //       return dateB.compareTo(dateA);
    //     });
    //   }
    //
    //   if (filterList.value.contains("amount")) {
    //     sorted.sort((a, b) => b.amount.compareTo(a.amount));
    //   }
    //
    //   filterResultList.value = sorted;
    // }

    return AppStateWrapper(builder: (theme, state) {
      if (isAddProduct.value) {
        return AddProductPage(
          state: state,
          theme: theme,
          onBackPressed: () => isAddProduct.value = false,
        );
      }

      if (isUpdateProduct.value) {
        return AddProductPage(
          product: currentProduct.value,
          state: state,
          theme: theme,
          onBackPressed: () {
            currentProduct.value = null;
            isUpdateProduct.value = false;
          },
        );
      }

      return Scaffold(
        floatingActionButton: WebButton(
          onPressed: () {
            isAddProduct.value = true;
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
            SliverToBoxAdapter(
              child: Padding(
                padding: Dis.only(lr: context.w(24), top: context.h(24)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: context.w(16),
                  children: [
                    Expanded(
                      child: Text(
                        AppLocales.products.tr(),
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
                        onChanged: onSearchChanges,
                        theme: theme,
                        fillColor: Colors.white,
                        // useBorder: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            state.whenProviderDataSliver(
              provider: categoryProvider,
              builder: (categories) {
                categories as List<Category>;
                return SliverPinnedHeader(
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
                    child: SingleChildScrollView(
                      padding: Dis.only(lr: context.w(24), tb: context.h(24)),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: context.w(16),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          WebButton(
                            onPressed: () {
                              selectedCategory.value = '';
                            },
                            builder: (focused) => Container(
                              padding: Dis.all(context.s(12)),
                              decoration: BoxDecoration(
                                color: selectedCategory.value.isEmpty ? theme.mainColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: focused
                                    ? Border.all(color: theme.mainColor)
                                    : Border.all(
                                        color: selectedCategory.value.isEmpty ? theme.mainColor : Colors.white,
                                      ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: context.s(12),
                                children: [
                                  Container(
                                    padding: Dis.all(context.s(8)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: selectedCategory.value.isEmpty ? theme.white : theme.scaffoldBgColor,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Ionicons.grid_outline,
                                        size: context.s(32),
                                        color: selectedCategory.value.isEmpty ? theme.mainColor : theme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocales.all.tr(),
                                        style: TextStyle(
                                          fontSize: context.s(16),
                                          fontFamily: mediumFamily,
                                          color: selectedCategory.value.isEmpty ? Colors.white : theme.textColor,
                                        ),
                                      ),
                                      Text(
                                        "${'productCount'.tr()}: ${getProductCount(0)}",
                                        style: TextStyle(
                                          fontSize: context.s(14),
                                          fontFamily: regularFamily,
                                          color: selectedCategory.value.isEmpty ? Colors.white : theme.secondaryTextColor,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          for (final item in categories)
                            WebButton(
                              onPressed: () {
                                selectedCategory.value = item.id;
                              },
                              builder: (focused) => Container(
                                padding: Dis.all(context.s(12)),
                                decoration: BoxDecoration(
                                  color: selectedCategory.value.contains(item.id) ? theme.mainColor : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: focused
                                      ? Border.all(color: theme.mainColor)
                                      : Border.all(
                                          color: selectedCategory.value.contains(item.id) ? theme.mainColor : Colors.white,
                                        ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: context.s(12),
                                  children: [
                                    Container(
                                      height: context.s(48),
                                      width: context.s(48),
                                      padding: Dis.all(context.s(8)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: selectedCategory.value.contains(item.id) ? theme.white : theme.scaffoldBgColor,
                                      ),
                                      child: Center(
                                        child: item.icon == null
                                            ? Text(
                                                item.name.trim().isNotEmpty ? item.name.trim()[0] : "🍜",
                                                style: TextStyle(
                                                  fontSize: context.s(24),
                                                  fontFamily: boldFamily,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                item.icon ?? '',
                                                width: context.s(32),
                                                height: context.s(32),
                                                colorFilter: ColorFilter.mode(
                                                  selectedCategory.value.contains(item.id) ? theme.mainColor : theme.secondaryTextColor,
                                                  BlendMode.color,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: selectedCategory.value.contains(item.id) ? Colors.white : theme.textColor,
                                          ),
                                        ),
                                        Text(
                                          "${'productCount'.tr()}: ${getProductCount(item.id)}",
                                          style: TextStyle(
                                            fontSize: context.s(14),
                                            fontFamily: regularFamily,
                                            color: selectedCategory.value.contains(item.id) ? Colors.white : theme.secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (buildFilterResult().isEmpty)
              SliverPadding(
                padding: Dis.all(100),
                sliver: SliverToBoxAdapter(child: AppEmptyWidget()),
              ),
            SliverPadding(
              padding: Dis.only(lr: context.w(24), tb: context.h(24)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: context.s(16),
                  crossAxisSpacing: context.s(16),
                  childAspectRatio: 261 / 321,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: buildFilterResult().length,
                  (context, index) {
                    final product = buildFilterResult()[index];
                    return ProductCardNew(
                      product: product,
                      colors: theme,
                      onPressed: () {
                        currentProduct.value = product;
                        Future.delayed(Duration(milliseconds: 100));
                        isUpdateProduct.value = true;
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
