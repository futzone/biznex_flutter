import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
          child: Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 12),
            child: Row(
              children: [
                AppBackButton(),
                24.w,
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: boldFamily,
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
                color: theme.accentColor),
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
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: 100.all,
                child: AppEmptyWidget(),
              ),
            ),
          )
      ],
    );
  }
}
