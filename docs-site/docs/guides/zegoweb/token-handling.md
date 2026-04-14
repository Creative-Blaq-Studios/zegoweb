---
sidebar_position: 3
title: Token Handling
---

# Token Handling

Tokens authenticate users with ZEGOCLOUD's servers. The zegoweb plugin manages the token lifecycle — you provide the fetch logic.

## How it works

1. You supply a `tokenProvider` callback in `ZegoEngineConfig`
2. On `loginRoom()`, the plugin calls your `tokenProvider` to get an initial token
3. When the token is about to expire, the JS SDK fires `tokenWillExpire`
4. The plugin calls your `tokenProvider` again and passes the fresh token to the SDK

```dart
ZegoEngineConfig(
  appId: 123456789,
  server: 'wss://webliveroom-api.zego.im/ws',
  tokenProvider: () async {
    // Called on login AND on token refresh
    final response = await http.get(Uri.parse('https://my-api.com/zego-token'));
    return response.body;
  },
)
```

---

## Development patterns

### 1. AppSign mode (empty token)

If your ZEGOCLOUD project uses AppSign / test mode authentication, `loginRoom` accepts an empty token. Fastest path for local development.

```dart
tokenProvider: () async => '',
```

Not suitable for production. Switch your project to Token auth before shipping.

### 2. Console token (paste-in)

The ZEGOCLOUD console has a **temporary token generator** (24h expiry). Paste the generated token while prototyping:

```dart
tokenProvider: () async => 'kZDJ... (paste from console)',
```

### 3. Local CLI token

Generate a test token from the command line using the included Dart tool:

```bash
dart run tool/generate_test_token.dart --user-id user-1 [--ttl 86400]
```

