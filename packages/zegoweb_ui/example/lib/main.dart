import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';
import 'package:zegoweb_ui/zegoweb_ui.dart';

void main() {
  runApp(const ZegoUiExampleApp());
}

class ZegoUiExampleApp extends StatefulWidget {
  const ZegoUiExampleApp({super.key});

  @override
  State<ZegoUiExampleApp> createState() => _ZegoUiExampleAppState();
}

class _ZegoUiExampleAppState extends State<ZegoUiExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'zegoweb_ui example',
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: SetupScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

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

  IconData get _themeIcon => switch (widget.themeMode) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  String get _themeLabel => switch (widget.themeMode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

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
      appBar: AppBar(
        title: const Text('zegoweb_ui Demo'),
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleTheme,
            icon: Icon(_themeIcon),
            label: Text(_themeLabel),
          ),
        ],
      ),
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
