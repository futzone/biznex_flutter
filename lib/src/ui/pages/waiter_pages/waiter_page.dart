import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/pages/order_pages/employee_orders_page.dart';
import 'package:biznex/src/ui/screens/order_screens/order_items_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/employee_settings_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import '../../screens/order_screens/order_half_page.dart';
import '../order_pages/table_choose_screen.dart';

class WaiterPage extends ConsumerStatefulWidget {
  final bool haveBack;

  const WaiterPage({super.key, this.haveBack = false});

  @override
  ConsumerState<WaiterPage> createState() => _WaiterPageState();
}

class _WaiterPageState extends ConsumerState<WaiterPage> {
  @override
  Widget build(BuildContext context) {
    return TableChooseScreen();
  }
}
