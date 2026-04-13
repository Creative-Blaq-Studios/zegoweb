// packages/zegoweb/lib/src/audio_level_rms.dart
//
// Pure-Dart RMS helper extracted from ZegoAudioLevelMonitor so that unit
// tests can import it on the Dart VM without touching dart:js_interop.
import 'dart:math';
import 'dart:typed_data';

/// Compute normalised RMS of a time-domain byte buffer (values 0–255,
/// centred at 128). Result is in range 0.0–1.0.
double computeAudioRms(Uint8List samples) {
  if (samples.isEmpty) return 0.0;
  double sum = 0;
  for (final byte in samples) {
    final centered = (byte - 128).toDouble();
    sum += centered * centered;
  }
  return sqrt(sum / samples.length) / 128.0;
}
