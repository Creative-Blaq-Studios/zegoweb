// packages/zegoweb/test/video_view_registry_test.dart
@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;
import 'package:zegoweb/src/video_view_registry.dart';
import 'package:zegoweb/src/zego_local_stream.dart';

void main() {
  group('VideoViewRegistry', () {
    late VideoViewRegistry registry;

    setUp(() {
      registry = VideoViewRegistry();
    });

    test('registerStream returns a unique viewType per call', () {
      final s1 = ZegoLocalStreamTestAccess.create('a', JSObject());
      final s2 = ZegoLocalStreamTestAccess.create('b', JSObject());
      final t1 = registry.registerStream(s1);
      final t2 = registry.registerStream(s2);
      expect(t1, isNotEmpty);
      expect(t2, isNotEmpty);
      expect(t1, isNot(equals(t2)));
      registry.unregisterStream(t1);
      registry.unregisterStream(t2);
    });

    test('registerStream eagerly produces an HTML <video> element', () {
      final stream = ZegoLocalStreamTestAccess.create('v', JSObject());
      final viewType = registry.registerStream(stream);

      final element = registry.elementFor(viewType);
      expect(element, isNotNull);
      expect(element!.tagName.toLowerCase(), 'video');

      registry.unregisterStream(viewType);
    });

    test('video element has autoplay/playsinline defaults', () {
      final stream = ZegoLocalStreamTestAccess.create('v2', JSObject());
      final viewType = registry.registerStream(stream);
      final element = registry.elementFor(viewType);
      expect(element, isA<web.HTMLVideoElement>());
      expect(element!.autoplay, isTrue);
      expect(element.muted, isTrue);
      expect(element.playsInline, isTrue);
      registry.unregisterStream(viewType);
    });

    test('unregisterStream clears internal bookkeeping', () {
      final stream = ZegoLocalStreamTestAccess.create('u', JSObject());
      final viewType = registry.registerStream(stream);
      registry.unregisterStream(viewType);
      expect(registry.isRegistered(viewType), isFalse);
      expect(registry.elementFor(viewType), isNull);
    });

    test('registerStream rejects objects that are not zego streams', () {
      expect(
        () => registry.registerStream(Object()),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
