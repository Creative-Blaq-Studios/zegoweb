// packages/zegoweb/lib/src/models/zego_enums.dart

/// Dart-side log levels for `ZegoWeb.setLogLevel`. Also forwarded to the JS
/// SDK's `setLogConfig` so Dart and JS console output stay consistent.
enum ZegoLogLevel { verbose, info, warn, error, off }

/// Room scenario hint passed to the underlying JS SDK when the engine is
/// created. Mirrors the scenario enum from `zego-express-engine-webrtc`.
enum ZegoScenario { general, communication, live }

/// Delta type for user / stream room updates.
enum ZegoUpdateType { add, delete }

/// Connection state of the currently-joined room.
enum ZegoRoomState { disconnected, connecting, connected }

/// Result of a pre-flight permission check via `navigator.permissions.query`.
///
/// `unavailable` means the browser does not expose the Permissions API for
/// camera/microphone (e.g. Safari). Callers should treat `unavailable` like
/// `prompt` and proceed to `getUserMedia`.
enum ZegoPermissionStatus { granted, denied, prompt, unavailable }

/// Sub-classification for `ZegoPermissionException`. Lets callers distinguish
/// a user-denied prompt from a missing device from a device held by another
/// application from an insecure (non-HTTPS) context.
enum PermissionErrorKind { denied, notFound, inUse, insecureContext }
