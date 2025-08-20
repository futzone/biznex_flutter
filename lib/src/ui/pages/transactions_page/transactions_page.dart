import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/transaction_controller.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/pages/transactions_page/add_transaction_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/model/transaction_model/transaction_model.dart';

class TransactionsPage extends HookConsumerWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const TransactionsPage(this.floatingActionButton, {super.key, required this.appbar});

  @override
  Widget build(BuildContext context, ref) {
    final providerListener = ref.watch(transactionProvider).value ?? [];
    final searchController = useTextEditingController();
    final searchResultList = useState(<Transaction>[]);
    final selectedDate = useState<DateTime?>(null);

    List<Transaction> buildList() {
      if (selectedDate.value != null) {
        return searchResultList.value;
      }

      if (searchController.text.trim().isNotEmpty) {
        return searchResultList.value;
      }

      return providerListener;
    }

    void onSearchChanged(dynamic query) {
      if (query is DateTime) {
        log('date filter working');
        searchResultList.value = [
          ...providerListener.where((element) {
            final date = DateTime.parse(element.createdDate);
            return query.day == date.day && query.month == date.month && query.year == date.year;
          }),
        ];

        log(searchResultList.value.length.toString());

        return;
      }

      selectedDate.value = null;

      if (query.trim().isEmpty) {
        searchResultList.value.clear();
        return;
      }

      searchResultList.value = [
        ...providerListener.where((element) {
          final dayQuery = DateFormat('yyyy, d-MMMM, HH:mm', context.locale.languageCode).format(DateTime.parse(element.createdDate)).toLowerCase();
          final payQuery = element.paymentType.tr().toLowerCase();
          final elementQuery = (element.employee?.fullname.toLowerCase()) ?? '';

          return (element.note.toLowerCase().contains(query.toLowerCase()) ||
              dayQuery.contains(query.toLowerCase()) ||
              payQuery.contains(query.toLowerCase()) ||
              elementQuery.contains(query.toLowerCase()));
        })
      ];
    }

    final headerStyle = TextStyle(
      fontSize: context.s(14),
      color: Colors.black,
      fontFamily: mediumFamily,
    );

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        floatingActionButton: WebButton(
          onPressed: () {
            showDesktopModal(context: context, body: AddTransactionPage(), width: context.w(600));
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
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(context.s(24)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: context.w(16),
                  children: [
                    Expanded(
                      child: Text(
                        AppLocales.transactions.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: mediumFamily,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    0.w,
                    SizedBox(
                      width: context.w(400),
                      child: AppTextField(
                        title: AppLocales.search.tr(),
                        controller: searchController,
                        theme: theme,
                        fillColor: Colors.white,
                        onChanged: onSearchChanged,
                        // useBorder: false,
                      ),
                    ),
                    0.w,
                    Text(
                      AppLocales.date.tr(),
                      style: TextStyle(
                        fontSize: context.s(16),
                        fontFamily: mediumFamily,
                        color: Colors.black,
                      ),
                    ),
                    SimpleButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now(),
                        ).then((date) {
                          selectedDate.value = date;
                          if (date == null) return;
                          onSearchChanged(date);
                        });
                      },
                      child: Container(
                        padding: Dis.only(lr: 16),
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (selectedDate.value == null)
                              Text(
                                AppLocales.all.tr(),
                                style: TextStyle(color: theme.secondaryTextColor, fontSize: context.s(14)),
                              ),
                            if (selectedDate.value == null) 16.w,
                            if (selectedDate.value == null)
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: context.s(16),
                                color: theme.secondaryTextColor,
                              ),
                            if (selectedDate.value != null)
                              Text(
                                DateFormat('yyyy, d-MMMM', context.locale.languageCode).format(selectedDate.value!).toLowerCase(),
                                style: TextStyle(
                                  color: theme.secondaryTextColor,
                                  fontSize: context.s(14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPinnedHeader(
              child: Container(
                margin: Dis.only(lr: context.s(24)),
                padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.20)),
                  color: theme.scaffoldBgColor,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Center(child: Text(AppLocales.createdDate.tr(), style: headerStyle))),
                    Expanded(flex: 3, child: Center(child: Text(AppLocales.total.tr(), style: headerStyle))),
                    Expanded(flex: 3, child: Center(child: Text(AppLocales.note.tr(), style: headerStyle))),
                    Expanded(flex: 3, child: Center(child: Text(AppLocales.paymentType.tr(), style: headerStyle))),
                    Expanded(flex: 3, child: Center(child: Text(AppLocales.employeeNameLabel.tr(), style: headerStyle))),
                    Expanded(flex: 2, child: Center(child: Text(''))),
                  ],
                ),
              ),
            ),
            state.whenProviderDataSliver(
              provider: transactionProvider,
              builder: (transactions) {
                transactions as List<Transaction>;
                if (transactions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(padding: Dis.all(context.s(100)), child: AppEmptyWidget()),
                  );
                }

                final list = buildList();

                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(padding: Dis.all(context.s(100)), child: AppEmptyWidget()),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: list.length,
                    (context, index) {
                      final item = list[index];
                      return Container(
                        margin: Dis.only(lr: context.s(24)),
                        padding: Dis.only(lr: context.w(20), tb: context.h(20)),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: theme.scaffoldBgColor)),
                          color: theme.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  DateFormat('yyyy, d-MMMM, HH:mm', context.locale.languageCode)
                                      .format(DateTime.parse(item.createdDate))
                                      .toLowerCase(),
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: context.s(16),
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  item.value.priceUZS,
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: context.s(16),
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  item.note,
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: context.s(16),
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  item.paymentType.tr(),
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: context.s(16),
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  item.employee?.fullname ?? ' - ',
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: context.s(16),
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                spacing: context.w(16),
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SimpleButton(
                                    onPressed: () {
                                      showDesktopModal(
                                        context: context,
                                        body: AddTransactionPage(transaction: item),
                                        width: 600,
                                      );
                                    },
                                    child: Container(
                                      height: context.s(36),
                                      width: context.s(36),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: theme.scaffoldBgColor,
                                      ),
                                      padding: Dis.all(context.s(8)),
                                      child: Icon(
                                        Iconsax.edit_copy,
                                        size: context.s(20),
                                        color: theme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  SimpleButton(
                                    onPressed: () {
                                      TransactionController tc = TransactionController(context: context, state: state);
                                      tc.delete(item.id);
                                    },
                                    child: Container(
                                      height: context.s(36),
                                      width: context.s(36),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: theme.scaffoldBgColor,
                                      ),
                                      padding: Dis.all(context.s(8)),
                                      child: Icon(
                                        Iconsax.trash_copy,
                                        size: context.s(20),
                                        color: theme.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
