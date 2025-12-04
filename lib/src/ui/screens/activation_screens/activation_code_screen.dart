import 'package:biznex/src/controllers/app_subscription_controller.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import '../../../../biznex.dart';
import '../../../core/database/app_database/app_state_database.dart';

class ActivationCodeScreen extends StatefulWidget {
  final WidgetRef ref;
  final AppModel state;

  const ActivationCodeScreen(
      {super.key, required this.ref, required this.state});

  @override
  State<ActivationCodeScreen> createState() => _ActivationTestPageState();
}

class _ActivationTestPageState extends State<ActivationCodeScreen> {
  late AppSubscriptionController _controller;
  int? code;
  bool _initializing = true;

  _initialize() async {
    setState(() {
      _controller = AppSubscriptionController(context);
    });

    await _controller.createSubscription().then((co) {
      setState(() {
        code = co;
        _initializing = false;
      });
    });

    await _controller.listenChanges(onChanged: (String token) async {
      AppModel newApp = widget.state;
      newApp.licenseKey = token;
      await LicenseServices().verifyLicense(token);

      AppStateDatabase().updateApp(newApp).then((_) {
        widget.ref.invalidate(appStateProvider);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppColors(isDark: false);
    return Scaffold(
      body: Center(
        child: _initializing
            ? AppLoadingScreen()
            : Container(
                padding: 16.all,
                constraints: BoxConstraints(maxWidth: 600),
                margin: Dis.only(lr: 160, tb: 48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.cardColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Image.asset(
                      "assets/icons/expired.png",
                      height: 100,
                    ),
                    Text(
                      AppLocales.subscriptionPaymentTextForCode.tr(),
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      code.toString().split('').join(' '),
                      style: TextStyle(
                        color: theme.mainColor,
                        fontSize: 48,
                        fontFamily: boldFamily,
                      ),
                    ),
                    Text(
                      "${AppLocales.contactWithUs.tr()}:  +998 94 244 99 89",
                      style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
