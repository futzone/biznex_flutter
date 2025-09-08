import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/ui/pages/order_pages/menu_page.dart';
import 'package:biznex/src/ui/pages/order_pages/table_choose_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import '../../../../biznex.dart';
import '../../../core/model/order_models/order_model.dart';

class ChangeOrderPlace extends HookConsumerWidget {
  final Place place;

  const ChangeOrderPlace(this.place, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TableChooseScreen(
      onSelected: (newPlace) async {
        ///
        OrderDatabase orderDatabase = OrderDatabase();
        showAppLoadingDialog(context);

        final order = await orderDatabase.getPlaceOrder(place.id);
        final orderNewPlace = await orderDatabase.getPlaceOrder(newPlace.id);

        await orderDatabase.deletePlaceOrder(place.id);
        await orderDatabase.deletePlaceOrder(newPlace.id);

        ref.watch(orderSetProvider.notifier).clearPlaceItems(place.id);
        ref.watch(orderSetProvider.notifier).clearPlaceItems(newPlace.id);

        if (order != null) {
          final List<OrderItem> list = [];
          for (final item in order.products) {
            OrderItem orderItem = item;
            orderItem.placeId = newPlace.id;
            list.add(orderItem);
          }

          Order updatedOrder = order;
          updatedOrder.products = list;
          order.place = newPlace;
          await orderDatabase.setPlaceOrder(data: updatedOrder, placeId: newPlace.id, disablePrint: true).then((_) async {
            ref.watch(orderSetProvider.notifier).addMultiple(list);
          });
        }

        if (orderNewPlace != null) {
          final List<OrderItem> list = [];
          for (final item in orderNewPlace.products) {
            OrderItem orderItem = item;
            orderItem.placeId = place.id;
            list.add(orderItem);
          }

          Order updatedOrder = orderNewPlace;
          updatedOrder.products = list;
          orderNewPlace.place = place;
          await orderDatabase.setPlaceOrder(data: updatedOrder, placeId: place.id, disablePrint: true).then((_) async {
            ref.watch(orderSetProvider.notifier).addMultiple(list);
          });
        }

        ref.invalidate(ordersProvider(place.id));
        ref.invalidate(ordersProvider(newPlace.id));

        AppRouter.close(context);
        AppRouter.open(context, MenuPage(place: newPlace));
        //
      },
    );
  }
}
