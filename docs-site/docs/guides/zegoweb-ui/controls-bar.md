---
sidebar_position: 5
title: Controls Bar
---

# Controls Bar

The `ZegoControlsBar` appears at the bottom of the call screen during an active call.

## Default controls

- **Microphone toggle** — mute/unmute with device selection dropdown
- **Camera toggle** — enable/disable with device selection dropdown
- **Layout picker** — opens the "Adjust view" dialog for switching layouts, adjusting tile size, and toggling visibility of camera-off tiles
- **Hang up** — leave the call (red pill button)
- **Settings** — audio processing settings (AEC, ANS, AGC)

## Button styles

Controls come in two shapes:

- **`ZegoControlPill`** — rounded pill shape, used for the main action buttons (mic, camera)
- **`ZegoControlCircle`** — circular, used for secondary actions (layout, settings)

## Device selection

Clicking the dropdown arrow on the mic or camera button opens a `ZegoDevicePopover` showing all available devices. Selecting a device switches the active input immediately.

## Layout picker

Tapping the grid icon opens a `ZegoLayoutPickerDialog` — a floating dialog with:

- Radio list of all 6 layout modes
- Tile size slider (grid columns 2–6)
- "Hide tiles without video" toggle

The dialog stays open and updates live as you change settings.

Disable the layout picker button:

```dart
ZegoCallConfig(showLayoutPicker: false)
```

## Layout

The controls bar follows a toolbar layout:
- **Center:** Main control buttons (mic, camera, layout, hang up, settings)
- Optional **leading** and **trailing** builders for custom widgets on each side
