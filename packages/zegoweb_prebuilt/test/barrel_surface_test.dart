// Compile-only check: every symbol listed in the barrel is referenced.

// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';

void main() {
  test('public surface is reachable', () {
    // Entry point
    final loadScript = ZegoPrebuilt.loadScript;
    final create = ZegoPrebuilt.create;
    final testToken = ZegoPrebuilt.generateTestKitToken;
    final prodToken = ZegoPrebuilt.generateProductionKitToken;

    // Widget
    const Type viewType = ZegoPrebuiltView;

    // Config + enums
    const Type configType = ZegoPrebuiltConfig;
    const scenario = ZegoPrebuiltScenario.oneOnOneCall;
    const layout = ZegoPrebuiltLayout.auto;
    const resolution = ZegoPrebuiltVideoResolution.hd720;
    const language = ZegoPrebuiltLanguage.english;

    // User
    const Type userType = ZegoPrebuiltUser;

    // Errors
    const Type errType = ZegoError;
    const Type stateErrType = ZegoStateError;

    expect(true, isTrue);
  });
}
