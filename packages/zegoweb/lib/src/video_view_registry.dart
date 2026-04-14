// packages/zegoweb/lib/src/video_view_registry.dart
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

import 'log.dart';
import 'zego_local_stream.dart';
import 'zego_remote_stream.dart';

/// Maps a `ZegoLocalStream`/`ZegoRemoteStream` handle to a Flutter
/// `HtmlElementView` viewType.
///
/// `registerStream` eagerly creates the underlying `<video>` element so
/// callers can read it via [elementFor] (e.g. to apply mirror or BoxFit
/// styles) without waiting for Flutter to mount the platform view. The
/// registered factory simply returns the same element when invoked.
class VideoViewRegistry {
  VideoViewRegistry();

  /// Process-wide singleton used by `ZegoVideoView`. Tests may also use it
  /// directly.
  static final VideoViewRegistry instance = VideoViewRegistry();

  static int _counter = 0;
  final Set<String> _registered = <String>{};
  final Map<String, web.HTMLVideoElement> _elements =
      <String, web.HTMLVideoElement>{};

  /// Registers a factory for [zegoStream] and returns the viewType string
  /// for use with [HtmlElementView].
  ///
  /// [zegoStream] must be either a [ZegoLocalStream] or [ZegoRemoteStream].
  String registerStream(Object zegoStream) {
    final JSObject jsStream;
    final String id;
    final bool muteAudio;
    if (zegoStream is ZegoLocalStream) {
      jsStream = zegoStream.jsStream;
      id = zegoStream.id;
      muteAudio = true; // prevent hearing your own microphone back
    } else if (zegoStream is ZegoRemoteStream) {
      jsStream = zegoStream.jsStream;
      id = zegoStream.id;
      muteAudio = false; // remote audio must be audible
    } else {
      throw ArgumentError.value(
        zegoStream,
        'zegoStream',
        'Expected ZegoLocalStream or ZegoRemoteStream',
      );
    }

    final viewType =
        'zegoweb-video-$id-${_counter++}-${DateTime.now().microsecondsSinceEpoch}';

    final element = _createVideoElement(jsStream, muteAudio: muteAudio);
    _elements[viewType] = element;
    _registered.add(viewType);

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => _elements[viewType] ?? element,
    );

    ZegoLog.info('VideoViewRegistry: registered $viewType for stream $id');
    return viewType;
  }

  /// Removes bookkeeping for [viewType]. The platform-view factory remains
  /// registered for the lifetime of the page (Flutter does not expose an
  /// unregister API), but we drop our reference to the element.
  void unregisterStream(String viewType) {
    _registered.remove(viewType);
    final element = _elements.remove(viewType);
    if (element != null) {
      try {
        // Hide immediately so the element doesn't show as a black overlay
        // on the Flutter canvas while the platform view is being torn down.
        element.style.display = 'none';
        element.srcObject = null;
      } catch (_) {
        // best-effort cleanup
      }
    }
    ZegoLog.info('VideoViewRegistry: unregistered $viewType');
  }

  /// Whether [viewType] is currently tracked by this registry.
  bool isRegistered(String viewType) => _registered.contains(viewType);

  /// Returns the `<video>` element backing [viewType], or `null` if the
  /// viewType is unknown / has been unregistered.
  web.HTMLVideoElement? elementFor(String viewType) => _elements[viewType];

  web.HTMLVideoElement _createVideoElement(
    JSObject jsStream, {
    bool muteAudio = false,
  }) {
    final element =
        (web.document.createElement('video') as web.HTMLVideoElement)
          ..autoplay = true
          ..muted = muteAudio
          ..playsInline = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover';
    // Binding a MediaStream to the <video> element is all this registry
    // does; the engine is responsible for invoking the SDK's playback
    // method if needed.
    try {
      element.srcObject = jsStream as web.MediaStream;
    } catch (e) {
      ZegoLog.warn('VideoViewRegistry: could not bind srcObject: $e');
    }
    return element;
  }
}
