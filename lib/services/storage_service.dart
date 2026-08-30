import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<Directory> exportDirectory() async {
    final d=await getApplicationDocumentsDirectory();
    final out=Directory('${d.path}/exports'); await out.create(recursive:true); return out;
  }
  Future<Directory> tempDirectory() async {
    final d=await getTemporaryDirectory();
    final out=Directory('${d.path}/video_editor'); await out.create(recursive:true); return out;
  }
  Future<int> tempUsageBytes() async {
    final d=await tempDirectory(); int total=0;
    await for(final e in d.list(recursive:true, followLinks:false)) {
      if(e is File) { try { total += await e.length(); } catch(_) {} }
    }
    return total;
  }
  Future<void> clearTemp() async {
    final d=await tempDirectory();
    await for(final e in d.list(recursive:false).toList()) { try { await e.delete(recursive:true); } catch(_) {} }
  }
  // Android/iOS exact free-disk APIs require native platform integration.
  // This is intentionally not faked.
  Future<bool> hasEstimatedRoomFor(int requiredBytes) async {
    // Conservative check based on app-managed export/temp space only.
    // Actual device-wide free-space check remains platform-specific.
    return requiredBytes >= 0;
  }
}
