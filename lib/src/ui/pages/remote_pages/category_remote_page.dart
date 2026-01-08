import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/ui/pages/remote_pages/remote_data_service.dart';
import 'package:biznex/src/ui/screens/category_screens/category_card.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryRemotePage extends HookConsumerWidget {
  const CategoryRemotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks should be at the top level of build
    final categories = useState<List<Category>>([]);
    final isLoading = useState(true);
    final page = useState(1);
    final hasMore = useState(true);
    final scrollController = useScrollController();

    // Defined inside build, but called in useEffect
    Future<void> loadData() async {
      if (!hasMore.value) return;

      final service = RemoteDataService();
      final rawData = await service.fetchData(
          endpoint: '/api/v2/categories/list', page: page.value, limit: 20);

      if (rawData.length < 20) {
        hasMore.value = false;
      }

      try {
        final List<Category> newCategories = [];
        for (final item in rawData) {
          newCategories.add(Category.fromJson(item));
        }

        log("Parsed ${newCategories.length} categories successfully.");

        if (page.value == 1) {
          categories.value = newCategories;
        } else {
          categories.value = [...categories.value, ...newCategories];
        }
      } catch (e, st) {
        log("Error parsing categories: $e", error: e, stackTrace: st);
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
        appBar: AppBar(title: Text(AppLocales.categories.tr())),
        body: isLoading.value && categories.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : categories.value.isEmpty
                ? AppEmptyWidget()
                : ListView.builder(
                    controller: scrollController,
                    itemCount:
                        categories.value.length + (hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == categories.value.length) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator()));
                      }
                      final item = categories.value[index];
                      // Pass converted model to existing card
                      return CategoryCard(item, count: 0);
                    },
                  ),
      );
    });
  }
}
