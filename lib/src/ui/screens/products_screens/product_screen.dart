import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ProductScreen extends AppStatelessWidget {
  final Product product;

  const ProductScreen(this.product, {super.key});

  @override
  Widget builder(context, theme, ref, state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: 8.bottom,
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (product.images != null && product.images!.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: product.images!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.accentColor),
                                image: DecorationImage(
                                  image: FileImage(File(product.images![index])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                AppText.$18Bold(product.name),
                Row(
                  children: [
                    AppText.$14Bold("${AppLocales.price.tr()}: "),
                    AppText.$16Bold(product.price.priceUZS),
                    24.w,
                    AppText.$14Bold("${AppLocales.pricePercentHint.tr()}: "),
                    AppText.$16Bold("${product.percent.toStringAsFixed(1)} %"),
                  ],
                ),
                if (product.size != null || product.color != null)
                  Row(
                    // spacing: 24,
                    children: [
                      if (product.size != null) AppText.$14Bold("${AppLocales.productSizeLabel.tr()}: ${product.size}"),
                      if (product.colorCode != null) 24.w,
                      if (product.colorCode != null) AppText.$14Bold("${AppLocales.productColorLabel.tr()}: "),
                      if (product.colorCode != null) Icon(Icons.circle, size: 16, color: colorFromHex(product.colorCode!))
                    ],
                  ),
                if (product.informations != null && product.informations!.isNotEmpty)
                  for (final item in product.informations!) AppText.$14Bold("${item.name}: ${item.data}"),
                if (product.category != null)
                  Wrap(
                    children: [
                      Container(
                        padding: Dis.only(lr: 8, tb: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: theme.accentColor,
                        ),
                        child: Text(
                          product.category!.name,
                          style: TextStyle(color: theme.textColor),
                        ),
                      ),
                    ],
                  ),
                if (product.description != null) AppText.subtitle(product.description!, state),
                if (product.cratedDate != null || product.updatedDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 24,
                    children: [
                      AppText.$14Bold(
                        "${AppLocales.createdDate.tr()}: ${DateFormat('yyyy.MM.dd, HH:mm').format(DateTime.parse(product.cratedDate!))}",
                      ),
                      AppText.$14Bold(
                        "${AppLocales.updatedDate.tr()}: ${DateFormat('yyyy.MM.dd, HH:mm').format(DateTime.parse(product.updatedDate!))}",
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
        ConfirmCancelButton(
          confirmText: AppLocales.toSet.tr(),
          onlyClose: true,
        ),
      ],
    );
  }
}
