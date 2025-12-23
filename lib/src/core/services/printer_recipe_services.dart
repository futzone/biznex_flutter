import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/utils/font_utils.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

class PrinterRecipeServices {
  final AppModel model;
  final DateTime startTime;
  final DateTime endTime;

  PrinterRecipeServices({
    required this.model,
    required this.startTime,
    required this.endTime,
  });

  static final FontUtils _fontUtils = FontUtils.instance;

  pw.TextStyle get _pdfTheme =>
      pw.TextStyle(font: _fontUtils.medium, fontSize: 9);

  pw.TextStyle get _headerStyle =>
      pw.TextStyle(font: _fontUtils.medium, fontSize: 16);

  pw.TextStyle get _boldStyle =>
      pw.TextStyle(font: _fontUtils.bold, fontSize: 9);

  pw.TextStyle get _smallStyle =>
      pw.TextStyle(font: _fontUtils.regular, fontSize: 7.5);

  Future<Uint8List?> _shopLogoImage() async {
    if (model.imagePath == null || model.imagePath!.isEmpty) return null;
    final imageFile = File(model.imagePath!);
    if (!await imageFile.exists()) return null;
    return await imageFile.readAsBytes();
  }

  pw.Widget _buildDottedLine() {
    return pw.Row(children: [
      ...List.generate(
        40,
        (index) {
          return pw.Expanded(
            child: pw.Container(
              margin: pw.EdgeInsets.symmetric(horizontal: 1.0, vertical: 4.0),
              color: PdfColor.fromHex("#000000"),
              height: 0.5,
            ),
          );
        },
      ),
    ]);
  }

  pw.Widget _buildHeader(Uint8List? image) {
    return pw.Column(
      children: [
        if (image != null) pw.Center(child: pw.Image(pw.MemoryImage(image))),
        if (image != null) pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            model.shopName?.isNotEmpty == true ? model.shopName! : 'Biznex',
            style: _headerStyle,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            "${DateFormat("yyyy.MM.dd").format(startTime)} - ${DateFormat("yyyy.MM.dd").format(endTime)}",
            style: _pdfTheme,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            AppLocales.recipes.tr(),
            style: _pdfTheme.copyWith(
                fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 4),
        _buildDottedLine(),
      ],
    );
  }

  pw.Widget _buildDaySummary(String date, List<Map<String, dynamic>> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(date, style: _boldStyle),
        ),
        pw.Row(
          children: [
            pw.Expanded(
                flex: 3,
                child:
                    pw.Text(AppLocales.ingredients.tr(), style: _smallStyle)),
            pw.Expanded(
                flex: 1,
                child: pw.Center(
                    child: pw.Text(AppLocales.amount.tr().substring(0, 3) + '.',
                        style: _smallStyle))),
            pw.Expanded(
                flex: 2,
                child: pw.Center(
                    child: pw.Text(
                        AppLocales.unitPrice.tr().substring(0, 3) + '.',
                        style: _smallStyle))),
            pw.Expanded(
                flex: 2,
                child: pw.Text(AppLocales.total.tr(),
                    style: _smallStyle, textAlign: pw.TextAlign.end)),
          ],
        ),
        pw.Divider(height: 1, thickness: 0.5, color: PdfColors.black),
        ...items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(item['name'],
                        style: _pdfTheme,
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Center(
                        child: pw.Text(item['amount'].toString(),
                            style: _pdfTheme)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Center(
                        child: pw.Text(item['unitPrice'].toStringAsFixed(0),
                            style: _pdfTheme)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(item['total'].toStringAsFixed(0),
                        style: _pdfTheme, textAlign: pw.TextAlign.end),
                  ),
                ],
              ),
            )),
        pw.SizedBox(height: 8),
      ],
    );
  }

  Future<void> printIngredientReport(
      List<Map<String, dynamic>> dailyReports) async {
    final image = await _shopLogoImage();
    final doc = pw.Document();

    double grandTotal = 0;
    for (var report in dailyReports) {
      for (var item in report['items']) {
        grandTotal += item['total'];
      }
    }

    final content = pw.Column(
      children: [
        _buildHeader(image),
        ...dailyReports
            .map((report) => _buildDaySummary(report['date'], report['items'])),
        _buildDottedLine(),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("${AppLocales.total.tr()}:",
                style: _boldStyle.copyWith(fontSize: 12)),
            pw.Text(grandTotal.priceUZS,
                style: _boldStyle.copyWith(fontSize: 14)),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );

    int totalItems = 0;
    for (var day in dailyReports) {
      totalItems += (day['items'] as List).length;
    }
    final pageHeight =
        (totalItems * 15.0) + (dailyReports.length * 40.0) + 300.0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          72 * PdfPageFormat.mm,
          pageHeight * PdfPageFormat.mm,
          marginLeft: 2 * PdfPageFormat.mm,
          marginRight: 2 * PdfPageFormat.mm,
          marginTop: 5 * PdfPageFormat.mm,
          marginBottom: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) => content,
      ),
    );

    final bytes = await doc.save();

    try {
      await Printing.directPrintPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        printer: Printer(url: model.token, name: model.refresh),
      );
    } catch (_) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
      );
    }
  }
}
