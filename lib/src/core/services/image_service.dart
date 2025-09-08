import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final File imageFile = File(image.path);
    final String fileName = imageFile.uri.pathSegments.last;

    final Directory appDir = await getApplicationSupportDirectory();
    final String savedPath = '${appDir.path}/$fileName';

    await imageFile.copy(savedPath);

    return savedPath;
  }

  static Future<String> copyImageToAppFolder(String imagePath) async {
    final appDir = await getApplicationSupportDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = path.basename(imagePath);

    final destPath = path.join(imagesDir.path, fileName);
    final destFile = File(destPath);

    await File(imagePath).copy(destFile.path);

    log(destFile.path);
    return destFile.path;
  }
}
