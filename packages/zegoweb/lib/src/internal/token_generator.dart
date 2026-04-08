// packages/zegoweb/lib/src/internal/token_generator.dart
//
// Pure-Dart implementation of the ZEGO `token04` algorithm. No `dart:io`,
// no platform-specific imports — works on both the VM and the web. The CLI
// shell at `tool/generate_test_token.dart` wraps this function with arg
// parsing and stdout printing.
//
// NOT a production token minter — local development only. Production
// systems should mint tokens on a server you control. See
// `example/supabase/functions/zego-token/` and
// `example/functions/src/zegoToken.ts` for reference implementations.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Generates a ZEGO `token04` string.
///
/// Algorithm (as documented by ZEGOCLOUD and implemented by their official
/// `zego-server-assistant` npm package):
///
///  1. Build a JSON payload:
///       { "app_id", "user_id", "nonce", "ctime", "expire", "payload" }
///     The plaintext is the utf8-encoded JSON string — NOT prefixed with any
///     length or timestamp fields.
///
///  2. Encrypt with AES-128-CBC + PKCS#7 padding, using:
///       - key: the first 16 bytes of [serverSecret] (as utf8 bytes)
///       - iv:  a random 16-byte nonce
///
///  3. Build a binary buffer:
///       expire (8 bytes i64 BE)
///       iv_length (2 bytes u16 BE) = 16
///       iv (16 bytes)
///       cipher_length (2 bytes u16 BE)
///       cipher (N bytes)
///
///  4. Return: the literal prefix "04" concatenated with the base64 of that
///     buffer. The "04" is OUTSIDE the base64, not part of the base64 payload.
String generateToken04({
  required int appId,
  required String userId,
  required String serverSecret,
  int effectiveTimeInSeconds = 86400,
}) {
  if (serverSecret.length < 16) {
    throw ArgumentError.value(
      serverSecret,
      'serverSecret',
      'must be at least 16 bytes (ZEGO server secrets are 32)',
    );
  }

  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final expire = now + effectiveTimeInSeconds;
  final rng = Random.secure();
  // Pick a random 31-bit nonce so it always fits in a positive i64.
  final nonce = rng.nextInt(0x7fffffff);

  final payloadMap = <String, dynamic>{
    'app_id': appId,
    'user_id': userId,
    'nonce': nonce,
    'ctime': now,
    'expire': expire,
    'payload': '',
  };
  final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(payloadMap)));

  final iv = Uint8List.fromList(
    List<int>.generate(16, (_) => rng.nextInt(256)),
  );
  final keyBytes = Uint8List.fromList(
    utf8.encode(serverSecret).sublist(0, 16),
  );

  final cipher = _aesCbcPkcs7Encrypt(
    key: keyBytes,
    iv: iv,
    plaintext: plaintext,
  );

  // Buffer layout: expire(8) + ivLen(2) + iv(16) + cipherLen(2) + cipher(N)
  final buf = BytesBuilder()
    ..add(_int64BE(expire))
    ..add(_uint16BE(iv.length))
    ..add(iv)
    ..add(_uint16BE(cipher.length))
    ..add(cipher);

  return '04${base64.encode(buf.toBytes())}';
}

Uint8List _int64BE(int value) {
  final b = ByteData(8);
  b.setInt64(0, value, Endian.big);
  return b.buffer.asUint8List();
}

Uint8List _uint16BE(int value) {
  final b = ByteData(2);
  b.setUint16(0, value, Endian.big);
  return b.buffer.asUint8List();
}

/// AES-128-CBC with PKCS#7 padding via pointycastle. ZEGO's server-side
/// token verifier expects this exact scheme — GCM and unpadded CBC are both
/// rejected with `50120 token format err`.
Uint8List _aesCbcPkcs7Encrypt({
  required Uint8List key,
  required Uint8List iv,
  required Uint8List plaintext,
}) {
  assert(key.length == 16, 'AES-128 key must be exactly 16 bytes');
  assert(iv.length == 16, 'IV must be exactly 16 bytes');
  final cipher = PaddedBlockCipher('AES/CBC/PKCS7')
    ..init(
      true, // forEncryption
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );
  return cipher.process(plaintext);
}
