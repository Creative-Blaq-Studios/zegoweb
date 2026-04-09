// packages/zegoweb/example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';

void main() {
  // setLogLevel can be called before or after loadScript.
  ZegoWeb.setLogLevel(ZegoLogLevel.info);
  runApp(const ZegoExampleApp());
}

class ZegoExampleApp extends StatelessWidget {
  const ZegoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zegoweb example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const CallScreen(),
    );
  }
}

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _appIdCtrl = TextEditingController();
  final _serverCtrl = TextEditingController(
    text: 'wss://webliveroom-api.zego.im/ws',
  );
  final _roomCtrl = TextEditingController(text: 'demo-room');
  final _userIdCtrl = TextEditingController(text: 'user-1');
  final _userNameCtrl = TextEditingController(text: 'Alice');
  final _tokenCtrl = TextEditingController();

  ZegoEngine? _engine;
  ZegoLocalStream? _local;
  final Map<String, ZegoRemoteStream> _remotes = {};
  String _status = 'idle';

  @override
  void dispose() {
    _appIdCtrl.dispose();
    _serverCtrl.dispose();
    _roomCtrl.dispose();
    _userIdCtrl.dispose();
    _userNameCtrl.dispose();
    _tokenCtrl.dispose();
    _engine?.destroy();
    super.dispose();
  }

  Future<void> _join() async {
    if (_engine != null) return;
    setState(() => _status = 'loading SDK…');
    try {
      await ZegoWeb.loadScript();

      final engine = await ZegoWeb.createEngine(
        ZegoEngineConfig(
          appId: int.parse(_appIdCtrl.text.trim()),
          server: _serverCtrl.text.trim(),
          scenario: ZegoScenario.communication,
          tokenProvider: () async => _tokenCtrl.text.trim(),
        ),
      );

      engine.onError.listen((e) {
        debugPrint('zegoweb error: ${e.code} ${e.message}');
        if (mounted) {
          setState(() => _status = 'error ${e.code}: ${e.message}');
        }
      });

      engine.onRoomStreamUpdate.listen((u) async {
        debugPrint(
          '[example] roomStreamUpdate type=${u.type.name} '
          'roomId=${u.roomId} streams=${u.streams.length}',
        );
        for (final s in u.streams) {
          debugPrint(
            '[example]   stream: id=${s.streamId} user=${s.user.userId}',
          );
        }
        if (u.type == ZegoUpdateType.add) {
          for (final s in u.streams) {
            try {
              debugPrint('[example] startPlaying(${s.streamId}) …');
              final r = await engine.startPlaying(s.streamId);
              debugPrint('[example] startPlaying OK: ${r.id}');
              if (mounted) setState(() => _remotes[s.streamId] = r);
            } catch (e, st) {
              debugPrint('[example] startPlaying FAILED: $e\n$st');
            }
          }
        } else {
          for (final s in u.streams) {
            await engine.stopPlaying(s.streamId);
            if (mounted) setState(() => _remotes.remove(s.streamId));
          }
        }
      });

      engine.onRoomUserUpdate.listen((u) {
        debugPrint(
          '[example] roomUserUpdate type=${u.type.name} '
          'users=${u.users.map((x) => x.userId).toList()}',
        );
      });

      engine.onRoomStateChanged.listen((s) {
        debugPrint('[example] roomStateChanged → ${s.name}');
      });

      await engine.loginRoom(
        _roomCtrl.text.trim(),
        ZegoUser(
          userId: _userIdCtrl.text.trim(),
          userName: _userNameCtrl.text.trim(),
        ),
      );

      final local = await engine.createLocalStream(
        config: const ZegoStreamConfig(camera: true, microphone: true),
      );

      final streamId = 'stream-${_userIdCtrl.text.trim()}';
      await engine.startPublishing(streamId, local);

      if (!mounted) return;
      setState(() {
        _engine = engine;
        _local = local;
        _status = 'joined $streamId';
      });
    } catch (e) {
      if (mounted) setState(() => _status = 'join failed: $e');
    }
  }

  Future<void> _leave() async {
    final e = _engine;
    if (e == null) return;
    setState(() => _status = 'leaving…');
    await e.destroy();
    if (!mounted) return;
    setState(() {
      _engine = null;
      _local = null;
      _remotes.clear();
      _status = 'left';
    });
  }

  @override
  Widget build(BuildContext context) {
    final joined = _engine != null;
    return Scaffold(
      appBar: AppBar(title: const Text('zegoweb example — 1:1 call')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!joined) ...[
              TextField(
                controller: _appIdCtrl,
                decoration: const InputDecoration(labelText: 'App ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _serverCtrl,
                decoration: const InputDecoration(labelText: 'Server (wss://)'),
              ),
              TextField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: 'Room ID'),
              ),
              TextField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(labelText: 'User ID'),
              ),
              TextField(
                controller: _userNameCtrl,
                decoration: const InputDecoration(labelText: 'User name'),
              ),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Token (empty if using dev/AppSign mode)',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _join, child: const Text('Join')),
            ] else ...[
              OutlinedButton(onPressed: _leave, child: const Text('Leave')),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  children: [
                    if (_local != null)
                      Expanded(
                        child: Container(
                          color: Colors.black12,
                          child: ZegoVideoView(stream: _local!, mirror: true),
                        ),
                      ),
                    ..._remotes.values.map(
                      (r) => Expanded(
                        child: Container(
                          color: Colors.black26,
                          margin: const EdgeInsets.only(top: 8),
                          child: ZegoVideoView(stream: r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            SelectableText('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
