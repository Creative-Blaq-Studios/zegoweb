// packages/zegoweb_prebuilt/lib/src/zego_prebuilt.dart

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
// ignore: uri_does_not_exist
import 'dart:ui_web' as ui_web;

import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

import 'interop/config_builder.dart';
import 'interop/prebuilt_js.dart';
import 'sdk_loader.dart';
import 'zego_prebuilt_config.dart';
import 'zego_prebuilt_error.dart';
import 'zego_prebuilt_user.dart';

/// Entry class for the prebuilt UIKit.
///
/// Obtain an instance via [create], configure with [joinRoom], render with
/// `ZegoPrebuiltView`, tear down with [destroy].
class ZegoPrebuilt {
  ZegoPrebuilt._(this._jsInstance);

  final JSObject _jsInstance;

  // ---------------------------------------------------------------------------
  // Instance state
  // ---------------------------------------------------------------------------

  bool _joined = false;
  bool _destroyed = false;
  String? _roomId;
  String? _viewType;
  web.HTMLDivElement? _container;

  // Event stream controllers
  final StreamController<void> _onJoinRoom = StreamController<void>.broadcast();
  final StreamController<void> _onLeaveRoom =
      StreamController<void>.broadcast();
  final StreamController<List<ZegoPrebuiltUser>> _onUserJoin =
      StreamController<List<ZegoPrebuiltUser>>.broadcast();
  final StreamController<List<ZegoPrebuiltUser>> _onUserLeave =
      StreamController<List<ZegoPrebuiltUser>>.broadcast();
  final StreamController<void> _onYouRemovedFromRoom =
      StreamController<void>.broadcast();

  // ---------------------------------------------------------------------------
  // Static surface
  // ---------------------------------------------------------------------------

  /// Inject the prebuilt UIKit via a `<script>` tag. Idempotent. Optional if
  /// your `web/index.html` already has a matching `<script>` tag.
  static Future<void> loadScript({String? version}) =>
      SdkLoader.loadScript(version: version);

  /// Dev-only kit-token generator. Server secret is exposed to the browser.
  static String generateTestKitToken({
    required int appId,
    required String serverSecret,
    required String roomId,
    required String userId,
    String? userName,
  }) {
    return generateKitTokenForTest(
        appId, serverSecret, roomId, userId, userName ?? userId);
  }

  /// Production kit-token wrapper around a server-minted token04.
  static String generateProductionKitToken({
    required int appId,
    required String serverToken,
    required String roomId,
    required String userId,
    String? userName,
  }) {
    return generateKitTokenForProduction(
        appId, serverToken, roomId, userId, userName ?? userId);
  }

  /// Create a configured instance. Async.
  static Future<ZegoPrebuilt> create(String kitToken) async {
    if (kitToken.isEmpty) {
      throw ArgumentError.value(kitToken, 'kitToken', 'must not be empty');
    }

    // Wait for the SDK to be ready.
    try {
      await SdkLoader.readyWithTimeout(const Duration(seconds: 5));
    } on ZegoStateError {
      rethrow;
    }

    if (!isZegoPrebuiltJsLoaded) {
      throw const ZegoStateError(
        -1,
        'ZegoUIKitPrebuilt global not found. '
        'Call ZegoPrebuilt.loadScript() before create, or add a '
        '<script src="https://unpkg.com/@zegocloud/zego-uikit-prebuilt/zego-uikit-prebuilt.js"></script> '
        'tag to web/index.html.',
      );
    }

    // Call ZegoUIKitPrebuilt.create(kitToken) on the JS side.
    final createFn = (web.window as JSObject)['ZegoUIKitPrebuilt'] as JSObject;
    final jsResult =
        (createFn['create'] as JSFunction).callAsFunction(null, kitToken.toJS);

    // The result is either a JSPromise or a direct object depending on
    // UIKit version. We treat it as a direct JSObject since the fake and
    // current versions return synchronously.
    final jsInstance = jsResult! as JSObject;

    return ZegoPrebuilt._(jsInstance);
  }

