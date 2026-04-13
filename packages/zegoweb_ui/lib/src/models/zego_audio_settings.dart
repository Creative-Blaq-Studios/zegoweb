import 'package:meta/meta.dart';

/// Immutable set of audio-processing flags passed to the ZEGO stream config.
///
/// Defaults mirror the ZEGO SDK defaults (all three enabled).
@immutable
class ZegoAudioSettings {
  const ZegoAudioSettings({
    this.echoCancellation = true,
    this.noiseSuppression = true,
    this.autoGainControl = true,
  });

  /// Acoustic Echo Cancellation (AEC). Prevents audio feedback when speakers
  /// are used without headphones.
  final bool echoCancellation;

  /// Acoustic Noise Suppression (ANS). Filters steady background noise.
  final bool noiseSuppression;

  /// Auto Gain Control (AGC). Normalises mic volume across different
  /// input levels.
  final bool autoGainControl;

  ZegoAudioSettings copyWith({
    bool? echoCancellation,
    bool? noiseSuppression,
    bool? autoGainControl,
  }) {
    return ZegoAudioSettings(
      echoCancellation: echoCancellation ?? this.echoCancellation,
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
      autoGainControl: autoGainControl ?? this.autoGainControl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZegoAudioSettings &&
          other.echoCancellation == echoCancellation &&
          other.noiseSuppression == noiseSuppression &&
          other.autoGainControl == autoGainControl;

  @override
  int get hashCode =>
      Object.hash(echoCancellation, noiseSuppression, autoGainControl);
}
