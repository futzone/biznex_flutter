import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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

  pw.Widget dottedLine() {
    return pw.Row(children: [
      ...List.generate(
        20,
        (index) {
          return pw.Expanded(
            child: pw.Container(
              margin: pw.EdgeInsets.only(
                left: index == 0 ? 0 : 2,
                right: index == 19 ? 0 : 2,
                top: 4,
                bottom: 4,
              ),
              color: PdfColor.fromHex("#000000"),
              height: 1,
            ),
          );
        },
      ),
    ]);
  }

  pw.Widget dottedLine2({int height = 12}) {
    return pw.Column(children: [
      ...List.generate(
        (height / 3).toInt(),
        (index) {
          return pw.Container(
            width: 1,
            margin: pw.EdgeInsets.only(
              top: index == 0 ? 0 : 2,
              bottom: index == ((height / 3).toInt() - 1) ? 0 : 2,
              // top: 4,
              // bottom: 4,
            ),
            color: PdfColor.fromHex("#000000"),
            height: 3,
          );
        },
      ),
    ]);
  }

  void printOrderCheck({String? phone, String? address}) async {
    log("printing started: ${order.place.price} ${order.place.name}");

    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final font = pw.Font.ttf(fontData);

    final percents = await OrderPercentDatabase().get();
    final doc = pw.Document();

    final pdfTheme = pw.TextStyle(font: font, fontSize: 7);
    final headerStyle = pw.TextStyle(font: font, fontSize: 16);
    final boldStyle = pw.TextStyle(font: font, fontSize: 7.5);

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
        dottedLine(),
        // pw.SizedBox(height: 4),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  AppLocales.productName.tr(),
                  style: pdfTheme.copyWith(fontSize: 6),
                  overflow: pw.TextOverflow.clip,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      (AppLocales.amount.tr()),
                      style: pdfTheme.copyWith(fontSize: 6),
                    ),
                  )),
              pw.SizedBox(width: 4),

              // dottedLine2(),
              pw.Expanded(
                flex: 2,
                child: pw.Center(
                  child: pw.Text(
                    (AppLocales.price.tr()),
                    style: pdfTheme.copyWith(fontSize: 6),
                  ),
                ),
              ),
              // dottedLine2(),
              pw.SizedBox(width: 4),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  AppLocales.total.tr(),
                  style: pdfTheme.copyWith(fontSize: 6),
                  textAlign: pw.TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        dottedLine(),
        for (final item in order.products)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    item.product.name.capitalize,
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
                pw.SizedBox(width: 2),

                // dottedLine2(),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      (item.amount.toMeasure),
                      style: pdfTheme,
                      maxLines: 1,
                    ),
                  ),
                ),
                // dottedLine2(),
                pw.SizedBox(width: 2),
                pw.Expanded(
                  flex: 2,
                  child: pw.Center(
                    child: pw.Text(
                      (item.product.price.price),
                      style: pdfTheme,
                    ),
                  ),
                ),
                // dottedLine2(),
                pw.SizedBox(width: 2),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    (item.product.price * item.amount).price,
                    style: pdfTheme,
                    textAlign: pw.TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        dottedLine(),
        pw.SizedBox(height: 4),
        pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    "${AppLocales.total.tr()}: ",
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  order.products.fold(0.0, (a, el) {
                    return a += (el.amount * el.product.price);
                  }).priceUZS,
                  style: pdfTheme,
                ),
              ],
            )),

        if (order.place.percent != null && order.place.percent != 0.0) ...[
          pw.SizedBox(height: 8),
          dottedLine(),
          pw.SizedBox(height: 4),
          for (final item in percents)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.placePercent.tr()} (${order.place.percent!.toMeasure} %):",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    ((order.products.fold(
                                0.0,
                                (tot, el) =>
                                    tot += el.amount * el.product.price)) *
                            (order.place.percent ?? 0.0) *
                            0.01)
                        .priceUZS,
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          if (order.place.price != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.placePrice.tr()}: ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "${order.place.price?.priceUZS}",
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          if (!order.place.percentNull && (order.place.percent ?? 0) > 0)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.placePercent.tr()} (${order.place.percent}%): ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    ((order.products.fold(
                                0.0,
                                (tot, el) =>
                                    tot += el.amount * el.product.price)) *
                            (order.place.percent ?? 0) *
                            0.01)
                        .priceUZS,
                    style: boldStyle,
                  ),
                ],
              ),
            ),
        ],

        if ((percents.isNotEmpty && !order.place.percentNull) ||
            order.place.price != null) ...[
          pw.SizedBox(height: 8),
          dottedLine(),
          pw.SizedBox(height: 4),
          for (final item in percents)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${item.name}: ${item.percent} %",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    ((order.products.fold(
                                0.0,
                                (tot, el) =>
                                    tot += el.amount * el.product.price)) *
                            item.percent *
                            0.01)
                        .priceUZS,
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          if (order.place.price != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.placePrice.tr()}: ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "${order.place.price?.priceUZS}",
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          if (!order.place.percentNull && (order.place.percent ?? 0) > 0)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${AppLocales.placePercent.tr()} (${order.place.percent}%): ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    ((order.products.fold(
                                0.0,
                                (tot, el) =>
                                    tot += el.amount * el.product.price)) *
                            (order.place.percent ?? 0) *
                            0.01)
                        .priceUZS,
                    style: boldStyle,
                  ),
                ],
              ),
            ),
        ],
        if (order.customer != null &&
            (order.customer!.name.isNotEmpty ||
                order.customer!.phone.isNotEmpty)) ...[
          dottedLine(),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              AppLocales.delivery.tr(),
              style: pdfTheme.copyWith(fontSize: 10),
              maxLines: 1,
            ),
          ),
          pw.SizedBox(height: 4),
          if (order.customer?.name != null && order.customer!.name.isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  "${AppLocales.address.tr()}:",
                  style: pdfTheme,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 2,
                ),
                pw.SizedBox(height: 4),
                pw.Expanded(
                  child: pw.Text(order.customer?.name ?? '',
                      style: boldStyle, textAlign: pw.TextAlign.right),
                ),
              ],
            ),
          if (order.customer?.phone != null && order.customer!.phone.isNotEmpty)
            pw.SizedBox(height: 4),
          if (order.customer?.phone != null && order.customer!.phone.isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  "${AppLocales.phone.tr()}:",
                  style: pdfTheme,
                  overflow: pw.TextOverflow.clip,
                  maxLines: 2,
                ),
                pw.SizedBox(height: 4),
                pw.Expanded(
                  child: pw.Text(order.customer?.phone ?? '',
                      style: boldStyle, textAlign: pw.TextAlign.right),
                ),
              ],
            ),
        ],
        pw.SizedBox(height: 4),
        dottedLine(),
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
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            "${order.price.price} UZS",
            style: pw.TextStyle(font: font, fontSize: 18),
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Row(children: [
          pw.Expanded(child: pw.Container(height: 1, color: PdfColors.black)),
          pw.Container(
            constraints: pw.BoxConstraints(maxWidth: 120),
            padding: pw.EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: (model.byeText == null || model.byeText!.isEmpty)
                ? pw.Center(
                    child: pw.Text(
                      AppLocales.thanksForOrder.tr(),
                      style: pdfTheme,
                      textAlign: pw.TextAlign.center,
                    ),
                  )
                : pw.Center(
                    child: pw.Text(
                      model.byeText!,
                      style: pdfTheme,
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
          ),
          pw.Expanded(child: pw.Container(height: 1, color: PdfColors.black)),
        ]),
        pw.SizedBox(height: 8),
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
