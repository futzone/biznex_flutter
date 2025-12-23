import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';

import 'package:biznex/src/core/services/printer_recipe_services.dart';
import '../core/model/excel_models/orders_excel_model.dart';

final productRecipeProvider = FutureProvider.family((ref, String id) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final recipe = await recipeDatabase.productRecipe(id);
  return recipe;
});

final ingredientsProvider = FutureProvider((ref) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final data = await recipeDatabase.getIngredients();
  return data;
});

final recipesProvider = FutureProvider((ref) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final data = await recipeDatabase.getRecipe();
  return data;
});

final shoppingProvider = FutureProvider((ref) async {
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  final data = await shoppingDatabase.get();
  return data;
});

final ingredientTransactionsProvider =
    FutureProvider.family((ref, String id) async {
  final isar = IsarDatabase.instance.isar;
  final dateTime = DateTime.now().subtract(Duration(days: 1));

  final data = await isar.ingredientTransactions
      .filter()
      .idEqualTo(id)
      .createdDateGreaterThan(dateTime.toIso8601String())
      .sortByCreatedDateDesc()
      .findAll();
  return data;
});

class IngredientTransactionsService {
  final Isar _isar = IsarDatabase.instance.isar;
  final DateTime startTime;
  final DateTime endTime;

  IngredientTransactionsService(this.startTime, this.endTime);

  late final provider = FutureProvider.family<Map<String, Object>, String>(
      (ref, String id) async {
    final query = _isar.ingredientTransactions
        .filter()
        .createdDateBetween(
          startTime
              .copyWith(
                hour: 0,
                minute: 0,
                second: 0,
              )
              .toIso8601String(),
          endTime
              .copyWith(
                hour: 23,
                minute: 59,
                second: 59,
              )
              .toIso8601String(),
        )
        .idEqualTo(id)
        .sortByCreatedDateDesc();

    final amount = await query.amountProperty().sum();
    final count = await query.count();
    final data = await query.findAll();

    return {"amount": amount, "count": count, "data": data};
  });

  Future<void> saveToExcel() async {
    var excel = Excel.createExcel();
    final ingredients = await RecipeDatabase().getIngredients();

    for (final item in AppDateUtils.getDaysBetween(startTime, endTime)) {
      final prefix = item.toIso8601String().split("T").first;
      Sheet sheetObject = excel[prefix];
      final query =
          _isar.ingredientTransactions.filter().createdDateStartsWith(prefix);

      sheetObject.appendRow([
        TextCellValue('Sana'),
        TextCellValue('Tovar'),
        TextCellValue('Tovar narxi'),
        TextCellValue('Sarflangan miqdori'),
        TextCellValue('Jami summa'),
      ]);
      for (final ing in ingredients) {
        final amount = await query.idEqualTo(ing.id).amountProperty().sum();

        sheetObject.appendRow([
          TextCellValue(prefix),
          TextCellValue(ing.name),
          DoubleCellValue(ing.unitPrice ?? 0.0),
          DoubleCellValue(amount),
          DoubleCellValue(amount * (ing.unitPrice ?? 0.0)),
        ]);
      }
    }

    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: 'ingredients.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var file = File("${result}.xlsx");
      await file.writeAsBytes(excel.encode()!);
    }
  }

  Future<void> printToCheck(WidgetRef ref) async {
    final ingredients = await RecipeDatabase().getIngredients();
    final model = await ref.read(appStateProvider.future);

    List<Map<String, dynamic>> dailyReports = [];

    for (final item in AppDateUtils.getDaysBetween(startTime, endTime)) {
      final prefix = item.toIso8601String().split("T").first;
      final query =
          _isar.ingredientTransactions.filter().createdDateStartsWith(prefix);

      List<Map<String, dynamic>> dayItems = [];

      for (final ing in ingredients) {
        final amount = await query.idEqualTo(ing.id).amountProperty().sum();
        if (amount > 0) {
          dayItems.add({
            "name": ing.name,
            "unitPrice": ing.unitPrice ?? 0.0,
            "amount": amount,
            "total": amount * (ing.unitPrice ?? 0.0),
          });
        }
      }

      if (dayItems.isNotEmpty) {
        dailyReports.add({
          "date": prefix,
          "items": dayItems,
        });
      }
    }

    if (dailyReports.isNotEmpty) {
      final printerService = PrinterRecipeServices(
        model: model,
        startTime: startTime,
        endTime: endTime,
      );
      await printerService.printIngredientReport(dailyReports);
    }
  }
}
