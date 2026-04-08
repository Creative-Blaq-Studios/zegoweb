// packages/zegoweb/lib/src/token_manager.dart
import 'dart:async';

import 'package:meta/meta.dart';

import 'log.dart';
import 'models/zego_error.dart';
import 'models/zego_events.dart';
import 'token_bridge.dart';

/// Minimal clock abstraction so tests can inject a deterministic time
/// source without pulling in `package:clock`.
abstract class TokenClock {
  DateTime now();
  const TokenClock();
  factory TokenClock.system() = _SystemClock;
}

class _SystemClock extends TokenClock {
  const _SystemClock();
  @override
  DateTime now() => DateTime.now();
}

typedef TokenProvider = Future<String> Function();
typedef RenewFn = Future<void> Function(String roomId, String token);

/// Holds the token provider and auto-refreshes tokens when the JS SDK
/// signals `tokenWillExpire`.
class TokenManager {
  TokenManager({
    required TokenProvider tokenProvider,
    TokenClock? clock,
  })  : _provider = tokenProvider,
        _clock = clock ?? const _SystemClock();

  final TokenProvider _provider;
  // ignore: unused_field
  final TokenClock _clock;

  StreamSubscription<ZegoTokenWillExpire>? _sub;
  bool _disposed = false;

  /// Fetch the initial token by invoking the provider once.
  Future<String> initialToken() async {
    try {
      return await _provider();
    } catch (e, st) {
      ZegoLog.warn('TokenManager.initialToken provider failed: $e');
      throw ZegoAuthException(
        -1,
        'tokenProvider failed during initial login: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Subscribe to `tokenWillExpire` from [bridge]. On event, call
  /// [_provider] and then [renewFn]; on any failure, emit a
  /// [ZegoAuthException] on [errorSink].
  void wireRefresh(
    TokenBridge bridge,
    RenewFn renewFn,
    StreamController<ZegoError> errorSink,
  ) {
    if (_disposed) return;
    _sub?.cancel();
    _sub = bridge.onTokenWillExpire.listen((event) {
      if (_disposed) return;
      unawaited(_handleExpire(event, renewFn, errorSink));
    });
  }

  Future<void> _handleExpire(
    ZegoTokenWillExpire event,
    RenewFn renewFn,
    StreamController<ZegoError> errorSink,
  ) async {
    final roomId = event.roomId;
    ZegoLog.info(
      'TokenManager: tokenWillExpire for room=$roomId; refreshing',
    );
    String token;
    try {
      token = await _provider();
    } catch (e, st) {
      ZegoLog.warn('TokenManager: provider failed during refresh: $e');
      if (!errorSink.isClosed) {
        errorSink.add(ZegoAuthException(
          -1,
          'tokenProvider failed during refresh: $e',
          cause: e,
          stackTrace: st,
        ));
      }
      return;
    }
    try {
      await renewFn(roomId, token);
    } catch (e, st) {
      ZegoLog.warn('TokenManager: renewToken failed: $e');
      if (!errorSink.isClosed) {
        errorSink.add(ZegoAuthException(
          -1,
          'renewToken failed: $e',
          cause: e,
          stackTrace: st,
        ));
      }
    }
  }

  /// Cancel the refresh subscription. Idempotent.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _sub?.cancel();
    _sub = null;
  }

  @visibleForTesting
  bool get isDisposed => _disposed;
}
