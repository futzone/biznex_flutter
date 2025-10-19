import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/intro_static.dart';
import '../../../providers/app_state_provider.dart';

class LoginHalfPage extends HookConsumerWidget {
  final AppModel app;

  const LoginHalfPage(this.app, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: Container(
        color: AppColors(isDark: false).mainColor,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.2,
                child: SvgPicture.asset(
                  'assets/svg/Vector.svg',
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.white,
                  // fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (Navigator.canPop(context))
                      SimpleButton(
                        onPressed: () {
                          AppRouter.close(context);
                        },
                        child: Container(
                          margin: Dis.top(32),
                          padding: Dis.only(lr: 16, tb: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Ionicons.arrow_back,
                          ),
                        ),
                      ),
                    Container(
                      margin: Dis.top(32),
                      padding: Dis.only(lr: 32, tb: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        color: Colors.white,
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(Iconsax.call_copy),
                          Text(
                            "${AppLocales.contactWithUs.tr()}: +998 94 244 99 89",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: boldFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ref.watch(appUpdaterProvider).when(
                        error: (_, __) => 0.h,
                        loading: () => 0.h,
                        data: (data) {
                          final current = data['current'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              "v$current",
                              style: TextStyle(
                                fontFamily: mediumFamily,
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
