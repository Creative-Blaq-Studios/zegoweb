// packages/zegoweb/test/tool/generate_test_token_test.dart
@TestOn('vm')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_test_token.dart' as gen;

void main() {
  group('generateToken04', () {
    test('produces base64 string with leading version bytes "04"', () {
      // 32-byte ASCII secret — first 16 bytes are used as the AES key.
      const secret = '0123456789abcdef0123456789abcdef';
      final token = gen.generateToken04(
        appId: 1234567890,
        userId: 'user-1',
        serverSecret: secret,
        effectiveTimeInSeconds: 3600,
      );

      expect(token, isNotEmpty);
      final decoded = base64.decode(token);
      // version(2) + iv(16) + at-least-some-ciphertext + tag(16)
      expect(decoded.length, greaterThanOrEqualTo(2 + 16 + 16));
      expect(String.fromCharCodes(decoded.sublist(0, 2)), '04');
    });

    test('two invocations produce different tokens (random iv/nonce)', () {
      const secret = '0123456789abcdef0123456789abcdef';
      final a = gen.generateToken04(
        appId: 1,
        userId: 'u',
        serverSecret: secret,
      );
      final b = gen.generateToken04(
        appId: 1,
        userId: 'u',
        serverSecret: secret,
      );
      expect(a, isNot(equals(b)));
    });

    test('throws if serverSecret is shorter than 16 bytes', () {
      expect(
        () => gen.generateToken04(
          appId: 1,
          userId: 'u',
          serverSecret: 'short',
        ),
        throwsArgumentError,
      );
    });
  });
}
