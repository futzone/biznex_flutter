import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/providers/customer_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../screens/order_screens/order_card.dart';

class CustomerDetailScreen extends HookConsumerWidget {
  final Customer customer;
  final AppColors theme;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, ref) {
    final isOrdersScreen = useState(true);
    return CustomScrollView(
      slivers: [
        SliverPinnedHeader(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                AppBackButton(),
                24.w,
                Expanded(
                  child: Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: boldFamily,
                    ),
                  ),
                ),
                24.w,
                SimpleButton(
                  onPressed: () {
                    ref.refresh(customerOrdersProvider(customer.id));
                    ref.invalidate(customerOrdersProvider);
                    ref.invalidate(customerDebtProvider);
                    ref.refresh(customerOrdersProvider(customer.id));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      color: Color(0xffEDFEF5),
                      border: Border.all(color: theme.mainColor),
                    ),
                    height: context.s(48),
                    width: context.s(48),
                    child: Center(
                      child: Icon(
                        Iconsax.refresh_copy,
                        color: theme.mainColor,
                        size: context.s(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  Container(
                    height: 36,
                    padding: Dis.only(lr: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.scaffoldBgColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 20,
                          // color: theme.secondaryTextColor,
                        ),
                        Text(
                          "${AppLocales.customerPhone.tr()}: ${customer.phone.trim()}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: mediumFamily,
                            // color: theme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (customer.address != null && customer.address!.isNotEmpty)
                    Container(
                      height: 36,
                      padding: Dis.only(lr: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.scaffoldBgColor,
                      ),
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            // color: theme.secondaryTextColor,
                          ),
                          Text(
                            "${AppLocales.address.tr()}: ${customer.address ?? ''}",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: mediumFamily,
                              // color: theme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (customer.created != null)
                    Container(
                      height: 36,
                      padding: Dis.only(lr: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.scaffoldBgColor,
                      ),
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.calendar_1_copy,
                            size: 20,
                            // color: theme.secondaryTextColor,
                          ),
                          Text(
                            "${AppLocales.createdDate.tr()}: ${DateFormat("yyyy.MM.dd").format(customer.created!)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: mediumFamily,
                              // color: theme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (customer.updated != null)
                    Container(
                      height: 36,
                      padding: Dis.only(lr: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.scaffoldBgColor,
                      ),
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.calendar_1_copy,
                            size: 20,
                            // color: theme.secondaryTextColor,
                          ),
                          Text(
                            "${AppLocales.updatedDate.tr()}: ${DateFormat("yyyy.MM.dd, HH:mm").format(customer.updated!)}",
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
              ),
              8.h,
              if (customer.note != null && customer.note!.isNotEmpty)
                Text(
                  AppLocales.note.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: boldFamily,
                  ),
                ),
              if (customer.note != null && customer.note!.isNotEmpty)
                Text(
                  customer.note ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: mediumFamily,
                  ),
                ),
              if (customer.note != null && customer.note!.isNotEmpty) 24.h,
            ],
          ),
        ),
        SliverPinnedHeader(
          child: Container(
            padding: Dis.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              color: theme.accentColor,
            ),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    color: isOrdersScreen.value ? null : Colors.white,
                    theme: theme,
                    border: Border.all(
                      color:
                          isOrdersScreen.value ? theme.mainColor : Colors.white,
                    ),
                    onPressed: () {
                      isOrdersScreen.value = true;
                    },
                    title: AppLocales.orders.tr(),
                    textColor:
                        !isOrdersScreen.value ? Colors.black : Colors.white,
                  ),
                ),
                Expanded(
                  child: AppPrimaryButton(
                    color: !isOrdersScreen.value ? null : Colors.white,
                    border: Border.all(
                      color: !isOrdersScreen.value
                          ? theme.mainColor
                          : Colors.white,
                    ),
                    theme: theme,
                    title: "debt".tr(),
                    textColor:
                        isOrdersScreen.value ? Colors.black : Colors.white,
                    onPressed: () {
                      isOrdersScreen.value = false;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOrdersScreen.value)
          ref.watch(customerOrdersProvider(customer.id)).when(
                loading: () => SliverToBoxAdapter(child: AppLoadingScreen()),
                error: (e, st) => SliverToBoxAdapter(child: AppErrorScreen()),
                data: (orders) {
                  if (orders.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: 100.all,
                          child: AppEmptyWidget(),
                        ),
                      ),
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.w(16),
                      // mainAxisSpacing: context.h(16),
                      childAspectRatio: 1.2,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: OrderCard(
                          color: theme.scaffoldBgColor,
                          order: Order.fromIsar(orders[index]),
                          theme: theme,
                        ),
                      );
                    },
                  );
                },
              ),
        if (!isOrdersScreen.value)
          ref.watch(customerDebtProvider(customer.id)).when(
                loading: () => SliverToBoxAdapter(child: AppLoadingScreen()),
                error: (e, st) => SliverToBoxAdapter(child: AppErrorScreen()),
                data: (orders) {
                  if (orders.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: 100.all,
                          child: AppEmptyWidget(),
                        ),
                      ),
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.w(16),
                      // mainAxisSpacing: context.h(16),
                      childAspectRatio: 1.2,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: OrderCard(
                          color: theme.scaffoldBgColor,
                          order: Order.fromIsar(orders[index]),
                          theme: theme,
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
  }
}
