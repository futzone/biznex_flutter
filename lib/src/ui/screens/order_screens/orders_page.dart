import 'package:biznex/biznex.dart';
import 'package:biznex/main.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_date.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/screens/order_screens/orders_widgets/add_order_btn.dart';
import 'package:biznex/src/ui/screens/order_screens/orders_widgets/items_body.dart';
import 'package:biznex/src/ui/screens/order_screens/orders_widgets/order_filter_widget.dart';
import 'package:biznex/src/ui/screens/order_screens/orders_widgets/search_bar.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_database/isar.dart';
import '../../../core/model/order_models/order_model.dart';
import 'orders_loading_screen.dart';
import 'orders_widgets/order_pinned_widget.dart';

class OrdersPage extends StatefulHookConsumerWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  bool _isLoading = true;
  final List<Order> _ordersList = [];
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  Place? _fatherPlace;
  Place? _place;
  DateTime _dateTime = DateTime.now();
  Employee? _employee;
  Product? _product;
  final Isar isar = IsarDatabase.instance.isar;

  Future<void> _onLoadData({
    int page = 1,
    int pageSize = appPageSize,
  }) async {
    setState(() {
      _isLoading = true;
      _ordersList.clear();
    });

    final dayPrefix = _dateTime.toIso8601String().split("T").first;
    final searchQuery = _searchController.text.trim();

    var filterQuery = isar.orderIsars
        .where()
        .filter()
        .createdDateStartsWith(dayPrefix)
        .optional(
          _place != null,
          (o) => o.place((p) => p.idEqualTo(_place!.id)),
        )
        .optional(
          _employee != null,
          (o) => o.employee((p) => p.idEqualTo(_employee!.id)),
        )
        .optional(
          _product != null,
          (o) => o.productsElement(
            (p) => p.product((j) => j.idEqualTo(_product!.id)),
          ),
        )
        .optional(
          (searchQuery.length > 2),
          (o) => o
              .idContains(searchQuery)
              .or()
              .noteContains(searchQuery)
              .or()
              .customer((ct) => ct.nameContains(searchQuery))
              .or()
              .employee((ct) => ct.fullnameContains(searchQuery))
              .or()
              .place((pl) => pl.nameContains(searchQuery)),
        );

    final data = await filterQuery
        .sortByCreatedDateDesc()
        .offset((page - 1) * pageSize)
        .limit(pageSize)
        .findAll();

    for (final item in data) {
      _ordersList.add(Order.fromIsar(item));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onLoadNextPage() async {
    setState(() {
      _currentPage++;
    });

    await _onLoadData(page: _currentPage);
  }

  void _onLoadPreviousPage() async {
    if (_currentPage == 1) return;
    setState(() {
      _currentPage--;
    });

    await _onLoadData(page: _currentPage);
  }

  void _initializeIsarWatcher() async {
    isar.orderIsars.watchLazy().listen((event) async {
      if (_isLoading) return;
      if (!_dateTime.isToday) return;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final pinned = useState(false);

    useEffect(() {
      controller.addListener(() {
        pinned.value = controller.offset > 40;
      });
      return () {};
    });

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        floatingActionButton: AddOrderBtn(theme: theme),
        body: Padding(
          padding: Dis.only(lr: context.w(24), top: context.h(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderFilterWidget(
                place: _place,
                fatherPlace: _fatherPlace,
                product: _product,
                employee: _employee,
                theme: theme,
                state: state,
                dateTime: _dateTime,
                onChangePlace: (pls) async {
                  if (pls == null) {
                    setState(() {
                      _fatherPlace = null;
                      _place = null;
                    });
                    _onLoadData();
                  } else {
                    if (pls.children != null && pls.children!.isNotEmpty) {
                      _fatherPlace = pls;
                      setState(() {});
                      return;
                    }

                    setState(() {
                      _place = pls;
                      _currentPage = 1;
                    });

                    await _onLoadData();
                  }
                },
                onChangeEmployee: (employee) async {
                  if (employee == null) {
                    setState(() {
                      _employee = null;
                      _currentPage = 1;
                    });

                    await _onLoadData();
                  } else {
                    setState(() {
                      _employee = employee;
                      _currentPage = 1;
                    });

                    await _onLoadData();
                  }
                },
                onChangeProduct: (product) async {
                  if (product == null) {
                    setState(() {
                      _product = null;
                      _currentPage = 1;
                    });

                    await _onLoadData();
                  } else {
                    setState(() {
                      _product = product;
                      _currentPage = 1;
                    });

                    await _onLoadData();
                  }
                },
                onChangeDateTime: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(2025, 1),
                    lastDate: DateTime.now(),
                  ).then((date) async {
                    if (date != null) {
                      setState(() {
                        _dateTime = date;
                        _currentPage = 1;
                      });

                      await _onLoadData();
                    }
                  });
                },
              ),
              OrderSearchBar(
                  theme: theme,
                  controller: _searchController,
                  onSearch: (char) {
                    if (char.length <= 2) return;
                    if (_isLoading) return;

                    setState(() {
                      _currentPage = 1;
                    });

                    _onLoadData();
                  }),
              if (pinned.value) OrderPinnedWidget(theme: theme),
              if (_isLoading) OrdersLoadingScreen(theme: theme),
              if (_ordersList.isEmpty && !_isLoading)
                Expanded(child: AppEmptyWidget()),
              if (_ordersList.isNotEmpty && !_isLoading)
                OrderItemsBody(
                  controller: controller,
                  theme: theme,
                  orders: _ordersList,
                  currentPage: _currentPage,
                  onLoadNextPage: _onLoadNextPage,
                  onLoadPreviousPage: _onLoadPreviousPage,
                )
            ],
          ),
        ),
      );
    });
  }
}
