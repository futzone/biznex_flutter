import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/app_state_provider.dart';

import '../../../../biznex.dart';
import '../../widgets/custom/app_state_wrapper.dart';

class WarehouseTypeScreen extends StatefulWidget {
  const WarehouseTypeScreen({super.key});

  @override
  State<WarehouseTypeScreen> createState() => _AppLanguageBarState();
}

class _AppLanguageBarState extends State<WarehouseTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return AppStateWrapper(builder: (theme, state) {
        return Container(
          padding: context.s(20).all,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              Text(
                AppLocales.warehouseCalculating.tr(),
                style: TextStyle(
                  fontSize: context.s(24),
                  fontFamily: mediumFamily,
                  color: Colors.black,
                ),
              ),
              Text(
                AppLocales.warehouseCalculatingInfo.tr(),
                style: TextStyle(
                  fontSize: context.s(14),
                  fontFamily: mediumFamily,
                  color: Colors.black,
                ),
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    flex: 3,
                    child: SimpleButton(
                      onPressed: () {
                        AppModel as = state;
                        as.after = false;
                        AppStateDatabase().updateApp(as).then((_) {
                          ref.invalidate(appStateProvider);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.scaffoldBgColor,
                        ),
                        padding: Dis.only(lr: 12, tb: 12),
                        child: Row(
                          spacing: 12,
                          children: [
                            Icon(
                              !state.after
                                  ? Icons.check_circle_outline
                                  : Icons.circle_outlined,
                              color: theme.mainColor,
                            ),
                            Text(
                              AppLocales.becomeReport.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: mediumFamily,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SimpleButton(
                      onPressed: () {
                        AppModel as = state;
                        as.after = true;
                        AppStateDatabase().updateApp(as).then((_) {
                          ref.invalidate(appStateProvider);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.scaffoldBgColor,
                        ),
                        padding: Dis.only(lr: 12, tb: 12),
                        child: Row(
                          spacing: 12,
                          children: [
                            Icon(
                              state.after
                                  ? Icons.check_circle_outline
                                  : Icons.circle_outlined,
                              color: theme.mainColor,
                            ),
                            Text(
                              AppLocales.afterReport.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: mediumFamily,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    });
  }
}
