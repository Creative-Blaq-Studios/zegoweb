# Layout Picker Dialog & Extended Layouts

**Date:** 2026-04-15
**Package:** `zegoweb_ui`
**Status:** Approved

## Summary

Replace the current layout cycle button with a Google Meet-style "Adjust view" dialog. Add three new layouts (Spotlight, Gallery, Auto), a tile size slider, a hide-no-video toggle, participant pinning, and move the mic indicator into the name chip. Also add a drop shadow to the PiP floating tile.

## Layout Picker Dialog

### Widget: `ZegoLayoutPickerDialog`

A floating dialog anchored near the layout button in the controls bar. Opens when the user taps the existing grid icon (replaces the cycle-through behavior). Closes on tap outside or the X button.

### Contents (top to bottom)

1. **Header** — "Adjust view" title + close (X) button
2. **Layout radio list** — 6 options, each with a label and small thumbnail icon:
   - Grid
   - Sidebar
   - Picture-in-picture
   - Spotlight *(new)*
   - Gallery *(new)*
   - Auto *(new)*
3. **Divider**
4. **Tile size slider** — controls grid column count (2–6). Disabled when a non-grid layout is selected.
5. **"Hide tiles without video" toggle** — hides camera-off participants. Works across all layouts.

### Styling

Follows the existing `ZegoCallTheme` dark theme. Rounded corners (12px), subtle box shadow, semi-transparent scrim behind the dialog.

## New Layouts

### Spotlight (`ZegoSpotlightLayout`)

- Renders only the active speaker full-screen (or the first participant if no active speaker is detected).
- No other tiles are visible.
- When the active speaker changes, the view transitions to the new speaker.
- If a participant is pinned, the pinned participant is shown regardless of active speaker.

### Gallery (`ZegoGalleryLayout`)

- Large speaker tile takes approximately 80% of vertical space.
- Horizontal filmstrip row at the bottom with thumbnail tiles for remaining participants.
- Filmstrip scrolls horizontally when participants exceed available width.
- Active speaker (or pinned participant) occupies the large tile.

### Auto Layout (Controller Logic)

Not a separate layout widget. Logic in `ZegoCallController` that auto-selects a layout:

| Condition | Layout selected |
|---|---|
| 1 participant | Spotlight |
| 2 participants | PiP |
| 3–6 participants | Grid |
| 7+ participants | Sidebar |
| Screen sharing active | Sidebar |

When the user manually picks a layout from the dialog, Auto mode is exited. Selecting "Auto" again re-enables it.

### `ZegoLayoutMode` Enum

```dart
enum ZegoLayoutMode {
  grid,
  sidebar,
  pip,
  spotlight,  // new
  gallery,    // new
  auto,       // new
}
```

## Tile Controls

### Tile Size Slider

- Stored as `gridColumns` (`int?`) on the controller. Null means auto-calculated (current `gridReflow` behavior).
- Range: 2–6 columns.
- Only affects Grid layout. Slider is visually disabled for other layouts.
- When the user drags the slider, it overrides auto-calculation.
- Resets on `leave()`.

### Hide Tiles Without Video

- Boolean `hideNoVideoTiles` on the controller (default: value from `ZegoCallConfig.hideNoVideoTiles`).
- Filters the participants list before passing to layout widgets.
- Removes participants where `stream == null` and `isCameraOff == true`.
- Never hides the local participant.
- Works across all layouts.

### Pin Participant

- Long-press or right-click a participant tile to pin them.
- Pinned participant always occupies the "main" position in Sidebar, Gallery, PiP, and Spotlight layouts.
- Overrides active speaker detection for the main tile.
- Stored as `pinnedUserId` (`String?`) on the controller.
- Unpins when: the pinned user leaves the room, or the user explicitly taps "Unpin".
- When a participant is pinned, a small "📌 Unpin" chip appears on their tile (top-left). Tapping it unpins.

## Participant Tile Changes

### Mic Indicator Moved to Name Chip

- Remove the top-right mic indicator circle from `ZegoParticipantTile`.
- Add a mic icon inside the bottom-left name overlay chip, to the left of the name text.
- Unmuted: green `mic` icon. Muted: red `mic_off` icon.
- Reduces visual clutter. Matches Google Meet convention.

### PiP Floating Tile Shadow

- Wrap the floating tile in `DecoratedBox` with `BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2))`.
- Already coded, ships with this release.

## API Surface

### `ZegoCallConfig` Changes

```dart
ZegoCallConfig(
  // ... existing fields ...
  layout: ZegoLayoutMode.auto,       // default changed from grid to auto
  showLayoutPicker: true,            // replaces showLayoutSwitcher
  hideNoVideoTiles: false,           // initial toggle state
)
```

### `ZegoCallController` New Reactive State

| Field | Type | Description |
|---|---|---|
| `gridColumns` | `int?` | Slider value. Null = auto-calculated. |
| `hideNoVideoTiles` | `bool` | Toggle state for hiding camera-off tiles. |
| `pinnedUserId` | `String?` | User ID of pinned participant. Null = no pin. |
| `filteredParticipants` | `List<ZegoParticipant>` | Participants after hide-no-video filtering. All layouts consume this instead of raw `participants`. |

### Breaking Changes

- `showLayoutSwitcher` renamed to `showLayoutPicker`.
- `ZegoLayoutMode` enum gains `spotlight`, `gallery`, `auto`.
- Default layout changes from `grid` to `auto`.
- Mic indicator position changes from top-right to name chip (visual only, no API change).

## New Files

| File | Purpose |
|---|---|
| `lib/src/layouts/zego_spotlight_layout.dart` | Spotlight layout widget |
| `lib/src/layouts/zego_gallery_layout.dart` | Gallery layout widget |
| `lib/src/widgets/zego_layout_picker_dialog.dart` | Layout picker dialog widget |
| `test/layouts/zego_spotlight_layout_test.dart` | Spotlight tests |
| `test/layouts/zego_gallery_layout_test.dart` | Gallery tests |
| `test/widgets/zego_layout_picker_dialog_test.dart` | Dialog tests |

## Modified Files

| File | Changes |
|---|---|
| `lib/src/zego_layout_mode.dart` | Add `spotlight`, `gallery`, `auto` to enum |
| `lib/src/zego_call_config.dart` | Replace `showLayoutSwitcher` with `showLayoutPicker`, add `hideNoVideoTiles`, change default layout to `auto` |
| `lib/src/zego_call_controller.dart` | Add `gridColumns`, `hideNoVideoTiles`, `pinnedUserId`, `filteredParticipants`, auto-layout logic |
| `lib/src/zego_call_screen.dart` | Wire up new layouts, replace cycle handler with dialog, consume `filteredParticipants` |
| `lib/src/widgets/zego_controls_bar.dart` | Layout button opens dialog instead of cycling |
| `lib/src/widgets/zego_participant_tile.dart` | Move mic indicator into name chip, remove top-right indicator |
| `lib/src/layouts/zego_pip_layout.dart` | Add shadow to floating tile |
