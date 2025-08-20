import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/product_color_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/providers/product_color_provider.dart';
import 'package:biznex/src/ui/screens/other_screens/header_screen.dart';
import 'package:biznex/src/ui/screens/product_info_screen/add_product_color.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../widgets/dialogs/app_custom_dialog.dart';

class ProductColorResponsive extends AppStatelessWidget {
  final bool useBack;

  const ProductColorResponsive({super.key, this.useBack = false});

  @override
  Widget builder(context, theme, ref, state) {
    return Column(
      children: [
        Row(
          children: [
            if (useBack)
              SimpleButton(
                child: Icon(Icons.arrow_back_ios_new),
                onPressed: () => AppRouter.close(context),
              ),
            if (useBack) 24.w,
            Expanded(
              child: HeaderScreen(
                title: AppLocales.productColors.tr(),
                onAddPressed: () => showDesktopModal(context: context, body: AddProductColor()),
              ),
            ),
          ],
        ),
        Expanded(
          child: ref.watch(productColorProvider).when(
                loading: () => AppLoadingScreen(),
                error: RefErrorScreen,
                data: (data) {
                  if (data.isEmpty) return AppEmptyWidget();
                  return ListView.builder(
                    padding: 8.top,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final info = data[index];
                      return AppListTile(
                        title: info.name,
                        theme: theme,
                        leadingIcon: Icons.circle,
                        iconColor: colorFromHex(info.code ?? ''),
                        onDelete: () {
                          ProductColorController controller = ProductColorController(context: context, state: state);
                          controller.delete(info.id);
                        },
                        onEdit: () {
                          showDesktopModal(context: context, body: AddProductColor(productColor: info));
                        },
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }
}
