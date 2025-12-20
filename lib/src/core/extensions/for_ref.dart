import '../../../biznex.dart';
import '../../ui/widgets/helpers/app_loading_screen.dart';

extension ProviderUi on WidgetRef {
  Widget whenProviderData(
      {required dynamic provider,
        required Widget Function(dynamic data) builder}) {
    return watch(provider as FutureProvider).when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) {
        return const Center(child: Text("An Unknown Error: "));
      },
      data: (data) => builder(data),
    );
  }
}