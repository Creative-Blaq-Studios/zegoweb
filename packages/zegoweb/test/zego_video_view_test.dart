// packages/zegoweb/test/zego_video_view_test.dart
@TestOn('chrome')
library;

// Object() in the negative-path test prevents some const constructions, and
// SizedBox with non-const children chains the lint upward.
// ignore_for_file: prefer_const_constructors

import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/video_view_registry.dart';
import 'package:zegoweb/src/zego_local_stream.dart';
import 'package:zegoweb/src/zego_remote_stream.dart';
import 'package:zegoweb/src/zego_video_view.dart';

void main() {
  group('ZegoVideoView', () {
    testWidgets('mounts an HtmlElementView for a local stream',
        (tester) async {
      final local = ZegoLocalStreamTestAccess.create('v-1', JSObject());
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 240,
            child: ZegoVideoView(stream: local),
          ),
        ),
      );
      expect(find.byType(HtmlElementView), findsOneWidget);
    });

    testWidgets('mounts an HtmlElementView for a remote stream',
        (tester) async {
      final remote = ZegoRemoteStreamTestAccess.create('r-1', JSObject());
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 240,
            child: ZegoVideoView(stream: remote),
          ),
        ),
      );
      expect(find.byType(HtmlElementView), findsOneWidget);
    });

    testWidgets('throws ArgumentError for a non-zego stream', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 240,
            child: ZegoVideoView(stream: Object()),
          ),
        ),
      );
      expect(tester.takeException(), isA<ArgumentError>());
    });

    testWidgets('unregisters the viewType on dispose', (tester) async {
      final local = ZegoLocalStreamTestAccess.create('v-dispose', JSObject());
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 240,
            child: ZegoVideoView(stream: local),
          ),
        ),
      );
      final state =
          tester.state<ZegoVideoViewState>(find.byType(ZegoVideoView));
      final viewType = state.debugViewType;
      expect(VideoViewRegistry.instance.isRegistered(viewType), isTrue);
      await tester.pumpWidget(const SizedBox());
      expect(VideoViewRegistry.instance.isRegistered(viewType), isFalse);
    });

    testWidgets('mirror=true applies scaleX(-1) transform to the element',
        (tester) async {
      final local = ZegoLocalStreamTestAccess.create('v-mirror', JSObject());
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 240,
            child: ZegoVideoView(stream: local, mirror: true),
          ),
        ),
      );
      // Wait for the post-frame style application microtask.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      final state =
          tester.state<ZegoVideoViewState>(find.byType(ZegoVideoView));
      final element =
          VideoViewRegistry.instance.elementFor(state.debugViewType);
      expect(element, isNotNull);
      expect(element!.style.transform, contains('scaleX(-1)'));
    });
  });
}
