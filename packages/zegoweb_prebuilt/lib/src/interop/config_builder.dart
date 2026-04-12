// packages/zegoweb_prebuilt/lib/src/interop/config_builder.dart
//
// Translates ZegoPrebuiltConfig → JS object for ZegoUIKitPrebuilt.joinRoom.
// Typed fields first, then rawConfig merged on top (rawConfig wins on
// collision). Event callbacks are wired as .toJS closures that pump into
// the StreamControllers held by the ZegoPrebuilt instance.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../zego_prebuilt_config.dart';

/// Builds the JS config object for `joinRoom(container, config)`.
abstract final class ConfigBuilder {
  /// Build a JS object from the typed [config] and a map of stream controllers
  /// keyed by event name.
  static JSObject build(
    ZegoPrebuiltConfig config,
    Map<String, dynamic> streamControllers,
  ) {
    // Validate rawConfig: reject Function values
    _validateRawConfig(config.rawConfig);

    final js = JSObject();

    // --- Scenario ---
    final scenario = JSObject();
    scenario['mode'] = switch (config.scenario) {
      ZegoPrebuiltScenario.oneOnOneCall => 0.toJS,
      ZegoPrebuiltScenario.groupCall => 1.toJS,
      ZegoPrebuiltScenario.videoConference => 2.toJS,
    };
    js['scenario'] = scenario;

    // --- Boolean toggles ---
    js['showPreJoinView'] = config.showPreJoinView.toJS;
    js['turnOnMicrophoneWhenJoining'] = config.turnOnMicrophoneWhenJoining.toJS;
    js['turnOnCameraWhenJoining'] = config.turnOnCameraWhenJoining.toJS;
    js['useFrontFacingCamera'] = config.useFrontFacingCamera.toJS;
    js['showRoomTimer'] = config.showRoomTimer.toJS;
    js['showMyCameraToggleButton'] = config.showMyCameraToggleButton.toJS;
    js['showMyMicrophoneToggleButton'] =
        config.showMyMicrophoneToggleButton.toJS;
    js['showAudioVideoSettingsButton'] =
        config.showAudioVideoSettingsButton.toJS;
    js['showTextChat'] = config.showTextChat.toJS;
    js['showUserList'] = config.showUserList.toJS;
    js['showScreenSharingButton'] = config.showScreenSharingButton.toJS;
    js['showLeaveRoomConfirmDialog'] = config.showLeaveRoomConfirmDialog.toJS;

    // --- Optional typed fields ---
    if (config.maxUsers != null) {
      js['maxUsers'] = config.maxUsers!.toJS;
    }
    if (config.preJoinViewTitle != null) {
      js['preJoinViewTitle'] = config.preJoinViewTitle!.toJS;
    }
    if (config.brandingLogoUrl != null) {
      final branding = JSObject();
      branding['logoURL'] = config.brandingLogoUrl!.toJS;
      js['branding'] = branding;
    }

    // --- Layout ---
    js['layout'] = switch (config.layout) {
      ZegoPrebuiltLayout.auto => 'Auto'.toJS,
      ZegoPrebuiltLayout.sidebar => 'Sidebar'.toJS,
      ZegoPrebuiltLayout.grid => 'Grid'.toJS,
    };

    // --- Video resolution ---
    js['videoResolutionDefault'] = switch (config.videoResolution) {
      ZegoPrebuiltVideoResolution.sd180 => 180.toJS,
      ZegoPrebuiltVideoResolution.sd360 => 360.toJS,
      ZegoPrebuiltVideoResolution.sd480 => 480.toJS,
      ZegoPrebuiltVideoResolution.hd720 => 720.toJS,
    };

    // --- Language ---
    js['language'] = switch (config.language) {
      ZegoPrebuiltLanguage.english => 'ENGLISH'.toJS,
      ZegoPrebuiltLanguage.chinese => 'CHS'.toJS,
    };

    // --- Event callbacks → wired to StreamControllers ---
    _wireEvents(js, streamControllers);

    // --- rawConfig merge (wins on collision) ---
    if (config.rawConfig != null) {
      for (final entry in config.rawConfig!.entries) {
        js[entry.key] = entry.value.jsify();
      }
    }

    return js;
  }

  static void _validateRawConfig(Map<String, Object?>? rawConfig) {
    if (rawConfig == null) return;
    for (final entry in rawConfig.entries) {
      _validateValue(entry.key, entry.value);
    }
  }

  static void _validateValue(String key, Object? value) {
    if (value is Function) {
      throw ArgumentError.value(
        value,
        'rawConfig["$key"]',
        'Functions are not allowed in rawConfig. Use the matching Stream '
            'getter on ZegoPrebuilt instead (e.g. prebuilt.onJoinRoom). '
            'If no matching Stream exists, file a PR to add the event.',
      );
    }
    if (value is Map) {
      for (final nested in value.entries) {
        _validateValue('$key.${nested.key}', nested.value);
      }
    }
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _validateValue('$key[$i]', value[i]);
      }
    }
  }

  static void _wireEvents(
    JSObject js,
    Map<String, dynamic> streamControllers,
  ) {
    js['onJoinRoom'] = (() {
      final ctrl = streamControllers['onJoinRoom'];
      if (ctrl is StreamController<void>) ctrl.add(null);
    }).toJS;

    js['onLeaveRoom'] = (() {
      final ctrl = streamControllers['onLeaveRoom'];
      if (ctrl is StreamController<void>) ctrl.add(null);
    }).toJS;

    js['onUserJoin'] = ((JSAny? users) {
      final ctrl = streamControllers['onUserJoin'];
      if (ctrl is StreamController) ctrl.add(users);
    }).toJS;

    js['onUserLeave'] = ((JSAny? users) {
      final ctrl = streamControllers['onUserLeave'];
      if (ctrl is StreamController) ctrl.add(users);
    }).toJS;

    js['onYouRemovedFromRoom'] = (() {
      final ctrl = streamControllers['onYouRemovedFromRoom'];
      if (ctrl is StreamController<void>) ctrl.add(null);
    }).toJS;
  }
}
