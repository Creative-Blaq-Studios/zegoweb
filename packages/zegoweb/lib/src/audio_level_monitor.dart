// packages/zegoweb/lib/src/audio_level_monitor.dart
import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:zegoweb/src/audio_level_rms.dart';

// ---------------------------------------------------------------------------
// Web Audio API extension types (private to this file)
// ---------------------------------------------------------------------------

@JS('AudioContext')
extension type _AudioCtx._(JSObject _) implements JSObject {
  external factory _AudioCtx();
  external JSPromise<JSAny?> resume();
  external _SourceNode createMediaStreamSource(JSObject stream);
  external _AnalyserNode createAnalyser();
  external JSPromise<JSAny?> close();
}

@JS()
extension type _SourceNode._(JSObject _) implements JSObject {
  external void connect(JSObject destination);
  external void disconnect();
}

@JS()
extension type _AnalyserNode._(JSObject _) implements JSObject {
  external set fftSize(int value);
  external void getByteTimeDomainData(JSUint8Array array);
  external void disconnect();
}

// ---------------------------------------------------------------------------
// Per-stream state
// ---------------------------------------------------------------------------

class _Entry {
  _Entry(this.source, this.analyser, this.jsBuffer);
  final _SourceNode source;
  final _AnalyserNode analyser;
  final JSUint8Array jsBuffer; // pre-allocated; shares memory with Dart view
}

// ---------------------------------------------------------------------------
// ZegoAudioLevelMonitor
// ---------------------------------------------------------------------------

/// Measures per-stream audio levels using the Web Audio API and emits the
/// stream ID of the loudest speaker, or null for silence.
///
/// Owned by [ZegoEngine]. Do not instantiate directly.
class ZegoAudioLevelMonitor {
  static const int _fftSize = 256;
  static const double _threshold = 0.02; // normalised RMS 0.0-1.0
  static const Duration _pollInterval = Duration(milliseconds: 100);
  static const Duration _debounce = Duration(milliseconds: 500);

  _AudioCtx? _ctx;
  final Map<String, _Entry> _entries = {};
  final StreamController<String?> _sc = StreamController.broadcast();

  Timer? _pollTimer;
  Timer? _debounceTimer;
  String? _candidateId;
  String? _activeSpeakerId;

  /// Emits the loudest stream ID above threshold (debounced 500 ms),
  /// or null when all streams fall silent.
  Stream<String?> get onActiveSpeakerChanged => _sc.stream;

  /// Register a MediaStream JS object for level monitoring.
  void addStream(String streamId, JSObject jsMediaStream) {
    if (_entries.containsKey(streamId)) return;

    _ctx ??= _AudioCtx();
    _ctx!.resume(); // resume if browser suspended the context

    final source = _ctx!.createMediaStreamSource(jsMediaStream);
    final analyser = _ctx!.createAnalyser();
    analyser.fftSize = _fftSize;
    source.connect(analyser);

    final jsBuffer = Uint8List(_fftSize).toJS;
    _entries[streamId] = _Entry(source, analyser, jsBuffer);

    _pollTimer ??= Timer.periodic(_pollInterval, _poll);
  }

  /// Unregister a stream and clean up its Web Audio nodes.
  void removeStream(String streamId) {
    final entry = _entries.remove(streamId);
    if (entry == null) return;

    try {
      entry.source.disconnect();
    } catch (_) {}
    try {
      entry.analyser.disconnect();
    } catch (_) {}

    if (_entries.isEmpty) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }

    if (_activeSpeakerId == streamId) {
      _activeSpeakerId = null;
      if (!_sc.isClosed) _sc.add(null);
    }
    if (_candidateId == streamId) {
      _candidateId = null;
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  void _poll(Timer _) {
    if (_entries.isEmpty) return;

    String? loudestId;
    double loudestRms = 0;

    for (final kv in _entries.entries) {
      kv.value.analyser.getByteTimeDomainData(kv.value.jsBuffer);
      final rms = computeRms(kv.value.jsBuffer.toDart);
      if (rms > _threshold && rms > loudestRms) {
        loudestRms = rms;
        loudestId = kv.key;
      }
    }

    if (loudestId == null) {
      // Silence — clear immediately (no debounce on silence).
      _debounceTimer?.cancel();
      _debounceTimer = null;
      _candidateId = null;
      if (_activeSpeakerId != null) {
        _activeSpeakerId = null;
        if (!_sc.isClosed) _sc.add(null);
      }
      return;
    }

    if (loudestId == _activeSpeakerId) {
      // Same speaker — cancel any pending switch.
      _debounceTimer?.cancel();
      _debounceTimer = null;
      _candidateId = null;
      return;
    }

    if (loudestId == _candidateId) return; // already debouncing

    // New candidate — start 500 ms debounce.
    _debounceTimer?.cancel();
    _candidateId = loudestId;
    _debounceTimer = Timer(_debounce, () {
      if (_candidateId != null && _candidateId != _activeSpeakerId) {
        _activeSpeakerId = _candidateId;
        _candidateId = null;
        if (!_sc.isClosed) _sc.add(_activeSpeakerId);
      }
    });
  }

  /// Compute normalised RMS of a time-domain byte buffer (values 0-255,
  /// centred at 128). Result is in range 0.0-1.0.
  ///
  /// Exposed for testing.
  static double computeRms(Uint8List samples) => computeAudioRms(samples);

  /// Cancel the poll timer, disconnect all nodes, close the AudioContext.
  void dispose() {
    _pollTimer?.cancel();
    _debounceTimer?.cancel();
    for (final e in _entries.values) {
      try {
        e.source.disconnect();
      } catch (_) {}
      try {
        e.analyser.disconnect();
      } catch (_) {}
    }
    _entries.clear();
    try {
      _ctx?.close();
    } catch (_) {}
    _ctx = null;
    _sc.close();
  }
}
