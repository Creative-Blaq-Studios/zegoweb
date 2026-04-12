import 'package:meta/meta.dart';

/// A user participating in a prebuilt UIKit call.
///
/// Immutable value type. Equality is structural over `userId` and `userName`.
@immutable
class ZegoPrebuiltUser {
  const ZegoPrebuiltUser({required this.userId, this.userName});

  final String userId;
  final String? userName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZegoPrebuiltUser &&
        other.userId == userId &&
        other.userName == userName;
  }

  @override
  int get hashCode => Object.hash(userId, userName);

  @override
  String toString() => 'ZegoPrebuiltUser(userId: $userId, userName: $userName)';
}
