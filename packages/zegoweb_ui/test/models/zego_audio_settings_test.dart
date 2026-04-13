import 'package:test/test.dart';
import 'package:zegoweb_ui/src/models/zego_audio_settings.dart';

void main() {
  group('ZegoAudioSettings', () {
    test('default constructor enables all three flags', () {
      const s = ZegoAudioSettings();
      expect(s.echoCancellation, isTrue);
      expect(s.noiseSuppression, isTrue);
      expect(s.autoGainControl, isTrue);
    });

    test('copyWith replaces only specified fields', () {
      const s = ZegoAudioSettings();
      final s2 = s.copyWith(noiseSuppression: false);
      expect(s2.echoCancellation, isTrue);
      expect(s2.noiseSuppression, isFalse);
      expect(s2.autoGainControl, isTrue);
    });

    test('equality holds when all fields match', () {
      const a = ZegoAudioSettings(echoCancellation: false);
      const b = ZegoAudioSettings(echoCancellation: false);
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      const a = ZegoAudioSettings();
      const b = ZegoAudioSettings(autoGainControl: false);
      expect(a, isNot(equals(b)));
    });
  });
}
