import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project_template.dart';

class TemplateService {
  Future<Directory> _dir() async {
    final d=await getApplicationDocumentsDirectory();
    final out=Directory('${d.path}/templates');
    await out.create(recursive:true); return out;
  }

  Future<List<ProjectTemplate>> listTemplates() async {
    final d=await _dir(); final result=<ProjectTemplate>[];
    await for(final e in d.list()) {
      if(e is File && e.path.endsWith('.json')) {
        try { result.add(ProjectTemplate.fromJson(Map<String,dynamic>.from(jsonDecode(await e.readAsString())))); } catch(_) {}
      }
    }
    result.sort((a,b)=>b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> save(ProjectTemplate t) async {
    final d=await _dir();
    await File('${d.path}/${t.id}.json').writeAsString(jsonEncode(t.toJson()));
  }

  Future<void> delete(String id) async {
    final d=await _dir(); final f=File('${d.path}/$id.json');
    if(await f.exists()) await f.delete();
  }
}
