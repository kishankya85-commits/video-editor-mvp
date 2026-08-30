import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/text_overlay.dart';

void main() {
  const overlay = TextOverlay(
    id: 't1',
    text: 'Hello',
    x: .5,
    y: .5,
    fontSize: 24,
    color: Colors.white,
    fontWeight: FontWeight.normal,
    startTime: Duration(seconds: 2),
    endTime: Duration(seconds: 6),
  );

  test('text overlay visibility respects start and end times', () {
    expect(overlay.isVisibleAt(const Duration(seconds: 1)), isFalse);
    expect(overlay.isVisibleAt(const Duration(seconds: 2)), isTrue);
    expect(overlay.isVisibleAt(const Duration(seconds: 4)), isTrue);
    expect(overlay.isVisibleAt(const Duration(seconds: 6)), isTrue);
    expect(overlay.isVisibleAt(const Duration(seconds: 7)), isFalse);
  });

  test('copyWith updates text properties immutably', () {
    final updated = overlay.copyWith(
      text: 'Updated',
      fontSize: 40,
      fontWeight: FontWeight.bold,
    );
    expect(updated.id, 't1');
    expect(updated.text, 'Updated');
    expect(updated.fontSize, 40);
    expect(updated.fontWeight, FontWeight.bold);
    expect(updated.startTime, const Duration(seconds: 2));
  });
}
