class Caption {
  final String id;
  final String text;
  final Duration start;
  final Duration end;
  const Caption({required this.id, required this.text, required this.start, required this.end});
  bool visibleAt(Duration position) => position >= start && position <= end;
  Caption copyWith({String? text, Duration? start, Duration? end}) =>
      Caption(id:id,text:text??this.text,start:start??this.start,end:end??this.end);
}
