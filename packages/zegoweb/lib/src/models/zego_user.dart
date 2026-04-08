// packages/zegoweb/lib/src/models/zego_user.dart
import 'package:meta/meta.dart';

/// A user participating in a ZEGO room.
///
/// Immutable value type. Equality is structural over `userId` and `userName`.
@immutable
class ZegoUser {
  const ZegoUser({required this.userId, required this.userName});

  final String userId;
  final String userName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoUser &&
        other.userId == userId &&
        other.userName == userName;
  }

  @override
  int get hashCode => Object.hash(userId, userName);

  @override
  String toString() => 'ZegoUser(userId: $userId, userName: $userName)';
}
