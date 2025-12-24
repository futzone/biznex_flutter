import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/core/services/printer_monitoring_services.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import '../core/database/isar_database/isar.dart';

final FutureProvider<List<Product>> productsProvider =
    FutureProvider<List<Product>>((ref) async {
  ProductDatabase productDatabase = ProductDatabase();
  final list = await productDatabase.get();

  list.sort((a, b) {
    final dateA =
        DateTime.parse(a.cratedDate ?? DateTime.now().toIso8601String());
    final dateB =
        DateTime.parse(b.updatedDate ?? DateTime.now().toIso8601String());
    return dateB.compareTo(dateA);
  });

  return list;
});

class ProductOrdersFilter {
  final DateTime start;
  final DateTime end;
  final String id;

  ProductOrdersFilter({
    required this.end,
    required this.start,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductOrdersFilter &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          id == other.id;

  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ id.hashCode;
}

final productOrdersProvider =
    FutureProvider.family((ref, ProductOrdersFilter filter) async {
  final Isar isar = IsarDatabase.instance.isar;

  final orders = await isar.orderIsars
      .filter()
      .createdDateBetween(
        filter.start.toIso8601String(),
        filter.end.toIso8601String(),
      )
      .productsElement((p) => p.product((pr) => pr.idEqualTo(filter.id)))
      .findAll();

  double amounts = 0.0;
  for (final order in orders) {
    amounts += (order.products
            .where((e) => e.product?.id == filter.id)
            .firstOrNull
            ?.amount) ??
        0;
  }

  print('object');

  return {'count': orders.length, 'amount': amounts};
});

class ProductMonitoringService {
  final DateTime startTime;
  final DateTime endTime;

  ProductMonitoringService({required this.startTime, required this.endTime});

  Future<void> saveToExcel() async {
    final Isar isar = IsarDatabase.instance.isar;
    final products = await ProductDatabase().get();

    final orders = await isar.orderIsars
        .filter()
        .createdDateBetween(
          startTime.toIso8601String(),
          endTime.toIso8601String(),
        )
        .findAll();

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      TextCellValue('Mahsulot nomi'),
      TextCellValue('Narxi'),
      TextCellValue('Buyurtmalar soni'),
      TextCellValue('Miqdori'),
      TextCellValue('Jami summa'),
    ]);

    for (final product in products) {
      int count = 0;
      double amount = 0;

      for (final order in orders) {
        final orderItem = order.products
            .where((e) => e.product?.id == product.id)
            .firstOrNull;
        if (orderItem != null) {
          count++;
          amount += orderItem.amount;
        }
      }

      if (count > 0) {
        sheetObject.appendRow([
          TextCellValue(product.name),
          DoubleCellValue(product.price),
          IntCellValue(count),
          DoubleCellValue(amount),
          DoubleCellValue(amount * product.price),
        ]);
      }
    }

    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: 'products_monitoring.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      if (!result.endsWith('.xlsx')) {
        result = '$result.xlsx';
      }
      var file = File(result);
      await file.writeAsBytes(excel.encode()!);
    }
  }

  Future<void> printToCheck(WidgetRef ref) async {
    final Isar isar = IsarDatabase.instance.isar;
    final products = await ProductDatabase().get();
    final model = await ref.read(appStateProvider.future);

    final orders = await isar.orderIsars
        .filter()
        .createdDateBetween(
          startTime.toIso8601String(),
          endTime.toIso8601String(),
        )
        .findAll();

    Map<String, OrderItem> productsMonitoring = {};

    for (final product in products) {
      double amount = 0;
      for (final order in orders) {
        final orderItem = order.products
            .where((e) => e.product?.id == product.id)
            .firstOrNull;
        if (orderItem != null) {
          amount += orderItem.amount;
        }
      }

      if (amount > 0) {
        productsMonitoring[product.id] = OrderItem(
          amount: amount,
          product: product,
          placeId: '',
        );
      }
    }

    final printerService = PrinterMonitoringServices(
      model: model,
      dateTime: startTime,
      employeesMonitoring: {},
      ordersCount: orders.length,
      orderPercentSumm: 0,
      ordersTotalProductSumm: 0,
      ordersTotalSumm: orders.fold(0.0, (sum, o) => sum + o.price),
      productsMonitoring: productsMonitoring,
      paymentMonitoring: {},
      placesTotalSumm: 0,
    );

    printerService.printOrderCheck();
  }
}
