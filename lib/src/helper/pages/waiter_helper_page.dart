import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/helper/pages/login_page.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/pages/order_pages/employee_orders_page.dart';
import 'package:biznex/src/ui/screens/order_screens/order_half_page.dart';
import 'package:biznex/src/ui/screens/order_screens/order_items_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/employee_settings_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';

class WaiterHelperPage extends ConsumerStatefulWidget {
  final bool haveBack;

  const WaiterHelperPage({super.key, this.haveBack = false});

  @override
  ConsumerState<WaiterHelperPage> createState() => _WaiterPageState();
}

class _WaiterPageState extends ConsumerState<WaiterHelperPage> {
  bool _expandPlaces = true;
  Place? _place;
  bool _expandPlaceChildren = false;
  Place? _placeChild;

  @override
  Widget build(BuildContext context) {
    final employee = ref.watch(currentEmployeeProvider);
    return Scaffold(
      appBar: AppBar(
        leading: widget.haveBack ? null : Icon(Ionicons.person_outline, size: 28),
        title: Text(employee.fullname),
        actions: [
          IconButton(
            onPressed: () {
              showDesktopModal(
                context: context,
                body: EmployeeOrdersPage(),
                width: MediaQuery.of(context).size.width * 0.5,
              );
            },
            icon: Icon(Ionicons.bar_chart_outline, size: 28),
          ),
          8.w,
          IconButton(
            onPressed: () {
              showDesktopModal(context: context, body: EmployeeSettingsScreen());
            },
            icon: Icon(Ionicons.settings_outline, size: 28),
          ),
          8.w,
          IconButton(
            onPressed: () {

              AppRouter.open(context, HelperLoginPage());
            },
            icon: Icon(Ionicons.log_out_outline, size: 28),
          ),
          8.w,
        ],
      ),
      body: AppStateWrapper(builder: (theme, state) {
        return Row(
          children: [
            AnimatedContainer(
              duration: theme.animationDuration,
              margin: 16.all,
              padding: 16.tb,
              height: double.infinity,
              width: (_place == null || _expandPlaces) ? 240 : 80,
              decoration: BoxDecoration(
                color: theme.sidebarBG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: state.whenProviderData(
                provider: placesProvider,
                builder: (places) {
                  places as List<Place>;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        if ((_place == null || _expandPlaces))
                          Row(
                            children: [
                              16.w,
                              Expanded(
                                child: AppText.$18Bold(
                                  AppLocales.choosePlace.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxlines: 1,
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  onPressed: () {
                                    _expandPlaces = false;
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                                ),
                              ),
                              8.w,
                            ],
                          )
                        else
                          Center(
                            child: IconButton(
                              onPressed: () {
                                _expandPlaces = true;
                                setState(() {});
                              },
                              icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          height: 2,
                          color: Colors.white54,
                        ),
                        for (final pls in places)
                          SimpleButton(
                            onPressed: () {
                              _place = pls;
                              _expandPlaceChildren = true;
                              _expandPlaces = false;
                              _placeChild = null;
                              setState(() {});
                            },
                            child: Container(
                              margin: 16.lr,
                              padding: 16.all,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: pls.id == _place?.id ? theme.mainColor : null,
                              ),
                              child: Text(
                                ((_place == null || _expandPlaces)) ? pls.name : pls.name[0],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: boldFamily,
                                  color: Colors.white,
                                ),
                                textAlign: ((_place == null || _expandPlaces)) ? null : TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_place != null && _place?.children != null)
              AnimatedContainer(
                duration: theme.animationDuration,
                margin: 16.tb,
                padding: 16.tb,
                height: double.infinity,
                width: (_placeChild == null || _expandPlaceChildren) ? 240 : 80,
                decoration: BoxDecoration(
                  color: theme.sidebarBG,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      if ((_expandPlaceChildren))
                        Row(
                          children: [
                            16.w,
                            Expanded(
                              child: AppText.$18Bold(
                                AppLocales.choosePlace.tr(),
                                maxlines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  _expandPlaceChildren = false;
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            8.w,
                          ],
                        )
                      else
                        Center(
                          child: IconButton(
                            onPressed: () {
                              _expandPlaceChildren = true;
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Colors.white54,
                      ),
                      for (final pls in _place?.children ?? [])
                        SimpleButton(
                          onPressed: () {
                            _placeChild = pls;
                            _expandPlaceChildren = false;
                            setState(() {});
                          },
                          child: Container(
                            width: double.infinity,
                            margin: 16.lr,
                            padding: 16.all,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: pls.id == _placeChild?.id ? theme.mainColor : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_expandPlaceChildren) ? pls.name : pls.name[0],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: boldFamily,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    textAlign: (_expandPlaceChildren) ? null : TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            if ((_place != null && _place?.children != null && _placeChild != null) ||
                (_place != null && (_place?.children == null || _place!.children!.isEmpty)))
              state.whenProviderData(
                provider: ordersProvider((_placeChild ?? _place!).id),
                builder: (order) {
                  order as Order?;
                  Place? kPlace;

                  if (_placeChild != null) {
                    kPlace = _placeChild!;
                    kPlace.father = _place;
                  } else {
                    kPlace = _place;
                  }

                  return OrderItemsPage(state: state, theme: theme, place: kPlace!);
                },
              ),
            if ((_place != null && _place?.children != null && _placeChild != null) ||
                (_place != null && (_place?.children == null || _place!.children!.isEmpty)))
              OrderHalfPage(_placeChild ?? _place!),
          ],
        );
      }),
    );
  }
}