Reads `ZEGO_APP_ID` and `ZEGO_SERVER_SECRET` from a local `.env` file. See [`tool/generate_test_token.dart`](https://github.com/Creative-Blaq-Studios/zegoweb/blob/main/packages/zegoweb/tool/generate_test_token.dart) for the implementation.

:::danger Development only
Options 1-3 all require your ServerSecret on the client or are time-limited. Never ship your ServerSecret in client code. Use a server-side function (below) in production.
:::

---

## Production: server-side token generation

In production, mint tokens on a backend endpoint that the client calls with its authenticated session. Two reference implementations are included in the repo.

### Supabase Edge Function (Deno)

A complete implementation using the Web Crypto API (no npm dependencies). Implements the ZEGO `token04` algorithm directly.

```ts
// supabase/functions/zego-token/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const APP_ID = parseInt(Deno.env.get('ZEGO_APP_ID') ?? '0', 10)
const SERVER_SECRET = Deno.env.get('ZEGO_SERVER_SECRET') ?? ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? ''

function int64BE(n: number | bigint): Uint8Array {
  const buf = new ArrayBuffer(8)
  new DataView(buf).setBigInt64(0, BigInt(n), false)
  return new Uint8Array(buf)
}

async function generateToken04(
  appId: number,
  userId: string,
  serverSecret: string,
  ttlSeconds = 3600,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const expire = now + ttlSeconds
  const nonce = (crypto.getRandomValues(new Uint32Array(1))[0] | 0) ^ now

  const payload = {
    app_id: appId,
    user_id: userId,
    nonce,
    ctime: now,
    expire,
    payload: '',
  }
  const payloadBytes = new TextEncoder().encode(JSON.stringify(payload))

  const plaintext = new Uint8Array(16 + payloadBytes.length)
  plaintext.set(int64BE(expire), 0)
  plaintext.set(int64BE(nonce), 8)
  plaintext.set(payloadBytes, 16)

  const keyBytes = new TextEncoder().encode(serverSecret).slice(0, 16)
  const key = await crypto.subtle.importKey(
    'raw', keyBytes, { name: 'AES-GCM' }, false, ['encrypt'],
  )

  const iv = crypto.getRandomValues(new Uint8Array(16))
  const ct = new Uint8Array(
    await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, plaintext),
  )

  const out = new Uint8Array(2 + iv.length + ct.length)
  out.set(new TextEncoder().encode('04'), 0)
  out.set(iv, 2)
  out.set(ct, 2 + iv.length)

  let bin = ''
  for (const b of out) bin += String.fromCharCode(b)
  return btoa(bin)
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    })
  }

  // Verify Supabase JWT
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return Response.json({ error: 'unauthorized' }, { status: 401 })
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  })
  const { data, error } = await supabase.auth.getUser()
  if (error || !data.user) {
    return Response.json({ error: 'invalid token' }, { status: 401 })
  }

  const token = await generateToken04(APP_ID, data.user.id, SERVER_SECRET)
  return Response.json({ token })
})
```

**Deploy:**
```bash
supabase functions deploy zego-token --no-verify-jwt
```

**Client-side usage:**
```dart
tokenProvider: () async {
  final res = await supabase.functions.invoke('zego-token');
  return (res.data as Map)['token'] as String;
},
```

---

### Firebase Callable Function (Node.js)

Uses the official `zego-server-assistant` npm package with Firebase secrets.

```ts
// functions/src/zegoToken.ts

import { onCall, HttpsError } from 'firebase-functions/v2/https'
import { defineSecret } from 'firebase-functions/params'
import { generateToken04 } from 'zego-server-assistant'

const ZEGO_APP_ID = defineSecret('ZEGO_APP_ID')
const ZEGO_SERVER_SECRET = defineSecret('ZEGO_SERVER_SECRET')

export const zegoToken = onCall(
  { secrets: [ZEGO_APP_ID, ZEGO_SERVER_SECRET] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.')
    }

    const userId = request.data?.userId ?? request.auth.uid
    const ttl = Math.min(
      Math.max(request.data?.effectiveTimeInSeconds ?? 3600, 60),
      86400,
    )

    const appId = Number.parseInt(ZEGO_APP_ID.value(), 10)
    const serverSecret = ZEGO_SERVER_SECRET.value()
    if (!appId || !serverSecret) {
      throw new HttpsError('failed-precondition', 'ZEGO secrets not configured.')
    }

    const token = generateToken04(appId, userId, serverSecret, ttl, '')
    return { token }
  },
)
```

**Setup:**
```bash
npm install zego-server-assistant
firebase functions:secrets:set ZEGO_APP_ID
firebase functions:secrets:set ZEGO_SERVER_SECRET
firebase deploy --only functions:zegoToken
```

**Client-side usage:**
```dart
tokenProvider: () async {
  final callable = FirebaseFunctions.instance.httpsCallable('zegoToken');
  final result = await callable.call();
  return result.data['token'] as String;
},
```

---

### Node.js / Express (generic)

If you're running your own Node.js server:

```ts
import express from 'express'
import { generateToken04 } from 'zego-server-assistant'

const app = express()
app.use(express.json())

const APP_ID = parseInt(process.env.ZEGO_APP_ID!)
const SERVER_SECRET = process.env.ZEGO_SERVER_SECRET!

app.post('/api/zego-token', (req, res) => {
  // Add your own auth middleware here
  const { userId } = req.body
  const token = generateToken04(APP_ID, userId, SERVER_SECRET, 3600, '')
  res.json({ token })
})

app.listen(3000)
```

**Install:** `npm install zego-server-assistant`

**Client-side usage:**
```dart
tokenProvider: () async {
  final response = await dio.post('https://my-api.com/api/zego-token', data: {
    'userId': currentUser.id,
  });
  return response.data['token'] as String;
},
```

---

### Dart Server (shelf)

If your backend is also Dart, you can use the same `generateToken04` algorithm that ships with `zegoweb`:

```dart
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:zegoweb/src/internal/token_generator.dart';

final appId = int.parse(Platform.environment['ZEGO_APP_ID']!);
final serverSecret = Platform.environment['ZEGO_SERVER_SECRET']!;

shelf.Response handleToken(shelf.Request request) {
  // Add your own auth middleware here
  final userId = request.url.queryParameters['userId']!;

  final token = generateToken04(
    appId: appId,
    userId: userId,
    serverSecret: serverSecret,
    effectiveTimeInSeconds: 3600,
  );

  return shelf.Response.ok(
    '{"token":"$token"}',
    headers: {'Content-Type': 'application/json'},
  );
}

void main() async {
  final handler = const shelf.Pipeline()
      .addHandler(handleToken);
  await io.serve(handler, 'localhost', 8080);
}
```

**Client-side usage:**
```dart
tokenProvider: () async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/?userId=${currentUser.id}'),
  );
  return jsonDecode(response.body)['token'] as String;
},
```

---

## Summary

| Pattern | Use case | Security |
|---|---|---|
| Empty token (AppSign) | Quick local dev | No auth |
| Console token | Demos, short experiments | 24h expiry, manual |
| CLI tool | CI, integration tests | Requires .env with secret |
| **Supabase Edge Function** | **Production** | JWT-verified, serverless |
| **Firebase Callable** | **Production** | Firebase Auth, serverless |
| **Node.js / Express** | **Production** | Your own auth middleware |
| **Dart server** | **Production** | Your own auth middleware |
