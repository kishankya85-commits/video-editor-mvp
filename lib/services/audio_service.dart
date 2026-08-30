import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AudioService {
  Future<File?> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    return path == null ? null : File(path);
  }
}
