import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/utils/scroll_behavior.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../providers/place_status_provider.dart';
import '../../widgets/custom/app_toast.dart';
import '../products_screens/product_card.dart';

class OrderHalfPage extends ConsumerStatefulWidget {
  final Place place;
  final bool minimalistic;

  const OrderHalfPage(this.place, {super.key, this.minimalistic = false});

  @override
  ConsumerState<OrderHalfPage> createState() => _OrderHalfPageState();
}

class _OrderHalfPageState extends ConsumerState<OrderHalfPage> {
  Category? _selectedCategory;
  final controller = ScrollController();
  bool pinned = false;
  final _searchController = TextEditingController();
  bool _searchExpand = false;

  final TextEditingController _textEditingController = TextEditingController();
  List<Product> _searchResultList = [];

  void _onCategorySelected(String id) {
    final providerValue = ref.watch(productsProvider).value ?? [];
    if (_textEditingController.text.trim().isEmpty) {
      _searchResultList =
          providerValue.where((element) => element.category?.id == id).toList();
    } else {
      final char = _textEditingController.text.trim();
      _searchResultList = providerValue.where((element) {
        return ((element.name.toLowerCase().contains(char.toLowerCase())) ||
                (element.size != null &&
                    element.size!
                        .toLowerCase()
                        .contains(char.toLowerCase()))) &&
            element.category?.id == _selectedCategory?.id;
      }).toList();
    }
    setState(() {});
  }

  List<Product> buildFilterResult() {
    final providerListener = ref.watch(productsProvider).value ?? [];
    if (_searchController.text.trim().isNotEmpty) {
      final query = _searchController.text.trim();
      return [
        ...providerListener
            .where((el) => el.name.toLowerCase().contains(query.toLowerCase()))
      ];
    }

    if (_selectedCategory == null) return providerListener;
    return providerListener.where((e) {
      return e.category?.id == _selectedCategory?.id;
    }).toList();
  }

