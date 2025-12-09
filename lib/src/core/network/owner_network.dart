import 'dart:developer';

import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_isar.dart';
import 'package:biznex/src/core/network/pocketbase/actions.dart';
import 'package:biznex/src/core/network/pocketbase/ingredients.dart';
import 'package:biznex/src/core/network/pocketbase/orders.dart';
import 'package:biznex/src/core/network/pocketbase/products.dart';
import 'package:biznex/src/core/network/pocketbase/repots.dart';
import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';

import '../database/isar_database/isar.dart';
import '../services/license_services.dart';
import '../utils/action_listener.dart';
import '../utils/date_utils.dart';

class OwnerService {
  bool isConnected = false;
  String? clientId;

  final AppStateDatabase stateDatabase = AppStateDatabase();

  final ChangesDatabase changesDatabase = ChangesDatabase();

  final RecipeDatabase recipeDatabase = RecipeDatabase();

  final ProductDatabase productDatabase = ProductDatabase();

  final OrderDatabase orderDatabase = OrderDatabase();

  static final PocketBase _pb = PocketBase('https://noco.biznex.uz');
  static final String _password = 'zamon.2810';
  final IngredientsService ingredientsService =
      IngredientsService(_pb, _password);

  final Isar isar = IsarDatabase.instance.isar;

  final LicenseServices licenseServices = LicenseServices();

  final ActionService actionService = ActionService(_pb, _password);

  final ReportsService reportsService = ReportsService(_pb, _password);

  final ProductsService productsService = ProductsService(_pb, _password);

  final OrdersService ordersService = OrdersService(_pb, _password);

  final EmployeeDatabase employeeDatabase = EmployeeDatabase();

  Future<void> init() async {
    final state = await stateDatabase.getApp();
    isConnected = !state.offline;
    if (state.offline) return;

    clientId = await licenseServices.getDeviceId();

    try {
      await _onSyncOrders();
      await _onSyncReports();
      await _onSyncProducts();
      await _onSyncActions();
      await _onSyncIngredients();
    } catch (error, st) {
      log("$error, $st");
    }

    isar.orderIsars.watchLazy().listen((_) async {
      try {
        await _onSyncOrders();
        await _onSyncProducts();
        await _onSyncReports();
      } catch (_) {}
    });

    ActionController.stream.listen((_) async {
      await _onSyncProducts();
      await _onSyncActions();
      await _onSyncIngredients();
    });
  }

