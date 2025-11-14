import 'dart:io';

import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../biznex.dart';

class OrdersLoadingScreen extends StatelessWidget {
  final AppColors theme;

  const OrdersLoadingScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: 120.bottom,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: context.w(16),
          mainAxisSpacing: context.h(16),
          childAspectRatio: 1.2,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          return Container(
              margin: Platform.isWindows ? null : Dis.only(tb: 8, lr: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: theme.secondaryTextColor.withValues(alpha: 0.2),
                    highlightColor: theme.cardColor,
                    child: Container(
                      padding: Dis.all(context.s(16)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Shimmer.fromColors(
                              baseColor: theme.secondaryTextColor
                                  .withValues(alpha: 0.2),
                              highlightColor: theme.accentColor,
                              child: Container(
                                height: 56,
                                width: 56,
                                padding: Dis.all(context.s(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: theme.secondaryTextColor
                                        .withValues(alpha: 0.2),
                                    highlightColor: theme.accentColor,
                                    child: Container(
                                      height: 12,
                                      padding: Dis.all(context.s(16)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: theme.secondaryTextColor
                                        .withValues(alpha: 0.2),
                                    highlightColor: theme.accentColor,
                                    child: Container(
                                      margin: Dis.right(40),
                                      height: 12,
                                      padding: Dis.all(context.s(16)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        16.h,
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: theme.secondaryTextColor
                                  .withValues(alpha: 0.2),
                              highlightColor: theme.accentColor,
                              child: Container(
                                height: 12,
                                padding: Dis.all(context.s(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: theme.secondaryTextColor
                                  .withValues(alpha: 0.2),
                              highlightColor: theme.accentColor,
                              child: Container(
                                height: 12,
                                padding: Dis.all(context.s(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: theme.secondaryTextColor
                                  .withValues(alpha: 0.2),
                              highlightColor: theme.accentColor,
                              child: Container(
                                height: 12,
                                padding: Dis.all(context.s(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: theme.secondaryTextColor
                                  .withValues(alpha: 0.2),
                              highlightColor: theme.accentColor,
                              child: Container(
                                margin: Dis.right(40),
                                height: 12,
                                padding: Dis.all(context.s(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Shimmer.fromColors(
                      baseColor:
                          theme.secondaryTextColor.withValues(alpha: 0.2),
                      highlightColor: theme.accentColor,
                      child: Container(
                        height: 56,
                        width: 56,
                        padding: Dis.all(context.s(16)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