  void _onSearchQuery(String char) {
    // final providerValue = ref.watch(productsProvider).value ?? [];
    // if (_selectedCategory != null) {
    //   _searchResultList = providerValue.where((element) {
    //     return ((element.name.toLowerCase().contains(char.toLowerCase())) ||
    //             (element.size != null && element.size!.toLowerCase().contains(char.toLowerCase()))) &&
    //         element.category?.id == _selectedCategory?.id;
    //   }).toList();
    //   setState(() {});
    //   return;
    // }
    //
    // _searchResultList = providerValue.where((element) {
    //   return (element.name.toLowerCase().contains(char.toLowerCase())) ||
    //       (element.size != null && element.size!.toLowerCase().contains(char.toLowerCase()));
    // }).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      pinned = controller.offset > 100;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderNotifier = ref.read(orderSetProvider.notifier);
    final providerListener = ref.watch(productsProvider).value ?? [];

    int getProductCount(ctg) {
      if (ctg == 0) return providerListener.length;
      return providerListener.where((el) => ctg == el.category?.id).length;
    }

    final categories = ref.watch(categoryProvider).value ?? [];

    final mobile = getDeviceType(context) == DeviceType.mobile;

    final showSetIcon =
        orderNotifier.getItemsByPlace(widget.place.id).isNotEmpty;

    return AppStateWrapper(
      builder: (theme, state) {
        if (mobile) {
          return Scaffold(
            floatingActionButton: !showSetIcon
                ? null
                : FloatingActionButton(
                    backgroundColor: theme.mainColor,
                    child:
                        Icon(Iconsax.bag_copy, size: 32, color: Colors.white),
                    onPressed: () {
                      AppRouter.close(context);
                    },
                  ),
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: AppTextField(
                  prefixIcon: Icon(Iconsax.search_normal_copy),
                  onChanged: _onSearchQuery,
                  radius: 16,
                  title: AppLocales.searchBarHint.tr(),
                  controller: _searchController,
                  theme: theme,
                ),
              ),
            ),
            body: CustomScrollView(
              slivers: [
                SliverPinnedHeader(
                  child: Container(
                    color: theme.appBarColor,
                    height: 64,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: Dis.only(lr: 16),
                      child: Row(
                        spacing: 16,
                        children: [
                          for (final category in categories)
                            SimpleButton(
                              onPressed: () {
                                if (_selectedCategory == category) {
                                  _selectedCategory = null;
                                } else {
                                  _selectedCategory = category;
                                  _onCategorySelected(category.id);
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: Dis.only(lr: 16, tb: 8),
                                decoration: BoxDecoration(
                                  color: _selectedCategory?.id == category.id
                                      ? theme.mainColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: mediumFamily,
                                    color: _selectedCategory?.id == category.id
                                        ? Colors.white
                                        : theme.textColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                state.whenProviderDataSliver(
                  provider: productsProvider,
                  builder: (products) {
                    if (buildFilterResult().isEmpty &&
                        _searchController.text.isNotEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 100, bottom: 100),
                          child: AppEmptyWidget(),
                        )),
                      );
                    }

                    products as List<Product>;

                    return SliverPadding(
                      padding: Dis.only(lr: 16, tb: 16),
                      sliver: SliverGrid.builder(
                        // controller: controller,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: context.s(16),
                          crossAxisSpacing: context.s(16),
                          childAspectRatio: 2,
                        ),
                        itemCount: buildFilterResult().length,
                        itemBuilder: (BuildContext context, int index) {
                          final product = buildFilterResult()[index];
                          return SimpleButton(
                            onPressed: () async {
                              if (product.amount < 1) {
                                ShowToast.error(
                                    context, AppLocales.productStockError.tr());
                                return;
                              }

                              final status = ref.watch(
                                      placeStatusProvider)[widget.place.id] ??
                                  false;
                              if (!status) {
                                final placeState = await OrderDatabase()
                                    .getPlaceOrder(widget.place.id);
                                if (placeState == null) {
                                  orderNotifier
                                      .clearPlaceItems(widget.place.id);
                                }

                                ref
                                    .read(placeStatusProvider.notifier)
                                    .update((state) {
                                  state[widget.place.id] = true;
                                  return state;
                                });
                              }

                              if (product.amount != -1) {
                                orderNotifier.addItem(
                                  OrderItem(
                                      product: product,
                                      amount: 1,
                                      placeId: widget.place.id),
                                  context,
                                );

                                ShowToast.success(
                                    context, AppLocales.productAddedToSet.tr());
                              } else {
                                ShowToast.error(
                                    context, AppLocales.productStockError.tr());
                              }
                            },
                            child: IgnorePointer(
                              child: ProductCardNew(
                                have: orderNotifier.haveProduct(
                                    widget.place.id, product.id),
                                product: product,
                                colors: theme,
                                minimalistic: true,
                                onPressed: () {},
                                placeId: widget.place.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }
        return Expanded(
          flex: 9,
          child: Column(
            spacing: context.h(16),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ScrollConfiguration(
                behavior: HorizontalScrollBehavior(),
                child: SingleChildScrollView(
                  padding: Dis.only(left: context.w(24), top: context.h(24)),
                  scrollDirection: Axis.horizontal,
                  child: state.whenProviderData(
                    provider: categoryProvider,
                    builder: (categories) {
                      categories as List<Category>;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: context.w(16),
                        children: [
                          WebButton(
                            onPressed: () {
                              _searchExpand = !_searchExpand;
                              setState(() {});
                            },
                            builder: (focused) => Container(
                              padding: widget.minimalistic
                                  ? Dis.only(lr: 8, tb: 2)
                                  : Dis.all(context.s(12)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: focused
                                    ? Border.all(color: theme.mainColor)
                                    : Border.all(
                                        color: Colors.white,
                                      ),
                              ),
                              child: _searchExpand
                                  ? Container(
                                      height: context.s(48),
                                      width: context.s(320),
                                      child: Row(
                                        spacing: context.w(8),
                                        children: [
                                          Expanded(
                                            child: AppTextField(
                                              autofocus: true,
                                              prefixIcon: Icon(
                                                  Iconsax.search_normal_copy),
                                              onChanged: _onSearchQuery,
                                              radius: 8,
                                              title:
                                                  AppLocales.searchBarHint.tr(),
                                              controller: _searchController,
                                              theme: theme,
                                            ),
                                          ),
                                          Container(
                                            height: widget.minimalistic
                                                ? null
                                                : context.s(40),
                                            width: widget.minimalistic
                                                ? null
                                                : context.s(40),
                                            padding: Dis.all(context.s(8)),
                                            margin: widget.minimalistic
                                                ? Dis.only(tb: 6)
                                                : null,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: theme.scaffoldBgColor,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Ionicons.close_outline,
                                                size: context.s(24),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: context.s(48),
                                      width: context.s(48),
                                      padding: Dis.all(context.s(8)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: widget.minimalistic
                                            ? null
                                            : theme.scaffoldBgColor,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Ionicons.search_outline,
                                          size: context.s(24),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          for (final category in categories)
                            WebButton(
                              onPressed: () {
                                if (_selectedCategory == category) {
                                  _selectedCategory = null;
                                } else {
                                  _selectedCategory = category;
                                  _onCategorySelected(category.id);
                                }
                                setState(() {});
                              },
                              builder: (focused) => Container(
                                padding: widget.minimalistic
                                    ? Dis.only(lr: 8, tb: 4)
                                    : Dis.all(context.s(12)),
                                decoration: BoxDecoration(
                                  color: _selectedCategory?.id == category.id
                                      ? theme.mainColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: focused
                                      ? Border.all(color: theme.mainColor)
                                      : Border.all(
                                          color: _selectedCategory?.id ==
                                                  category.id
                                              ? theme.mainColor
                                              : Colors.white,
                                        ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: context.s(12),
                                  children: [
                                    if (!widget.minimalistic)
                                      Container(
                                        height: context.s(48),
                                        width: context.s(48),
                                        padding: Dis.all(context.s(8)),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: _selectedCategory?.id ==
                                                  category.id
                                              ? theme.white
                                              : theme.scaffoldBgColor,
                                        ),
                                        child: Center(
                                          child: category.icon == null
                                              ? Text(
                                                  category.name
                                                          .trim()
                                                          .isNotEmpty
                                                      ? category.name.trim()[0]
                                                      : "🍜",
                                                  style: TextStyle(
                                                    fontSize: context.s(24),
                                                    fontFamily: boldFamily,
                                                  ),
                                                )
                                              : SvgPicture.asset(
                                                  category.icon ?? '',
                                                  width: context.s(32),
                                                  height: context.s(32),
                                                  colorFilter: ColorFilter.mode(
                                                    _selectedCategory?.id ==
                                                            category.id
                                                        ? theme.mainColor
                                                        : theme
                                                            .secondaryTextColor,
                                                    BlendMode.color,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          category.name.trim(),
                                          style: TextStyle(
                                            fontSize: context.s(16),
                                            fontFamily: mediumFamily,
                                            color: _selectedCategory?.id ==
                                                    category.id
                                                ? Colors.white
                                                : theme.textColor,
                                          ),
                                        ),
                                        Text(
                                          "${'productCount'.tr()}: ${getProductCount(category.id)}",
                                          style: TextStyle(
                                            fontSize: context.s(14),
                                            fontFamily: regularFamily,
                                            color: _selectedCategory?.id ==
                                                    category.id
                                                ? Colors.white
                                                : theme.secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: Dis.only(left: context.w(24)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocales.all_products.tr(),
                      style: TextStyle(
                          fontFamily: mediumFamily, fontSize: context.s(20)),
                    ),
                    Text(
                      "${'productCount'.tr()}: ${providerListener.length} ${AppLocales.ta.tr()}",
                      style: TextStyle(
                        fontFamily: regularFamily,
                        fontSize: context.s(16),
                        color: theme.secondaryTextColor,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: Dis.only(left: context.w(24)),
                  decoration: BoxDecoration(
                    border: pinned
                        ? Border(
                            top: BorderSide(color: theme.white, width: 2),
                          )
                        : null,
                  ),
                  child: state.whenProviderData(
                    provider: productsProvider,
                    builder: (products) {
                      if (buildFilterResult().isEmpty &&
                          _searchController.text.isNotEmpty)
                        return AppEmptyWidget();

                      products as List<Product>;

                      return GridView.builder(
                        controller: controller,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: context.s(16),
                          crossAxisSpacing: context.s(16),
                          childAspectRatio:
                              widget.minimalistic ? (3) : (261 / 321),
                        ),
                        itemCount: buildFilterResult().length,
                        itemBuilder: (BuildContext context, int index) {
                          final product = buildFilterResult()[index];
                          return SimpleButton(
                            onPressed: () async {
                              final status = ref.watch(
                                      placeStatusProvider)[widget.place.id] ??
                                  false;
                              if (!status) {
                                final placeState = await OrderDatabase()
                                    .getPlaceOrder(widget.place.id);
                                if (placeState == null) {
                                  orderNotifier
                                      .clearPlaceItems(widget.place.id);
                                }

                                ref
                                    .read(placeStatusProvider.notifier)
                                    .update((state) {
                                  state[widget.place.id] = true;
                                  return state;
                                });
                              }

                              if (product.amount != -1) {
                                orderNotifier.addItem(
                                    OrderItem(
                                        product: product,
                                        amount: 1,
                                        placeId: widget.place.id),
                                    context);
                              } else {
                                ShowToast.error(
                                    context, AppLocales.productStockError.tr());
                              }
                            },
                            child: IgnorePointer(
                              child: ProductCardNew(
                                product: product,
                                placeId: widget.place.id,
                                colors: theme,
                                minimalistic: widget.minimalistic,
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
