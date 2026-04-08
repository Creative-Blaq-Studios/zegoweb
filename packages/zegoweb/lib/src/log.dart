// packages/zegoweb/lib/src/log.dart
import 'dart:developer' as developer;

import 'package:meta/meta.dart';

import 'models/zego_enums.dart';

/// Signature for an injectable log sink, used in tests to capture output
/// without depending on `dart:developer`.
typedef ZegoLogSink = void Function(
  ZegoLogLevel level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// Dart-side logging for `zegoweb`. Filters by [level] and routes through
/// `developer.log` with `name: 'zegoweb'`.
///
/// The JS SDK has its own logging; `ZegoWeb.setLogLevel` updates
/// [ZegoLog.level] and the engine constructor also forwards to the JS SDK's
/// `setLogConfig` (see `interop/log_bridge.dart`) so the two stay consistent.
abstract final class ZegoLog {
  /// Current minimum level. Messages below this level are dropped.
  /// Defaults to [ZegoLogLevel.warn].
  static ZegoLogLevel level = ZegoLogLevel.warn;

  /// Optional override for the sink. Tests set this to capture output;
  /// production code leaves it null and messages go to `developer.log`.
  @visibleForTesting
  static ZegoLogSink? testSink;

  static const String _name = 'zegoweb';

  static void verbose(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _emit(ZegoLogLevel.verbose, message, error, stackTrace);
  }

  static void info(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _emit(ZegoLogLevel.info, message, error, stackTrace);
  }

  static void warn(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _emit(ZegoLogLevel.warn, message, error, stackTrace);
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _emit(ZegoLogLevel.error, message, error, stackTrace);
  }

  static void _emit(
    ZegoLogLevel msgLevel,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!_shouldEmit(msgLevel)) return;
    final sink = testSink;
    if (sink != null) {
      sink(msgLevel, message, error: error, stackTrace: stackTrace);
      return;
    }
    developer.log(
      message,
      name: _name,
      level: _developerLevel(msgLevel),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static bool _shouldEmit(ZegoLogLevel msgLevel) {
    // Ordering: verbose < info < warn < error < off. `off` drops all.
    if (level == ZegoLogLevel.off) return false;
    return msgLevel.index >= level.index;
  }

  /// Map our enum to the numeric scale expected by `dart:developer`.
  /// Values roughly track `java.util.logging.Level`.
  static int _developerLevel(ZegoLogLevel msgLevel) {
    switch (msgLevel) {
      case ZegoLogLevel.verbose:
        return 500; // FINE
      case ZegoLogLevel.info:
        return 800; // INFO
      case ZegoLogLevel.warn:
        return 900; // WARNING
      case ZegoLogLevel.error:
        return 1000; // SEVERE
      case ZegoLogLevel.off:
        return 2000; // OFF
    }
  }
}
