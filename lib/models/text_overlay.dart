import 'package:flutter/material.dart';

class TextOverlay {
  final String id;
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final Duration startTime;
  final Duration endTime;

  const TextOverlay({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
    required this.startTime,
    required this.endTime,
  });

  bool isVisibleAt(Duration position) =>
      position >= startTime && position <= endTime;

  TextOverlay copyWith({
    String? text,
    double? x,
    double? y,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    Duration? startTime,
    Duration? endTime,
  }) {
    return TextOverlay(
      id: id,
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
