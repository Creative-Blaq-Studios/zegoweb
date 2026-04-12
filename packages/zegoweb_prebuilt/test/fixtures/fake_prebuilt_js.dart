import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

class FakeJoinRoomCall {
  FakeJoinRoomCall({required this.container, required this.config});
  final JSObject container;
  final JSObject config;
}

class FakePrebuiltJs {
  FakePrebuiltJs();

  bool _installed = false;
  JSAny? _previousCtor;

  final List<String> createCalls = <String>[];
  final List<FakeJoinRoomCall> joinRoomCalls = <FakeJoinRoomCall>[];
  int hangUpCalls = 0;
  int destroyCalls = 0;

  bool _shouldRejectCreate = false;
  String? _createRejectMessage;

  JSFunction? _onJoinRoom;
  JSFunction? _onLeaveRoom;
  JSFunction? _onUserJoin;
  JSFunction? _onUserLeave;
  JSFunction? _onYouRemovedFromRoom;

  JSObject? lastContainer;

  void installAsWindowGlobal() {
    if (_installed) return;
    _previousCtor = (web.window as JSObject)['ZegoUIKitPrebuilt'];

    final fakeClass = JSObject();

    fakeClass['create'] = ((String kitToken) {
      createCalls.add(kitToken);
      if (_shouldRejectCreate) {
        _shouldRejectCreate = false;
        throw Exception(_createRejectMessage ?? 'fake create error');
      }
      return _makeFakeInstance();
    }).toJS;

    fakeClass['generateKitTokenForTest'] =
        ((int appID, String serverSecret, String roomID, String userID,
            [String? userName]) {
      return 'fake-test-token-$appID-$roomID-$userID';
    }).toJS;

    fakeClass['generateKitTokenForProduction'] =
        ((int appID, String serverToken, String roomID, String userID,
            [String? userName]) {
      return 'fake-prod-token-$appID-$roomID-$userID';
    }).toJS;

    (web.window as JSObject)['ZegoUIKitPrebuilt'] = fakeClass;
    _installed = true;
  }

  void uninstall() {
    if (!_installed) return;
    (web.window as JSObject)['ZegoUIKitPrebuilt'] = _previousCtor;
    _installed = false;
    _onJoinRoom = null;
    _onLeaveRoom = null;
    _onUserJoin = null;
    _onUserLeave = null;
    _onYouRemovedFromRoom = null;
  }

  void rejectNextCreate({String message = 'fake error'}) {
    _shouldRejectCreate = true;
    _createRejectMessage = message;
  }

  void fireOnJoinRoom() {
    _onJoinRoom?.callAsFunction(null);
  }

  void fireOnLeaveRoom() {
    _onLeaveRoom?.callAsFunction(null);
  }

  void fireOnUserJoin(List<Map<String, String>> users) {
    final jsUsers = users
        .map((u) => <String, Object?>{
              'userID': u['userID'],
              'userName': u['userName'],
            }.jsify())
        .toList();
    _onUserJoin?.callAsFunction(null, jsUsers.jsify());
  }

  void fireOnUserLeave(List<Map<String, String>> users) {
    final jsUsers = users
        .map((u) => <String, Object?>{
              'userID': u['userID'],
              'userName': u['userName'],
            }.jsify())
        .toList();
    _onUserLeave?.callAsFunction(null, jsUsers.jsify());
  }

  void fireOnYouRemovedFromRoom() {
    _onYouRemovedFromRoom?.callAsFunction(null);
  }

  JSObject _makeFakeInstance() {
    final instance = JSObject();

    instance['joinRoom'] = ((JSObject container, JSObject config) {
      lastContainer = container;
      _onJoinRoom = config['onJoinRoom'] as JSFunction?;
      _onLeaveRoom = config['onLeaveRoom'] as JSFunction?;
      _onUserJoin = config['onUserJoin'] as JSFunction?;
      _onUserLeave = config['onUserLeave'] as JSFunction?;
      _onYouRemovedFromRoom = config['onYouRemovedFromRoom'] as JSFunction?;
      joinRoomCalls.add(FakeJoinRoomCall(container: container, config: config));
    }).toJS;

    instance['hangUp'] = (() {
      hangUpCalls++;
    }).toJS;

    instance['setLanguage'] = ((JSObject language) {}).toJS;

    instance['destroy'] = (() {
      destroyCalls++;
    }).toJS;

    return instance;
  }
}
