import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/utils/font_utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../model/order_models/percent_model.dart';

class PrinterServices {
  final AppModel model;
  final Order order;

  PrinterServices({
    required this.order,
    required this.model,
  });

  static final FontUtils _fontUtils = FontUtils.instance;

  pw.TextStyle get _pdfTheme =>
      pw.TextStyle(font: _fontUtils.medium, fontSize: 9);

  pw.TextStyle get _totalProducts =>
      pw.TextStyle(font: _fontUtils.medium, fontSize: 10);

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
    if (order.status != 'completed') {
      return pw.Column(children: [
        pw.Center(
          child: pw.Text(
            '${AppLocales.order.tr()}: ${order.isarId ?? (order.orderNumber ?? order.id)}',
            style: _pdfTheme.copyWith(fontSize: 12),
            maxLines: 1,
          ),
        ),
        pw.SizedBox(height: 4),
        _buildDottedLine(),
      ]);
    }

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
        if (model.shopAddress != null)
          pw.Center(child: pw.Text(model.shopAddress ?? '', style: _pdfTheme)),
        if (model.shopAddress != null) pw.SizedBox(height: 3),
        pw.Center(
          child: pw.Text(
            '${AppLocales.order.tr()}: ${order.isarId ?? (order.orderNumber ?? order.id)}',
            style: _pdfTheme,
            maxLines: 1,
          ),
        ),
        pw.SizedBox(height: 4),
        _buildDottedLine(),
      ],
    );
  }

  pw.Widget _buildProductsTableHeader() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(AppLocales.products.tr(), style: _smallStyle),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            flex: 1,
            child: pw.Center(
              child: pw.Text("${AppLocales.amount.tr().substring(0, 3)}.",
                  style: _smallStyle),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            flex: 2,
            child: pw.Center(
              child: pw.Text("${AppLocales.price.tr().substring(0, 3)}.",
                  style: _smallStyle),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              AppLocales.total.tr().substring(0, 4),
              style: _smallStyle,
              textAlign: pw.TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProductItem(OrderItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              item.product.name.capitalize,
              style: _pdfTheme,
              overflow: pw.TextOverflow.clip,
              maxLines: 1,
            ),
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
            flex: 1,
            child: pw.Center(
                child: pw.Text(item.amount.toMeasure,
                    style: _pdfTheme, maxLines: 1)),
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
            flex: 2,
            child: pw.Center(
                child: pw.Text(item.product.price.price, style: _pdfTheme)),
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              (item.product.price * item.amount).price,
              style: _pdfTheme,
              textAlign: pw.TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalSection({required List<Percent> percents}) {
    final productTotal = order.products.fold(0.0, (a, el) {
      return a += (el.amount * el.product.price);
    });

    return pw.Column(
      children: [
        _buildDottedLine(),
        // pw.SizedBox(height: 4),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                  child: pw.Text("${AppLocales.total.tr()}: ",
                      style: _totalProducts, maxLines: 2)),
              pw.SizedBox(width: 4),
              pw.Text(productTotal.priceUZS, style: _totalProducts),
            ],
          ),
        ),
        if (order.place.percent != null && order.place.percent != 0.0)
          ..._buildPlacePercentSection(productTotal, percents),
        if ((percents.isNotEmpty && !order.place.percentNull) ||
            order.place.price != null)
          ..._buildAdditionalPercentsSection(productTotal, percents),
      ],
    );
  }

  List<pw.Widget> _buildPlacePercentSection(
      double productTotal, List<Percent> percents) {
    return [
      _buildDottedLine(),
      if (order.place.price != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                  child: pw.Text("${AppLocales.placePrice.tr()}: ",
                      style: _pdfTheme, maxLines: 2)),
              pw.SizedBox(width: 8),
              pw.Text("${order.place.price?.priceUZS}", style: _boldStyle),
            ],
          ),
        ),
      if ((order.place.percent ?? 0) > 0)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  "${AppLocales.placePercent.tr()} (${order.place.percent}%): ",
                  style: _pdfTheme,
                  maxLines: 2,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                (productTotal * (order.place.percent ?? 0) * 0.01).priceUZS,
                style: _boldStyle,
              ),
            ],
          ),
        ),
    ];
  }

  List<pw.Widget> _buildAdditionalPercentsSection(
      double productTotal, List<Percent> percents) {
    return [
      pw.SizedBox(height: 4),
      _buildDottedLine(),
      pw.SizedBox(height: 4),
      for (final item in percents)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text("${item.name}: ${item.percent} %",
                    style: _pdfTheme, maxLines: 2),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                ((productTotal + (order.place.price ?? 0)) *
                        item.percent *
                        0.01)
                    .priceUZS,
                style: _boldStyle,
              ),
            ],
          ),
        ),
    ];
  }

  pw.Widget _buildCustomerInfo() {
    if (order.customer == null ||
        (order.customer!.name.isEmpty && order.customer!.phone.isEmpty)) {
      return pw.SizedBox();
    }
    return pw.Column(
      children: [
        _buildDottedLine(),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            (order.customer?.id ?? '').isNotEmpty
                ? AppLocales.customer.tr()
                : AppLocales.delivery.tr(),
            style: _pdfTheme.copyWith(fontSize: 10),
            maxLines: 1,
          ),
        ),
        pw.SizedBox(height: 4),
        if (order.customer!.name.isNotEmpty)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  (order.customer?.id ?? '').isNotEmpty
                      ? "${AppLocales.customer.tr()}:"
                      : "${AppLocales.address.tr()}:",
                  style: _pdfTheme),
              pw.SizedBox(height: 4),
              pw.Expanded(
                child: pw.Text((order.customer?.name ?? '').capitalize,
                    style: _boldStyle, textAlign: pw.TextAlign.right),
              ),
            ],
          ),
        if (order.customer!.phone.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("${AppLocales.phone.tr()}:", style: _pdfTheme),
              pw.SizedBox(height: 4),
              pw.Expanded(
                child: pw.Text(order.customer?.phone ?? '',
                    style: _boldStyle, textAlign: pw.TextAlign.right),
              ),
            ],
          )
        ]
      ],
    );
  }

  pw.Widget _buildOrderDetails(String? printPhone) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 4),
        _buildDottedLine(),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
                child: pw.Text("${order.employee.roleName.capitalize}:",
                    style: _pdfTheme, maxLines: 2)),
            pw.SizedBox(width: 8),
            pw.Text(order.employee.fullname, style: _boldStyle),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
                child: pw.Text("${AppLocales.placeNameLabel.tr()}:",
                    style: _pdfTheme, maxLines: 2)),
            pw.SizedBox(width: 8),
            pw.Text(
              "${order.place.name}${order.place.father?.name != null ? ", ${order.place.father!.name}" : ''}",
              style: _boldStyle,
            ),
          ],
        ),
        if (printPhone != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                  child: pw.Text("${AppLocales.contact.tr()}:",
                      style: _pdfTheme, maxLines: 2)),
              pw.SizedBox(width: 8),
              pw.Text(printPhone, style: _boldStyle),
            ],
          )
        ],
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
                child: pw.Text("${AppLocales.createdDate.tr()}:",
                    style: _pdfTheme, maxLines: 2)),
            pw.SizedBox(width: 8),
            pw.Text(
              DateFormat('yyyy.MM.dd HH:mm')
                  .format(DateTime.parse(order.updatedDate)),
              style: _boldStyle,
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Expanded(
                child: pw.Text("${AppLocales.status.tr()}:",
                    style: _pdfTheme, maxLines: 2)),
            pw.SizedBox(width: 8),
            pw.Text(
              (order.status ?? 'opened').tr(),
              style: _boldStyle,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFinalTotals() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 12),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "${AppLocales.total.tr()}:",
                style: pw.TextStyle(font: _fontUtils.bold, fontSize: 12),
              ),
              pw.Text(
                "${order.price.price} UZS",
                style: pw.TextStyle(font: _fontUtils.bold, fontSize: 18),
              )
            ]),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildPaymentTypes() {
    return pw.Column(
      children: [
        _buildDottedLine(),
        pw.SizedBox(height: 4),
        for (final pt in order.paymentTypes)
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(pt.name.tr().capitalize, style: _pdfTheme),
                  pw.Text(pt.percent.priceUZS, style: _pdfTheme),
                ]),
          ),
        // _buildDottedLine(),
      ],
    );
  }

  pw.Widget _buildFooterMessage() {
    return pw.Row(children: [
      pw.Expanded(child: pw.Container(height: 1, color: PdfColors.black)),
      pw.Container(
        constraints: pw.BoxConstraints(maxWidth: 120),
        padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: PdfColors.black),
        ),
        child: pw.Center(
          child: pw.Text(
            (model.byeText?.isEmpty ?? true)
                ? AppLocales.thanksForOrder.tr()
                : model.byeText!,
            style: _pdfTheme,
            textAlign: pw.TextAlign.center,
          ),
        ),
      ),
      pw.Expanded(child: pw.Container(height: 1, color: PdfColors.black)),
    ]);
  }

  void printOrderCheck({String? phone, String? address}) async {
    final percents = await OrderPercentDatabase().get();
    final image = await _shopLogoImage();

    log(order.status.toString());

    final content = pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(image),
        _buildProductsTableHeader(),
        _buildDottedLine(),
        ...order.products.map((item) => _buildProductItem(item)),
        _buildTotalSection(percents: percents),
        _buildCustomerInfo(),
        _buildOrderDetails(model.printPhone),
        _buildFinalTotals(),
        if (order.status == 'completed') ...[
          _buildPaymentTypes(),
          pw.SizedBox(height: 4),
          _buildFooterMessage(),
        ],
        pw.SizedBox(height: 8),
      ],
    );

    final pageHeight = (order.products.length * 20.0) + 600.0;

    final doc = pw.Document();
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
        onLayout: (PdfPageFormat format) async {
          return bytes;
        },
        printer: Printer(url: model.token, name: model.refresh),
      );
    } catch (_) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return bytes;
        },
      );
    }
  }
}
