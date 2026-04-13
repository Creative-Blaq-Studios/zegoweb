// packages/zegoweb/test/audio_level_monitor_test.dart
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:zegoweb/src/audio_level_rms.dart';

void main() {
  group('ZegoAudioLevelMonitor.computeRms', () {
    test('returns 0.0 for silence (all 128)', () {
      final silence = Uint8List(256)..fillRange(0, 256, 128);
      expect(computeAudioRms(silence), equals(0.0));
    });

    test('returns 1.0 for maximum alternating signal', () {
      // Alternating 0 and 255 produces centred values of ±128, RMS = 128/128 = 1.0.
      final max = Uint8List(256);
      for (var i = 0; i < 256; i++) {
        max[i] = i.isEven ? 0 : 255;
      }
      expect(computeAudioRms(max), closeTo(1.0, 0.01));
    });

    test('returns 0.0 for empty buffer', () {
      expect(computeAudioRms(Uint8List(0)), equals(0.0));
    });

    test('returns value between 0 and 1 for moderate signal', () {
      // Values 110-146 centred around 128 → moderate RMS.
      final moderate = Uint8List(256);
      for (var i = 0; i < 256; i++) {
        moderate[i] = 110 + (i % 37);
      }
      final rms = computeAudioRms(moderate);
      expect(rms, greaterThan(0.0));
      expect(rms, lessThan(1.0));
    });
  });
}
