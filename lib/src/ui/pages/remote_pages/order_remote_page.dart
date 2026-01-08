import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/ui/pages/remote_pages/remote_data_service.dart';
import 'package:biznex/src/ui/screens/order_screens/order_card.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../screens/order_screens/orders_widgets/add_order_btn.dart';
import '../../widgets/custom/app_empty_widget.dart';

class OrderRemotePage extends HookConsumerWidget {
  const OrderRemotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = useState<List<Order>>([]);
    final isLoading = useState(true);
    final page = useState(1);
    final hasMore = useState(true);
    final scrollController = useScrollController();

    Future<void> loadData() async {
      if (!hasMore.value) return;

      final service = RemoteDataService();
      final rawData = await service.fetchData(
          endpoint: '/api/v2/orders/list', page: page.value, limit: 20);

      if (rawData.length < 20) {
        hasMore.value = false;
      }

      try {
        final List<Order> newOrders =
            rawData.map((e) => Order.fromJson(e)).toList();

        if (page.value == 1) {
          orders.value = newOrders;
        } else {
          orders.value = [...orders.value, ...newOrders];
        }
      } catch (e, st) {
        log("Error parsing orders: $e", error: e, stackTrace: st);
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
        floatingActionButton: AddOrderBtn(theme: theme),
        appBar: AppBar(title: Text(AppLocales.orders.tr())),
        body: isLoading.value && orders.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : orders.value.isEmpty
                ? AppEmptyWidget()
                : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 353 / 363,
                    ),
                    itemCount: orders.value.length + (hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == orders.value.length) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator()));
                      }
                      final item = orders.value[index];
                      // Use OrderCard
                      return OrderCard(
                        order: item,
                        theme: theme,
                        color: theme.cardColor,
                      );
                    },
                  ),
      );
    });
  }
}
