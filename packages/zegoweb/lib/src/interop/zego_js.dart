// packages/zegoweb/lib/src/interop/zego_js.dart
//
// @JS externs for the zego-express-engine-webrtc JavaScript SDK.
//
// Targets zego-express-engine-webrtc ^3.6.0.
//
// SCOPE: only the methods and event names consumed by the public Dart API
// in lib/zegoweb.dart. Every new public method must add a matching extern
// here first. Do not expose JS types outside lib/src/interop/.
//
// This file is internal — NOT exported from lib/zegoweb.dart.

@JS()
library zego_js;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

// ---------------------------------------------------------------------------
// Global constructor lookup
// ---------------------------------------------------------------------------

/// `window.ZegoExpressEngine` — the constructor. Present iff the JS SDK has
/// been loaded (via a manual <script> or SdkLoader.loadScript).
@JS('ZegoExpressEngine')
external JSFunction? get zegoExpressEngineCtor;

/// True when `window.ZegoExpressEngine` is defined.
bool get isZegoJsLoaded {
  final v = (web.window as JSObject)['ZegoExpressEngine'];
  return v != null;
}

// ---------------------------------------------------------------------------
// ZegoExpressEngine instance
// ---------------------------------------------------------------------------

/// The JS `ZegoExpressEngine` instance produced by `new ZegoExpressEngine(...)`.
///
/// All async methods return `JSPromise`; callers MUST route through
/// `promise_adapter.dart` so JS errors become typed `ZegoError`s.
extension type ZegoExpressEngineJs._(JSObject _) implements JSObject {
  external factory ZegoExpressEngineJs(int appID, String server);

  // -- Room lifecycle -------------------------------------------------------

  /// `loginRoom(roomId, token, user, config?)` — resolves on success.
  external JSPromise<JSAny?> loginRoom(
    String roomId,
    String token,
    ZegoUserJs user, [
    JSObject? config,
  ]);

  /// `logoutRoom(roomId?)` — resolves on success.
  external JSPromise<JSAny?> logoutRoom([String? roomId]);

  // -- Local stream ---------------------------------------------------------

  /// `createStream(config?)` → Promise<MediaStream-like object>.
  /// The resolved value is a JS object with a `.streamID` property.
  external JSPromise<JSAny?> createStream([JSObject? config]);

  external JSPromise<JSAny?> startPublishingStream(
    String streamId,
    JSObject mediaStream, [
    JSObject? config,
  ]);

  external JSPromise<JSAny?> stopPublishingStream(String streamId);

  // -- Remote playback ------------------------------------------------------

  /// `startPlayingStream(streamId, config?)` → Promise<MediaStream-like object>.
  external JSPromise<JSAny?> startPlayingStream(
    String streamId, [
    JSObject? config,
  ]);

  external JSPromise<JSAny?> stopPlayingStream(String streamId);

  // -- Device enumeration ---------------------------------------------------

  /// Resolves with `JSArray<ZegoDeviceInfoJs>`.
  external JSPromise<JSArray<JSObject>> getCameras();

  /// Resolves with `JSArray<ZegoDeviceInfoJs>`.
  external JSPromise<JSArray<JSObject>> getMicrophones();

  external JSPromise<JSAny?> useVideoDevice(
    JSObject mediaStream,
    String deviceId,
  );
  external JSPromise<JSAny?> useAudioDevice(
    JSObject mediaStream,
    String deviceId,
  );

  // -- Device toggles -------------------------------------------------------

  external JSPromise<JSAny?> mutePublishStreamAudio(
    JSObject mediaStream,
    bool mute,
  );
  external JSPromise<JSAny?> mutePublishStreamVideo(
    JSObject mediaStream,
    bool mute,
  );

  /// Enable or disable the video capture device on the given local stream.
  /// Mirrors `enableVideoCaptureDevice(mediaStream, enable)` in Express 3.x.
  external JSPromise<JSAny?> enableVideoCaptureDevice(
    JSObject mediaStream,
    bool enable,
  );

  // -- Scenario -------------------------------------------------------------

  /// `setRoomScenario(scenario)` — forwards the Dart-side enum (mapped to the
  /// SDK's integer scenario) to the JS engine. Called from `ZegoWeb.createEngine`.
  external void setRoomScenario(int scenario);

  // -- Token refresh --------------------------------------------------------

  /// `renewToken(token, [roomID])`. The `roomID` overload is used from
  /// `ZegoEngine` when a room is active.
  external JSPromise<JSAny?> renewToken(String token, [String? roomID]);

  // -- Engine teardown ------------------------------------------------------

  /// Static on the JS side: `ZegoExpressEngine.destroyEngine(instance)`.
  /// Exposed here as an instance helper for callers that already hold the
  /// instance.
  external JSPromise<JSAny?> destroyEngine();

  // -- Logging --------------------------------------------------------------

  /// `setLogConfig({ logLevel, remoteLogLevel })` — synchronous.
  external void setLogConfig(JSObject config);

  // -- Event listener registration ------------------------------------------

  /// `on(eventName, callback)` — attach. The callback receives event-specific
  /// positional arguments; we normalize to a single `JSAny?` via the bridge.
  external void on(String eventName, JSFunction callback);

  /// `off(eventName, callback)` — detach. Must pass the same callback
  /// reference that was registered, so event_bridge tracks them.
  external void off(String eventName, JSFunction callback);
}

// ---------------------------------------------------------------------------
// Value types passed to / returned from the JS SDK
// ---------------------------------------------------------------------------

/// User dict consumed by `loginRoom(user, ...)`. JS shape: `{ userID, userName }`.
extension type ZegoUserJs._(JSObject _) implements JSObject {
  external factory ZegoUserJs({required String userID, required String userName});
  external String get userID;
  external String get userName;
}

/// Device info returned by `getCameras` / `getMicrophones`.
/// JS shape: `{ deviceID, deviceName }`.
extension type ZegoDeviceInfoJs._(JSObject _) implements JSObject {
  external String get deviceID;
  external String get deviceName;
}

/// Log config object for `setLogConfig`.
extension type ZegoLogConfigJs._(JSObject _) implements JSObject {
  external factory ZegoLogConfigJs({
    required String logLevel,
    required String remoteLogLevel,
  });
}

// ---------------------------------------------------------------------------
// Canonical event name strings
// ---------------------------------------------------------------------------
//
// Kept as constants (not a Dart enum) because they are passed verbatim to
// `engine.on(...)`.

abstract final class ZegoJsEvents {
  static const roomStateChanged = 'roomStateUpdate';
  static const roomUserUpdate = 'roomUserUpdate';
  static const roomStreamUpdate = 'roomStreamUpdate';
  static const publisherStateUpdate = 'publisherStateUpdate';
  static const playerStateUpdate = 'playerStateUpdate';
  static const tokenWillExpire = 'tokenWillExpire';
  static const publishQualityUpdate = 'publishQualityUpdate';
  static const playQualityUpdate = 'playQualityUpdate';
}
