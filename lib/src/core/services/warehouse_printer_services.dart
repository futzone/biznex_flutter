import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/ui/screens/warehouse_charts/ingredient_food_screen.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/recipe_providers.dart';

class _IngredientUsage {
  final Ingredient ingredient;
  final List<ChartData> data;

  _IngredientUsage({
    required this.ingredient,
    required this.data,
  });
}

class WarehousePrinterServices {
  static final Isar isar = IsarDatabase.instance.isar;

  static Future<void> printIngredientUsage({
    required WidgetRef ref,
    required DateTime selectedDate,
    DateTime? selectedDateTime,
    bool allTime = false,
  }) async {
    final ingredients = ref.watch(ingredientsProvider).value ?? [];
    final List<_IngredientUsage> usages = [];
    final lower = selectedDate
        .copyWith(
          day: 1,
          hour: 0,
          minute: 0,
          second: 0,
        )
        .toIso8601String();
    final upper = selectedDate
        .copyWith(
          day: AppDateUtils().daysInMonth(
            selectedDate.year,
            selectedDate.month,
          ),
          hour: 0,
          minute: 0,
          second: 0,
        )
        .toIso8601String();

    for (final item in ingredients) {
      List<IngredientTransaction> transactions;
      if (allTime) {
        transactions = await isar.ingredientTransactions
            .filter()
            .idEqualTo(item.id)
            .findAll();
      } else if (selectedDateTime != null) {
        transactions = await isar.ingredientTransactions
            .filter()
            .idEqualTo(item.id)
            .createdDateStartsWith(
                selectedDateTime.toIso8601String().split("T").first)
            .findAll();
      } else {
        transactions = await isar.ingredientTransactions
            .filter()
            .idEqualTo(item.id)
            .createdDateBetween(lower, upper)
            .findAll();
      }

      final productData = {};
      for (final transaction in transactions) {
        if (productData[transaction.product.id] == null) {
          productData[transaction.product.id] = {
            'product': transaction.product,
            'amount': transaction.amount,
          };
        } else {
          productData[transaction.product.id]['amount'] += transaction.amount;
        }
      }

      final List<ChartData> data = [];

      for (final item in productData.values) {
        data.add(ChartData(item['product'].name, item['amount']));
      }

      usages.add(_IngredientUsage(ingredient: item, data: data));
    }

    await _printUsage(usages);
  }

  static Future<void> ingredientForFoodPrint({
    required Ingredient ingredient,
    required List<ChartData> data,
  }) async =>
      await _print(ingredient.name, data, ingredient.measure ?? '');

  static Future<void> ingredientUsagePrint({
    required Ingredient ingredient,
    required List<ChartData> data,
    bool shopping = false,
  }) async =>
      _print(
        "${ingredient.name} (${!shopping ? AppLocales.usage.tr() : AppLocales.shopping.tr()})",
        data,
        ingredient.measure ?? '',
      );

  static Future<void> shoppingHistoryPrint() async {}

  static Future<void> _printUsage(List<_IngredientUsage> usages) async {
    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final font = pw.Font.ttf(fontData);
    final doc = pw.Document();
    final pdfTheme = pw.TextStyle(font: font, fontSize: 8);
    final headerStyle = pw.TextStyle(font: font, fontSize: 14);

    final boldStyle = pw.TextStyle(
      font: font,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final usage in usages) ...[
          pw.Center(child: pw.Text(usage.ingredient.name, style: headerStyle)),
          pw.SizedBox(height: 4),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 0.5),
          pw.SizedBox(height: 4),
          for (final item in usage.data)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "${item.x}: ",
                      style: pdfTheme,
                      overflow: pw.TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    "${item.y.toMeasure} ${usage.ingredient.measure}",
                    style: boldStyle,
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 4),
          pw.SizedBox(height: 4),
          pw.Container(color: PdfColor.fromHex("#000000"), height: 2),
          pw.SizedBox(height: 4),
        ]
      ],
    );

    final pageHeight =
        (usages.fold((0), (a, b) => a += b.data.length) * 20.0) + 1200.0;

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
    final model = await AppStateDatabase().getApp();

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

  static Future<void> _print(
    String title,
    List<ChartData> data,
    String measure,
  ) async {
    final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    final font = pw.Font.ttf(fontData);
    final doc = pw.Document();
    final pdfTheme = pw.TextStyle(font: font, fontSize: 8);
    final headerStyle = pw.TextStyle(font: font, fontSize: 14);

    final boldStyle = pw.TextStyle(
      font: font,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text(title, style: headerStyle)),
        pw.SizedBox(height: 4),
        pw.Container(color: PdfColor.fromHex("#000000"), height: 1),
        pw.SizedBox(height: 4),
        for (final item in data)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    "${item.x}: ",
                    style: pdfTheme,
                    overflow: pw.TextOverflow.clip,
                    maxLines: 2,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  "${item.y.toMeasure} $measure",
                  style: boldStyle,
                ),
              ],
            ),
          ),
        pw.SizedBox(height: 4),
      ],
    );

    final pageHeight = (data.length * 20.0) + 1200.0;

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
    final model = await AppStateDatabase().getApp();

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
