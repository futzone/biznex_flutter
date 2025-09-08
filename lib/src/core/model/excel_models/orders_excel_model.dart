import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class OrdersExcelModel {
  String dateTime;
  String day;
  int ordersCount;
  double ordersSumm;

  OrdersExcelModel({
    required this.ordersCount,
    required this.ordersSumm,
    required this.dateTime,
    required this.day,
  });

  static Future<void> saveFileDialog(List<OrdersExcelModel> dataList) async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: 'orders_report.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result;

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow([
        TextCellValue('Sana'),
        TextCellValue('Hafta kuni'),
        TextCellValue('Buyurtmalar soni'),
        TextCellValue('Buyurtmalar umumiy narxi'),
      ]);

      for (var model in dataList) {
        sheetObject.appendRow([
          // TextCellValue(model.productName),
          // DoubleCellValue(model.price),
          TextCellValue(model.dateTime),
          TextCellValue(model.day),
          IntCellValue(model.ordersCount),
          DoubleCellValue(model.ordersSumm),
        ]);
      }

      var file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      print('Excel file saved at $filePath');
    } else {
      print('Fayl tanlanmadi');
    }
  }

  static Future<void> saveTransactionsFileDialog(List<OrdersExcelModel> dataList, String paymentType) async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: 'payments.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result;

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow([
        TextCellValue('Sana'),
        TextCellValue('Hafta kuni'),
        TextCellValue('Tranzaksiyalar soni'),
        TextCellValue('Umumiy summasi'),
        TextCellValue("To'lov turi"),
      ]);

      for (var model in dataList) {
        sheetObject.appendRow([
          // TextCellValue(model.productName),
          // DoubleCellValue(model.price),
          TextCellValue(model.dateTime),
          TextCellValue(model.day),
          IntCellValue(model.ordersCount),
          DoubleCellValue(model.ordersSumm),
          TextCellValue(paymentType),
        ]);
      }

      var file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      print('Excel file saved at $filePath');
    } else {
      print('Fayl tanlanmadi');
    }
  }
}
