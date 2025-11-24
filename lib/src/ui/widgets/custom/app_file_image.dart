import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';

import '../../../providers/app_image_provider.dart';

final _fileImageProvider = FutureProvider.family((ref, dynamic path) async {
  if (path == null || path.toString().isEmpty) return null;
  final File file = File(path.toString());
  if (await file.exists()) return file;
  return null;
});

class AppFileImage extends ConsumerWidget {
  final dynamic path;
  final String name;
  final double? size;
  final Color? color;
  final double radius;
  final String? id;

  const AppFileImage({
    this.color,
    this.id,
    this.radius = 8,
    super.key,
    required this.name,
    required this.path,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isWindows) return SizedBox();

    return AppStateWrapper(
      builder: (theme, state) {
        if (state.alwaysWaiter && id != null) {
          final imageUrl = ref.watch(appImageProvider(id ?? '')).value;

          if (imageUrl == null) {
            return AppFileImage(
              name: name,
              path: path,
              color: color,
            );
          }

          return Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: color ?? theme.scaffoldBgColor,
              border: Border.all(color: theme.accentColor),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        return ref.watch(_fileImageProvider(path)).when(
              loading: () => AppLoadingScreen(),
              error: (error, stackTrace) {
                return Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: color ?? theme.scaffoldBgColor,
                    border: Border.all(color: theme.accentColor),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name.trim()[0] : '?',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 24,
                        fontFamily: boldFamily,
                      ),
                    ),
                  ),
                );
              },
              data: (data) {
                return Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: color ?? theme.scaffoldBgColor,
                    image: data != null
                        ? DecorationImage(
                            image: FileImage(data),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                    border: Border.all(color: theme.accentColor),
                  ),
                  child: data == null
                      ? Center(
                          child: Text(
                            name.isNotEmpty ? name.trim()[0] : '?',
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 24,
                              fontFamily: boldFamily,
                            ),
                          ),
                        )
                      : null,
                );
              },
            );
      },
    );
  }
}
