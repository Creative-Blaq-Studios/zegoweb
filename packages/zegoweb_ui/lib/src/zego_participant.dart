import 'package:meta/meta.dart';

@immutable
class ZegoParticipant {
  const ZegoParticipant({
    required this.userId,
    this.userName,
    this.streamId,
    this.stream,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isLocal = false,
  });

  final String userId;
  final String? userName;

  /// The SDK stream ID used for publishing/playing. For the local participant
  /// this is the ID passed to `startPublishing`; for remote participants it
  /// comes from the `roomStreamUpdate` event.
  final String? streamId;
  final Object? stream;
  final bool isMuted;
  final bool isCameraOff;
  final bool isLocal;

  String get initials {
    final name = userName ?? userId;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  ZegoParticipant copyWith({
    String? userId,
    String? userName,
    String? streamId,
    Object? stream,
    bool? isMuted,
    bool? isCameraOff,
    bool? isLocal,
  }) {
    return ZegoParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      streamId: streamId ?? this.streamId,
      stream: stream ?? this.stream,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoParticipant &&
        other.userId == userId &&
        other.userName == userName &&
        other.streamId == streamId &&
        other.isMuted == isMuted &&
        other.isCameraOff == isCameraOff &&
        other.isLocal == isLocal;
  }

  @override
  int get hashCode =>
      Object.hash(userId, userName, streamId, isMuted, isCameraOff, isLocal);

  @override
  String toString() => 'ZegoParticipant(userId: $userId, userName: $userName, '
      'streamId: $streamId, isMuted: $isMuted, isCameraOff: $isCameraOff, '
      'isLocal: $isLocal)';
}
