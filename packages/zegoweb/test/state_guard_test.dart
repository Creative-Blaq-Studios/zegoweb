// packages/zegoweb/test/state_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_error.dart';
import 'package:zegoweb/src/state_guard.dart';

/// Minimal concrete subclass exposing StateGuard so we can drive it in tests.
class _Guarded with StateGuard {
  void callAlive() => requireAlive();
  String? callRoom() {
    requireRoom();
    return currentRoomId;
  }

  void enter(String roomId) => setCurrentRoom(roomId);
  void leave() => clearCurrentRoom();
  void kill() => markDisposed();

  bool get disposedExposed => isDisposed;
}

void main() {
  group('StateGuard.requireAlive', () {
    test('does not throw when alive', () {
      final g = _Guarded();
      expect(g.callAlive, returnsNormally);
    });

    test('throws ZegoStateError after markDisposed', () {
      final g = _Guarded()..kill();
      expect(
        g.callAlive,
        throwsA(
          isA<ZegoStateError>().having(
            (e) => e.message,
            'message',
            contains('disposed'),
          ),
        ),
      );
    });

    test('is idempotent: double kill does not change error', () {
      final g = _Guarded()
        ..kill()
        ..kill();
      expect(g.disposedExposed, isTrue);
      expect(g.callAlive, throwsA(isA<ZegoStateError>()));
    });
  });

  group('StateGuard.requireRoom', () {
    test('throws ZegoStateError with actionable message when no room', () {
      final g = _Guarded();
      expect(
        g.callRoom,
        throwsA(
          isA<ZegoStateError>().having(
            (e) => e.message,
            'message',
            contains('loginRoom'),
          ),
        ),
      );
    });

    test('returns the current room id after setCurrentRoom', () {
      final g = _Guarded()..enter('room-1');
      expect(g.callRoom(), 'room-1');
    });

    test('throws again after clearCurrentRoom', () {
      final g = _Guarded()
        ..enter('room-1')
        ..leave();
      expect(g.callRoom, throwsA(isA<ZegoStateError>()));
    });

    test('requireRoom throws disposed error first if both are wrong', () {
      final g = _Guarded()..kill();
      expect(
        g.callRoom,
        throwsA(
          isA<ZegoStateError>().having(
            (e) => e.message,
            'message',
            contains('disposed'),
          ),
        ),
      );
    });
  });
}
