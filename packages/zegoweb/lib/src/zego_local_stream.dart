// packages/zegoweb/lib/src/zego_local_stream.dart
import 'dart:js_interop';

import 'package:meta/meta.dart';

/// A handle to a locally captured media stream (camera/mic).
///
/// Construction is library-private; obtain instances via
/// [ZegoEngine.createLocalStream].
class ZegoLocalStream {
  ZegoLocalStream._(this._id, this._jsStream);

  final String _id;
  final JSObject _jsStream;

  /// Unique identifier for this local stream.
  String get id => _id;

  /// Underlying JS `MediaStream`. Internal only.
  @internal
  JSObject get jsStream => _jsStream;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZegoLocalStream && other._id == _id);

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => 'ZegoLocalStream(id: $_id)';
}

/// Library-private constructor access for tests and engine internals.
@internal
class ZegoLocalStreamTestAccess {
  static ZegoLocalStream create(String id, JSObject jsStream) =>
      ZegoLocalStream._(id, jsStream);
}

/// Library-private constructor access for [ZegoEngine] and
/// [VideoViewRegistry] within this package.
@internal
ZegoLocalStream zegoLocalStreamInternal(String id, JSObject jsStream) =>
    ZegoLocalStream._(id, jsStream);
