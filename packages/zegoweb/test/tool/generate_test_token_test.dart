// packages/zegoweb/test/tool/generate_test_token_test.dart
//
// VM-only: the token generator uses ByteData.setInt64 which dart2js does not
// support (JS numbers don't have native 64-bit integers). The token generator
// itself is intended to run from a CLI shell, never in the browser.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/internal/token_generator.dart' as gen;

void main() {
  group('generateToken04', () {
    test('is prefixed with the literal "04" version tag (outside base64)', () {
      // 32-byte ASCII secret — first 16 bytes are used as the AES key.
      const secret = '0123456789abcdef0123456789abcdef';
      final token = gen.generateToken04(
        appId: 1234567890,
        userId: 'user-1',
        serverSecret: secret,
        effectiveTimeInSeconds: 3600,
      );

      expect(token, isNotEmpty);
      expect(token.startsWith('04'), isTrue,
          reason: 'token must start with the literal "04" version tag');

      // Decode the base64 payload (everything after "04") and check the
      // binary layout: expire(8) + ivLen(2) + iv(16) + cipherLen(2) + cipher.
      final decoded = base64.decode(token.substring(2));
      expect(decoded.length, greaterThanOrEqualTo(8 + 2 + 16 + 2 + 16));

      // expire: i64 BE at offset 0 — should be roughly now + 3600.
      final expire = ByteData.sublistView(decoded, 0, 8).getInt64(0);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(expire, greaterThanOrEqualTo(now + 3590));
      expect(expire, lessThanOrEqualTo(now + 3610));

      // ivLen: u16 BE at offset 8 — should be exactly 16.
      final ivLen = ByteData.sublistView(decoded, 8, 10).getUint16(0);
      expect(ivLen, 16);

      // cipherLen: u16 BE at offset 8 + 2 + 16 = 26.
      final cipherLen = ByteData.sublistView(decoded, 26, 28).getUint16(0);
      expect(cipherLen, greaterThan(0));
      // Total trailing bytes must equal the declared cipherLen.
      expect(decoded.length, 8 + 2 + 16 + 2 + cipherLen);

      // AES-128-CBC ciphertext with PKCS#7 padding is always a multiple of
      // 16 bytes and at least 16 bytes long.
      expect(cipherLen % 16, 0);
      expect(cipherLen, greaterThanOrEqualTo(16));
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
