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
/// Matches the official Node reference at
/// https://github.com/ZEGOCLOUD/zego_server_assistant/blob/master/token/nodejs/server/zegoServerAssistant.js
/// byte-for-byte:
///
///  1. JSON payload:
///       { "app_id", "user_id", "nonce", "ctime", "expire", "payload" }
///
///  2. AES-CBC + PKCS#7 padding with the FULL [serverSecret] as the key.
///     The cipher variant is chosen by key length (matching Node's
///     createCipheriv):
///       - 16-byte secret → AES-128-CBC
///       - 24-byte secret → AES-192-CBC
///       - 32-byte secret → AES-256-CBC  (this is what ZEGO issues by default)
///
///  3. The IV is 16 printable ASCII characters drawn uniformly from
///     `0123456789abcdefghijklmnopqrstuvwxyz`. The reference impl has always
///     shipped ASCII IVs — emitting raw random bytes gets the token rejected
///     with `50120 token format err`.
///
///  4. Binary buffer layout:
///       expire        (8 bytes i64 BE)
///       ivLength      (2 bytes u16 BE) = 16
///       iv            (16 bytes)
///       cipherLength  (2 bytes u16 BE)
///       cipher        (N bytes, multiple of 16)
///
///  5. Token = literal "04" + base64(buffer). The "04" is OUTSIDE the base64.
String generateToken04({
  required int appId,
  required String userId,
  required String serverSecret,
  int effectiveTimeInSeconds = 86400,
}) {
  final keyBytes = Uint8List.fromList(utf8.encode(serverSecret));
  if (keyBytes.length != 16 && keyBytes.length != 24 && keyBytes.length != 32) {
    throw ArgumentError.value(
      serverSecret,
      'serverSecret',
      'must be exactly 16, 24, or 32 bytes '
          '(ZEGO server secrets are 32 — got ${keyBytes.length})',
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

  // 16 printable ASCII chars from the reference impl's alphabet.
  const ivAlphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
  final ivString = String.fromCharCodes(
    List<int>.generate(
      16,
      (_) => ivAlphabet.codeUnitAt(rng.nextInt(ivAlphabet.length)),
    ),
  );
  final iv = Uint8List.fromList(utf8.encode(ivString));

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

/// AES-CBC with PKCS#7 padding via pointycastle. The key length determines
/// the cipher variant (128/192/256). ZEGO's server-side token verifier
/// expects this exact scheme — GCM and unpadded CBC are both rejected with
/// `50120 token format err`.
Uint8List _aesCbcPkcs7Encrypt({
  required Uint8List key,
  required Uint8List iv,
  required Uint8List plaintext,
}) {
  assert(
    key.length == 16 || key.length == 24 || key.length == 32,
    'AES key must be 16, 24, or 32 bytes',
  );
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
