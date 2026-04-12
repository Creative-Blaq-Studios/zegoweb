import 'package:flutter/material.dart';
import 'package:zegoweb_prebuilt/zegoweb_prebuilt.dart';

void main() {
  runApp(const PrebuiltExampleApp());
}

class PrebuiltExampleApp extends StatelessWidget {
  const PrebuiltExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zegoweb_prebuilt example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const JoinScreen(),
    );
  }
}

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _appIdCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _roomCtrl = TextEditingController(text: 'demo-room');
  final _userIdCtrl = TextEditingController(text: 'user-1');
  final _userNameCtrl = TextEditingController(text: 'Alice');

  bool _loading = false;

  Future<void> _join() async {
    final appId = int.tryParse(_appIdCtrl.text);
    if (appId == null) return;

    setState(() => _loading = true);

    try {
      await ZegoPrebuilt.loadScript();

      final kitToken = ZegoPrebuilt.generateTestKitToken(
        appId: appId,
        serverSecret: _secretCtrl.text,
        roomId: _roomCtrl.text,
        userId: _userIdCtrl.text,
        userName: _userNameCtrl.text,
      );

      final prebuilt = await ZegoPrebuilt.create(kitToken);

      prebuilt.onLeaveRoom.listen((_) {
        if (mounted) Navigator.pop(context);
      });

      await prebuilt.joinRoom(ZegoPrebuiltConfig(
        roomId: _roomCtrl.text,
        userId: _userIdCtrl.text,
        userName: _userNameCtrl.text,
        scenario: ZegoPrebuiltScenario.oneOnOneCall,
      ));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CallScreen(prebuilt: prebuilt),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _appIdCtrl.dispose();
    _secretCtrl.dispose();
    _roomCtrl.dispose();
    _userIdCtrl.dispose();
    _userNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prebuilt Call Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
                controller: _appIdCtrl,
                decoration: const InputDecoration(labelText: 'App ID')),
            TextField(
                controller: _secretCtrl,
                decoration:
                    const InputDecoration(labelText: 'Server Secret (dev)')),
            TextField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: 'Room ID')),
            TextField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(labelText: 'User ID')),
            TextField(
                controller: _userNameCtrl,
                decoration: const InputDecoration(labelText: 'User Name')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _join,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Join Call'),
            ),
          ],
        ),
      ),
    );
  }
}

class CallScreen extends StatelessWidget {
  const CallScreen({super.key, required this.prebuilt});
  final ZegoPrebuilt prebuilt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZegoPrebuiltView(prebuilt: prebuilt),
    );
  }
}
