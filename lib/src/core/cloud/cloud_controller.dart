import 'dart:developer';

import 'package:biznex/src/core/cloud/change_versions_db.dart';
import 'package:biznex/src/core/cloud/cloud_event.dart';
import 'package:biznex/src/core/cloud/cloud_services.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
import 'package:biznex/src/core/cloud/migrations/migration_status.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/employee_database/role_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class EventResult {
  final List<Map<String, dynamic>> eventData;

  EventResult({required this.eventData});
}

class BiznexCloudController {
  final BiznexCloudServices cloudServices = BiznexCloudServices();
  final ChangeVersionsDB _versionsDB = ChangeVersionsDB();
  final Uuid uuid = Uuid();
  final MigrationStatus _migrationStatus = MigrationStatus();

  late final Map<String, Future<dynamic> Function(String id)> _dbFetchers;
  final pDb = ProductDatabase();
  final eDb = EmployeeDatabase();
  final oDb = OrderDatabase();
  final cDb = CategoryDatabase();
  final tDb = TransactionsDatabase();
  final rDb = RecipeDatabase();
  final custDb = CustomerDatabase();
  final plDb = PlaceDatabase();
  final roleDb = RoleDatabase();
  final shopDb = ShoppingDatabase();
  final perDb = OrderPercentDatabase();

  BiznexCloudController() {
    _dbFetchers = {
      Entity.PRODUCT.name: (id) async =>
          (await pDb.getProductById(id))?.toJson(),
      Entity.ORDER.name: (id) async => (await oDb.getOrderById(id))?.toJson(),
      Entity.EMPLOYEE.name: (id) async => (await eDb.getOne(id))?.toJson(),
      Entity.CATEGORY.name: (id) async => (await cDb.getOne(id: id))?.toJson(),
      Entity.TRANSACTION.name: (id) async =>
          (await tDb.getTransactionById(id))?.toJson(),
      Entity.INGREDIENT.name: (id) async =>
          (await rDb.getIngredient(id))?.toMap(),
      Entity.RECIPE.name: (id) async => (await rDb.getOneRecipe(id))?.toJson(),
      Entity.CUSTOMER.name: (id) async =>
          (await custDb.getCustomer(id))?.toJson(),
      Entity.PLACE.name: (id) async => (await plDb.getOne(id))?.toJson(),
      Entity.ROLE.name: (id) async => (await roleDb.getRole(id))?.toJson(),
      Entity.PERCENT.name: (id) async =>
          (await perDb.getPercentById(id))?.toJson(),
      Entity.SHOPPING.name: (id) async =>
          (await shopDb.getShopping(id))?.toMap(),
    };
  }

  bool _isDeleteEvent(String eventType) {
    return eventType.endsWith('_DELETED');
  }

  Future<EventResult> _getEvents({int maxSize = 1023}) async {
    final LocalChanges localChanges = LocalChanges();

    final List<Map<String, dynamic>> eventsList = [];
    final List<String> eventDataIds = [];
    final changes = await localChanges.getChanges();

    for (final item in changes) {
      final fetcher = _dbFetchers[item.entityType.name];

      final results = await Future.wait([
        fetcher != null ? fetcher(item.entityId) : Future.value(null),
        _versionsDB.getEntityVersion(item.entityId),
        _versionsDB.getEventSeq(),
      ]);

      final dbData = results[0] as Map<String, dynamic>?;
      final entityVersion = results[1] as int;
      final eventSeq = results[2] as int;

      if (dbData == null && !_isDeleteEvent(item.eventType.getName())) {
        continue;
      }

      final payloadData = dbData ?? {};

      final CloudEvent cloudEvent = CloudEvent(
        id: item.id,
        entityType: item.entityType,
        eventType: item.eventType,
        entityId: item.entityId,
        entityVersion: entityVersion,
        payloadVersion: _versionsDB.payloadVersion,
        data: payloadData,
        eventSeq: eventSeq,
      );

      final eventJson = cloudEvent.toJson();
      eventsList.add(eventJson);

      if (cloudServices.checkRequestSize(eventsList, maxSize)) {
        eventsList.removeLast();
        return EventResult(eventData: eventsList);
      }

      eventDataIds.add(item.id);
    }

    return EventResult(eventData: eventsList);
  }

