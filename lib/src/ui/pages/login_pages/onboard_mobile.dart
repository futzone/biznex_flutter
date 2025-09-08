import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';
import '../../../core/config/router.dart';
import '../../../providers/employee_provider.dart';
import 'login_page.dart';

class OnboardMobile extends ConsumerWidget {
  final List<Employee> employees;
  final AppColors theme;
  final AppModel state;

  const OnboardMobile({super.key, required this.state, required this.employees, required this.theme});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset("assets/images/Vector.svg", height: 20),
        actions: [
          IconButton(
            icon: Icon(Iconsax.logout_copy),
            onPressed: () {},
          ),
          8.w,
        ],
      ),
      body: SingleChildScrollView(
        padding: Dis.only(lr: 16, tb: 16),
        child: Column(
          spacing: 16,
          children: [
            for (final employee in employees)
              MaterialButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: Dis.only(tb: 24, lr: 24),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Iconsax.user_copy, size: 20),
                    8.w,
                    Expanded(
                      child: Text(
                        employee.fullname,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: boldFamily,
                        ),
                      ),
                    ),
                    Text(
                      employee.roleName.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: mediumFamily,
                        color: theme.secondaryTextColor,
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  ref.read(currentEmployeeProvider.notifier).update((state) => employee);
                  AppRouter.go(context, LoginPageHarom(model: state, theme: theme));
                },
              ),
          ],
        ),
      ),
    );
  }
}