  Future<void> _onSyncOrders() async {
    log("syncing orders");
    final dayPrefix = DateTime.now().toIso8601String().split("T").first;
    final todayOrders = await isar.orderIsars
        .filter()
        .createdDateStartsWith(dayPrefix)
        .findAll();

    for (final item in todayOrders) {
      try {
        final order = Order.fromIsar(item);
        await ordersService.createOrder(
          id: order.id.substring(0, 15),
          clientId: clientId ?? '',
          data: order.toJson(),
          employeeId: Order.fromIsar(item).employee.id,
        );
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Future<void> _onSyncActions() async {
    log("syncing actions");
    final List<Change> changes = await changesDatabase.get();
    for (final item in changes) {
      if (item.database != 'app') continue;

      try {
        await actionService.createAction(
          clientId: clientId ?? '',
          from: item.itemId,
          type: item.method,
          data: item.itemId == "admin"
              ? 'admin'
              : (await employeeDatabase.getOne(item.itemId))?.toJson(),
        );
      } catch (_) {}

      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Future<void> _onSyncProduct(String id, {Product? productModel}) async {
    Product? product;
    if (productModel != null) {
      product = productModel;
    } else {
      product = await productDatabase.getProductById(id);
    }

    if (product == null) return;

    try {
      await productsService.updateProduct(product.id.substring(0, 15),
          localId: product.id,
          price: product.price,
          clientId: clientId ?? '',
          measure: product.measure,
          oldPrice: product.price * (1 - (100 / (100 + product.percent))),
          name: product.name,
          amount: product.amount);
    } on ClientException catch (error) {
      if (error.statusCode == 404) {
        try {
          await productsService.createProduct(
            localId: product.id,
            price: product.price,
            amount: product.amount,
            clientId: clientId ?? '',
            measure: product.measure,
            oldPrice: product.price * (1 - (100 / (100 + product.percent))),
            name: product.name,
            id: product.id.substring(0, 15),
          );
        } catch (_) {}
      }
    }
  }

  Future<void> _onSyncIngredient(String id, {Ingredient? ingredient}) async {
    Ingredient? kIngredient;
    if (ingredient != null) {
      kIngredient = ingredient;
    } else {
      kIngredient = await recipeDatabase.getIngredient(id);
    }

    if (kIngredient == null) return;

    try {
      await ingredientsService.updateIngredient(
        kIngredient.id.substring(0, 15),
        price: kIngredient.unitPrice,
        clientId: clientId ?? '',
        measure: kIngredient.measure,
        name: kIngredient.name,
        amount: kIngredient.quantity,
      );
    } on ClientException catch (error) {
      if (error.statusCode == 404) {
        try {
          await ingredientsService.createIngredient(
            price: kIngredient.unitPrice,
            clientId: clientId ?? '',
            measure: kIngredient.measure,
            name: kIngredient.name,
            amount: kIngredient.quantity,
            localId: kIngredient.id,
            id: kIngredient.id.substring(0, 15),
          );
        } catch (_) {}
      }
    }
  }

  Future<void> _onSyncProducts() async {
    log("syncing products");
    final products = await productDatabase.getAll();
    for (final item in products) {
      await _onSyncProduct('id', productModel: item);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Future<void> _onSyncIngredients() async {
    log("syncing ingredients");
    final products = await recipeDatabase.getIngredients();
    for (final item in products) {
      await _onSyncIngredient('id', ingredient: item);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Future<void> _onSyncReports() async {
    log("syncing reports");
    final percentsData = await OrderPercentDatabase().get();
    final percent = percentsData.fold(0.0, (a, b) => a += b.percent);

    final prefix = DateTime.now().toIso8601String().split("T").first;
    final orders =
        await isar.orderIsars.filter().createdDateStartsWith(prefix).findAll();

    final count = orders.length;
    double percentsProfit = 0.0;
    double placesProfit = 0.0;
    double productsProfit = 0.0;
    double totalOrders = 0.0;
    for (final item in orders) {
      final order = Order.fromIsar(item);
      totalOrders += order.price;
      if (order.place.price != null) placesProfit += order.place.price ?? 0.0;

      final productOldPrice = order.products.fold(0.0, (value, product) {
        final kPrice = (product.amount *
            (product.product.price *
                (1 - (100 / (100 + product.product.percent)))));
        return value + kPrice;
      });

      productsProfit += productOldPrice;

      if (!order.place.percentNull) {
        percentsProfit += (order.price * (1 - (100 / (100 + percent))));
      }
    }

    final ingredients = (await recipeDatabase.getIngredients()).length;
    final products = (await productDatabase.getAll()).length;
    final employees = (await employeeDatabase.get()).length;
    final transactions = (await isar.transactionIsars.count());
    final shoppingList = await ShoppingDatabase().get();
    final shoppingSum =
        shoppingList.fold(0.0, (tot, shop) => tot += shop.totalPrice);

    await reportsService.updateReport(
      clientId: clientId ?? '',
      totalOrders: totalOrders,
      ordersCount: count,
      percentsProfit: percentsProfit,
      placesProfit: placesProfit,
      productsProfit: productsProfit,
      transactions: transactions,
      ingredients: ingredients,
      products: products,
      employees: employees,
      totalShopping: shoppingSum,
      weekly: await _weekly(),
    );
  }

  Future<Map<String, dynamic>> _weekly() async {
    final Isar isar = IsarDatabase.instance.isar;
    final days = AppDateUtils().last7Days();
    final Map<String, dynamic> data = {};
    for (final day in days) {
      final prefix = day.toIso8601String().split('T').first;
      final summ = await isar.orderIsars
          .where()
          .filter()
          .createdDateStartsWith(prefix)
          .priceProperty()
          .sum();

      data[prefix] = summ;
    }

    return data;
  }
}
