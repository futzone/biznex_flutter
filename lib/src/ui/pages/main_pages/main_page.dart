import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/pages/category_pages/category_page.dart';
import 'package:biznex/src/ui/pages/cloud_pages/cloud_page.dart';
import 'package:biznex/src/ui/pages/order_pages/order_set_page.dart';
import 'package:biznex/src/ui/pages/places_pages/places_page.dart';
import 'package:biznex/src/ui/pages/transactions_page/transactions_page.dart';
import 'package:biznex/src/ui/screens/custom_scaffold/app_sidebar.dart';
import 'package:biznex/src/ui/screens/order_screens/orders_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import '../../screens/product_info_screen/product_measure_reponsive.dart';
import '../../screens/settings_screen/settings_page_screen.dart';
import '../employee_pages/employee_page.dart';
import '../monitoring_pages/monitoring_page.dart';
import '../product_pages/products_page.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  Widget buildBody({required AppModel state, required Widget child, required Widget sidebar}) {
    if (!state.isDesktop) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [sidebar, Expanded(child: child)],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final pageValue = useState(2);

    final appbar = useState(AppBar());
    final fab = useState<FloatingActionButton?>(null);
    return AppStateWrapper(
      builder: (theme, state) {
        return Scaffold(
          appBar: !state.isDesktop ? appbar.value : null,
          drawer: state.isDesktop ? null : AppSidebar(pageValue),
          floatingActionButton: !state.isDesktop ? fab.value : null,
          body: buildBody(
            state: state,
            sidebar: AppSidebar(pageValue),
            child: HookBuilder(
              builder: (context) {
                if (pageValue.value == 0) return SettingsPageScreen();
                if (pageValue.value == 1) return OrderSetPage();
                if (pageValue.value == 2) return OrdersPage();
                if (pageValue.value == 3) return CategoryPage(appbar: appbar, fab);
                if (pageValue.value == 10) return PlacesPage(appbar: appbar, fab);
                // if (pageValue.value == 5) return ProductInformationsPage(appbar: appbar, fab);
                if (pageValue.value == 6) return ProductMeasureReponsive();
                if (pageValue.value == 8) return EmployeePage(appbar: appbar, fab);
                if (pageValue.value == 7) return MonitoringPage();
                if (pageValue.value == 9) return TransactionsPage(fab, appbar: appbar);
                if (pageValue.value == 11) return CloudPage();
                return ProductsPage(fab, appbar: appbar);
              },
            ),
          ),
        );
      },
    );
  }
}
