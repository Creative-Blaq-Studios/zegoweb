// packages/zegoweb/example/supabase/functions/zego-token/index.ts
//
// Reference Supabase Edge Function — mints ZEGO token04 for authenticated
// callers. NOT shipped as part of the plugin; copy into your own Supabase
// project and adapt.
//
// Deploy:
//   supabase functions deploy zego-token --no-verify-jwt
// (We verify the Supabase JWT manually below so we can return a typed 401.)

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const APP_ID = parseInt(Deno.env.get('ZEGO_APP_ID') ?? '0', 10)
const SERVER_SECRET = Deno.env.get('ZEGO_SERVER_SECRET') ?? ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? ''

if (!APP_ID || !SERVER_SECRET) {
  console.error('ZEGO_APP_ID and ZEGO_SERVER_SECRET must be set')
}

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function json(body: unknown, init: ResponseInit = {}): Response {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  })
}

function int64BE(n: number | bigint): Uint8Array {
  const buf = new ArrayBuffer(8)
  new DataView(buf).setBigInt64(0, BigInt(n), false)
  return new Uint8Array(buf)
}

/**
 * ZEGO token04 algorithm.
 * Layout:
 *   plaintext = expire(i64 BE) + nonce(i64 BE) + utf8(JSON payload)
 *   ciphertext = AES-128-GCM(key=first 16 bytes of serverSecret, iv=random 16 bytes)
 *   token = base64("04" + iv + ciphertext+tag)
 */
async function generateToken04(
  appId: number,
  userId: string,
  serverSecret: string,
  ttlSeconds = 3600,
): Promise<string> {
  if (serverSecret.length < 16) {
    throw new Error('serverSecret must be >= 16 bytes')
  }

  const now = Math.floor(Date.now() / 1000)
  const expire = now + ttlSeconds
  const nonce =
    (crypto.getRandomValues(new Uint32Array(1))[0] | 0) ^ now

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
    'raw',
    keyBytes,
    { name: 'AES-GCM' },
    false,
    ['encrypt'],
  )

  const iv = crypto.getRandomValues(new Uint8Array(16))
  const ctBuf = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    plaintext,
  )
  const ct = new Uint8Array(ctBuf)

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
    return new Response('ok', { headers: CORS_HEADERS })
  }
  if (req.method !== 'POST') {
    return json({ error: 'method not allowed' }, { status: 405 })
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return json({ error: 'missing Authorization header' }, { status: 401 })
  }

  // Verify the Supabase JWT
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  })
  const { data: userRes, error: userErr } = await supabase.auth.getUser()
  if (userErr || !userRes.user) {
    return json({ error: 'invalid token' }, { status: 401 })
  }

  try {
    const token = await generateToken04(
      APP_ID,
      userRes.user.id,
      SERVER_SECRET,
      3600,
    )
    return json({ token })
  } catch (e) {
    console.error(e)
    return json({ error: String(e) }, { status: 500 })
  }
})
