import 'package:biznex/biznex.dart';
import 'package:biznex/main.dart';
import 'package:biznex/src/controllers/transaction_controller.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_date.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_isar.dart';
import 'package:biznex/src/ui/pages/transactions_page/add_transaction_page.dart';
import 'package:biznex/src/ui/pages/transactions_page/transaction_loader_screen.dart';
import 'package:biznex/src/ui/pages/transactions_page/transactions_filter.dart';
import 'package:biznex/src/ui/screens/order_screens/order_detail_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../../core/model/transaction_model/transaction_model.dart';
import 'add_transaction_btn.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime _selectedDate = DateTime.now();
  String? _paymentType;
  int _currentPage = 1;
  bool _isLoading = true;
  final List<Transaction> _transactions = [];
  final Isar isar = IsarDatabase.instance.isar;

  Future<void> _onLoadData() async {
    setState(() {
      _isLoading = true;
      _transactions.clear();
    });

    final datePrefix = _selectedDate.toIso8601String().split("T").first;
    final filterQuery = isar.transactionIsars
        .where()
        .filter()
        .createdDateStartsWith(datePrefix)
        .optional(
          _paymentType != null,
          (tr) => tr
              .paymentTypeContains(_paymentType!)
              .or()
              .paymentTypesElement((pte) => pte.nameContains(_paymentType!)),
        );

    await filterQuery
        .sortByCreatedDateDesc()
        .offset((_currentPage - 1) * appPageSize)
        .limit(appPageSize)
        .findAll()
        .then((list) {
      for (final item in list) {
        _transactions.add(Transaction.fromIsar(item));
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  void _onLoadNextPage() async {
    setState(() {
      _currentPage++;
    });

    await _onLoadData();
  }

  void _onLoadPreviousPage() async {
    if (_currentPage == 1) return;
    setState(() {
      _currentPage--;
    });

    await _onLoadData();
  }

  void _initializeIsarWatcher() async {
    isar.transactionIsars.watchLazy().listen((event) async {
      if (_isLoading) return;
      if (!_selectedDate.isToday) return;
      await _onLoadData();
    });
  }

  void _initialize() async {
    await _onLoadData();
    _initializeIsarWatcher();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: context.s(14),
      color: Colors.black,
      fontFamily: mediumFamily,
    );

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        floatingActionButton: AddTransactionBtn(theme: theme),
        body: CustomScrollView(
          slivers: [
            TransactionsFilter(
              onSelectedDate: () {
                showDatePicker(
                  context: context,
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now(),
                ).then((date) async {
                  if (date == null) return;

                  setState(() {
                    _selectedDate = date;
                    _currentPage = 1;
                  });

                  await _onLoadData();
                });
              },
              selectedDate: _selectedDate,
              theme: theme,
              onSelectedPaymentType: (pt) async {
                if (pt == null) {
                  setState(() {
                    _paymentType = null;
                    _currentPage = 1;
                  });

                  await _onLoadData();
                } else {
                  setState(() {
                    _paymentType = pt;
                    _currentPage = 1;
                  });

                  await _onLoadData();
                }
              },
            ),
            SliverPinnedHeader(
              child: Container(
                margin: Dis.only(lr: context.s(24)),
                padding: Dis.only(lr: context.w(20), tb: context.h(12)),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.20)),
                  color: theme.scaffoldBgColor,
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: Text(AppLocales.createdDate.tr(),
                                style: headerStyle))),
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: Text(AppLocales.total.tr(),
                                style: headerStyle))),
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: Text(AppLocales.note.tr(),
                                style: headerStyle))),
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: Text(AppLocales.paymentType.tr(),
                                style: headerStyle))),
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: Text(AppLocales.employeeNameLabel.tr(),
                                style: headerStyle))),
                    Expanded(flex: 2, child: Center(child: Text(''))),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: 30,
                  (context, index) {
                    return TransactionLoaderScreen(theme: theme);
                  },
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: _transactions.length,
                (context, index) {
                  final item = _transactions[index];
                  return Container(
                    margin: Dis.only(lr: context.s(24)),
                    padding: Dis.only(lr: context.w(20), tb: context.h(20)),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: theme.scaffoldBgColor)),
                      color: theme.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              DateFormat('yyyy, d-MMMM, HH:mm',
                                      context.locale.languageCode)
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
                              item.paymentType
                                  .split(",")
                                  .map((e) => e.trim().tr().capitalize)
                                  .join(", "),
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item.order == null)
                                SimpleButton(
                                  onPressed: () {
                                    showDesktopModal(
                                      context: context,
                                      body:
                                          AddTransactionPage(transaction: item),
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
                                )
                              else
                                SimpleButton(
                                  onPressed: () {
                                    showDesktopModal(
                                      context: context,
                                      body: OrderDetail(order: item.order!),
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
                                      Icons.info_outline,
                                      size: context.s(20),
                                      color: theme.secondaryTextColor,
                                    ),
                                  ),
                                ),
                              SimpleButton(
                                onPressed: () {
                                  TransactionController tc =
                                      TransactionController(
                                          context: context, state: state);
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
            ),
            SliverPadding(padding: Dis.only(tb: 12)),
            if (!_isLoading && _transactions.isEmpty)
              SliverPadding(
                padding: 80.tb,
                sliver: SliverToBoxAdapter(child: AppEmptyWidget()),
              ),
            if (!_isLoading && _transactions.isNotEmpty)
              SliverToBoxAdapter(
                child: Row(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentPage > 1)
                      SimpleButton(
                        onPressed: _onLoadPreviousPage,
                        child: Container(
                          padding: Dis.only(lr: 24, tb: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_sharp,
                                size: 20,
                                color: Colors.black,
                              ),
                              8.w,
                              Text(
                                (_currentPage - 1).toString(),
                                style: TextStyle(
                                  fontFamily: boldFamily,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    Container(
                      padding: Dis.only(lr: 24, tb: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "$_currentPage (${(_currentPage - 1) * appPageSize + 1} - ${_currentPage * appPageSize})",
                            style: TextStyle(
                              fontFamily: boldFamily,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                    if (_transactions.length == appPageSize)
                      SimpleButton(
                        onPressed: _onLoadNextPage,
                        child: Container(
                          padding: Dis.only(lr: 24, tb: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                (_currentPage + 1).toString(),
                                style: TextStyle(
                                  fontFamily: boldFamily,
                                  fontSize: 18,
                                ),
                              ),
                              8.w,
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            SliverPadding(padding: Dis.only(tb: 80)),
          ],
        ),
      );
    });
  }
}
