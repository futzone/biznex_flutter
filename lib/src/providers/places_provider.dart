import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/helper/services/api_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';

final placesProvider = FutureProvider((ref) async {
  // if (!ref.watch(serverAppProvider)) {
  //   final HelperApiServices apiServices = HelperApiServices();
  //   final List<Place> placesList = [];
  //   final response = await apiServices.getPlaces(ref.watch(currentEmployeeProvider).pincode);
  //   if (response.isSuccess) {
  //     for (final item in response.data) {
  //       placesList.add(Place.fromJson(item));
  //     }
  //   }
  //
  //   return placesList;
  // }
  PlaceDatabase placeDatabase = PlaceDatabase();
  return await placeDatabase.get();
});
