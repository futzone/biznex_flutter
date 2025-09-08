import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/services/printer_multiple_services.dart';

final printerDevicesProvider = FutureProvider((ref) async {
  PrinterMultipleServices printerMultipleServices = PrinterMultipleServices();
  return await printerMultipleServices.printersList();
});
