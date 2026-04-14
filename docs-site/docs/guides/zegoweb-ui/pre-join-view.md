---
sidebar_position: 4
title: Pre-Join View
---

# Pre-Join View

Before joining a call, `ZegoCallScreen` shows a pre-join view where users can:

- Preview their camera feed
- Select camera and microphone devices
- Toggle camera/mic on or off before joining
- See their display name
- Click "Join" to enter the call

## How it works

The pre-join view is shown automatically as part of the `ZegoCallScreen` lifecycle. When the call state is `preJoin`:

1. The JS SDK is loaded (if not already)
2. A `ZegoEngine` is created
3. A local preview stream is captured
4. Camera and microphone device lists are populated
5. The user sees their video preview with device selection controls

When the user clicks "Join", the state transitions to `connecting` then `connected`.

## Layout

The pre-join view uses a split layout:
- **Left side:** Camera preview with overlaid mute/camera toggle controls
- **Right side:** Room info and join button
- **Below preview:** Device selection chips for camera and microphone
