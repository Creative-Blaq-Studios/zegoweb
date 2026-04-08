// packages/zegoweb/example/functions/src/zegoToken.ts
//
// Reference Firebase Callable Function — mints ZEGO token04 for
// authenticated callers via the official zego-server-assistant npm package.
// NOT shipped with the plugin; copy into your own Firebase project.
//
// Deploy:
//   firebase deploy --only functions:zegoToken

import { onCall, HttpsError } from 'firebase-functions/v2/https'
import { defineSecret } from 'firebase-functions/params'
import { generateToken04 } from 'zego-server-assistant'

const ZEGO_APP_ID = defineSecret('ZEGO_APP_ID')
const ZEGO_SERVER_SECRET = defineSecret('ZEGO_SERVER_SECRET')

interface ZegoTokenRequest {
  /** Optional override; defaults to the authenticated Firebase uid. */
  userId?: string
  /** Optional TTL in seconds (default 3600, max 86400). */
  effectiveTimeInSeconds?: number
}

interface ZegoTokenResponse {
  token: string
}

export const zegoToken = onCall<ZegoTokenRequest, Promise<ZegoTokenResponse>>(
  { secrets: [ZEGO_APP_ID, ZEGO_SERVER_SECRET] },
  async (request) => {
    const auth = request.auth
    if (!auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.')
    }

    const userId = request.data?.userId ?? auth.uid
    const ttl = Math.min(
      Math.max(request.data?.effectiveTimeInSeconds ?? 3600, 60),
      86400,
    )

    const appId = Number.parseInt(ZEGO_APP_ID.value(), 10)
    const serverSecret = ZEGO_SERVER_SECRET.value()
    if (!appId || !serverSecret) {
      throw new HttpsError(
        'failed-precondition',
        'ZEGO secrets not configured.',
      )
    }

    const token = generateToken04(appId, userId, serverSecret, ttl, '')
    return { token }
  },
)
