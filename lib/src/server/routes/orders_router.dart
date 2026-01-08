import 'dart:convert';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/order_models/order_set_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';

// import 'package:biznex/src/core/services/printer_multiple_services.dart';
import 'package:biznex/src/core/utils/product_utils.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:isar/isar.dart';
import 'package:shelf/src/request.dart';

class OrdersRouter {
  Request request;

  OrdersRouter(this.request);

  DatabaseMiddleware databaseMiddleware(boxName) => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: boxName,
      );

  OrderDatabase orderDatabase = OrderDatabase();

  Future<AppResponse> getEmployeeOrders() async {
    final employee = await databaseMiddleware(orderDatabase.getBoxName('all'))
        .employeeState();
    if (employee == null) {
      return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    }
    final box =
        await databaseMiddleware(orderDatabase.getBoxName('all')).openBox();
    List responseList = [];
    for (final item in box.values) {
      if (item['employee']['id'] == employee.id) {
        responseList.add(item);
      }
    }

    return AppResponse(statusCode: 200, data: responseList);
  }

  Future<AppResponse> getOrdersPaginated({int page = 1, int limit = 20}) async {
    final ordersMapList = [];
    final ordersList = await IsarDatabase.instance.isar.orderIsars
        .where()
        .sortByCreatedDateDesc()
        .offset((page - 1) * limit)
        .limit(limit)
        .findAll();

    for (final item in ordersList) {
      ordersMapList.add(Order.fromIsar(item).toJson());
    }

    return AppResponse(statusCode: 200, data: ordersMapList);
  }

  Future<AppResponse> getPlaceState(String id) async {
    final employee = await databaseMiddleware(orderDatabase.getBoxName('all'))
        .employeeState();
    if (employee == null)
      return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final state = await orderDatabase.getPlaceOrder(id);

    return AppResponse(statusCode: 200, data: state?.toJson());
  }

  Future<AppResponse> openOrder(Request request) async {
    final employee = await databaseMiddleware(orderDatabase.getBoxName('all'))
        .employeeState();
    if (employee == null)
      return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final body = await request.readAsString();
    final bodyJson = jsonDecode(body);
    OrderModel orderModel = OrderModel.fromJson(bodyJson);
    final response = await _openOrder(orderModel, employee);

    return response;
  }

  Future<AppResponse> closeOrder(Request request) async {
    final employee = await databaseMiddleware(orderDatabase.getBoxName('all'))
        .employeeState();
    if (employee == null)
      return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final body = await request.readAsString();
    final bodyJson = jsonDecode(body);
    if (bodyJson['placeId'] == null) {
      return AppResponse(
          statusCode: 400, error: ResponseMessages.placeIdRequired);
    }

    final placeId = bodyJson['placeId'];
    Order? placeState = await orderDatabase.getPlaceOrder(placeId);

    Order newOrder = placeState!;

    if (!newOrder.place.percentNull) {
      final percents = await OrderPercentDatabase().get();
      final totalPercent =
          percents.map((e) => e.percent).fold(0.0, (a, b) => a + b);
      newOrder.price =
          placeState.price + (placeState.price * (totalPercent / 100));
    }
    if (newOrder.place.price != null) {
      newOrder.price = newOrder.price + (newOrder.place.price ?? 0.0);
    }

    final database = OrderDatabase();
    newOrder.status = Order.completed;
    await database.saveOrder(newOrder);
    await _onUpdateAmounts(newOrder);
    await database.closeOrder(placeId: placeId);

    // try {
    //   final model = await AppStateDatabase().getApp();
    //   PrinterServices printerServices = PrinterServices(order: newOrder, model: model);
    //   printerServices.printOrderCheck();
    // } catch (e) {
    //   log("$e");
    // }

    return AppResponse(statusCode: 200, message: ResponseMessages.orderClosed);
  }

  Future<void> _onUpdateAmounts(Order order) async {
    ProductDatabase productDatabase = ProductDatabase();
    for (final item in order.products) {
      Product product = item.product;
      if (product.unlimited) continue;
      if (product.amount == 1) continue;

      product.amount = product.amount - item.amount;
      await productDatabase.update(key: product.id, data: product);
    }
  }

  Future<AppResponse> _openOrder(OrderModel order, Employee employee) async {
    Place? place;
    Place? fatherPlace;
    final places = await PlaceDatabase().get();
    if (order.placeFatherId != null) {
      fatherPlace = places.firstWhere((el) => el.id == order.placeFatherId,
          orElse: () => Place(name: '-', id: '=', price: null));
    }

    if (fatherPlace != null && fatherPlace.id == '=') {
      return AppResponse(
          statusCode: 404,
          data: order.placeFatherId,
          error: ResponseMessages.fatherPlaceNotFound);
    }

    if (fatherPlace != null &&
        fatherPlace.children != null &&
        fatherPlace.children!.isNotEmpty) {
      place = fatherPlace.children?.firstWhere((el) => el.id == order.placeId,
          orElse: () => Place(name: '-', id: '=', price: null));
    }

    if (place != null && place.id == '=') {
      return AppResponse(
          statusCode: 404,
          data: order.placeId,
          error: ResponseMessages.placeNotFound);
    }

    if (order.placeFatherId == null) {
      place = places.firstWhere((el) => el.id == order.placeId,
          orElse: () => Place(name: '-', id: '=', price: null));
    }

    if (place != null && place.id == '=') {
      return AppResponse(
        statusCode: 404,
        data: order.placeId,
        error: ResponseMessages.placeNotFound,
      );
    }

    final products = await ProductDatabase().get();
    Product? stockError;
    Map<String, Product> productsMap = {};

    for (final item in order.items) {
      final productState = products.firstWhere((el) => el.id == item.productId,
          orElse: () => Product(name: '', price: 0, amount: 0));
      if (productState.amount < item.amount) {
        stockError = productState;
        break;
      } else {
        productsMap[item.productId] = productState;
      }
    }

    if (stockError != null) {
      return AppResponse(
          statusCode: 404,
          data: stockError.toJson(),
          error: ResponseMessages.productStockError);
    }

    double totalPrice = order.items.fold(0, (oldValue, element) {
      return oldValue += (products.firstWhere((prd) {
            return prd.id == element.productId;
          }, orElse: () => Product(name: '', price: 0)).price *
          element.amount);
    });

    place?.father ??= fatherPlace;

    Order? placeState = await orderDatabase.getPlaceOrder(place!.id);

    if (placeState == null) {
      Order newOrder = Order(
        // paymentTypes: order.
        paymentTypes: [],
        place: place,
        employee: employee,
        price: totalPrice,
        products: order.items
            .map((el) => OrderItem(
                product: productsMap[el.productId]!,
                amount: el.amount,
                placeId: place!.id))
            .toList(),
        createdDate: DateTime.now().toIso8601String(),
        updatedDate: DateTime.now().toIso8601String(),
        customer: order.customerName != null
            ? Customer(
                name: order.customerName!,
                phone: order.customerPhone ?? '',
                id: ProductUtils.generateID,
              )
            : null,
        note: order.note,
        scheduledDate: order.scheduledDate,
        orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await orderDatabase.setPlaceOrder(
        data: newOrder,
        placeId: place.id,
        message: '',
      );

      // PrinterMultipleServices printerMultipleServices = PrinterMultipleServices();
      // printerMultipleServices.printForBack(newOrder, newOrder.products);
      return AppResponse(
          statusCode: 201, message: ResponseMessages.orderOpened);
    }

    final Order? olState = await orderDatabase.getPlaceOrder(place.id);

    placeState.updatedDate = DateTime.now().toIso8601String();
    placeState.products = order.items
        .map((el) => OrderItem(
            product: productsMap[el.productId]!,
            amount: el.amount,
            placeId: place!.id))
        .toList();
    placeState.customer = order.customerName != null
        ? Customer(
            name: order.customerName!,
            phone: order.customerPhone ?? '',
            id: ProductUtils.generateID,
          )
        : placeState.customer;

    double newTotalPrice = order.items.fold(0, (oldValue, element) {
      return oldValue += (products.firstWhere((prd) {
            return prd.id == element.productId;
          }, orElse: () => Product(name: '', price: 0)).price *
          element.amount);
    });

    placeState.note = order.note ?? placeState.note;
    placeState.price = newTotalPrice;
    placeState.scheduledDate = order.scheduledDate ?? placeState.scheduledDate;
    await orderDatabase.updatePlaceOrder(
      data: placeState,
      placeId: place.id,
      message: '',
    );

    // PrinterMultipleServices printerMultipleServices = PrinterMultipleServices();
    final List<OrderItem> productChanges =
        _onGetChanges(placeState.products, olState!);

    // log('changes: ${productChanges.length}');
    // printerMultipleServices.printForBack(placeState, productChanges);
    return AppResponse(statusCode: 200, message: ResponseMessages.orderUpdated);
  }

  List<OrderItem> _onGetChanges(
      List<OrderItem> newItemsList, Order oldOrderState) {
    final List<OrderItem> changes = [];

    final oldItemsMap = {
      for (var item in oldOrderState.products) item.product.id: item
    };
    final newItemsMap = {for (var item in newItemsList) item.product.id: item};

    for (final newItem in newItemsList) {
      final oldItem = oldItemsMap[newItem.product.id];
      if (oldItem == null) {
        changes.add(newItem.copyWith());
      } else if (newItem.amount != oldItem.amount) {
        changes.add(newItem.copyWith(amount: newItem.amount - oldItem.amount));
      }
    }

    for (final oldItem in oldOrderState.products) {
      if (!newItemsMap.containsKey(oldItem.product.id)) {
        changes.add(oldItem.copyWith(amount: -oldItem.amount));
      }
    }

    return changes;
  }

  static ApiRequest orders() => ApiRequest(
        name: 'Get Orders',
        path: ApiEndpoints.orders,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: [
          {
            "place": {
              "name": "table 1",
              "id": "950708f0-19fa-11f0-80b6-5b844bb28dff",
              "image": null,
              "children": [],
              "father": {
                "name": "redy",
                "id": "8b880130-19fa-11f0-80b6-5b844bb28dff",
                "image": null,
                "father": null
              }
            },
            "id": "8eed1a50-1b5c-11f0-8e81-79294647df32",
            "createdDate": "2025-04-17T12:21:19.707097",
            "updatedDate": "2025-04-17T12:21:19.707097",
            "customer": null,
            "employee": {
              "fullname": "Name",
              "createdDate": "",
              "description": null,
              "phone": "876543234567",
              "id": "40290a10-1796-11f0-8d58-5fe7800001ab",
              "roleName": "Harrom",
              "roleId": "37a1f6e0-1796-11f0-8d58-5fe7800001ab",
              "pincode": "1111"
            },
            "status": "completed",
            "realPrice": null,
            "price": 22590.0,
            "note": "",
            "scheduledDate": null,
            "products": [
              {
                "placeId": "950708f0-19fa-11f0-80b6-5b844bb28dff",
                "product": {
                  "name": "Bulochka",
                  "barcode": "886021044309",
                  "tagnumber": "370C3",
                  "cratedDate": "2025-04-16T14:20:29.475858",
                  "updatedDate": "2025-04-16T14:20:29.474841",
                  "informations": [],
                  "description": "",
                  "images": [],
                  "measure": "gramm",
                  "color": null,
                  "colorCode": null,
                  "size": null,
                  "price": 13440.0,
                  "amount": 213.0,
                  "percent": 12.0,
                  "id": "0a176730-1aa4-11f0-8fa3-998087b4fdae",
                  "productId": null,
                  "variants": null,
                  "category": {
                    "name": "Dessert",
                    "id": "26c32500-1aa3-11f0-8fa3-998087b4fdae",
                    "parentId": null,
                    "printerParams": {}
                  }
                },
                "amount": 1.0,
                "customPrice": null
              },
              {
                "placeId": "950708f0-19fa-11f0-80b6-5b844bb28dff",
                "product": {
                  "name": "Kirvetki",
                  "barcode": "920783232801",
                  "tagnumber": "F4055",
                  "cratedDate": "2025-04-16T14:17:18.133468",
                  "updatedDate": "2025-04-16T14:17:18.132480",
                  "informations": [],
                  "description": "",
                  "images": [],
                  "measure": "gramm",
                  "color": null,
                  "colorCode": null,
                  "size": null,
                  "price": 1100.0,
                  "amount": 123.0,
                  "percent": 10.0,
                  "id": "980aee50-1aa3-11f0-8fa3-998087b4fdae",
                  "productId": null,
                  "variants": null,
                  "category": {
                    "name": "Shurpa",
                    "id": "2a1de8c0-1aa3-11f0-8fa3-998087b4fdae",
                    "parentId": null,
                    "printerParams": {}
                  }
                },
                "amount": 1.0,
                "customPrice": null
              },
              {
                "placeId": "950708f0-19fa-11f0-80b6-5b844bb28dff",
                "product": {
                  "name": "Somsa",
                  "barcode": "308591191324",
                  "tagnumber": "14F9E",
                  "cratedDate": "2025-04-16T14:18:09.060903",
                  "updatedDate": "2025-04-16T14:18:09.059901",
                  "informations": [],
                  "description": "",
                  "images": [],
                  "measure": "gramm",
                  "color": null,
                  "colorCode": null,
                  "size": null,
                  "price": 8050.0,
                  "amount": 123.0,
                  "percent": 15.0,
                  "id": "b665c640-1aa3-11f0-8fa3-998087b4fdae",
                  "productId": null,
                  "variants": null,
                  "category": {
                    "name": "Meal",
                    "id": "2321bb50-1aa3-11f0-8fa3-998087b4fdae",
                    "parentId": null,
                    "printerParams": {}
                  }
                },
                "amount": 1.0,
              }
            ],
            "orderNumber": null
          },
        ],
      );

  static ApiRequest placeState() => ApiRequest(
        name: 'Get Place State',
        path: "${ApiEndpoints.placeOrders}{place_id}",
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: {
          "place": {
            "name": "table 1",
            "id": "950708f0-19fa-11f0-80b6-5b844bb28dff",
            "image": null,
            "children": [],
            "father": {
              "name": "redy",
              "id": "8b880130-19fa-11f0-80b6-5b844bb28dff",
              "image": null,
              "father": null
            }
          },
          "id": "bf3e7570-1b5f-11f0-8c85-1f38c19c7799",
          "createdDate": "2025-04-17T12:44:09.287983",
          "updatedDate": "2025-04-17T12:44:09.287983",
          "customer": null,
          "employee": {
            "fullname": "Name",
            "createdDate": "",
            "description": null,
            "phone": "876543234567",
            "id": "40290a10-1796-11f0-8d58-5fe7800001ab",
            "roleName": "Harrom",
            "roleId": "37a1f6e0-1796-11f0-8d58-5fe7800001ab",
            "pincode": "1111"
          },
          "status": "opened",
          "realPrice": null,
          "price": 53050.0,
          "note": "",
          "scheduledDate": null,
          "products": [
            {
              "placeId": "950708f0-19fa-11f0-80b6-5b844bb28dff",
              "product": {
                "name": "Somsa",
                "barcode": "308591191324",
                "tagnumber": "14F9E",
                "cratedDate": "2025-04-16T14:18:09.060903",
                "updatedDate": "2025-04-16T14:18:09.059901",
                "informations": [],
                "description": "",
                "images": [],
                "measure": "gramm",
                "color": null,
                "colorCode": null,
                "size": null,
                "price": 8050.0,
                "amount": 122.0,
                "percent": 15.0,
                "id": "b665c640-1aa3-11f0-8fa3-998087b4fdae",
                "productId": null,
                "variants": null,
                "category": {
                  "name": "Meal",
                  "id": "2321bb50-1aa3-11f0-8fa3-998087b4fdae",
                  "parentId": null,
                  "printerParams": {}
                }
              },
              "amount": 1.0,
            },
            {
              "placeId": "950708f0-19fa-11f0-80b6-5b844bb28dff",
              "product": {
                "name": "Sendvich",
                "barcode": "373827905147",
                "tagnumber": "57393",
                "cratedDate": "2025-04-16T14:19:03.460033",
                "updatedDate": "2025-04-16T14:19:03.460033",
                "informations": [],
                "description": "",
                "images": [],
                "measure": "gramm",
                "color": null,
                "colorCode": null,
                "size": null,
                "price": 45000.0,
                "amount": 899.0,
                "percent": 0.0,
                "id": "d6d28e40-1aa3-11f0-8fa3-998087b4fdae",
                "productId": null,
                "variants": null,
                "category": {
                  "name": "Meal",
                  "id": "2321bb50-1aa3-11f0-8fa3-998087b4fdae",
                  "parentId": null,
                  "printerParams": {},
                }
              },
              "amount": 1.0,
            }
          ],
          "orderNumber": "1744875849287"
        },
      );

  static ApiRequest open() => ApiRequest(
        name: 'Open order for place',
        path: ApiEndpoints.orders,
        method: 'POST',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: """{
  "note": "Buyurtma tug'ilgan kun uchun",
  "id": "order_123",
  "placeId": "place_456",
  "placeFatherId": "placeplaceFatherId_456",
  "customerName": "Sardor Abdullayev",
  "customerPhone": "+998901234567",
  "scheduledDate": "2025-04-20T15:30:00",
  "items": [
    {
      "amount": 2.5,
      "productId": "product_789"
    },
    {
      "amount": 1.0,
      "productId": "product_321"
    }
  ]
}
""",
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: {'message': ResponseMessages.orderCreated},
      );

  static ApiRequest close() => ApiRequest(
        name: 'Close place order',
        path: ApiEndpoints.orders,
        method: 'PUT',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{"placeId": "place_456"}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: {'message': ResponseMessages.orderClosed},
      );
}
