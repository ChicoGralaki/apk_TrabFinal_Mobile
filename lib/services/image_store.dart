import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStore {
  ImageStore({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  Future<String?> pickAndStore({
    ImageSource source = ImageSource.gallery,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (image == null) return null;
    final directory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(p.join(directory.path, 'agenda_images'));
    await targetDirectory.create(recursive: true);
    final extension = p.extension(image.path).isEmpty
        ? '.jpg'
        : p.extension(image.path);
    final target = p.join(
      targetDirectory.path,
      '${const Uuid().v4()}$extension',
    );
    await File(image.path).copy(target);
    return target;
  }

  Future<void> deleteIfUnused(String? imagePath) async {
    if (imagePath == null) return;
    final file = File(imagePath);
    if (await file.exists()) await file.delete();
  }
}
