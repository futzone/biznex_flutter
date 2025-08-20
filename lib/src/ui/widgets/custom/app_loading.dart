import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import '../../widgets/helpers/app_loading_screen.dart';

showAppLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AppLoadingScreen(padding: Dis.all(100));
    },
  );
}

showAppProgressDialog(BuildContext context, ValueNotifier<double> progressNotifier) {
  showDialog(
    context: context,
    // barrierDismissible: true,
    builder: (context) {
      return ProgressQ(progressNotifier: progressNotifier);
    },
  );
}

class ProgressQ extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;

  ProgressQ({super.key, required this.progressNotifier});

  final theme = AppColors(isDark: false);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      child: Center(
        child: Container(
          margin: 100.all,
          constraints: BoxConstraints(),
          padding: Dis.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: ValueListenableBuilder(
            valueListenable: progressNotifier,
            builder: (a, value, c) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Ionicons.cloud_upload_outline,
                    size: context.s(40),
                    color: theme.mainColor,
                  ),
                  16.h,
                  Text(
                    AppLocales.sendingReports.tr(),
                    style: TextStyle(
                      fontSize: context.s(18),
                      fontFamily: boldFamily,
                    ),
                  ),
                  16.h,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20)
                    // decoration: BoxDecoration(
                    // ),
                    ,
                    child: LinearProgressIndicator(
                      value: value == 0 ? null : value * 0.01,
                      backgroundColor: theme.scaffoldBgColor,
                      color: theme.mainColor,
                      minHeight: 6,
                    ),
                  ),
                  if (value != 0) 16.h,
                  if (value != 0)
                    Text(
                      "${AppLocales.done.tr()}: ${value.toStringAsFixed(1)} %",
                      style: TextStyle(
                        fontSize: context.s(18),
                        fontFamily: boldFamily,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
