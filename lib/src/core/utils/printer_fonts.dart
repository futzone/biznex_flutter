// import 'package:flutter/services.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// class PrinterFonts {
//   static final PrinterFonts instance = PrinterFonts._internal();
//
//   factory PrinterFonts() => instance;
//
//   PrinterFonts._internal();
//
//   late ByteData font;
//   late pw.TextStyle bold;
//   late pw.TextStyle medium;
//   late pw.TextStyle header;
//
//   Future<void> init() async {
//     font = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
//     final boldFont = await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf');
//     final ttf = pw.Font.ttf(font);
//     final boldTtf = pw.Font.ttf(boldFont);
//
//     medium = pw.TextStyle(
//       fontSize: 8,
//       font: ttf,
//     );
//
//     bold = pw.TextStyle(
//       fontSize: 8,
//       font: boldTtf,
//       fontWeight: pw.FontWeight.bold,
//     );
//
//     header = pw.TextStyle(
//       fontSize: 16,
//       font: boldTtf,
//       fontWeight: pw.FontWeight.bold,
//     );
//   }
// }
