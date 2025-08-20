import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ProductsExcelModel {
  String dateTime;
  String productName;
  double price;
  int ordersCount;
  double ordersSumm;

  ProductsExcelModel({
    required this.ordersCount,
    required this.ordersSumm,
    required this.dateTime,
    required this.price,
    required this.productName,
  });

  static Future<void> saveFileDialog(List<ProductsExcelModel> dataList) async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: 'products_report.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result;

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow([
        TextCellValue('Mahsulot nomi'),
        TextCellValue('Narxi'),
        TextCellValue('Buyurtmalar soni'),
        TextCellValue('Buyurtmalar umumiy narxi'),
        TextCellValue('Muddat'),
      ]);

      for (var model in dataList) {
        sheetObject.appendRow([
          TextCellValue(model.productName),
          DoubleCellValue(model.price),
          IntCellValue(model.ordersCount),
          DoubleCellValue(model.ordersSumm),
          TextCellValue(model.dateTime),
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
