import 'package:biznex/main.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';

import '../../../../../biznex.dart';
import '../order_card.dart';

class OrderItemsBody extends StatelessWidget {
  final ScrollController controller;
  final AppColors theme;
  final List<Order> orders;
  final int currentPage;
  final void Function() onLoadNextPage;
  final void Function() onLoadPreviousPage;

  const OrderItemsBody({
    super.key,
    required this.controller,
    required this.theme,
    required this.orders,
    required this.currentPage,
    required this.onLoadNextPage,
    required this.onLoadPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: context.w(16),
              mainAxisSpacing: context.h(16),
              childAspectRatio: 1.2,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderCard(
                order: orders[index],
                theme: theme,
              );
            },
          ),
          SliverPadding(padding: Dis.only(tb: 12)),
          SliverToBoxAdapter(
            child: Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentPage > 1)
                  SimpleButton(
                    onPressed: () {
                      onLoadPreviousPage();
                    },
                    child: Container(
                      padding: Dis.only(lr: 24, tb: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_sharp,
                            size: 20,
                            color: Colors.black,
                          ),
                          8.w,
                          Text(
                            (currentPage - 1).toString(),
                            style: TextStyle(
                              fontFamily: boldFamily,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding: Dis.only(lr: 24, tb: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$currentPage (${(currentPage - 1) * appPageSize+1} - ${currentPage * appPageSize})",
                        style: TextStyle(
                          fontFamily: boldFamily,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                ),
                if (orders.length == appPageSize)
                  SimpleButton(
                    onPressed: () {
                      onLoadNextPage();
                    },
                    child: Container(
                      padding: Dis.only(lr: 24, tb: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(
                            (currentPage + 1).toString(),
                            style: TextStyle(
                              fontFamily: boldFamily,
                              fontSize: 18,
                            ),
                          ),
                          8.w,
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SliverPadding(padding: Dis.only(tb: 80)),
        ],
      ),
    );
  }
}
