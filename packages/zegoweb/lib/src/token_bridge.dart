// packages/zegoweb/lib/src/token_bridge.dart
//
// Minimal interface decoupling TokenManager from EventBridge. EventBridge
// implements it by exposing its typed `onTokenWillExpire` getter; TokenManager
// consumes it via `wireRefresh(bridge, ...)`.
//
// Kept in its own file so neither side has to depend on the other's full
// implementation — TokenManager lives in token_manager.dart (Task 23) and
// EventBridge lives in interop/event_bridge.dart (Task 17).

import 'models/zego_events.dart';

/// Narrow surface the [TokenManager] needs from an event source.
abstract class TokenBridge {
  /// Typed stream of `tokenWillExpire` events.
  Stream<ZegoTokenWillExpire> get onTokenWillExpire;
}
