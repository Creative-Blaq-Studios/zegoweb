// packages/zegoweb/tool/generate_test_token.dart
//
// Standalone Dart script: generates a ZEGO `token04` for local development.
//
// Usage:
//   dart run tool/generate_test_token.dart --user-id user-1 [--ttl 86400]
//
// Reads ZEGO_APP_ID and ZEGO_SERVER_SECRET from a local .env file (simple
// KEY=VALUE format, no quoting). Keep the .env file out of version control.
//
// NOT a production token minter. For production, mint tokens on a server you
// control — see example/supabase/functions/zego-token/index.ts or
// example/functions/src/zegoToken.ts for reference implementations.
//
// The pure algorithm lives in lib/src/internal/token_generator.dart so it
// can be exercised by VM-only unit tests AND so the chrome test bundler
// (which can't reach files outside lib/ + test/) doesn't trip on this script.

import 'dart:io';

import 'package:args/args.dart';
import 'package:zegoweb/src/internal/token_generator.dart';

Map<String, String> _readDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln(
      'warning: $path not found, falling back to Platform.environment',
    );
    return const {};
  }
  final out = <String, String>{};
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    out[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
  }
  return out;
}

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('user-id', abbr: 'u', help: 'ZEGO user id', mandatory: true)
    ..addOption('ttl', defaultsTo: '86400', help: 'Effective time in seconds')
    ..addOption('env-file', defaultsTo: '.env', help: 'Path to .env file')
    ..addFlag('help', abbr: 'h', negatable: false);

  late final ArgResults args;
  try {
    args = parser.parse(argv);
  } on FormatException catch (e) {
    stderr.writeln('error: ${e.message}\n${parser.usage}');
    exit(64);
  }
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  final env = {
    ..._readDotEnv(args['env-file'] as String),
    ...Platform.environment,
  };
  final appIdStr = env['ZEGO_APP_ID'];
  final secret = env['ZEGO_SERVER_SECRET'];
  if (appIdStr == null || secret == null) {
    stderr.writeln(
      'error: ZEGO_APP_ID and ZEGO_SERVER_SECRET must be set '
      '(via ${args['env-file']} or the environment)',
    );
    exit(1);
  }

  final token = generateToken04(
    appId: int.parse(appIdStr),
    userId: args['user-id'] as String,
    serverSecret: secret,
    effectiveTimeInSeconds: int.parse(args['ttl'] as String),
  );
  stdout.writeln(token);
}
