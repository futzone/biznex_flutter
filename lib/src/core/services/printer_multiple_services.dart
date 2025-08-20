import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../biznex.dart';

class PrinterMultipleServices {
  Future<List<Printer>> printersList() async {
    final printers = await Printing.listPrinters();
    return printers;
  }

  Future<Map?> _getPrinter(String categoryId) async {
    CategoryDatabase categoryDatabase = CategoryDatabase();
    final categories = await categoryDatabase.getAll();
    final ctg = categories.firstWhere((item) => item.id == categoryId, orElse: () => Category(name: ''));
    return ctg.printerParams;
  }

  Future<void> printForBack(Order order, List<OrderItem> products) async {
    final categoryGroup = groupByCategory(products);

    for (final item in categoryGroup.values) {
      final product = item.firstOrNull;
      if (product == null || product.product.category == null || product.product.category?.printerParams == null) continue;

      final params = await _getPrinter(product.product.category!.id);
      log(params.toString());
      if (params == null) continue;

      try {
        _printCheck(item, order, params['url'], params['name']);
      } catch (e) {
        for (final item in products) {
          log("${item.product.name} -> ${item.amount}");
        }
      }
    }
  }

  Map<String, List<OrderItem>> groupByCategory(List<OrderItem> order) {
    log(order.length.toString());
    final Map<String, List<OrderItem>> grouped = {};

    for (var product in order) {
      final categoryId = product.product.category?.id;

      if (categoryId != null) {
        if (grouped.containsKey(categoryId)) {
          grouped[categoryId]!.add(product);
        } else {
          grouped[categoryId] = [product];
        }
      }
    }
    return grouped;
  }

  Future<void> _printCheck(List<OrderItem> products, Order order, String url, String name) async {
    for (final item in products) {
      log("${item.product.name} -> ${item.amount}");
    }
    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final ttf = pw.Font.ttf(fontData);
    final pdfTheme = pw.TextStyle(fontSize: 8, font: ttf);

    final doc = pw.Document();
    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(height: 4),
        if (products.firstOrNull?.product.category != null)
          pw.Center(
            child: pw.Text(
              "${products.first.product.category?.name}",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: ttf),
              overflow: pw.TextOverflow.clip,
              maxLines: 2,
            ),
          ),
        pw.SizedBox(height: 4),
        for (final item in products)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    "${item.product.name}: ",
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  "${item.amount.toMeasure} ${item.product.measure} * ${item.product.price.price} UZS",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ttf),
                ),
              ],
            ),
          ),
        pw.SizedBox(height: 4),
        pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                "${order.employee.roleName}:",
                style: pdfTheme,
                overflow: pw.TextOverflow.clip,
                maxLines: 2,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              order.employee.fullname,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ttf),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                "${AppLocales.orderNumber.tr()}:",
                style: pdfTheme,
                overflow: pw.TextOverflow.clip,
                maxLines: 2,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              order.orderNumber ?? order.id,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ttf),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                "${AppLocales.place.tr()}:",
                style: pdfTheme,
                overflow: pw.TextOverflow.clip,
                maxLines: 2,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              "${order.place.father != null ? order.place.father?.name == null ? '' : order.place.father!.name : ''}${order.place.name}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ttf),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                "${AppLocales.createdDate.tr()}:",
                style: pdfTheme,
                overflow: pw.TextOverflow.clip,
                maxLines: 2,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(order.updatedDate)),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ttf),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
      ],
    );

    final pageHeight = (order.products.length * 20.0) + 1100.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(72 * PdfPageFormat.mm, pageHeight * PdfPageFormat.mm, marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) => content,
      ),
    );

    await Printing.directPrintPdf(
      printer: Printer(url: url, name: name),
      onLayout: (PdfPageFormat format) async => await doc.save(),
    );

    log('print');
  }
}
