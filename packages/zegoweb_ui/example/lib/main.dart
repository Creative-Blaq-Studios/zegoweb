import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/zegoweb_ui.dart';

void main() {
  runApp(const ZegoUiExampleApp());
}

class ZegoUiExampleApp extends StatelessWidget {
  const ZegoUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zegoweb_ui example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _appIdCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _roomCtrl = TextEditingController(text: 'demo-room');
  final _userIdCtrl = TextEditingController(text: 'user-1');
  final _userNameCtrl = TextEditingController(text: 'Alice');

  void _startCall() {
    final appId = int.tryParse(_appIdCtrl.text);
    if (appId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ZegoCallScreen(
          engineConfig: ZegoEngineConfig(
            appId: appId,
            server: 'wss://webliveroom-api.zego.im/ws',
            scenario: ZegoScenario.communication,
            tokenProvider: () async => _tokenCtrl.text,
          ),
          callConfig: ZegoCallConfig(
            roomId: _roomCtrl.text,
            userId: _userIdCtrl.text,
            userName: _userNameCtrl.text,
          ),
          onCallEnded: () => Navigator.pop(context),
          onError: (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appIdCtrl.dispose();
    _tokenCtrl.dispose();
    _roomCtrl.dispose();
    _userIdCtrl.dispose();
    _userNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('zegoweb_ui Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _appIdCtrl,
              decoration: const InputDecoration(labelText: 'App ID'),
            ),
            TextField(
              controller: _tokenCtrl,
              decoration: const InputDecoration(labelText: 'Token'),
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
              decoration: const InputDecoration(labelText: 'User Name'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _startCall,
              child: const Text('Start Call'),
            ),
          ],
        ),
      ),
    );
  }
}
