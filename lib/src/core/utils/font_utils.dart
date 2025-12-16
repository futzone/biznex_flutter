import 'package:biznex/biznex.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class FontUtils {
  static final FontUtils instance = FontUtils._internal();

  factory FontUtils() => instance;

  FontUtils._internal();

  late pw.Font regular;
  late pw.Font bold;
  late pw.Font medium;
  late BuildContext context;

  void saveContext(BuildContext ctx) => context = ctx;

  Future<void> init() async {
    // final Locale locale = context.locale;

    final boldFontData =
        await rootBundle.load('assets/fonts/NotoSansMono-Bold.ttf');
    final mediumFontData =
        await rootBundle.load('assets/fonts/NotoSansMono-Medium.ttf');
    final regularFontData =
        await rootBundle.load('assets/fonts/NotoSansMono-Regular.ttf');

    bold = pw.Font.ttf(boldFontData);
    medium = pw.Font.ttf(mediumFontData);
    regular = pw.Font.ttf(regularFontData);

    //
    // final fontData = await rootBundle.load('assets/fonts/DejaVuSans.ttf');
    // final font = pw.Font.ttf(fontData);
    // regular = font;
    // bold = font;
    // medium = font;
  }
}
