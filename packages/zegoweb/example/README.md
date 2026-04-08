# zegoweb example

Minimal 1:1 call demo for the `zegoweb` plugin.

> Unofficial community plugin. Not affiliated with or endorsed by ZEGOCLOUD.
> Wraps the official `zego-express-engine-webrtc` JavaScript SDK.

## Running

```bash
cd packages/zegoweb/example
flutter run -d chrome
```

Fill in your ZEGOCLOUD **App ID**, **server URL**, a room ID, a user ID, and a
token (see below for how to get one). Click **Join**.

## Token sources

`zegoweb` takes a `tokenProvider: Future<String> Function()` in
`ZegoEngineConfig`. The plugin calls it once on login, then again automatically
whenever the SDK signals `tokenWillExpire`. You write the fetch logic once and
the plugin handles the refresh loop.

Three patterns, ordered from quick-and-dirty to production.

### 1. Dev mode — AppSign / test mode (no backend, no token)

If you configure your ZEGOCLOUD project for AppSign / test mode, `loginRoom`
accepts an empty token. This is the fastest path for local development.

```dart
tokenProvider: () async => '',
```

Not suitable for production. Switch your project to Token auth and pick a
pattern below before shipping.

### 2. Temporary console token (paste-in)

The ZEGOCLOUD console has a **temporary token generator** (24h expiry). Paste
the generated token into the example app's token field, or hardcode it while
prototyping:

```dart
tokenProvider: () async => 'kZDJ... (paste here)',
```

Good for demos and short local experiments. The plugin will try to refresh
it at expiry — if you want it to survive that you need a real provider.

Alternatively, generate one locally from a `.env` file:

```bash
dart run tool/generate_test_token.dart --user-id user-1
```

See [`../tool/generate_test_token.dart`](../tool/generate_test_token.dart)
for the implementation.

### 3. Production — serverless function

Mint tokens on a short-lived server endpoint the client can call with its
authenticated session. Two reference implementations are included:

- **Supabase Edge Function (Deno)** — [`supabase/functions/zego-token/index.ts`](supabase/functions/zego-token/index.ts)
  Deploy with:
  ```bash
  supabase functions deploy zego-token --no-verify-jwt
  ```
  Auth via the Supabase JWT in the `Authorization` header.

- **Firebase Callable Function (Node)** — [`functions/src/zegoToken.ts`](functions/src/zegoToken.ts)
  Uses the official `zego-server-assistant` npm package plus
  `defineSecret('ZEGO_SERVER_SECRET')`.
  Deploy with:
  ```bash
  firebase deploy --only functions:zegoToken
  ```
  Auth via `context.auth`.

In both cases, your client-side `tokenProvider` becomes a single HTTPS call:

```dart
tokenProvider: () async {
  final res = await supabase.functions.invoke('zego-token');
  return (res.data as Map)['token'] as String;
},
```

Neither function is shipped inside the plugin package itself — they are
reference snippets only. Copy, adapt, deploy.

## Integration test

A single real-SDK smoke test lives at
[`integration_test/real_sdk_smoke_test.dart`](integration_test/real_sdk_smoke_test.dart).
It is gated by environment variables so default CI doesn't require credentials.

```bash
flutter test integration_test/real_sdk_smoke_test.dart -d chrome \
  --dart-define=ZEGO_APP_ID=123456789 \
  --dart-define=ZEGO_SERVER=wss://webliveroom-api.zego.im/ws \
  --dart-define=ZEGO_TOKEN=$(dart run ../tool/generate_test_token.dart --user-id ci-bot)
```
