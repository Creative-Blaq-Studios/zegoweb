// packages/zegoweb_prebuilt/lib/src/interop/prebuilt_js.dart
//
// @JS externs for @zegocloud/zego-uikit-prebuilt JavaScript UIKit.
//
// Verified against @zegocloud/zego-uikit-prebuilt@2.17.3.
//
// SCOPE: only the methods and event names consumed by the public Dart API.
// This file is internal — NOT exported from lib/zegoweb_prebuilt.dart.

@JS()
library;

import 'dart:js_interop';

// ---------------------------------------------------------------------------
// Global constructor lookup
// ---------------------------------------------------------------------------

/// `window.ZegoUIKitPrebuilt` — the main class. Present iff the JS UIKit has
/// been loaded (via manual <script> or SdkLoader.loadScript).
@JS('ZegoUIKitPrebuilt')
external JSFunction? get zegoUIKitPrebuiltCtor;

/// True when `window.ZegoUIKitPrebuilt` is defined.
bool get isZegoPrebuiltJsLoaded => zegoUIKitPrebuiltCtor != null;

// ---------------------------------------------------------------------------
// Static methods on ZegoUIKitPrebuilt
// ---------------------------------------------------------------------------

/// `ZegoUIKitPrebuilt.generateKitTokenForTest(appID, serverSecret, roomID, userID, userName?)`
/// Returns a kit token string for development use.
@JS('ZegoUIKitPrebuilt.generateKitTokenForTest')
external String generateKitTokenForTest(
  int appID,
  String serverSecret,
  String roomID,
  String userID, [
  String? userName,
]);

/// `ZegoUIKitPrebuilt.generateKitTokenForProduction(appID, serverToken, roomID, userID, userName?)`
/// Returns a kit token for production use (wraps a server-minted token04).
@JS('ZegoUIKitPrebuilt.generateKitTokenForProduction')
external String generateKitTokenForProduction(
  int appID,
  String serverToken,
  String roomID,
  String userID, [
  String? userName,
]);

/// `ZegoUIKitPrebuilt.create(kitToken)` — creates a new instance.
@JS('ZegoUIKitPrebuilt.create')
external JSPromise<ZegoUIKitPrebuiltJs> zegoPrebuiltCreate(String kitToken);

// ---------------------------------------------------------------------------
// Instance
// ---------------------------------------------------------------------------

/// The JS `ZegoUIKitPrebuilt` instance returned by `.create(kitToken)`.
extension type ZegoUIKitPrebuiltJs._(JSObject _) implements JSObject {
  /// `joinRoom(container, config)` — mounts the call UI.
  external void joinRoom(JSObject container, JSObject config);

  /// `hangUp()` — hang up the current call.
  external void hangUp();

  /// `setLanguage(language)` — change the UIKit's display language at runtime.
  external void setLanguage(JSObject language);

  /// `destroy()` — tear down the instance.
  external JSPromise<JSAny?> destroy();
}

// ---------------------------------------------------------------------------
// ZegoUIKitPrebuilt language constants
// ---------------------------------------------------------------------------

/// `ZegoUIKitPrebuilt.LANGUAGE_ENGLISH`
@JS('ZegoUIKitPrebuilt.LANGUAGE_ENGLISH')
external JSObject get zegoLanguageEnglish;

/// `ZegoUIKitPrebuilt.LANGUAGE_CHS`
@JS('ZegoUIKitPrebuilt.LANGUAGE_CHS')
external JSObject get zegoLanguageChinese;
