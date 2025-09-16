import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

class PrinterServices {
  final AppModel model;
  final Order order;

  PrinterServices({
    required this.order,
    required this.model,
  });

  Future<Uint8List?> shopLogoImage() async {
    if (model.imagePath == null || model.imagePath!.isEmpty) return null;
    final imageFile = File(model.imagePath!);
    if (!await imageFile.exists()) return null;
    return await imageFile.readAsBytes();
  }

  void printOrderCheck({String? phone, String? address}) async {
    log("printing started");

    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final font = pw.Font.ttf(fontData);

    final percents = await OrderPercentDatabase().get();
    final doc = pw.Document();

    final pdfTheme = pw.TextStyle(font: font, fontSize: 8);
    final headerStyle = pw.TextStyle(font: font, fontSize: 16);
    final boldStyle =
        pw.TextStyle(font: font, fontSize: 8, fontWeight: pw.FontWeight.bold);

    final image = await shopLogoImage();

    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (image != null) pw.Center(child: pw.Image(pw.MemoryImage(image))),
        if (image != null) pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            model.shopName == null || model.shopName!.isEmpty
                ? 'Biznex'
                : model.shopName!,
            style: headerStyle,
          ),
        ),
        pw.SizedBox(height: 2),
        if (model.shopAddress != null)
          pw.Center(
            child: pw.Text(model.shopAddress ?? '', style: pdfTheme),
          ),
        if (model.shopAddress != null) pw.SizedBox(height: 3),
        pw.Center(
          child: pw.Text(
            '${AppLocales.orderNumber.tr()}: ${order.orderNumber ?? DateTime.now().millisecondsSinceEpoch}',
            style: pdfTheme,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
        pw.SizedBox(height: 4),
        for (final item in order.products)
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
                  style: boldStyle,
                ),
              ],
            ),
          ),
        if (percents.isNotEmpty && !order.place.percentNull) ...[
          pw.SizedBox(height: 4),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
          pw.SizedBox(height: 4),
          for (final item in percents)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${item.name}: ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "${item.percent} %",
                    style: boldStyle,
                  ),
                ],
              ),
            ),
        ],
        if (order.customer != null &&
            (order.customer!.name.isNotEmpty ||
                order.customer!.phone.isNotEmpty)) ...[
          pw.SizedBox(height: 4),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
          pw.SizedBox(height: 4),
          if (order.customer?.name != null && order.customer!.name.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  "${AppLocales.deliveryAddress.tr()}:",
                  style: pdfTheme,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 2,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  order.customer?.name ?? '',
                  style: boldStyle,
                ),
              ],
            ),
          if (order.customer?.phone != null && order.customer!.phone.isNotEmpty)
            pw.SizedBox(height: 4),
          if (order.customer?.phone != null && order.customer!.phone.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  "${AppLocales.customerPhone.tr()}:",
                  style: pdfTheme,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 2,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  order.customer?.phone ?? '',
                  style: boldStyle,
                ),
              ],
            ),
        ],
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
              style: boldStyle,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                "${AppLocales.placeNameLabel.tr()}:",
                style: pdfTheme,
                overflow: pw.TextOverflow.clip,
                maxLines: 2,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              "${order.place.name}${order.place.father?.name != null ? ", ${order.place.father!.name}" : ''}",
              style: boldStyle,
            ),
          ],
        ),
        if (model.printPhone != null) pw.SizedBox(height: 4),
        if (model.printPhone != null)
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  "${AppLocales.contact.tr()}:",
                  style: pdfTheme,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 2,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                model.printPhone ?? '',
                style: boldStyle,
              ),
            ],
          ),
        if (model.printPhone != null) pw.SizedBox(height: 4),
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
              DateFormat('yyyy.MM.dd HH:mm')
                  .format(DateTime.parse(order.updatedDate)),
              style: boldStyle,
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            "${order.price.price} UZS",
            style: pw.TextStyle(font: font, fontSize: 18),
          ),
        ),
        pw.SizedBox(height: 6),
        if (model.byeText == null || model.byeText!.isEmpty)
          pw.Center(
            child: pw.Text(AppLocales.thanksForOrder.tr(), style: pdfTheme),
          )
        else
          pw.Center(
            child: pw.Text(model.byeText!, style: pdfTheme),
          ),
        pw.SizedBox(height: 4),
      ],
    );

    final pageHeight = (order.products.length * 20.0) + 1200.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
            72 * PdfPageFormat.mm, pageHeight * PdfPageFormat.mm,
            marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) => content,
      ),
    );

    log("page is done");

    final bytes = await doc.save();

    log("bytes is done");
    try {
      await Printing.directPrintPdf(
        onLayout: (PdfPageFormat format) async {
          log("printing");
          return bytes;
        },
        printer: Printer(url: model.token, name: model.refresh),
      );
    } catch (_) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          log("printing");
          return bytes;
        },
      );
    }

    log('printing completed');
  }
}
