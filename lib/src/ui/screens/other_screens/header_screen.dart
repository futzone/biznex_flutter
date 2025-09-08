import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/ui/widgets/helpers/app_custom_padding.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';

class HeaderScreen extends AppStatelessWidget {
  final String title;
  final void Function()? onAddPressed;

  const HeaderScreen({
    super.key,
    required this.title,
    this.onAddPressed,
  });

  @override
  Widget builder(context, theme, ref, state) {
    return Padding(
      padding: Dis.only(tb: state.isDesktop ? 0 : 16),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: state.isDesktop ? 18 : 16,
                fontFamily: boldFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (state.isDesktop)
            AppSimpleButton(
              onPressed: onAddPressed,
              icon: Icons.add,
              text: AppLocales.add.tr(),
              padding: Dis.only(tb: 6, lr: 16),
            )
          else
            AppPrimaryButton(
              theme: theme,
              onPressed: () {
                if (onAddPressed == null) return;
                onAddPressed!();
              },
              icon: Icons.add,
              padding: 8.all,
            ),
        ],
      ),
    );
  }
}
