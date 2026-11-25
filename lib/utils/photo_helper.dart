// lib/utils/photo_helper.dart
// Picks a photo (camera or gallery) and copies it into the app's own folder.
// Why copy? The camera/gallery file is temporary. The copy stays forever.

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Returns the saved file path, or null if the user cancelled.
Future<String?> pickAndSavePhoto(ImageSource source) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600, // shrink big photos to save space
    imageQuality: 80,
  );
  if (picked == null) return null;

  final docs = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(docs.path, 'photos'));
  if (!await folder.exists()) await folder.create(recursive: true);

  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
  final saved = await File(picked.path).copy(p.join(folder.path, fileName));
  return saved.path;
}