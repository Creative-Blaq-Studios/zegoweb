// packages/zegoweb/lib/src/state_guard.dart
import 'package:meta/meta.dart';

import 'models/zego_error.dart';

/// Mixin providing lifecycle and ordering guards used by `ZegoEngine` and
/// friends.
///
/// Subclasses call [requireAlive] at the top of every public method and
/// [requireRoom] for methods that require an active room (e.g. publishing,
/// playing). Both guards throw [ZegoStateError] synchronously with an
/// explanatory message when violated, replacing opaque JS SDK errors with
/// actionable Dart ones.
mixin StateGuard {
  bool _disposed = false;
  String? _currentRoomId;

  /// The room id passed to the most recent successful `loginRoom`, or `null`
  /// if not currently in a room.
  @protected
  String? get currentRoomId => _currentRoomId;

  /// Whether [markDisposed] has been called.
  @protected
  bool get isDisposed => _disposed;

  /// Record that we have joined [roomId]. Called from the engine after a
  /// successful `loginRoom`.
  @protected
  void setCurrentRoom(String roomId) {
    _currentRoomId = roomId;
  }

  /// Forget the current room. Called from the engine after `logoutRoom`.
  @protected
  void clearCurrentRoom() {
    _currentRoomId = null;
  }

  /// Flip the disposed flag. Idempotent. After this, [requireAlive] and
  /// [requireRoom] always throw.
  @protected
  void markDisposed() {
    _disposed = true;
    _currentRoomId = null;
  }

  /// Throws [ZegoStateError] if the owning object has been disposed.
  @protected
  void requireAlive() {
    if (_disposed) {
      throw const ZegoStateError(
        -1,
        'engine has been disposed; create a new engine via '
        'ZegoWeb.createEngine before making further calls',
      );
    }
  }

  /// Throws [ZegoStateError] if either (a) the owning object has been
  /// disposed, or (b) no room is currently joined. The disposed check runs
  /// first so a disposed engine always reports "disposed" rather than
  /// "no room".
  @protected
  void requireRoom() {
    requireAlive();
    if (_currentRoomId == null) {
      throw const ZegoStateError(
        -2,
        'no active room; call loginRoom before this operation',
      );
    }
  }
}
