import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'project_service.dart';

class BackupService {
  Future<Directory> _dir() async {
    final d=await getApplicationDocumentsDirectory();
    final out=Directory('${d.path}/backups'); await out.create(recursive:true); return out;
  }

  Future<File> createBackup(ProjectService projectService) async {
    final source=await projectService.projectFile();
    if(!await source.exists()) throw StateError('No saved project to back up.');
    final d=await _dir();
    final file=File('${d.path}/project_${DateTime.now().millisecondsSinceEpoch}.json');
    return source.copy(file.path);
  }

  Future<List<File>> listBackups() async {
    final d=await _dir();
    final files=<File>[];
    await for(final e in d.list()) { if(e is File && e.path.endsWith('.json')) files.add(e); }
    files.sort((a,b)=>b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  Future<void> restore(File backup, ProjectService projectService) async {
    final target=await projectService.projectFile();
    await backup.copy(target.path);
  }
}
