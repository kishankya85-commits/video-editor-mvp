import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';
import '../models/export_models.dart';
import '../models/text_overlay.dart';
import '../models/timeline_clip.dart';

class ExportService {
  bool _cancelRequested = false;

  Future<void> cancel() async {
    _cancelRequested = true;
    await FFmpegKit.cancel();
  }

  Future<ExportState> exportProject({
    required List<TimelineClip> clips,
    required List<AudioTrack> audioTracks,
    required List<TextOverlay> textOverlays,
    required ExportResolution resolution,
    required void Function(double progress) onProgress,
  }) async {
    if (clips.isEmpty) {
      return const ExportState(status: ExportStatus.error, error: 'No clips to export.');
    }

    _cancelRequested = false;
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    await exportDir.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final output = '${exportDir.path}/video_editor_$stamp.mp4';
    final assPath = '${exportDir.path}/video_editor_$stamp.ass';
    await File(assPath).writeAsString(_buildAss(textOverlays, clips, resolution));

    final total = clips.fold<Duration>(Duration.zero, (sum, c) => sum + c.duration);
    final command = _buildCommand(
      clips: clips,
      audioTracks: audioTracks,
      assPath: assPath,
      output: output,
      resolution: resolution,
      totalDuration: total,
    );

    final completer = Completer<ExportState>();
    await FFmpegKit.executeAsync(
      command,
      (session) async {
        final code = await session.getReturnCode();
        if (_cancelRequested || ReturnCode.isCancel(code)) {
          if (!completer.isCompleted) {
            completer.complete(const ExportState(status: ExportStatus.cancelled));
          }
          return;
        }
        if (ReturnCode.isSuccess(code) && await File(output).exists()) {
          onProgress(1);
          if (!completer.isCompleted) {
            completer.complete(ExportState(
              status: ExportStatus.success,
              progress: 1,
              outputPath: output,
            ));
          }
        } else {
          final logs = await session.getAllLogsAsString();
          if (!completer.isCompleted) {
            completer.complete(ExportState(
              status: ExportStatus.error,
              error: (logs == null || logs.isEmpty) ? 'FFmpeg export failed.' : logs,
            ));
          }
        }
      },
      null,
      (statistics) {
        final ms = statistics.getTime();
        if (total.inMilliseconds > 0) {
          onProgress((ms / total.inMilliseconds).clamp(0.0, 0.99));
        }
      },
    );
    return completer.future;
  }

  String _q(String value) => "'${value.replaceAll("'", r"'\''")}'";

  String _buildCommand({
    required List<TimelineClip> clips,
    required List<AudioTrack> audioTracks,
    required String assPath,
    required String output,
    required ExportResolution resolution,
    required Duration totalDuration,
  }) {
    final inputs = <String>[];
    for (final clip in clips) {
      inputs.add('-i ${_q(clip.sourcePath)}');
    }
    for (final track in audioTracks) {
      inputs.add('-i ${_q(track.sourcePath)}');
    }

    final filters = <String>[];
    final videoLabels = <String>[];
    for (var i = 0; i < clips.length; i++) {
      final c = clips[i];
      final start = c.start.inMilliseconds / 1000;
      final end = c.end.inMilliseconds / 1000;
      filters.add(
        '[$i:v]trim=start=$start:end=$end,setpts=PTS-STARTPTS,'
        'scale=${resolution.width}:${resolution.height}:force_original_aspect_ratio=decrease,'
        'pad=${resolution.width}:${resolution.height}:(ow-iw)/2:(oh-ih)/2,setsar=1[v$i]'
      );
      videoLabels.add('[v$i]');
    }

    if (clips.length == 1) {
    } else {
      filters.add('${videoLabels.join()}concat=n=${clips.length}:v=1:a=0[vcat]');
    }

    final videoInput = clips.length == 1 ? videoLabels.first : '[vcat]';
    final subtitlePath = assPath
        .replaceAll('\\', '/')
        .replaceAll(':', r'\:')
        .replaceAll("'", r"\\'");
    filters.add('${videoInput}subtitles=\'$subtitlePath\'[vout]');

    final audioLabels = <String>[];
    for (var i = 0; i < audioTracks.length; i++) {
      final a = audioTracks[i];
      final inputIndex = clips.length + i;
      final start = a.start.inMilliseconds / 1000;
      final end = a.end.inMilliseconds / 1000;
      final delay = a.timelineStart.inMilliseconds;
      filters.add(
        '[$inputIndex:a]atrim=start=$start:end=$end,asetpts=PTS-STARTPTS,'
        'volume=${a.volume},adelay=${delay}|${delay}[a$i]'
      );
      audioLabels.add('[a$i]');
    }

    final maps = <String>['-map [vout]'];
    if (audioLabels.isNotEmpty) {
      if (audioLabels.length == 1) {
        filters.add('${audioLabels.first}apad,atrim=end=${totalDuration.inMilliseconds / 1000}[aout]');
      } else {
        filters.add('${audioLabels.join()}amix=inputs=${audioLabels.length}:duration=longest:normalize=0,'
            'apad,atrim=end=${totalDuration.inMilliseconds / 1000}[aout]');
      }
      maps.add('-map [aout]');
    } else {
      maps.add('-map 0:a?');
    }

    return '-y ${inputs.join(" ")} -filter_complex "${filters.join(";")}" '
        '${maps.join(" ")} -c:v libx264 -preset veryfast -crf 23 '
        '-pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart ${_q(output)}';
  }

  String _buildAss(
    List<TextOverlay> overlays,
    List<TimelineClip> clips,
    ExportResolution resolution,
  ) {
    String t(Duration d) {
      final cs = d.inMilliseconds ~/ 10;
      final h = cs ~/ 360000;
      final m = (cs ~/ 6000) % 60;
      final s = (cs ~/ 100) % 60;
      final c = cs % 100;
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${c.toString().padLeft(2, '0')}';
    }
    String esc(String value) => value
        .replaceAll('\\', r'\\')
        .replaceAll('{', r'\{')
        .replaceAll('}', r'\}')
        .replaceAll('\n', r'\N');
    String assColor(int argb) {
      final hex = argb.toRadixString(16).padLeft(8, '0');
      final rr = hex.substring(2,4), gg = hex.substring(4,6), bb = hex.substring(6,8);
      return '&H00$bb$gg$rr';
    }

    final b = StringBuffer()
      ..writeln('[Script Info]')
      ..writeln('ScriptType: v4.00+')
      ..writeln('PlayResX: ${resolution.width}')
      ..writeln('PlayResY: ${resolution.height}')
      ..writeln()
      ..writeln('[V4+ Styles]')
      ..writeln('Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding')
      ..writeln('Style: Default,Arial,36,&H00FFFFFF,&H000000FF,&H80000000,&H80000000,0,0,0,0,100,100,0,0,1,2,1,7,10,10,10,1')
      ..writeln()
      ..writeln('[Events]')
      ..writeln('Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text');

    for (final o in overlays) {
      final x = (o.x * resolution.width).round();
      final y = (o.y * resolution.height).round();
      final size = (o.fontSize / 100 * resolution.height).clamp(18, 96).round();
      final bold = o.fontWeight.index >= 6 ? -1 : 0;
      b.writeln('Dialogue: 0,${t(o.startTime)},${t(o.endTime)},Default,,0,0,0,,'
          '{\\pos($x,$y)\\fs$size\\b$bold\\c${assColor(o.color.value)}}${esc(o.text)}');
    }
    return b.toString();
  }
}
