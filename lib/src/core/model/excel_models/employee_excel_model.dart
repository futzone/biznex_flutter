import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class EmployeeExcel {
  String dateTime;
  String employeeName;
  String employeeRole;
  int ordersCount;
  double ordersSumm;

  EmployeeExcel({
    required this.ordersCount,
    required this.ordersSumm,
    required this.dateTime,
    required this.employeeName,
    required this.employeeRole,
  });

  static Future<void> saveFileDialog(List<EmployeeExcel> dataList) async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Faylni saqlash',
      fileName: '${dataList.firstOrNull?.dateTime}_reports.xlsx',
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result;

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow([
        TextCellValue('Xodim nomi'),
        TextCellValue('Lavozimi'),
        TextCellValue('Buyurtmalar soni'),
        TextCellValue('Buyurtmalar umumiy narxi'),
        TextCellValue('Muddat'),
      ]);

      for (var model in dataList) {
        sheetObject.appendRow([
          TextCellValue(model.employeeName),
          TextCellValue(model.employeeRole),
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
