import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/audio_track.dart';
import 'package:video_editor_mvp_final/models/timeline_clip.dart';

void main() {
  test('TimelineClip duration works', () {
    const clip = TimelineClip(
      id: '1', sourcePath: 'v.mp4',
      sourceDuration: Duration(seconds: 10),
      start: Duration(seconds: 2), end: Duration(seconds: 8),
    );
    expect(clip.duration, const Duration(seconds: 6));
  });

  test('AudioTrack trims immutably and preserves volume', () {
    const track = AudioTrack(
      id: 'a', sourcePath: 'a.mp3',
      sourceDuration: Duration(seconds: 30),
      start: Duration.zero, end: Duration(seconds: 20),
      timelineStart: Duration.zero, volume: .8, isBackgroundMusic: true,
    );
    final changed = track.copyWith(
      start: const Duration(seconds: 2),
      end: const Duration(seconds: 12),
      volume: .5,
    );
    expect(changed.duration, const Duration(seconds: 10));
    expect(changed.volume, .5);
    expect(changed.isBackgroundMusic, isTrue);
  });

  test('Multiple clips calculate continuous project duration', () {
    const a = TimelineClip(id:'a', sourcePath:'a', sourceDuration:Duration(seconds:5), start:Duration.zero, end:Duration(seconds:5));
    const b = TimelineClip(id:'b', sourcePath:'b', sourceDuration:Duration(seconds:7), start:Duration.zero, end:Duration(seconds:7));
    final total = [a,b].fold(Duration.zero, (sum, c) => sum + c.duration);
    expect(total, const Duration(seconds:12));
  });
}
