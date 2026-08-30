import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    return file == null ? null : File(file.path);
  }

  Future<List<File>> pickVideos() async {
    final List<XFile> files = await _picker.pickMultipleMedia();
    return files
        .where((file) {
          final name = file.name.toLowerCase();
          return name.endsWith('.mp4') ||
              name.endsWith('.mov') ||
              name.endsWith('.mkv') ||
              name.endsWith('.webm') ||
              name.endsWith('.avi') ||
              name.endsWith('.m4v');
        })
        .map((file) => File(file.path))
        .toList();
  }
}