  // ---------------------------------------------------------------------------
  // Instance surface
  // ---------------------------------------------------------------------------

  /// Mount the call into the internal container. Must be called exactly
  /// once per instance, before placing ZegoPrebuiltView in the tree.
  Future<void> joinRoom(ZegoPrebuiltConfig config) async {
    if (_destroyed) {
      throw const ZegoStateError(-1, 'Cannot joinRoom on a destroyed instance');
    }
    if (_joined) {
      throw const ZegoStateError(-1, 'joinRoom has already been called');
    }

    _roomId = config.roomId;

    // Create the container div
    _container = web.document.createElement('div') as web.HTMLDivElement
      ..style.width = '100%'
      ..style.height = '100%';

    // Register platform view factory
    _viewType = 'zego-prebuilt-${config.roomId}-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType!,
      (int viewId) => _container!,
    );

    // Build JS config with event wiring
    final streamControllers = <String, dynamic>{
      'onJoinRoom': _onJoinRoom,
      'onLeaveRoom': _onLeaveRoom,
      'onUserJoin': _onUserJoin,
      'onUserLeave': _onUserLeave,
      'onYouRemovedFromRoom': _onYouRemovedFromRoom,
    };

    final jsConfig = ConfigBuilder.build(config, streamControllers);
    // The UIKit's joinRoom(config) takes a single config object with
    // `container` as a key inside it.
    jsConfig['container'] = _container!;
    (_jsInstance['joinRoom'] as JSFunction)
        .callAsFunction(_jsInstance, jsConfig);

    _joined = true;
  }

  /// Hang up the current call (instance stays alive until destroy).
  void hangUp() {
    _checkAlive();
    (_jsInstance['hangUp'] as JSFunction).callAsFunction(_jsInstance);
  }

  /// Active room id, or null before joinRoom / after destroy.
  String? get roomId => _destroyed ? null : _roomId;

  /// Change the UIKit's display language at runtime.
  void setLanguage(ZegoPrebuiltLanguage language) {
    _checkAlive();
    final jsLang = switch (language) {
      ZegoPrebuiltLanguage.english => zegoLanguageEnglish,
      ZegoPrebuiltLanguage.chinese => zegoLanguageChinese,
    };
    (_jsInstance['setLanguage'] as JSFunction)
        .callAsFunction(_jsInstance, jsLang);
  }

  /// Tear down: stop the call, close streams, release JS instance. Idempotent.
  Future<void> destroy() async {
    if (_destroyed) return;
    _destroyed = true;

    try {
      final destroyFn = _jsInstance['destroy'];
      if (destroyFn != null) {
        (destroyFn as JSFunction).callAsFunction(_jsInstance);
      }
    } catch (_) {
      // Best-effort teardown; do not throw from destroy.
    }

    _onJoinRoom.close();
    _onLeaveRoom.close();
    _onUserJoin.close();
    _onUserLeave.close();
    _onYouRemovedFromRoom.close();
  }

  // ---------------------------------------------------------------------------
  // Events — broadcast streams
  // ---------------------------------------------------------------------------

  Stream<void> get onJoinRoom => _onJoinRoom.stream;
  Stream<void> get onLeaveRoom => _onLeaveRoom.stream;
  Stream<List<ZegoPrebuiltUser>> get onUserJoin => _onUserJoin.stream;
  Stream<List<ZegoPrebuiltUser>> get onUserLeave => _onUserLeave.stream;
  Stream<void> get onYouRemovedFromRoom => _onYouRemovedFromRoom.stream;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// The viewType string for HtmlElementView, or null before joinRoom.
  @internal
  String? get debugViewType => _viewType;

  /// The container div, or null before joinRoom.
  @internal
  web.HTMLDivElement? get debugContainer => _container;

  void _checkAlive() {
    if (_destroyed) {
      throw const ZegoStateError(-1, 'Instance has been destroyed');
    }
  }
}
