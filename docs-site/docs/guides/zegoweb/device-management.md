---
sidebar_position: 2
title: Device Management
---

# Device Management

Enumerate and switch cameras, microphones, and speakers at runtime.

## List available devices

```dart
final cameras = await engine.getCameras();
final mics = await engine.getMicrophones();

for (final cam in cameras) {
  print('${cam.deviceName} (${cam.deviceId})');
}
```

Each returns a `List<ZegoDeviceInfo>` with `deviceId` and `deviceName`.

## Switch devices

```dart
// Switch camera
await engine.useVideoDevice(cameras[1].deviceId);

// Switch microphone
await engine.useAudioDevice(mics[1].deviceId);
```

The stream updates in-place — no need to republish.

## Mute/unmute

```dart
// Mute microphone (stops sending audio, keeps the stream active)
await engine.muteAudio(true);

// Mute camera (stops sending video, keeps the stream active)
await engine.muteVideo(true);

// Unmute
await engine.muteAudio(false);
await engine.muteVideo(false);
```

## Enable/disable camera

```dart
// Disable camera entirely (remote side sees a black frame or no video track)
await engine.enableCamera(false);

// Re-enable
await engine.enableCamera(true);
```

The difference between `muteVideo` and `enableCamera`:
- `muteVideo(true)` keeps the video track active but sends empty frames
- `enableCamera(false)` removes the video track entirely
