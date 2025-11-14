import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';

import '../../../../../biznex.dart';
import '../../../../core/model/employee_models/employee_model.dart';
import '../../../../core/model/place_models/place_model.dart';
import '../../../../providers/employee_provider.dart';
import '../../../../providers/places_provider.dart';
import '../../../../providers/products_provider.dart';
import '../../../widgets/custom/app_custom_popup_menu.dart';

class OrderFilterWidget extends StatelessWidget {
  final AppColors theme;
  final AppModel state;
  final Employee? employee;
  final Place? fatherPlace;
  final Place? place;
  final Product? product;
  final DateTime dateTime;
  final void Function(Place? pls) onChangePlace;
  final void Function(Employee? pls) onChangeEmployee;
  final void Function(Product? pls) onChangeProduct;
  final void Function() onChangeDateTime;

  const OrderFilterWidget({
    super.key,
    required this.theme,
    required this.state,
    this.employee,
    this.fatherPlace,
    this.place,
    this.product,
    required this.dateTime,
    required this.onChangePlace,
    required this.onChangeEmployee,
    required this.onChangeProduct,
    required this.onChangeDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: 16.bottom,
      padding: Dis.only(tb: context.h(4), lr: context.w(4)),
      height: context.h(58),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        spacing: context.w(16),
        children: [
          Expanded(
            child: state.whenProviderData(
              provider: placesProvider,
              builder: (places) {
                places as List<Place>;

                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    CustomPopupItem(
                      title: AppLocales.all.tr(),
                      onPressed: () => onChangePlace(null),
                    ),
                    if (fatherPlace == null)
                      for (final pls in places)
                        CustomPopupItem(
                          title: pls.name,
                          onPressed: () => onChangePlace(pls),
                        )
                    else
                      for (final pls in fatherPlace?.children ?? [])
                        CustomPopupItem(
                          title: pls.name,
                          onPressed: () => onChangePlace(pls),
                        )
                  ],
                  child: Container(
                    padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: place != null
                          ? theme.mainColor
                          : fatherPlace != null
                              ? theme.secondaryColor
                              : null,
                      border: place == null
                          ? null
                          : Border.all(color: theme.mainColor),
                    ),
                    child: Center(
                      child: Text(
                        place != null
                            ? place!.name
                            : fatherPlace != null
                                ? fatherPlace!.name
                                : AppLocales.places.tr(),
                        style: TextStyle(
                          fontSize: context.s(16),
                          fontFamily: mediumFamily,
                          color: place == null
                              ? theme.secondaryTextColor
                              : theme.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: state.whenProviderData(
              provider: employeeProvider,
              builder: (places) {
                places as List<Employee>;

                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    CustomPopupItem(
                      title: AppLocales.all.tr(),
                      onPressed: () => onChangeEmployee(null),
                    ),
                    for (final item in [
                      Employee(
                        fullname: "Admin",
                        roleId: "0",
                        roleName: "Admin",
                        pincode: state.pincode,
                      ),
                      ...places
                    ])
                      CustomPopupItem(
                        title: item.fullname,
                        onPressed: () => onChangeEmployee(item),
                      ),
                  ],
                  child: Container(
                    padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: employee == null
                          ? null
                          : Border.all(color: theme.mainColor),
                      color: employee == null ? null : theme.mainColor,
                    ),
                    child: Center(
                      child: Text(
                        employee == null
                            ? AppLocales.employees.tr()
                            : places
                                .firstWhere(
                                  (el) => el.id == employee?.id,
                                  orElse: () => Employee(
                                    fullname: AppLocales.employees.tr(),
                                    roleId: '',
                                    roleName: ''
                                        '',
                                  ),
                                )
                                .fullname,
                        style: TextStyle(
                          fontSize: context.s(16),
                          fontFamily: mediumFamily,
                          color: employee == null
                              ? theme.secondaryTextColor
                              : theme.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: state.whenProviderData(
              provider: productsProvider,
              builder: (places) {
                places as List<Product>;

                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    CustomPopupItem(
                      title: AppLocales.all.tr(),
                      onPressed: () => onChangeProduct(null),
                    ),
                    for (int i = 0;
                        i < ((places.length > 100) ? 100 : places.length);
                        i++)
                      CustomPopupItem(
                        title: places[i].name,
                        onPressed: () => onChangeProduct(places[i]),
                      )
                  ],
                  child: Container(
                    padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: product == null ? null : theme.mainColor,
                      border: product == null
                          ? null
                          : Border.all(color: theme.mainColor),
                    ),
                    child: Center(
                      child: Text(
                        product == null
                            ? AppLocales.products.tr()
                            : places
                                .firstWhere(
                                  (el) => el.id == product?.id,
                                  orElse: () => Product(
                                    name: AppLocales.products.tr(),
                                    price: 0,
                                  ),
                                )
                                .name,
                        style: TextStyle(
                          fontSize: context.s(16),
                          fontFamily: mediumFamily,
                          color: product == null
                              ? theme.secondaryTextColor
                              : theme.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SimpleButton(
              onPressed: onChangeDateTime,
              child: Container(
                padding: Dis.only(lr: context.w(24), tb: context.h(10)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // color: theme.accentColor,
                  border: Border.all(color: theme.mainColor),
                  color: theme.mainColor,
                ),
                child: Center(
                  child: Text(
                    DateFormat('d-MMMM').format(dateTime),
                    style: TextStyle(
                      fontSize: context.s(16),
                      fontFamily: mediumFamily,
                      color: theme.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
