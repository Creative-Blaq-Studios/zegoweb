// packages/zegoweb/lib/src/models/zego_config.dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';

import 'zego_enums.dart';

/// Configuration for a `ZegoEngine` instance.
///
/// Validates `appId > 0` and `server` starting with `wss://` in its
/// constructor so bogus config is caught synchronously at creation time rather
/// than surfacing as an opaque JS SDK error on first call.
@immutable
class ZegoEngineConfig {
  ZegoEngineConfig({
    required this.appId,
    required this.server,
    required this.scenario,
    required this.tokenProvider,
  }) {
    if (appId <= 0) {
      throw ArgumentError.value(
        appId,
        'appId',
        'must be greater than 0',
      );
    }
    if (!server.startsWith('wss://')) {
      throw ArgumentError.value(
        server,
        'server',
        'must start with "wss://"',
      );
    }
  }

  /// ZEGO application id issued by the ZEGO console.
  final int appId;

  /// Signalling server URL. Must start with `wss://`.
  final String server;

  /// Room scenario hint.
  final ZegoScenario scenario;

  /// Async supplier of login tokens. Called on initial login and again when
  /// the JS SDK fires `tokenWillExpire`.
  final Future<String> Function() tokenProvider;
}

/// Configuration for a local capture stream.
///
/// Reserved fields (`videoWidth`, `videoHeight`, `videoFps`, `videoBitrate`)
/// are optional; if null the JS SDK picks defaults. Additional fields are
/// added non-breakingly in later versions.
@immutable
class ZegoStreamConfig {
  const ZegoStreamConfig({
    this.camera = true,
    this.microphone = true,
    this.videoWidth,
    this.videoHeight,
    this.videoFps,
    this.videoBitrate,
    this.audioBitrate,
    this.noiseSuppression,
    this.autoGainControl,
    this.echoCancellation,
  });

  final bool camera;
  final bool microphone;
  final int? videoWidth;
  final int? videoHeight;
  final int? videoFps;
  final int? videoBitrate;

  /// Audio bitrate in kbps. ZEGO default is 48; use 64–128 for better quality.
  final int? audioBitrate;

  /// Acoustic Noise Suppression (SDK key: `ANS`). Defaults to true in the SDK.
  /// Set to false if voices sound distant or over-processed.
  final bool? noiseSuppression;

  /// Auto Gain Control (SDK key: `AGC`). Defaults to true in the SDK.
  final bool? autoGainControl;

  /// Acoustic Echo Cancellation (SDK key: `AEC`). Defaults to true in the SDK.
  /// Only disable if all participants use headphones.
  final bool? echoCancellation;

  /// Convert to the JS config object expected by
  /// `ZegoExpressEngineJs.createStream`. Null fields are omitted so the JS
  /// SDK falls back to its own defaults.
  JSObject toJs() {
    final cfg = JSObject();
    cfg['camera'] = camera.toJS;
    cfg['microphone'] = microphone.toJS;
    if (videoWidth != null) cfg['videoWidth'] = videoWidth!.toJS;
    if (videoHeight != null) cfg['videoHeight'] = videoHeight!.toJS;
    if (videoFps != null) cfg['videoFps'] = videoFps!.toJS;
    if (videoBitrate != null) cfg['videoBitrate'] = videoBitrate!.toJS;
    if (audioBitrate != null) cfg['audioBitrate'] = audioBitrate!.toJS;
    if (noiseSuppression != null) cfg['ANS'] = noiseSuppression!.toJS;
    if (autoGainControl != null) cfg['AGC'] = autoGainControl!.toJS;
    if (echoCancellation != null) cfg['AEC'] = echoCancellation!.toJS;
    return cfg;
  }
}
