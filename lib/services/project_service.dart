import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';
import '../models/caption.dart';
import '../models/text_overlay.dart';
import '../models/timeline_clip.dart';

class ProjectService {
  static const _fileName = 'last_project.json';

  Future<File> projectFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> save({
    required List<TimelineClip> clips,
    required List<AudioTrack> audioTracks,
    required List<TextOverlay> textOverlays,
    List<Caption> captions = const [],
  }) async {
    final file = await projectFile();
    final data = {
      'clips': clips.map((c) => {
        'id': c.id,
        'sourcePath': c.sourcePath,
        'sourceDurationMs': c.sourceDuration.inMilliseconds,
        'startMs': c.start.inMilliseconds,
        'endMs': c.end.inMilliseconds,
      }).toList(),
      'audioTracks': audioTracks.map((a) => {
        'id': a.id,
        'sourcePath': a.sourcePath,
        'sourceDurationMs': a.sourceDuration.inMilliseconds,
        'startMs': a.start.inMilliseconds,
        'endMs': a.end.inMilliseconds,
        'timelineStartMs': a.timelineStart.inMilliseconds,
        'volume': a.volume,
        'isBackgroundMusic': a.isBackgroundMusic,
      }).toList(),
      'captions': captions.map((c) => {'id': c.id, 'text': c.text, 'startMs': c.start.inMilliseconds, 'endMs': c.end.inMilliseconds}).toList(),
      'textOverlays': textOverlays.map((t) => {
        'id': t.id,
        'text': t.text,
        'x': t.x,
        'y': t.y,
        'fontSize': t.fontSize,
        'color': t.color.value,
        'fontWeight': t.fontWeight.index,
        'startTimeMs': t.startTime.inMilliseconds,
        'endTimeMs': t.endTime.inMilliseconds,
      }).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadRaw() async {
    final file = await projectFile();
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<bool> hasSavedProject() async => (await projectFile()).exists();

  Future<void> clear() async {
    final file = await projectFile();
    if (await file.exists()) await file.delete();
  }
}
