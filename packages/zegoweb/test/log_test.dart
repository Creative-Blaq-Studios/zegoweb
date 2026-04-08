// packages/zegoweb/test/log_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/log.dart';
import 'package:zegoweb/src/models/zego_enums.dart';

class _Record {
  _Record(this.level, this.message, this.error);
  final ZegoLogLevel level;
  final String message;
  final Object? error;
}

void main() {
  late List<_Record> captured;

  setUp(() {
    captured = [];
    ZegoLog.testSink = (level, message, {error, stackTrace}) {
      captured.add(_Record(level, message, error));
    };
    ZegoLog.level = ZegoLogLevel.verbose;
  });

  tearDown(() {
    ZegoLog.testSink = null;
    ZegoLog.level = ZegoLogLevel.warn;
  });

  group('ZegoLog level filtering', () {
    test('verbose level emits every level', () {
      ZegoLog.level = ZegoLogLevel.verbose;
      ZegoLog.verbose('v');
      ZegoLog.info('i');
      ZegoLog.warn('w');
      ZegoLog.error('e');
      expect(captured.map((r) => r.level), [
        ZegoLogLevel.verbose,
        ZegoLogLevel.info,
        ZegoLogLevel.warn,
        ZegoLogLevel.error,
      ]);
    });

    test('info level drops verbose', () {
      ZegoLog.level = ZegoLogLevel.info;
      ZegoLog.verbose('v');
      ZegoLog.info('i');
      ZegoLog.warn('w');
      ZegoLog.error('e');
      expect(captured.map((r) => r.level), [
        ZegoLogLevel.info,
        ZegoLogLevel.warn,
        ZegoLogLevel.error,
      ]);
    });

    test('warn level keeps only warn and error', () {
      ZegoLog.level = ZegoLogLevel.warn;
      ZegoLog.verbose('v');
      ZegoLog.info('i');
      ZegoLog.warn('w');
      ZegoLog.error('e');
      expect(captured.map((r) => r.level), [
        ZegoLogLevel.warn,
        ZegoLogLevel.error,
      ]);
    });

    test('error level keeps only error', () {
      ZegoLog.level = ZegoLogLevel.error;
      ZegoLog.verbose('v');
      ZegoLog.info('i');
      ZegoLog.warn('w');
      ZegoLog.error('e');
      expect(captured.map((r) => r.level), [ZegoLogLevel.error]);
    });

    test('off level drops everything', () {
      ZegoLog.level = ZegoLogLevel.off;
      ZegoLog.verbose('v');
      ZegoLog.info('i');
      ZegoLog.warn('w');
      ZegoLog.error('e');
      expect(captured, isEmpty);
    });
  });

  group('ZegoLog payload', () {
    test('passes message and error through to sink', () {
      ZegoLog.level = ZegoLogLevel.verbose;
      final boom = Exception('boom');
      ZegoLog.error('something failed', boom, StackTrace.current);
      expect(captured, hasLength(1));
      expect(captured.single.message, 'something failed');
      expect(captured.single.error, same(boom));
    });

    test('falls back to developer.log when testSink is null', () {
      ZegoLog.testSink = null;
      ZegoLog.level = ZegoLogLevel.verbose;
      expect(() => ZegoLog.info('hello'), returnsNormally);
    });
  });
}
