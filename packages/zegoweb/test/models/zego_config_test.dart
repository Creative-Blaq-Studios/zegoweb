// packages/zegoweb/test/models/zego_config_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_config.dart';
import 'package:zegoweb/src/models/zego_enums.dart';

Future<String> _noopToken() async => 'tok';

void main() {
  group('ZegoEngineConfig', () {
    test('accepts a valid appId, wss server, and tokenProvider', () {
      final cfg = ZegoEngineConfig(
        appId: 1234,
        server: 'wss://example.com/ws',
        scenario: ZegoScenario.general,
        tokenProvider: _noopToken,
      );
      expect(cfg.appId, 1234);
      expect(cfg.server, 'wss://example.com/ws');
      expect(cfg.scenario, ZegoScenario.general);
      expect(cfg.tokenProvider, same(_noopToken));
    });

    test('throws ArgumentError when appId is zero', () {
      expect(
        () => ZegoEngineConfig(
          appId: 0,
          server: 'wss://example.com/ws',
          scenario: ZegoScenario.general,
          tokenProvider: _noopToken,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when appId is negative', () {
      expect(
        () => ZegoEngineConfig(
          appId: -5,
          server: 'wss://example.com/ws',
          scenario: ZegoScenario.general,
          tokenProvider: _noopToken,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when server does not start with wss://', () {
      expect(
        () => ZegoEngineConfig(
          appId: 1,
          server: 'https://example.com',
          scenario: ZegoScenario.general,
          tokenProvider: _noopToken,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when server is ws:// (plaintext)', () {
      expect(
        () => ZegoEngineConfig(
          appId: 1,
          server: 'ws://example.com',
          scenario: ZegoScenario.general,
          tokenProvider: _noopToken,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when server is empty', () {
      expect(
        () => ZegoEngineConfig(
          appId: 1,
          server: '',
          scenario: ZegoScenario.general,
          tokenProvider: _noopToken,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ZegoStreamConfig', () {
    test('defaults camera and microphone to true, numeric fields to null', () {
      const cfg = ZegoStreamConfig();
      expect(cfg.camera, isTrue);
      expect(cfg.microphone, isTrue);
      expect(cfg.videoWidth, isNull);
      expect(cfg.videoHeight, isNull);
      expect(cfg.videoFps, isNull);
      expect(cfg.videoBitrate, isNull);
    });

    test('accepts explicit values', () {
      const cfg = ZegoStreamConfig(
        camera: false,
        microphone: true,
        videoWidth: 1280,
        videoHeight: 720,
        videoFps: 30,
        videoBitrate: 1500,
      );
      expect(cfg.camera, isFalse);
      expect(cfg.microphone, isTrue);
      expect(cfg.videoWidth, 1280);
      expect(cfg.videoHeight, 720);
      expect(cfg.videoFps, 30);
      expect(cfg.videoBitrate, 1500);
    });

    test('toJs() emits camera and microphone always', () {
      const cfg = ZegoStreamConfig();
      final js = cfg.toJs();
      expect((js['camera'] as JSBoolean).toDart, isTrue);
      expect((js['microphone'] as JSBoolean).toDart, isTrue);
      expect(js['videoWidth'], isNull);
      expect(js['videoFps'], isNull);
    });

    test('toJs() emits optional fields only when set', () {
      const cfg = ZegoStreamConfig(
        camera: false,
        videoWidth: 1280,
        videoHeight: 720,
        videoFps: 30,
        videoBitrate: 1500,
      );
      final js = cfg.toJs();
      expect((js['camera'] as JSBoolean).toDart, isFalse);
      expect((js['videoWidth'] as JSNumber).toDartInt, 1280);
      expect((js['videoHeight'] as JSNumber).toDartInt, 720);
      expect((js['videoFps'] as JSNumber).toDartInt, 30);
      expect((js['videoBitrate'] as JSNumber).toDartInt, 1500);
    });
  });
}
