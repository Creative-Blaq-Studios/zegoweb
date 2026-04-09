// packages/zegoweb/lib/src/zego_remote_stream.dart
import 'dart:js_interop';

import 'package:meta/meta.dart';

/// A handle to a remote media stream being played back from the SDK.
///
/// Construction is library-private; obtain instances via
/// [ZegoEngine.startPlaying].
class ZegoRemoteStream {
  ZegoRemoteStream._(this._id, this._jsStream);

  final String _id;
  final JSObject _jsStream;

  /// Unique identifier for this remote stream.
  String get id => _id;

  /// Underlying JS `MediaStream`. Internal only.
  @internal
  JSObject get jsStream => _jsStream;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ZegoRemoteStream && other._id == _id);

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => 'ZegoRemoteStream(id: $_id)';
}

@internal
class ZegoRemoteStreamTestAccess {
  static ZegoRemoteStream create(String id, JSObject jsStream) =>
      ZegoRemoteStream._(id, jsStream);
}

@internal
ZegoRemoteStream zegoRemoteStreamInternal(String id, JSObject jsStream) =>
    ZegoRemoteStream._(id, jsStream);
