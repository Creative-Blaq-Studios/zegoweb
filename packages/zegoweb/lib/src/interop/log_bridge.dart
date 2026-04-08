// packages/zegoweb/lib/src/interop/log_bridge.dart
//
// Thin bridge between `ZegoLog.setLevel` (Dart-side) and the JS SDK's
// `setLogConfig({ logLevel, remoteLogLevel })`. Lives under interop/ so the
// public `lib/src/log.dart` does not depend on `dart:js_interop`.
//
// Called by ZegoWeb.createEngine after the JS engine is constructed so the
// JS SDK's console output matches the Dart-side level.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../models/zego_enums.dart';

/// Push [level] into the JS SDK's logging configuration on [engine].
///
/// `remoteLogLevel` is always set to `'disable'` — we do not want the SDK
/// phoning home with logs from community users of this plugin.
void configureJsLogging(JSObject engine, ZegoLogLevel level) {
  final cfg = JSObject();
  cfg['logLevel'] = _mapLevel(level).toJS;
  cfg['remoteLogLevel'] = 'disable'.toJS;

  final setLogConfig = engine['setLogConfig'] as JSFunction;
  setLogConfig.callAsFunction(engine, cfg);
}

String _mapLevel(ZegoLogLevel level) {
  switch (level) {
    case ZegoLogLevel.verbose:
      return 'debug';
    case ZegoLogLevel.info:
      return 'info';
    case ZegoLogLevel.warn:
      return 'warn';
    case ZegoLogLevel.error:
      return 'error';
    case ZegoLogLevel.off:
      return 'disable';
  }
}
