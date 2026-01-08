import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/ui/pages/remote_pages/remote_data_service.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom/app_empty_widget.dart';

class CustomerRemotePage extends HookConsumerWidget {
  const CustomerRemotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = useState<List<Customer>>([]);
    final isLoading = useState(true);
    final page = useState(1);
    final hasMore = useState(true);
    final scrollController = useScrollController();

    Future<void> loadData() async {
      if (!hasMore.value) return;

      final service = RemoteDataService();
      final rawData = await service.fetchData(
          endpoint: '/api/v2/customers/list', page: page.value, limit: 20);

      if (rawData.length < 20) {
        hasMore.value = false;
      }

      try {
        final List<Customer> newCustomers =
            rawData.map((e) => Customer.fromJson(e)).toList();

        if (page.value == 1) {
          customers.value = newCustomers;
        } else {
          customers.value = [...customers.value, ...newCustomers];
        }
      } catch (e, st) {
        log("Error parsing customers: $e", error: e, stackTrace: st);
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
        appBar: AppBar(title: Text(AppLocales.customers.tr())),
        body: isLoading.value && customers.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : customers.value.isEmpty
                ? AppEmptyWidget()
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: customers.value.length + (hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == customers.value.length) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator()));
                      }
                      final customer = customers.value[index];

                      // Replicating UI from CustomersPage
                      return SimpleButton(
                        onPressed: () {
                          // View details if needed, or do nothing for now
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: theme.mainColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          customer.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Bold',
                                            // Assuming boldFamily constant isn't available directly or imports are tricky, but biznex export usually has it?
                                            // Let's rely on imports potentially having it if it's top level, otherwise use string or standard style.
                                            // In snippets, boldFamily seemed to be global or in biznex export.
                                            // I'll assume theme fonts or defaults.
                                            fontWeight: FontWeight.bold,
                                            color: theme.mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: theme.scaffoldBgColor,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                customer.phone.trim(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (customer.address != null &&
                                            customer.address!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Container(
                                              height: 36,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: theme.scaffoldBgColor,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    customer.address ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(
                                          Iconsax.calendar_1_copy,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          customer.created != null
                                              ? DateFormat("yyyy.MM.dd")
                                                  .format(customer.created!)
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      );
    });
  }
}
