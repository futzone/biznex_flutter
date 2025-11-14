import 'dart:io';

import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../biznex.dart';

class TransactionLoaderScreen extends StatelessWidget {
  final AppColors theme;

  const TransactionLoaderScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Stack(
        children: [

          Center(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              // color: Colors.white,
              child: Shimmer.fromColors(
                highlightColor: theme.secondaryTextColor.withValues(alpha: 0.2),
                baseColor: theme.cardColor,
                child: Container(
                  // margin: Dis.only(lr: context.s(24)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: SizedBox(
              height: 56,
              child: Row(
                spacing: 24,
                children: [
                  for (final _ in [1, 2, 3, 4, 5, 6])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: theme.secondaryTextColor.withValues(alpha: 0.2),
                          highlightColor: theme.white,
                          child: Container(
                            padding: Dis.all(context.s(16)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
