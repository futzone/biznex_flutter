import 'package:biznex/biznex.dart';

class ProductsTableHeader extends AppStatelessWidget {
  final bool miniMode;

  const ProductsTableHeader({super.key, this.miniMode = false});

  @override
  Widget builder(context, theme, ref, state) {
    return Container(
      padding: Dis.only(lr: 24, tb: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.sidebarBG,
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              AppLocales.productImageLabel.tr(),
              style: TextStyle(color: Colors.white),
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                AppLocales.productName.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                AppLocales.currentPriceLabel.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                AppLocales.amountLabel.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                AppLocales.size.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          if(!miniMode)
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                AppLocales.productBarcodeLabel.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          if(!miniMode)
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                AppLocales.tagnumber.tr(),
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
          if(!miniMode)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "",
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
