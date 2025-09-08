import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/employee_screens/add_role.dart';
import 'package:biznex/src/ui/screens/other_screens/header_screen.dart';
import 'package:biznex/src/ui/screens/product_info_screen/add_product_color.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';

class RoleResponsive extends AppStatelessWidget {
  final bool useBack;

  const RoleResponsive({super.key, this.useBack = false});

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
                title: AppLocales.roles.tr(),
                onAddPressed: () => showDesktopModal(
                  context: context,
                  body: AddRole(),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ref.watch(roleProvider).when(
                loading: () => AppLoadingScreen(),
                error: RefErrorScreen,
                data: (data) {
                  if (data.isEmpty) return AppEmptyWidget();
                  return ListView.builder(
                    padding: 8.top,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final Role info = data[index];
                      return AppListTile(
                        title: info.name,
                        theme: theme,
                        leadingIcon: Icons.person,
                        onDelete: () {
                          EmployeeController controller = EmployeeController(context: context, state: state);
                          controller.deleteRole(info.id);
                        },
                        onEdit: () {
                          showDesktopModal(context: context, body: AddRole(role: info));
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
