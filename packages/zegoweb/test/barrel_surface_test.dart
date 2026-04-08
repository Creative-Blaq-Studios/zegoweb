// packages/zegoweb/test/barrel_surface_test.dart
// Compile-only check: every symbol listed in the barrel is referenced.
// If something disappears or is renamed, this file fails to compile and
// the test run fails.
//
// Pinned to chrome because the package transitively depends on
// dart:js_interop which can only be compiled for web targets.
@TestOn('chrome')
library;

// ignore_for_file: unused_local_variable, unused_import, prefer_const_declarations

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/zegoweb.dart';

void main() {
  test('public surface is reachable', () {
    // ZegoWeb entry point
    final loadScript = ZegoWeb.loadScript;
    final setLogLevel = ZegoWeb.setLogLevel;
    final createEngine = ZegoWeb.createEngine;

    // Engine + stream types
    const Type engineType = ZegoEngine;
    const Type localStreamType = ZegoLocalStream;
    const Type remoteStreamType = ZegoRemoteStream;
    const Type videoViewType = ZegoVideoView;

    // Config
    const Type engineCfgType = ZegoEngineConfig;
    const Type streamCfgType = ZegoStreamConfig;

    // Value types
    const Type userType = ZegoUser;
    const Type deviceType = ZegoDeviceInfo;
    const Type streamInfoType = ZegoStreamInfo;
    const Type roomUserUpdateType = ZegoRoomUserUpdate;
    const Type roomStreamUpdateType = ZegoRoomStreamUpdate;

    // Enums
    const loglevel = ZegoLogLevel.info;
    const scenario = ZegoScenario.general;
    const update = ZegoUpdateType.add;
    const roomState = ZegoRoomState.connected;
    const perm = ZegoPermissionStatus.granted;

    // Errors
    const Type errType = ZegoError;
    const Type permErrType = ZegoPermissionException;
    const Type netErrType = ZegoNetworkException;
    const Type authErrType = ZegoAuthException;
    const Type devErrType = ZegoDeviceException;
    const Type stateErrType = ZegoStateError;
    const pKind = PermissionErrorKind.denied;

    expect(true, isTrue);
  });
}
