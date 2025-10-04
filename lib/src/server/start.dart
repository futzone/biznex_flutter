import 'dart:convert';
import 'dart:developer';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/employee_database/role_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/providers/license_status_provider.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:biznex/src/server/routes/categories_router.dart';
import 'package:biznex/src/server/routes/employee_router.dart';
import 'package:biznex/src/server/routes/file_router.dart';
import 'package:biznex/src/server/routes/orders_router.dart';
import 'package:biznex/src/server/routes/places_router.dart';
import 'package:biznex/src/server/routes/products_router.dart';
import 'package:biznex/src/server/routes/stats_router.dart';
import 'package:biznex/src/server/services/authorization_services.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../core/model/employee_models/employee_model.dart';
import '../core/model/order_models/order_model.dart';
import '../core/model/other_models/customer_model.dart';
import '../core/model/place_models/place_model.dart';
import '../core/model/product_models/product_model.dart';

// void main() async => startS;

void startServer() async {
  log('Server running...');
  final app = Router();
  final AuthorizationServices authorizationServices = AuthorizationServices();

  final appDatabase = AppStateDatabase();
  final appState = await appDatabase.getApp();
  final licenseStatus = await verifyLicense(appState.licenseKey);

  if (!licenseStatus) {
    log("server disabled. reason: access key expired");
    return;
  }

  app.get(ApiEndpoints.docs, (Request request) async {
    return Response.ok(renderApiRequests(),
        headers: {"Content-Type": "text/html"});
  });

  app.get(ApiEndpoints.state, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    StatsRouter statsRouter = StatsRouter(request);
    final placesResponse = await statsRouter.getState();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.employee, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    EmployeeRouter placesRouter = EmployeeRouter(request);
    final placesResponse = await placesRouter.getCategories();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.places, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    PlacesRouter placesRouter = PlacesRouter(request);
    final placesResponse = await placesRouter.getPlaces();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.categories, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    CategoriesRouter categoriesRouter = CategoriesRouter(request);
    final placesResponse = await categoriesRouter.getCategories();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.products, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    ProductsRouter categoriesRouter = ProductsRouter(request);
    final placesResponse = await categoriesRouter.getProducts();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.getEmployeeOrders();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.placeOrders, (Request request, String id) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.getPlaceState(id);
    return placesResponse.toResponse();
  });

  app.post(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.openOrder(request);
    return placesResponse.toResponse();
  });

  app.put(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.closeOrder(request);
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.getImage, (Request request, String path) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status)
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));

    FileRouter fileRouter = FileRouter();
    final placesResponse = await fileRouter.getImage(request);
    return placesResponse.toImageResponse();
  });

  CategoryDatabase categoryDatabase = CategoryDatabase();
  CustomerDatabase customerDatabase = CustomerDatabase();
  EmployeeDatabase employeeDatabase = EmployeeDatabase();
  PlaceDatabase placeDatabase = PlaceDatabase();
  ProductDatabase productDatabase = ProductDatabase();

  app.get(categoryDatabase.endpoint, (Request request) async {
    final data = await categoryDatabase.get();
    return Response(200, body: jsonEncode([...data.map((e) => e.toJson())]));
  });

  app.get(customerDatabase.endpoint, (Request request) async {
    final data = await customerDatabase.get();
    return Response(200, body: jsonEncode([...data.map((e) => e.toJson())]));
  });

  app.get(employeeDatabase.endpoint, (Request request) async {
    final data = await employeeDatabase.get();
    return Response(200, body: jsonEncode([...data.map((e) => e.toJson())]));
  });

  app.get(placeDatabase.endpoint, (Request request) async {
    final data = await placeDatabase.get();
    return Response(200, body: jsonEncode([...data.map((e) => e.toJson())]));
  });

  app.get(productDatabase.endpoint, (Request request) async {
    final data = await productDatabase.get();
    return Response(200, body: jsonEncode([...data.map((e) => e.toJson())]));
  });

  ///
  ///

  app.post(categoryDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      await categoryDatabase.set(data: Category.fromJson(requestJson));
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(customerDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      await customerDatabase.set(data: Customer.fromJson(requestJson));
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(employeeDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      await employeeDatabase.set(data: Employee.fromJson(requestJson));
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(placeDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      await placeDatabase.set(data: Place.fromJson(requestJson));
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(productDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      await productDatabase.set(data: Product.fromJson(requestJson));
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  ///
  ///

  app.delete(categoryDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      final id = requestJson['id'];
      await categoryDatabase.delete(key: id.toString());
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(customerDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      final id = requestJson['id'];
      await customerDatabase.delete(key: id.toString());
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(employeeDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      final id = requestJson['id'];
      await employeeDatabase.delete(key: id.toString());
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(placeDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      final id = requestJson['id'];
      await placeDatabase.delete(key: id.toString());
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  app.post(productDatabase.endpoint, (Request request) async {
    try {
      final requestData = await request.readAsString();
      final requestJson = jsonDecode(requestData);
      final id = requestJson['id'];
      await productDatabase.delete(key: id.toString());
      return Response(200, body: jsonEncode({'message': 'success'}));
    } catch (error, stackTrace) {
      return Response(400, body: "$error\n$stackTrace");
    }
  });

  OrderDatabase orderDatabase = OrderDatabase();

  app.post('/api/v2/order/<placeId>', (Request request, String placeId) async {
    final jsonString = await request.readAsString();
    final jsonData = jsonDecode(jsonString);
    final data =
        Order.fromJson(jsonData is String ? jsonDecode(jsonData) : jsonData);
    final disablePrint = (jsonData is String
            ? jsonDecode(jsonData)
            : jsonData)['disablePrint'] ??
        false;
    log("disable: $disablePrint");
    log("jsonData: $jsonData");
    await orderDatabase.setPlaceOrder(
        data: data, placeId: placeId, disablePrint: disablePrint);
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.get('/api/v2/orders', (Request request) async {
    final data = await orderDatabase.getOrders();
    final dataList = [];
    for (final item in data) {
      dataList.add(item.toJson());
    }
    return Response(200, body: jsonEncode(dataList));
  });

  app.post('/api/v2/orders', (Request request) async {
    final jsonString = await request.readAsString();
    final jsonData = jsonDecode(jsonString);
    final data = Order.fromJson(parseJson(jsonData));
    await orderDatabase.saveOrder(data);
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.get('/api/v2/order/<placeId>', (Request request, String placeId) async {
    final orderData = await orderDatabase.getPlaceOrder(placeId);
    if (orderData == null) return Response(404);
    return Response(200, body: jsonEncode(orderData.toJson()));
  });

  app.delete('/api/v2/order/<placeId>',
      (Request request, String placeId) async {
    await orderDatabase.deletePlaceOrder(placeId);
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.delete('/api/v2/order/<placeId>',
      (Request request, String placeId) async {
    await orderDatabase.closeOrder(placeId: placeId);
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.put('/api/v2/order/<placeId>', (Request request, String placeId) async {
    final jsonString = await request.readAsString();
    final jsonData = jsonDecode(jsonString);
    final data = Order.fromJson(jsonData);
    await orderDatabase.updatePlaceOrder(data: data, placeId: placeId);
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.get('/api/v2/percents', (Request request) async {
    OrderPercentDatabase percentDatabase = OrderPercentDatabase();
    final percents = await percentDatabase.get();
    return Response(200,
        body: jsonEncode([for (final item in percents) item.toJson()]));
  });

  ///
  ///

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app.call);
  await io.serve(handler, '0.0.0.0', 8080);
}

dynamic parseJson(dynamic data) {
  if (data is String) {
    final decoded = jsonDecode(data);
    return parseJson(decoded);
  }

  return data;
}