  Future<void> _runMigrations() async {
    final status = await _migrationStatus.getStatus();
    log("Migration status: $status");

    if (status) return;

    try {
      await _migrateEntity(
        pDb.getAll,
        Entity.PRODUCT,
        ProductEvent.PRODUCT_CREATED,
      );

      await _migrateEntity(
        custDb.get,
        Entity.CUSTOMER,
        CustomerEvent.CUSTOMER_CREATED,
      );

      await _migrateEntity(
        cDb.get,
        Entity.CATEGORY,
        CategoryEvent.CATEGORY_CREATED,
      );

      await _migrateEntity(
        plDb.get,
        Entity.PLACE,
        PlaceEvent.PLACE_CREATED,
      );

      await _migrateEntity(
        perDb.get,
        Entity.PERCENT,
        PercentEvent.PERCENT_CREATED,
      );

      await _migrateEntity(
        eDb.get,
        Entity.EMPLOYEE,
        EmployeeEvent.EMPLOYEE_CREATED,
      );

      await _migrateEntity(
        roleDb.get,
        Entity.ROLE,
        RoleEvent.ROLE_CREATED,
      );

      await _migrateEntity(
        rDb.getIngredients,
        Entity.INGREDIENT,
        IngredientEvent.INGREDIENT_CREATED,
      );

      await _migrateEntity(
        rDb.getRecipe,
        Entity.RECIPE,
        RecipeEvent.RECIPE_CREATED,
      );

      await _migrateEntity(
        shopDb.get,
        Entity.SHOPPING,
        ShoppingEvent.SHOPPING_CREATED,
      );

      await _migrationStatus.saveStatus(true);
    } catch (error, st) {
      log('Error in migrations:', error: error, stackTrace: st);
    }
  }

  Future<void> _migrateEntity(
    Future<List<dynamic>> Function() fetcher,
    Entity entityType,
    EntityEvent eventType,
  ) async {
    final items = await fetcher();
    if (items.isEmpty) return;

    final LocalChanges localChanges = LocalChanges();
    for (final item in items) {
      await localChanges.saveChange(
        event: eventType,
        entity: entityType,
        objectId: item.id,
      );
    }
  }

  Future<void> sync() async {
    final state = await AppStateDatabase().getApp();
    if (state.alwaysWaiter) return;

    final LocalChanges localChanges = LocalChanges();
    final connection = await cloudServices.hasConnection();
    if (!connection) return;
    await _runMigrations();

    while (true) {
      final eventsResult = await _getEvents(maxSize: 1023);

      if (eventsResult.eventData.isEmpty) break;

      final response = await cloudServices.ingestEvent(
        CloudEventIngestion(
          events: eventsResult.eventData,
          batchId: uuid.v7(),
        ),
      );

      if (response.success) {
        for (final item in eventsResult.eventData) {
          try {
            if (item['eventType'] == ProductEvent.PRODUCT_CREATED.name ||
                item['eventType'] == ProductEvent.PRODUCT_IMAGE_UPDATED.name) {
              final productId = item['entityId'];
              final product = await pDb.getProductById(productId);
              if (product == null) {
                await localChanges.deleteChange(item['id']);
                continue;
              }
              await cloudServices.uploadProductImage(
                product.images?.firstOrNull ?? '',
                productId: product.id,
              );
            }
            await localChanges.deleteChange(item['id']);
          } catch (error, st) {
            log("ERROR ON K9: $item ", error: error, stackTrace: st);
          }
        }
      } else {
        break;
      }
    }
  }
}
