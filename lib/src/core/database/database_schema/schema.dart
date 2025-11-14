import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseSchema {
  Future<void> save() async {
    await _onLoadData();
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/data.json');

    if (await file.exists()) return file;

    await file.create(recursive: true);
    return file;
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    final file = await _getLocalFile();

    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);
    log('✅ File saved: ${file.path}');
  }

  final TransactionsDatabase transactionsDatabase = TransactionsDatabase();
  final OrderDatabase orderDatabase = OrderDatabase();
  final ProductDatabase productDatabase = ProductDatabase();
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  final CategoryDatabase categoryDatabase = CategoryDatabase();
  final PlaceDatabase placeDatabase = PlaceDatabase();
  final EmployeeDatabase employeeDatabase = EmployeeDatabase();

  Future<void> test() async {
    log("Start: ${DateTime.now()}");
    for (int i = 0; i < 10000000; i++) {
      await orderDatabase.saveOrder(Order.fromJson({
        "place": {
          "updatedDate": "updatedDate",
          "name": "7 - Table",
          "price": null,
          "id": "8238dc46-c070-11f0-87b5-37c795480a7b",
          "image": null,
          "percentNull": false,
          "children": [],
          "father": {
            "name": "2 - Place",
            "price": null,
            "id": "6dc802e0-c070-11f0-87b5-37c795480a7b",
            "image": null,
            "percentNull": false,
            "father": null
          }
        },
        "createdDate": "2025-11-13T15:49:14.413294",
        "updatedDate": "2025-11-13T15:49:16.366275",
        "customer": {"id": "", "name": "", "phone": ""},
        "employee": {
          "fullname": "Admin",
          "createdDate": "",
          "description": null,
          "phone": null,
          "id": "",
          "roleName": "admin",
          "roleId": "-1",
          "pincode": ""
        },
        "status": "completed",
        "realPrice": null,
        "price": 91000.0,
        "note": null,
        "scheduledDate": null,
        "products": [
          {
            "placeId": "8238dc46-c070-11f0-87b5-37c795480a7b",
            "product": {
              "name": "Cake",
              "barcode": "875512685345",
              "tagnumber": "3926B",
              "cratedDate": "2025-11-13T15:33:47.078986",
              "updatedDate": "2025-11-13T15:33:47.078986",
              "informations": [],
              "description": "",
              "images": [],
              "measure": "kg",
              "color": null,
              "colorCode": null,
              "size": null,
              "price": 12000.0,
              "amount": 200.0,
              "percent": 0.0,
              "id": "3c6d9e60-c07c-11f0-ae14-577976b8aa5d",
              "productId": null,
              "variants": null,
              "category": {
                "name": "Sweets",
                "id": "64f0acd0-c070-11f0-87b5-37c795480a7b",
                "parentId": null,
                "printerParams": {},
                "icon": null,
                "updatedDate": ""
              },
              "unlimited": false
            },
            "amount": 2.0,
            "customPrice": null
          },
          {
            "placeId": "8238dc46-c070-11f0-87b5-37c795480a7b",
            "product": {
              "name": "Cola",
              "barcode": "111823832232",
              "tagnumber": "5C295",
              "cratedDate": "2025-11-13T15:33:17.670966",
              "updatedDate": "2025-11-13T15:33:17.670966",
              "informations": [],
              "description": "",
              "images": [],
              "measure": "kg",
              "color": null,
              "colorCode": null,
              "size": null,
              "price": 8500.0,
              "amount": 100.0,
              "percent": 0.0,
              "id": "2ae65060-c07c-11f0-ae14-577976b8aa5d",
              "productId": null,
              "variants": null,
              "category": {
                "name": "Drinks",
                "id": "60167500-c070-11f0-87b5-37c795480a7b",
                "parentId": null,
                "printerParams": {},
                "icon": null,
                "updatedDate": ""
              },
              "unlimited": false
            },
            "amount": 2.0,
            "customPrice": null
          },
          {
            "placeId": "8238dc46-c070-11f0-87b5-37c795480a7b",
            "product": {
              "name": "Burger",
              "barcode": "917678040362",
              "tagnumber": "3A965",
              "cratedDate": "2025-11-13T15:32:50.271076",
              "updatedDate": "2025-11-13T15:32:50.271076",
              "informations": [],
              "description": "",
              "images": [],
              "measure": "kg",
              "color": null,
              "colorCode": null,
              "size": null,
              "price": 50000.0,
              "amount": 9000.0,
              "percent": 0.0,
              "id": "1a918ef0-c07c-11f0-ae14-577976b8aa5d",
              "productId": null,
              "variants": null,
              "category": {
                "name": "Foods",
                "id": "5b9fe100-c070-11f0-87b5-37c795480a7b",
                "parentId": null,
                "printerParams": {},
                "icon": null,
                "updatedDate": ""
              },
              "unlimited": false
            },
            "amount": 1.0,
            "customPrice": null
          }
        ],
        "paymentTypes": [],
      }));
    }

    log("End: ${DateTime.now()}");
  }

  Future<void> _onLoadData() async {
    final transactions = await transactionsDatabase.get();
    final orders = await orderDatabase.getOrders();
    final recipes = await recipeDatabase.getRecipe();
    final ingredients = await recipeDatabase.getIngredients();
    final products = await productDatabase.get();
    final shopping = await shoppingDatabase.get();
    final ctg = await categoryDatabase.get();
    final places = await placeDatabase.get();
    final employees = await employeeDatabase.get();

    Map<String, List<dynamic>> data = {
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'orders': orders.map((e) => e.toJson()).toList(),
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      'shopping': shopping.map((e) => e.toMap()).toList(),
      'category': ctg.map((e) => e.toJson()).toList(),
      'places': places.map((e) => e.toJson()).toList(),
      'employees': employees.map((e) => e.toJson()).toList(),
    };

    await saveData(data);
  }
}
