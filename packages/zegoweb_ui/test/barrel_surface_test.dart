@TestOn('chrome')
library;

// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/zegoweb_ui.dart';

void main() {
  test('public surface is reachable', () {
    const Type screenType = ZegoCallScreen;
    const Type controllerType = ZegoCallController;
    const Type configType = ZegoCallConfig;
    const Type themeType = ZegoCallTheme;
    const layout = ZegoLayoutMode.grid;
    const state = ZegoCallState.idle;
    const Type participantType = ZegoParticipant;
    const Type gridType = ZegoGridLayout;
    const Type sidebarType = ZegoSidebarLayout;
    const Type pipType = ZegoPipLayout;
    const Type tileType = ZegoParticipantTile;
    const Type controlsType = ZegoControlsBar;
    const Type preJoinType = ZegoPreJoinView;
    expect(true, isTrue);
  });
}
