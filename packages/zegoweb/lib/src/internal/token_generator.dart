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
/// Algorithm (as published by ZEGOCLOUD for token04):
///  1. Build a JSON payload:
///       { "app_id", "user_id", "nonce", "ctime", "expire", "payload" }
///  2. Concatenate: [expire i64 BE (8)] + [nonce i64 BE (8)] + [payload bytes]
///     (the "plain text" for encryption).
///  3. Encrypt with AES-128-GCM using the first 16 bytes of [serverSecret] as
///     the key and a random 16-byte IV.
///  4. Token = base64( "04" + iv(16) + ciphertext+tag ).
///
/// AES-128-GCM is provided by `package:pointycastle` (pure Dart, sync).
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
  final payloadJson = utf8.encode(jsonEncode(payloadMap));

  // [expire BE i64] + [nonce BE i64] + [payloadJson]
  final plainText = BytesBuilder()
    ..add(_int64BE(expire))
    ..add(_int64BE(nonce))
    ..add(payloadJson);

  final iv = Uint8List.fromList(
    List<int>.generate(16, (_) => rng.nextInt(256)),
  );
  final keyBytes = Uint8List.fromList(
    utf8.encode(serverSecret).sublist(0, 16),
  );

  final ciphertextAndTag = _aesGcmEncrypt(
    key: keyBytes,
    iv: iv,
    plaintext: plainText.toBytes(),
  );

  final out = BytesBuilder()
    ..add(utf8.encode('04'))
    ..add(iv)
    ..add(ciphertextAndTag);

  return base64.encode(out.toBytes());
}

Uint8List _int64BE(int value) {
  final b = ByteData(8);
  b.setInt64(0, value, Endian.big);
  return b.buffer.asUint8List();
}

/// Real AES-128-GCM via pointycastle. Returns ciphertext concatenated with the
/// 16-byte authentication tag (the standard GCM output layout that ZEGO's
/// server-side libraries also produce and that their backend expects).
Uint8List _aesGcmEncrypt({
  required Uint8List key,
  required Uint8List iv,
  required Uint8List plaintext,
}) {
  assert(key.length == 16, 'AES-128 key must be exactly 16 bytes');
  assert(iv.length == 16, 'IV must be exactly 16 bytes');
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      true, // forEncryption
      AEADParameters(
        KeyParameter(key),
        128, // tag length in bits
        iv,
        Uint8List(0), // no associated data
      ),
    );
  return cipher.process(plaintext);
}
