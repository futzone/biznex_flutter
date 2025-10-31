import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
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
import '../model/category_model/category_model.dart';
import '../model/product_models/product_model.dart';

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

  static Future<void> ingredientWarehousePrint(String locale) async {
    final ingredients = await RecipeDatabase().getIngredients();
    final List<ChartData> chartData = [
      ...ingredients
          .map((e) => ChartData(e.name, e.quantity, measure: e.measure))
    ];

    await _print(
      AppLocales.warehouse.tr(),
      chartData,
      '',
      subtitle: DateFormat("yyyy, dd-MMMM, HH:mm", locale).format(
        DateTime.now(),
      ),
    );
  }

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
          pw.Row(children: [
            pw.Expanded(
              child: pw.Container(
                height: 1,
                color: PdfColors.black,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 4,
              ),
              constraints: pw.BoxConstraints(
                maxWidth: 120,
              ),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Center(
                child: pw.Text(
                  usage.ingredient.name,
                  style: headerStyle.copyWith(fontSize: 12),
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 1,
                color: PdfColors.black,
              ),
            ),
          ]),
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
          pw.SizedBox(height: 12),
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

  static Future<void> _print(String title, List<ChartData> data, String measure,
      {String? subtitle}) async {
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
        pw.Center(
          child: pw.Text(
            title,
            style: headerStyle,
            textAlign: pw.TextAlign.center,
          ),
        ),
        if (subtitle != null) pw.SizedBox(height: 4),
        if (subtitle != null)
          pw.Center(
            child: pw.Text(
              subtitle,
              style: pdfTheme,
              textAlign: pw.TextAlign.center,
            ),
          ),
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
                  "${item.y.toMeasure} ${measure.isEmpty ? (item.measure ?? '') : measure}",
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

  static Future<void> printEmployeeFood({
    required Employee employee,
    required Map productMap,
    required DateTime day,
    required BuildContext context,
  }) async {
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
        pw.Center(
          child: pw.Text(
            employee.fullname,
            style: headerStyle,
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            DateFormat("yyyy, dd-MMMM", context.locale.languageCode)
                .format(day),
            style: headerStyle,
            textAlign: pw.TextAlign.center,
          ),
        ),
        // pw.SizedBox(height: 4),
        // pw.Container(color: PdfColor.fromHex("#000000"), height: 2),
        pw.SizedBox(height: 4),
        ...productMap.keys.map((key) {
          final category = productMap[key]['category'] as Category;
          double totalSumm = 0.0;
          for (final item in productMap[key]['products'].values) {
            totalSumm += item['product'].price * item['amount'];
          }

          return pw.Column(
            children: [
              pw.SizedBox(height: 8),
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Container(
                    height: 1,
                    color: PdfColors.black,
                  ),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Text(
                    category.name,
                    style: pdfTheme.copyWith(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    height: 1,
                    color: PdfColors.black,
                  ),
                ),
              ]),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "${AppLocales.total.tr()}: ${totalSumm.priceUZS}",
                  style: pdfTheme.copyWith(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 6),
              ...(productMap[key]['products'] as Map).keys.map(
                (id) {
                  final ctgObject = productMap[key]['products'];
                  // final productsList = ctgObject.values.toList();
                  final product = ctgObject[id]['product'] as Product;
                  final amount = ctgObject[id]['amount'] as num;
                  return pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              "${product.name}: ",
                              style: pdfTheme,
                              overflow: pw.TextOverflow.clip,
                              maxLines: 2,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            "${amount.toMeasure} ${product.measure ?? ''}",
                            style: boldStyle,
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(children: [
                        ...List.generate(20, (a) {
                          return pw.Expanded(
                            child: pw.Container(
                              margin: pw.EdgeInsets.only(left: 2, right: 2),
                              height: 0.4,
                              color: PdfColors.black,
                            ),
                          );
                        }),
                      ]),
                      pw.SizedBox(height: 6),
                    ],
                  );
                },
              )
            ],
          );
        }),
        pw.SizedBox(height: 4),
      ],
    );

    final length = productMap.values.length +
        productMap.values.fold(1, (a, b) => a += b.length);

    final pageHeight = (length * 20.0) + 1200.0;

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
