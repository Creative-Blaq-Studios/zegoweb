// packages/zegoweb/lib/src/zego_web.dart
import 'package:web/web.dart' as web;

import 'interop/event_bridge.dart';
import 'interop/log_bridge.dart';
import 'interop/zego_js.dart';
import 'log.dart';
import 'models/zego_config.dart';
import 'models/zego_enums.dart';
import 'models/zego_error.dart';
import 'sdk_loader.dart';
import 'token_manager.dart';
import 'zego_engine.dart';

/// Static entry point for the zegoweb plugin.
///
/// Load the SDK (manually or via [loadScript]), then call [createEngine] to
/// obtain a configured [ZegoEngine]. All methods are safe to call multiple
/// times; loading is idempotent.
abstract final class ZegoWeb {
  /// Dynamically inject the ZEGO Express Web SDK script tag.
  ///
  /// Optional — if your `web/index.html` already contains a matching
  /// `<script>` tag this call is a no-op. The call is idempotent.
  static Future<void> loadScript({String? version}) {
    return SdkLoader.loadScript(version: version);
  }

  /// Set the Dart-side log level. Also forwards to any future engine via
  /// `configureJsLogging` when an engine is constructed. For already-live
  /// engines the caller should rebuild the engine to propagate the change.
  static void setLogLevel(ZegoLogLevel level) {
    ZegoLog.level = level;
  }

  /// Create and return a configured [ZegoEngine].
  ///
  /// Throws:
  /// - [ZegoError] if `window.isSecureContext` is false.
  /// - [ZegoStateError] if the SDK has not been loaded by either mechanism
  ///   (manual `<script>` tag or [loadScript]).
  static Future<ZegoEngine> createEngine(ZegoEngineConfig config) async {
    if (!web.window.isSecureContext) {
      throw const ZegoError(
        -1,
        'zegoweb requires a secure context. Serve your app over HTTPS or '
        'use localhost during development.',
      );
    }

    // `ZegoEngineConfig` validates appId + server in its constructor, so
    // no extra check is needed here.

    // Wait for the SDK to be ready. If neither loadScript was called nor a
    // manual <script> tag exists this completes quickly — we then check and
    // throw.
    try {
      await SdkLoader.ready;
    } on ZegoStateError {
      rethrow;
    }

    if (!isZegoJsLoaded) {
      throw const ZegoStateError(
        -1,
        'ZegoExpressEngine global not found. '
        'Call ZegoWeb.loadScript() before createEngine, or add a '
        '<script src="https://unpkg.com/zego-express-engine-webrtc/index.js"></script> '
        'tag to web/index.html.',
      );
    }

    final jsEngine = ZegoExpressEngineJs(config.appId, config.server);

    // Forward the Dart log level and the scenario to the JS engine.
    try {
      configureJsLogging(jsEngine, ZegoLog.level);
    } catch (e) {
      ZegoLog.warn('configureJsLogging failed: $e');
    }
    try {
      jsEngine.setRoomScenario(_scenarioToInt(config.scenario));
    } catch (e) {
      ZegoLog.warn('setRoomScenario failed: $e');
    }

    ZegoLog.info(
      'createEngine appId=${config.appId} server=${config.server} '
      'scenario=${config.scenario.name}',
    );

    final bridge = EventBridge(jsEngine);
    final tokenManager = TokenManager(tokenProvider: config.tokenProvider);

    return ZegoEngine.internal(
      js: jsEngine,
      eventBridge: bridge,
      tokenManager: tokenManager,
    );
  }

  /// Map the Dart enum to the integer scenario the JS SDK expects.
  ///
  /// Values match the `zego-express-engine-webrtc` 3.x scenario constants:
  ///   0 = General, 1 = Communication, 2 = LiveBroadcast (a.k.a. Live).
  static int _scenarioToInt(ZegoScenario scenario) {
    switch (scenario) {
      case ZegoScenario.general:
        return 0;
      case ZegoScenario.communication:
        return 1;
      case ZegoScenario.live:
        return 2;
    }
  }
}
