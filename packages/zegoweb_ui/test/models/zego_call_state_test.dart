import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_state.dart';

void main() {
  group('ZegoCallState', () {
    test('has idle, preJoin, joining, inCall, leaving in order', () {
      expect(ZegoCallState.values, [
        ZegoCallState.idle,
        ZegoCallState.preJoin,
        ZegoCallState.joining,
        ZegoCallState.inCall,
        ZegoCallState.leaving,
      ]);
    });
  });
}
