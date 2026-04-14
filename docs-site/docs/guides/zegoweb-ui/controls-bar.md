---
sidebar_position: 5
title: Controls Bar
---

# Controls Bar

The `ZegoControlsBar` appears at the bottom of the call screen during an active call.

## Default controls

- **Microphone toggle** — mute/unmute with device selection dropdown
- **Camera toggle** — enable/disable with device selection dropdown
- **Hang up** — leave the call (red pill button)

## Button styles

Controls come in two shapes:

- **`ZegoControlPill`** — rounded pill shape, used for the main action buttons
- **`ZegoControlCircle`** — circular, used for secondary actions

## Device selection

Clicking the dropdown arrow on the mic or camera button opens a `ZegoDevicePopover` showing all available devices. Selecting a device switches the active input immediately.

## Layout

The controls bar follows a toolbar layout:
- **Center:** Main control buttons (mic, camera, hang up)
- Buttons are evenly spaced with consistent sizing
