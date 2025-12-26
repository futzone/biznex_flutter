import 'package:biznex/src/core/cloud/change_versions_db.dart';
import 'package:biznex/src/core/cloud/cloud_event.dart';
import 'package:biznex/src/core/cloud/cloud_services.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:uuid/uuid.dart';

class EventResult {
  final List<Map<String, dynamic>> eventData;
  final List<String> eventIds;

  EventResult({required this.eventData, required this.eventIds});
}

class BiznexCloudController {
  final BiznexCloudServices cloudServices = BiznexCloudServices();
  final ChangeVersionsDB _versionsDB = ChangeVersionsDB();
  final Uuid uuid = Uuid();
  final LocalChanges localChanges = LocalChanges();
  final ProductDatabase _productDatabase = ProductDatabase();
  final EmployeeDatabase _employeeDatabase = EmployeeDatabase();
  final OrderDatabase _orderDatabase = OrderDatabase();
  final CategoryDatabase _categoryDatabase = CategoryDatabase();
  final TransactionsDatabase _transactionsDatabase = TransactionsDatabase();

  Future<EventResult> _getEvents({int size = 1023}) async {
    List<Map<String, dynamic>> eventsList = [];
    List<String> eventDataIds = [];
    final changes = await localChanges.getChanges();
    for (final item in changes) {
      Map<String, dynamic>? eventData;

      if (item.entityType == Entity.PRODUCT) {
        final product = await _productDatabase.getProductById(item.entityId);
        if (product == null && item.eventType != ProductEvent.PRODUCT_DELETED) {
          continue;
        }
        eventData = product?.toJson();
      } else if (item.entityType == Entity.ORDER) {
        final order = await _orderDatabase.getOrderById(item.entityId);
        if (order == null) continue;
        eventData = order.toJson();
      } else if (item.entityType == Entity.EMPLOYEE) {
        final employee = await _employeeDatabase.getOne(item.entityId);
        if (employee == null &&
            item.eventType != EmployeeEvent.EMPLOYEE_DELETED) {
          continue;
        }
        eventData = employee?.toJson();
      } else if (item.entityType == Entity.CATEGORY) {
        final category = await _categoryDatabase.getOne(id: item.entityId);
        if (category == null &&
            item.eventType != CategoryEvent.CATEGORY_DELETED) {
          continue;
        }
        eventData = category?.toJson();
      } else if (item.entityType == Entity.TRANSACTION) {
        final transaction = await _transactionsDatabase.getTransactionById(
          item.entityId,
        );
        if (transaction == null) continue;
        eventData = transaction.toJson();
      }

      final CloudEvent cloudEvent = CloudEvent(
        entityType: item.entityType,
        eventType: item.eventType,
        entityId: item.entityId,
        entityVersion: await _versionsDB.getEntityVersion(item.entityId),
        payloadVersion: _versionsDB.payloadVersion,
        data: eventData ?? {},
        eventSeq: await _versionsDB.getEventSeq(),
      );

      final newList = [...eventsList, cloudEvent.toJson()];
      if (cloudServices.checkRequestSize(newList, size)) {
        return EventResult(eventData: eventsList, eventIds: eventDataIds);
      }

      eventsList.add(cloudEvent.toJson());
      eventDataIds.add(item.id);
    }

    return EventResult(eventData: eventsList, eventIds: eventDataIds);
  }

  int _size = 1023;

  Future<void> sync() async {
    final connection = await cloudServices.hasConnection();
    if (!connection) return;

    final changes = await localChanges.getChanges();
    if (changes.isEmpty) return;

    final eventsData = await _getEvents(size: _size);
    final response = await cloudServices.ingestEvent(
      CloudEventIngestion(
        events: eventsData.eventData,
        batchId: uuid.v7(),
      ),
    );

    if (response.sizeUnder) {
      _size--;
      await sync();
      return;
    }

    if (response.success) {
      for (final id in eventsData.eventIds) {
        await localChanges.deleteChange(id);
      }
    }
  }
}
