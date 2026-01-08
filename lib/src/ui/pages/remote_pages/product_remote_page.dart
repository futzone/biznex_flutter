import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/pages/remote_pages/remote_data_service.dart';
import 'package:biznex/src/ui/screens/products_screens/product_card.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/custom/app_empty_widget.dart';

class ProductRemotePage extends HookConsumerWidget {
  const ProductRemotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = useState<List<Product>>([]);
    final isLoading = useState(true);
    final page = useState(1);
    final hasMore = useState(true);
    final scrollController = useScrollController();

    Future<void> loadData() async {
      if (!hasMore.value) return;

      final service = RemoteDataService();
      final rawData = await service.fetchData(
          endpoint: '/api/v2/products/list', page: page.value, limit: 20);

      if (rawData.length < 20) {
        hasMore.value = false;
      }

      try {
        final List<Product> newProducts =
            rawData.map((e) => Product.fromJson(e)).toList();

        if (page.value == 1) {
          products.value = newProducts;
        } else {
          products.value = [...products.value, ...newProducts];
        }
      } catch (e, st) {
        log("Error parsing products: $e", error: e, stackTrace: st);
      }

      isLoading.value = false;
      page.value++;
    }

    useEffect(() {
      loadData();
      return null;
    }, []);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLoading.value && hasMore.value) {
          loadData();
        }
      }
    });

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocales.products.tr())),
        body: isLoading.value && products.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : products.value.isEmpty
                ? AppEmptyWidget()
                : CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 261 / 321,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = products.value[index];
                              return ProductCardNew(
                                product: item,
                                colors: theme,
                                onPressed: () {
                                  // Add interaction if defined, or empty
                                },
                                // minimal mode or other props if needed
                              );
                            },
                            childCount: products.value.length,
                          ),
                        ),
                      ),
                      if (hasMore.value)
                        const SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator())),
                        )
                    ],
                  ),
      );
    });
  }
}
