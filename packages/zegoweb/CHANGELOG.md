## 0.0.1

- Initial release.
- Dart wrapper for `zego-express-engine-webrtc` JS SDK via `dart:js_interop`.
- Engine lifecycle: create, login room, publish/play streams, destroy.
- Token management with auto-refresh on `tokenWillExpire`.
- Local and remote stream handling with platform view video registry.
- Device enumeration and switching (cameras, microphones).
- Audio processing config (AEC, ANS, AGC) with live constraint updates.
- Remote camera/mic status events.
- Sound level updates and Web Audio API mic level monitor.
- Secure context (HTTPS) enforcement.
- Dynamic SDK loading from CDN or manual `<script>` tag.
