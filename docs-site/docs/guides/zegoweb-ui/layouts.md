---
sidebar_position: 2
title: Layouts
---

# Layouts

`zegoweb_ui` provides six layout modes for arranging participant video tiles, plus an **Auto** mode that dynamically selects the best layout.

## Grid Layout

All participants displayed in a responsive grid that reflows based on count:

- 1 participant: full screen
- 2 participants: side by side
- 3-4 participants: 2x2 grid
- 5+ participants: wrapping grid

The grid supports a **tile size slider** (available in the layout picker dialog) that lets users control the number of columns (2–6).

```dart
ZegoCallConfig(layout: ZegoLayoutMode.grid)
```

## Sidebar Layout

One participant (the active speaker or a pinned user) takes up the main area. Other participants appear in a smaller sidebar strip on the right.

```dart
ZegoCallConfig(layout: ZegoLayoutMode.sidebar)
```

## PiP (Picture-in-Picture) Layout

The local user's video appears as a small floating overlay on top of the remote participant's full-screen video. The overlay is draggable and snaps to the nearest corner. Best for 1:1 calls.

The floating tile has a drop shadow for visual separation from the background.

```dart
ZegoCallConfig(layout: ZegoLayoutMode.pip)
```

## Spotlight Layout

Only the active speaker is shown full-screen. All other participants are hidden. The cleanest, most focused view.

If a participant is pinned, the pinned participant is shown regardless of who is speaking.

```dart
ZegoCallConfig(layout: ZegoLayoutMode.spotlight)
```

## Gallery Layout

A large speaker tile occupies most of the screen, with a horizontal filmstrip of thumbnails at the bottom for remaining participants. The filmstrip scrolls horizontally when there are many participants.

```dart
ZegoCallConfig(layout: ZegoLayoutMode.gallery)
```

## Auto Layout

Dynamically selects the best layout based on the current state:

| Condition | Layout selected |
|---|---|
| 1 participant | Spotlight |
| 2 participants | PiP |
| 3–6 participants | Grid |
| 7+ participants | Sidebar |
| Screen sharing active | Sidebar |

This is the **default layout**. Users can override it by manually selecting a layout from the picker.

```dart
ZegoCallConfig(layout: ZegoLayoutMode.auto)
```

## Layout Picker Dialog

During a call, users can open the layout picker by tapping the grid icon in the controls bar. This opens a Google Meet-style "Adjust view" dialog with:

- **Layout selection** — radio list of all 6 layouts
- **Tile size slider** — controls grid column count (2–6), only active in Grid/Auto mode
- **Hide tiles without video** — toggle to hide participants with camera off

The layout picker is enabled by default. Disable it with:

```dart
ZegoCallConfig(showLayoutPicker: false)
```

## Pin Participant

Long-press any participant tile to pin them. A pinned participant always occupies the main/large position in Sidebar, Gallery, PiP, and Spotlight layouts, overriding active speaker detection.

A small "📌 Unpin" chip appears on the pinned tile. Tap it or long-press again to unpin.

## Switching layouts programmatically

Use `ZegoCallController` to switch layouts at runtime:

```dart
controller.switchLayout(ZegoLayoutMode.gallery);
```

Other layout controls:

```dart
controller.setGridColumns(4);          // set tile size (2–6 columns)
controller.setHideNoVideoTiles(true);  // hide camera-off tiles
controller.pinParticipant('user-id');  // pin a participant
controller.pinParticipant(null);       // unpin
```
