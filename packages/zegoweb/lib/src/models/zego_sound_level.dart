import 'package:meta/meta.dart';

/// Volume level for a single stream, as reported by the ZEGO SDK's
/// `soundLevelUpdate` event.
@immutable
class ZegoSoundLevelInfo {
  const ZegoSoundLevelInfo({
    required this.streamId,
    required this.soundLevel,
  });

  /// The stream ID this level belongs to.
  final String streamId;

  /// Volume level in the range 0.0–100.0.
  final double soundLevel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoSoundLevelInfo &&
        other.streamId == streamId &&
        other.soundLevel == soundLevel;
  }

  @override
  int get hashCode => Object.hash(streamId, soundLevel);

  @override
  String toString() =>
      'ZegoSoundLevelInfo(streamId: $streamId, soundLevel: $soundLevel)';
}

/// Payload for the ZEGO SDK's `soundLevelUpdate` event. Contains volume
/// levels for all active streams in the room.
@immutable
class ZegoSoundLevelUpdate {
  const ZegoSoundLevelUpdate({required this.levels});

  /// Volume levels per stream.
  final List<ZegoSoundLevelInfo> levels;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZegoSoundLevelUpdate) return false;
    if (other.levels.length != levels.length) return false;
    for (var i = 0; i < levels.length; i++) {
      if (other.levels[i] != levels[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(levels);

  @override
  String toString() => 'ZegoSoundLevelUpdate(levels: $levels)';
}
