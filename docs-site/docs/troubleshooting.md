---
sidebar_position: 5
title: Troubleshooting
---

# Troubleshooting

## Common Issues

### "ZegoStateError: Secure context required"

**Cause:** The page is not served over HTTPS or localhost.

**Fix:** Use `flutter run -d chrome` (serves on localhost) or deploy with HTTPS. The browser requires a secure context for camera/mic access.

### "ZegoPermissionException: denied"

**Cause:** The user denied camera or microphone access in the browser.

**Fix:**
1. Click the camera icon in the browser's address bar
2. Reset permissions for the site
3. Reload the page

### "ZegoPermissionException: notFound"

**Cause:** No camera or microphone hardware detected.

**Fix:** Ensure a camera/mic is connected. Check browser settings to confirm the devices are not disabled.

### "ZegoPermissionException: inUse"

**Cause:** Another application or browser tab is using the camera/mic exclusively.

**Fix:** Close other apps or tabs that may be using the camera. Some devices don't support shared access.

### JS SDK not loading

**Cause:** The ZEGO JavaScript SDK script failed to load.

**Possible fixes:**
- Check your network connection
- If using a `<script>` tag, verify the URL is correct and the version exists on unpkg
- If using dynamic injection, check the browser console for errors
- Check if your Content Security Policy (CSP) blocks the CDN domain

### Content Security Policy (CSP) errors

**Cause:** Your CSP header blocks loading scripts from unpkg.com or connecting to ZEGO's WebSocket servers.

**Fix:** Add these to your CSP:
```
script-src 'self' https://unpkg.com;
connect-src 'self' wss://webliveroom-api.zego.im;
```

### Token errors

**Cause:** Token is invalid, expired, or generated with wrong parameters.

**Checklist:**
- Is the AppID correct?
- Is the token generated for the correct userId?
- Has the token expired? (Default TTL is typically 1 hour)
- For test tokens: is the ServerSecret correct?
- For production: is your backend returning a fresh token?

### No remote video after joining

**Cause:** Multiple possible causes.

**Checklist:**
1. Are you listening to `onRoomStreamUpdate` **before** calling `loginRoom()`?
2. Are you calling `startPlaying(streamId)` for each new stream?
3. Is the remote user actually publishing? Check `onRoomUserUpdate` to confirm they joined.
4. Is the stream being rendered with `ZegoVideoView`?

## Browser Compatibility

### Safari

- The Permissions API (`navigator.permissions.query`) is not available. `zegoweb` returns `ZegoPermissionStatus.prompt` as a safe default.
- Safari may require user interaction (a click/tap) before allowing camera/mic access.
- Screen sharing requires Safari 13+.

### Firefox

- Generally well supported.
- Some older versions may not support all video codecs. Use `ZegoScenario.communication` for best compatibility.

### Mobile browsers

- These packages are **web only** — they work in mobile browsers (Chrome for Android, Safari for iOS) but are not optimized for mobile viewports.
- For native mobile apps, use the official [`zego_express_engine`](https://pub.dev/packages/zego_express_engine) package.
