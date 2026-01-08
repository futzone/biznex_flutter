import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:biznex/src/core/cloud/cloud_services.dart';
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
import 'package:biznex/src/server/routes/customers_router.dart';
import 'package:biznex/src/core/utils/cashier_utils.dart';
import 'package:path/path.dart' as p;
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

  final BiznexCloudServices cloudServices = BiznexCloudServices();
  final tokenData = await cloudServices.getTokenData();

  if (tokenData == null) {
    log("server disabled. reason: access key expired");
    return;
  }

  app.get(ApiEndpoints.docs, (Request request) async {
    return Response.ok(renderApiRequests(),
        headers: {"Content-Type": "text/html"});
  });

  app.get(ApiEndpoints.state, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    StatsRouter statsRouter = StatsRouter(request);
    final placesResponse = await statsRouter.getState();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.employee, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    EmployeeRouter placesRouter = EmployeeRouter(request);
    final placesResponse = await placesRouter.getCategories();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.places, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    PlacesRouter placesRouter = PlacesRouter(request);
    final placesResponse = await placesRouter.getPlaces();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.categories, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    CategoriesRouter categoriesRouter = CategoriesRouter(request);
    final placesResponse = await categoriesRouter.getCategories();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.products, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    ProductsRouter categoriesRouter = ProductsRouter(request);
    final placesResponse = await categoriesRouter.getProducts();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.getEmployeeOrders();
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.placeOrders, (Request request, String id) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.getPlaceState(id);
    return placesResponse.toResponse();
  });

  app.post(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.openOrder(request);
    return placesResponse.toResponse();
  });

  app.put(ApiEndpoints.orders, (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    OrdersRouter ordersRouter = OrdersRouter(request);
    final placesResponse = await ordersRouter.closeOrder(request);
    return placesResponse.toResponse();
  });

  app.get(ApiEndpoints.getImage, (Request request, String path) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

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

    final message =
        (jsonData is String ? jsonDecode(jsonData) : jsonData)['message'] ?? '';
    log("disable: $disablePrint");
    log("jsonData: $jsonData");
    await orderDatabase.setPlaceOrder(
      data: data,
      placeId: placeId,
      disablePrint: disablePrint,
      message: message,
    );
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.get('/api/v2/orders', (Request request) async {
    final data = await orderDatabase.getDayOrders(DateTime.now());
    final dataList = [];
    for (final item in data) {
      dataList.add(Order.fromIsar(item).toJson());
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
    final message =
        (jsonData is String ? jsonDecode(jsonData) : jsonData)['message'] ?? '';

    final data = Order.fromJson(jsonData);
    await orderDatabase.updatePlaceOrder(
      data: data,
      placeId: placeId,
      message: message,
    );
    return Response(200, body: jsonEncode({'message': 'success'}));
  });

  app.get('/api/v2/percents', (Request request) async {
    OrderPercentDatabase percentDatabase = OrderPercentDatabase();
    final percents = await percentDatabase.get();
    return Response(
      200,
      body: jsonEncode([for (final item in percents) item.toJson()]),
    );
  });

  app.get('/api/v2/order-recipe/<id>', (Request request, String id) async {
    await orderDatabase.printOrderRecipe(id);
    return Response(200);
  });

  app.get('/api/v2/employee-orders/<id>', (Request request, String id) async {
    final orders = await orderDatabase.getEmployeeOrders(id);
    return Response(
      200,
      body: jsonEncode([for (final item in orders) item.toJson()]),
    );
  });

  app.get('/api/v2/image/<productId>',
      (Request request, String productId) async {
    final productData = await productDatabase.getProductById(productId);
    if (productData == null) return Response(404);
    if (productData.images == null || (productData.images ?? []).isEmpty) {
      return Response(404);
    }

    final image = productData.images?.firstOrNull;
    if (image == null || image.isEmpty) return Response(404);

    final imageFile = File(image);

    if (!await imageFile.exists()) {
      return Response(404);
    }

    final bytes = await imageFile.readAsBytes();

    final extension = p.extension(imageFile.path.split('.').last).toLowerCase();
    String contentType = 'image/jpeg';
    if (extension == '.png') contentType = 'image/png';
    if (extension == '.gif') contentType = 'image/gif';
    if (extension == '.webp') contentType = 'image/webp';

    return Response.ok(bytes, headers: {
      'Content-Type': contentType,
      'Cache-Control': 'public, max-age=3600',
    });
  });

  ///
  ///

  ///
  /// New Conditional APIs
  ///

  Future<bool> checkAccess(Request request) async {
    return true;
  }

  app.get('/api/v2/products/list', (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    if (await checkAccess(request)) {
      final page =
          int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit =
          int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      ProductsRouter router = ProductsRouter(request);
      final result =
          await router.getProductsPaginated(page: page, limit: limit);
      return result.toResponse();
    }
    return Response(403,
        body: jsonEncode({
          "error":
              "Access Denied: Condition not met (alwaysWaiter && isCashier)"
        }));
  });

  app.get('/api/v2/orders/list', (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    if (await checkAccess(request)) {
      final page =
          int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit =
          int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      OrdersRouter router = OrdersRouter(request);
      final result = await router.getOrdersPaginated(page: page, limit: limit);
      return result.toResponse();
    }
    return Response(403,
        body: jsonEncode({
          "error":
              "Access Denied: Condition not met (alwaysWaiter && isCashier)"
        }));
  });

  app.get('/api/v2/customers/list', (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    if (await checkAccess(request)) {
      final page =
          int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit =
          int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      CustomersRouter router = CustomersRouter(request);
      final result =
          await router.getCustomersPaginated(page: page, limit: limit);
      return result.toResponse();
    }
    return Response(403,
        body: jsonEncode({
          "error":
              "Access Denied: Condition not met (alwaysWaiter && isCashier)"
        }));
  });

  app.get('/api/v2/categories/list', (Request request) async {
    final status = authorizationServices.requestAuthChecker(request);
    if (!status) {
      return Response(403,
          body: jsonEncode({"error": ResponseMessages.unauthorized}));
    }

    if (await checkAccess(request)) {
      final page =
          int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
      final limit =
          int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      CategoriesRouter router = CategoriesRouter(request);
      final result =
          await router.getCategoriesPaginated(page: page, limit: limit);
      return result.toResponse();
    }
    return Response(403,
        body: jsonEncode({
          "error":
              "Access Denied: Condition not met (alwaysWaiter && isCashier)"
        }));
  });

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
