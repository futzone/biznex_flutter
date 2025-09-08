import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/screens/order_screens/order_complete_screen.dart';
import 'package:biznex/src/ui/screens/order_screens/order_item_card.dart';
import 'package:biznex/src/ui/screens/products_screens/products_table_header.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import '../../screens/products_screens/product_card.dart';

class OrderSetPage extends HookConsumerWidget {
  const OrderSetPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final searchController = useTextEditingController();
    final setItems = ref.watch(orderSetProvider);

    final searchResultList = useState(<Product>[]);

    void onSearchChanges(String char) {
      char = char.trim();
      final providerListener = ref.watch(productsProvider).value ?? [];
      searchResultList.value = providerListener.where((item) {
        return (item.name.toLowerCase().contains(char.toLowerCase()) ||
            item.barcode.toString().toLowerCase().contains(char.toLowerCase()) ||
            item.tagnumber.toString().toLowerCase().contains(char.toLowerCase()));
      }).toList();
    }

    return AppStateWrapper(builder: (theme, state) {
      return Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 16,
                children: [
                  AppTextField(
                    title: AppLocales.searchBarHint.tr(),
                    controller: searchController,
                    theme: theme,
                    onChanged: onSearchChanges,
                    suffixIcon: Icon(Ionicons.search_outline),
                  ),
                  ProductsTableHeader(miniMode: true),
                  state.whenProviderData(
                    provider: productsProvider,
                    builder: (products) {
                      products as List<Product>;
                      if (products.isEmpty || (searchResultList.value.isEmpty && searchController.text.isNotEmpty)) {
                        return Center(child: Padding(padding: 48.top, child: AppEmptyWidget()));
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: searchResultList.value.isEmpty ? products.length : searchResultList.value.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              (searchResultList.value.isEmpty ? products : searchResultList.value)[index],
                              miniMode: true,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: 24.lr,
              color: theme.accentColor,
              width: 2,
            ),
            Expanded(
              child: Column(
                children: [
                  8.h,
                  Row(
                    children: [
                      AppText.$24Bold(AppLocales.orderProducts.tr()),
                      Spacer(),
                      SimpleButton(
                        onPressed: () {
                          // ref.read(orderSetProvider.notifier).update((state) {
                          //   return [];
                          // });
                        },
                        child: Container(
                          padding: Dis.only(lr: 12, tb: 6),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: theme.accentColor),
                          child: Text(
                            AppLocales.clearAll.tr(),
                            style: TextStyle(fontSize: 16, fontFamily: mediumFamily, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.h,
                  Expanded(
                    child: ListView.builder(
                      itemCount: setItems.length + 1,
                      itemBuilder: (context, index) {
                        if (setItems.isEmpty) return Padding(padding: 24.top, child: AppEmptyWidget());
                        // if (setItems.isNotEmpty && index == 0) return 0.w;
                        if (index == setItems.length) {
                          return OrderCompleteScreen();
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
