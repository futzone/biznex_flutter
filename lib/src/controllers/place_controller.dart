import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

import '../core/config/router.dart';

class PlaceController extends AppController {
  PlaceController({required super.context, required super.state});

  @override
  Future<void> create(data, {bool multiple = false}) async {
    data as Place;
    if (data.name.isEmpty) return error(AppLocales.placeNameInputError.tr());
    showAppLoadingDialog(context);
    PlaceDatabase sizeDatabase = PlaceDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(placesProvider);
      if (!multiple) closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key, {Place? father, ref}) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deletePlaceQuestionText.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        PlaceDatabase sizeDatabase = PlaceDatabase();
        await sizeDatabase.delete(key: key, father: father).then((_) {
          ref!.invalidate(placesProvider);
          closeLoading();
          if (father == null) return;
          AppRouter.close(context);
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Place;
    if (data.name.isEmpty) return error(AppLocales.placeNameInputError.tr());
    showAppLoadingDialog(context);
    PlaceDatabase sizeDatabase = PlaceDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(placesProvider);
      closeLoading();
      closeLoading();
    });
  }
}
