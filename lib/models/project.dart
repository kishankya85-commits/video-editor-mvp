import 'timeline_clip.dart';

class VideoProject {
  final String id;
  final String name;
  final List<TimelineClip> clips;

  const VideoProject({required this.id, required this.name, required this.clips});

  Duration get duration => clips.fold(Duration.zero, (sum, clip) => sum + clip.duration);
}
