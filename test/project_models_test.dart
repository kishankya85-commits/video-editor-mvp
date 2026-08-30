import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/audio_track.dart';
import 'package:video_editor_mvp_final/models/text_overlay.dart';
import 'package:video_editor_mvp_final/models/timeline_clip.dart';

void main() {
  test('trim boundaries can preserve a minimum duration', () {
    const clip = TimelineClip(
      id: 'c', sourcePath: 'x.mp4', sourceDuration: Duration(seconds: 10),
      start: Duration(seconds: 2), end: Duration(seconds: 8),
    );
    expect(clip.duration, const Duration(seconds: 6));
    final trimmed = clip.copyWith(end: const Duration(seconds: 3));
    expect(trimmed.duration, const Duration(seconds: 1));
  });

  test('audio track keeps independent timeline position and source trim', () {
    const audio = AudioTrack(
      id: 'a', sourcePath: 'a.mp3', sourceDuration: Duration(seconds: 30),
      start: Duration(seconds: 5), end: Duration(seconds: 20),
      timelineStart: Duration(seconds: 3), volume: .7, isBackgroundMusic: false,
    );
    expect(audio.duration, const Duration(seconds: 15));
    expect(audio.timelineStart, const Duration(seconds: 3));
    expect(audio.copyWith(volume: 1).volume, 1);
  });

  test('text overlay timing and normalized position are retained', () {
    const text = TextOverlay(
      id: 't', text: 'Hello', x: .2, y: .8, fontSize: 30,
      color: Colors.red, fontWeight: FontWeight.bold,
      startTime: Duration(seconds: 1), endTime: Duration(seconds: 4),
    );
    expect(text.isVisibleAt(const Duration(seconds: 2)), isTrue);
    expect(text.isVisibleAt(const Duration(seconds: 5)), isFalse);
    expect(text.copyWith(x: .3).y, .8);
  });
}
