import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../controllers/customer_controller.dart';
import '../../../core/model/other_models/customer_model.dart';
import '../../../providers/customer_provider.dart';
import '../../screens/customer_screens/add_customer_screen.dart';
import '../../widgets/custom/app_list_tile.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import '../../widgets/helpers/app_text_field.dart';
import 'customer_detail_screen.dart';

class CustomersPage extends HookConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final searchController = useTextEditingController();

    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        floatingActionButton: WebButton(
          onPressed: () {
            showDesktopModal(context: context, body: AddCustomerScreen());
          },
          builder: (focused) => AnimatedContainer(
            duration: theme.animationDuration,
            height: focused ? 80 : 64,
            width: focused ? 80 : 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xff5CF6A9), width: 2),
              color: theme.mainColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(3, 3),
                )
              ],
            ),
            child: Center(
              child: Icon(Iconsax.add_copy,
                  color: Colors.white, size: focused ? 40 : 32),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: Dis.only(
                lr: context.w(24),
                top: context.h(24),
                bottom: context.h(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: context.w(16),
                children: [
                  Expanded(
                    child: Text(
                      AppLocales.customers.tr(),
                      style: TextStyle(
                        fontSize: context.s(24),
                        fontFamily: mediumFamily,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  0.w,
                  SizedBox(
                    width: context.w(400),
                    child: AppTextField(
                      prefixIcon: Icon(Iconsax.search_normal_copy),
                      title: AppLocales.search.tr(),
                      controller: searchController,
                      onChanged: (s) {},
                      theme: theme,
                      fillColor: Colors.white,
                      // useBorder: false,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.whenProviderData(
                provider: customerProvider,
                builder: (customers) {
                  customers as List<Customer>;
                  return ListView.builder(
                    padding: Dis.only(lr: context.w(24), top: 16, bottom: 200),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];

                      return SimpleButton(
                        onPressed: () {
                          showDesktopModal(
                            context: context,
                            body: CustomerDetailScreen(
                              customer: customer,
                              theme: theme,
                            ),
                          );
                        },
                        child: Container(
                          margin: Dis.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.white,
                          ),
                          padding: Dis.only(
                            left: 16,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  spacing: 12,
                                  children: [
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: theme.mainColor,
                                        ),
                                        Text(
                                          customer.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: boldFamily,
                                            color: theme.mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 16,
                                      children: [
                                        Container(
                                          height: 36,
                                          padding: Dis.only(lr: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: theme.scaffoldBgColor,
                                          ),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                size: 20,
                                                // color: theme.secondaryTextColor,
                                              ),
                                              Text(
                                                customer.phone.trim(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: mediumFamily,
                                                  // color: theme.secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (customer.address != null &&
                                            customer.address!.isNotEmpty)
                                          Container(
                                            height: 36,
                                            padding: Dis.only(lr: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: theme.scaffoldBgColor,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 20,
                                                  // color: theme.secondaryTextColor,
                                                ),
                                                Text(
                                                  customer.address ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: mediumFamily,
                                                    // color: theme.secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Iconsax.calendar_1_copy,
                                          size: 20,
                                          // color: theme.secondaryTextColor,
                                        ),
                                        Text(
                                          DateFormat("yyyy.MM.dd")
                                              .format(customer.created!),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: mediumFamily,
                                            // color: theme.secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    12.h,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SimpleButton(
                                          onPressed: () {
                                            showDesktopModal(
                                                context: context,
                                                body: AddCustomerScreen(
                                                  customer: customer,
                                                ));
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: theme.scaffoldBgColor,
                                            ),
                                            child: Icon(
                                              Iconsax.edit_copy,
                                              color: theme.secondaryTextColor,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        16.w,
                                        SimpleButton(
                                          onPressed: () {
                                            CustomerController cc =
                                                CustomerController(
                                              context: context,
                                              state: state,
                                            );

                                            cc.delete(customer.id);
                                            ref.invalidate(customerProvider);
                                            ref.refresh(customerProvider);
                                          },
                                          child: Container(
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: theme.scaffoldBgColor,
                                            ),
                                            child: Icon(
                                              Iconsax.trash_copy,
                                              color: theme.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
