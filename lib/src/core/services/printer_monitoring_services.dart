import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../../controllers/monitoring_controller.dart';

class PrinterMonitoringServices {
  final AppModel model;
  final Map<String, EM> employeesMonitoring;
  final Map<String, double> paymentMonitoring;
  final Map<String, OrderItem> productsMonitoring;
  final int ordersCount;
  final double ordersTotalSumm;
  final double ordersTotalProductSumm;
  final double placesTotalSumm;
  final double orderPercentSumm;
  final DateTime dateTime;

  PrinterMonitoringServices({
    required this.model,
    required this.dateTime,
    required this.employeesMonitoring,
    required this.ordersCount,
    required this.orderPercentSumm,
    required this.ordersTotalProductSumm,
    required this.ordersTotalSumm,
    required this.productsMonitoring,
    required this.paymentMonitoring,
    required this.placesTotalSumm,
  });

  Future<Uint8List?> shopLogoImage() async {
    if (model.imagePath == null || model.imagePath!.isEmpty) return null;
    final imageFile = File(model.imagePath!);
    if (!await imageFile.exists()) return null;
    return await imageFile.readAsBytes();
  }

  void printOrderCheck() async {
    log("printing started");

    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final font = pw.Font.ttf(fontData);

    final doc = pw.Document();

    final pdfTheme = pw.TextStyle(font: font, fontSize: 8);
    final headerStyle = pw.TextStyle(font: font, fontSize: 16);

    final image = await shopLogoImage();

    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (image != null) pw.Center(child: pw.Image(pw.MemoryImage(image))),
        if (image != null) pw.SizedBox(height: 2),
        pw.Text(
          DateFormat("yyyy.MM.dd").format(dateTime),
          style: headerStyle,
        ),
        pw.SizedBox(height: 8),
        pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
        pw.SizedBox(height: 8),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.orders.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    "$ordersCount",
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.profitFromPercents.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    orderPercentSumm.priceUZS,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.profitFromProducts.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    ordersTotalProductSumm.priceUZS,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.profitFromPlacePrice.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    placesTotalSumm.priceUZS,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.totalProfit.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    (ordersTotalProductSumm + orderPercentSumm).priceUZS,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.totalSumm.tr()}:",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.Text(
                    ordersTotalSumm.priceUZS,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (productsMonitoring.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
          pw.SizedBox(height: 8),
          for (final item in Transaction.values)
            if (paymentMonitoring[item] != null &&
                paymentMonitoring[item] != 0.0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Column(
                  children: [
                    pw.Row(children: [
                      pw.Text(
                        "${item.tr().capitalize}:",
                        style: pdfTheme,
                        overflow: pw.TextOverflow.clip,
                        maxLines: 2,
                      ),
                      pw.Expanded(
                        child: pw.Text(paymentMonitoring[item]?.priceUZS ?? '',
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                            textAlign: pw.TextAlign.end),
                      ),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(15, (index) {
                          return pw.Container(
                            height: 1,
                            width: 4,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex("#000000"),
                              borderRadius: pw.BorderRadius.circular(1),
                            ),
                          );
                        })
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
        ],
        pw.SizedBox(height: 8),
        pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
        pw.SizedBox(height: 8),
        if (employeesMonitoring.isNotEmpty)
          for (final item in employeesMonitoring.values)
            if (item.ordersCount != 0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                child: pw.Column(
                  children: [
                    pw.Text(
                      "${item.employee.fullname}, ${item.employee.roleName}",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.orders.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          "${item.ordersCount}",
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.profitFromPercents.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          item.percentSumm.priceUZS,
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.totalSumm.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          item.totalSumm.priceUZS,
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        if (productsMonitoring.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
          pw.SizedBox(height: 8),
          for (final item in productsMonitoring.values)
            if (item.amount != 0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                child: pw.Column(
                  children: [
                    pw.Text(
                      "${item.product.name} (${item.product.category?.name.trim()})",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.amount.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          "${item.amount.toMeasure} ${item.product.measure ?? ''}",
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.totalSumm.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          (item.amount * item.product.price).priceUZS,
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            "${AppLocales.totalProfit.tr()}:",
                            style: pdfTheme,
                            overflow: pw.TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                        pw.Text(
                          (item.amount *
                                  (item.product.price -
                                      (item.product.price /
                                          ((100 + item.product.percent) /
                                              100))))
                              .priceUZS,
                          style: pdfTheme,
                          overflow: pw.TextOverflow.clip,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(15, (index) {
                          return pw.Container(
                            height: 1,
                            width: 4,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex("#000000"),
                              borderRadius: pw.BorderRadius.circular(1),
                            ),
                          );
                        })
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
        ],
        pw.SizedBox(height: 40),
      ],
    );

    final pageHeight = (productsMonitoring.values.length * 20.0 +
            20.0 * employeesMonitoring.length +
            paymentMonitoring.length * 20.0) +
        2200.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          72 * PdfPageFormat.mm,
          pageHeight * PdfPageFormat.mm,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) => content,
      ),
    );

    final bytes = await doc.save();

    try {
      await Printing.directPrintPdf(
        usePrinterSettings: true,
        onLayout: (PdfPageFormat format) async {
          return bytes;
        },
        printer: Printer(url: model.token, name: model.refresh),
      );
    } catch (_) {
      await Printing.layoutPdf(
        usePrinterSettings: true,
        onLayout: (PdfPageFormat format) async {
          return bytes;
        },
      );
    }

    log('printing completed');
  }
}
