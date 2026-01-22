// import 'package:biznex/src/core/database/app_database/app_sync_database.dart';
// import 'package:biznex/src/core/database/category_database/category_database.dart';
// import 'package:biznex/src/core/database/employee_database/employee_database.dart';
// import 'package:biznex/src/core/database/order_database/order_database.dart';
// import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
// import 'package:biznex/src/core/database/place_database/place_database.dart';
// import 'package:biznex/src/core/database/product_database/product_database.dart';
// import 'package:biznex/src/core/database/product_database/recipe_database.dart';
// import 'package:biznex/src/core/database/product_database/shopping_database.dart';
// import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
// import 'package:biznex/src/core/services/device_id_service.dart';
// import 'package:mongo_dart/mongo_dart.dart';
//
// class AppBackupDatabase {
//   static final AppBackupDatabase instance = AppBackupDatabase._internal();
//   final _connectionString = "mongodb://localhost:27017";
//   late String clientId;
//   final SyncService syncService = SyncService(4);
//
//   factory AppBackupDatabase() => instance;
//
//   AppBackupDatabase._internal();
//
//   late Db db;
//
//   Future<Db> init() async {
//     db = Db(_connectionString);
//     await db.open();
//     clientId = await DeviceIdService().getDeviceId();
//     return db;
//   }
//
//   Future<void> put({required String collection, required Map data}) async {
//     final coll = db.collection(collection);
//
//     if (data['id'] != null) {
//       final newMap = data;
//       newMap['client_id'] = clientId;
//       await coll.updateOne(
//         where.eq("id", data['id']),
//         {r'$set': newMap},
//         upsert: true,
//       );
//     } else {
//       final newMap = data as Map<String, dynamic>;
//       newMap['client_id'] = clientId;
//       await coll.insert(newMap);
//     }
//   }
//
//   Future<void> syncLocalData({bool forceSync = false}) async {
//     final canSync = await syncService.canSync();
//     if (!forceSync && canSync == 'no') return;
//
//     final ProductDatabase productDatabase = ProductDatabase();
//     final TransactionsDatabase tDatabase = TransactionsDatabase();
//     final OrderDatabase orderDatabase = OrderDatabase();
//     final EmployeeDatabase employeeDatabase = EmployeeDatabase();
//     final CategoryDatabase categoryDatabase = CategoryDatabase();
//     final PlaceDatabase placeDatabase = PlaceDatabase();
//     final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
//     final RecipeDatabase recipeDatabase = RecipeDatabase();
//     final OrderPercentDatabase percentDatabase = OrderPercentDatabase();
//
//     final products = await productDatabase.getAll();
//     final transactions = await tDatabase.get();
//     final orders = await orderDatabase.getOrders();
//     final employees = await employeeDatabase.get();
//     final categories = await categoryDatabase.getAll();
//     final places = await placeDatabase.get();
//     final shopping = await shoppingDatabase.get();
//     final recipes = await recipeDatabase.getRecipe();
//     final ingredients = await recipeDatabase.getIngredients();
//     final percents = await percentDatabase.get();
//
//     if (canSync == 'first' || forceSync) {
//       for (final item in products) {
//         await put(collection: productDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in transactions) {
//         await put(collection: tDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final order in orders) {
//         await put(collection: orderDatabase.boxName, data: order.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in employees) {
//         await put(collection: employeeDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in categories) {
//         await put(collection: categoryDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in places) {
//         await put(collection: placeDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in shopping) {
//         await put(collection: shoppingDatabase.boxName, data: item.toMap());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in recipes) {
//         await put(collection: recipeDatabase.recipeBox, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in ingredients) {
//         await put(collection: recipeDatabase.ingBox, data: item.toMap());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       for (final item in percents) {
//         await put(collection: percentDatabase.boxName, data: item.toJson());
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//
//       return;
//     }
//
//     for (final item in products.where((e) => isSync(e.updatedDate))) {
//       await put(collection: productDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in transactions.where((e) => isSync(e.createdDate))) {
//       await put(collection: tDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final order in orders.where((e) => isSync(e.updatedDate))) {
//       await put(collection: orderDatabase.boxName, data: order.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in employees.where((e) => isSync(e.createdDate))) {
//       await put(collection: employeeDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in categories.where((e) => isSync(e.updatedDate))) {
//       await put(collection: categoryDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in places.where((e) => isSync(e.updatedDate))) {
//       await put(collection: placeDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in shopping.where((e) => isSync(e.updatedDate))) {
//       await put(collection: shoppingDatabase.boxName, data: item.toMap());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in recipes.where((e) => isSync(e.updatedDate))) {
//       await put(collection: recipeDatabase.recipeBox, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in ingredients.where((e) => isSync(e.updatedAt))) {
//       await put(collection: recipeDatabase.ingBox, data: item.toMap());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//
//     for (final item in percents.where((e) => isSync(e.updatedDate))) {
//       await put(collection: percentDatabase.boxName, data: item.toJson());
//       await Future.delayed(Duration(milliseconds: 100));
//     }
//   }
//
//   bool isSync(dynamic updated) {
//     if (updated == null) return true;
//
//     final date = DateTime.tryParse(updated.toString());
//     if (date != null) {
//       return syncService.shouldSync(date);
//     }
//
//     return false;
//   }
// }
