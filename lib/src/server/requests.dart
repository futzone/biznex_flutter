import 'package:biznex/src/server/docs.dart';
import 'package:biznex/src/server/routes/categories_router.dart';
import 'package:biznex/src/server/routes/employee_router.dart';
import 'package:biznex/src/server/routes/file_router.dart';
import 'package:biznex/src/server/routes/orders_router.dart';
import 'package:biznex/src/server/routes/places_router.dart';
import 'package:biznex/src/server/routes/products_router.dart';
import 'package:biznex/src/server/routes/stats_router.dart';

List<ApiRequest> serverRequestsList() {
  return [
    PlacesRouter.docs(),
    CategoriesRouter.docs(),
    ProductsRouter.docs(),
    OrdersRouter.orders(),
    OrdersRouter.placeState(),
    OrdersRouter.open(),
    OrdersRouter.close(),
    EmployeeRouter.docs(),
    StatsRouter.docs(),
    FileRouter.docs(),
  ];
}

