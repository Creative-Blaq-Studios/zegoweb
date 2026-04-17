## 0.1.1

### Breaking Changes
- Default publish stream ID format changed from `stream-{userId}` to `{roomId}_{userId}_main` to match the ZEGO mobile prebuilt UI kit. Web and mobile peers in the same room can now discover each other's streams.

### New Features
- `ZegoCallConfig.streamIdBuilder` — optional `(roomId, userId) -> String` builder to override the publish stream ID format.
- `ZegoCallConfig.defaultStreamIdBuilder` — static helper exposing the default `{roomId}_{userId}_main` format for composition.

## 0.1.0

### Breaking Changes
- `showLayoutSwitcher` renamed to `showLayoutPicker` on `ZegoCallConfig`.
- Default layout changed from `grid` to `auto`.
- Mic indicator moved from top-right to inside name chip on participant tiles.

### New Features
- **Layout picker dialog** — Google Meet-style "Adjust view" dialog with layout selection, tile size slider, and hide-no-video toggle.
- **Spotlight layout** — full-screen active speaker, no other tiles visible.
- **Gallery layout** — large speaker + horizontal filmstrip of thumbnails.
- **Auto layout** — dynamically selects layout based on participant count and screen sharing state.
- **Tile size slider** — control grid column count (2–6) from the layout picker.
- **Hide tiles without video** — toggle to hide camera-off participants.
- **Pin participant** — long-press a tile to pin as main speaker.
- **PiP floating tile shadow** — drop shadow for visual separation from background.

## 0.0.5

- Add `videoFit` to `ZegoCallConfig` — developers can choose `BoxFit.cover`, `.contain`, `.fill`, etc. Defaults to `BoxFit.contain`.

## 0.0.4

- **Fix**: Require zegoweb ^0.0.2 (ZegoLog export needed for lifecycle logging).

## 0.0.3

- **Fix**: Show participants who join a room without publishing a stream (camera+mic off).
- **Fix**: Audio playback for audio-only remote streams — hidden `<video>` element stays mounted when camera is off.
- **Fix**: Cross-platform stream ID mismatch — participant lookup now uses actual SDK stream IDs instead of assuming `stream-{userId}` format.
- Add lifecycle logging via `ZegoLog` (pre-join, join, stream add/remove, user join/leave, errors).
- Rename `debugMode` to `showAudioDebugOverlay` on `ZegoCallConfig`.
- Add `streamId` field to `ZegoParticipant`.

## 0.0.2

- **Fix**: Cross-platform stream ID mismatch preventing mobile users from appearing.

## 0.0.1

- Initial release.
- `ZegoCallScreen` — drop-in call widget with pre-join, in-call, and leaving states.
- `ZegoCallController` — manages call lifecycle, participants, and media controls.
- `ZegoControlsBar` — Google Meet-style toolbar with mic, camera, hang up, and settings.
- `ZegoPreJoinView` — camera preview with device selection before joining.
- Layouts: grid, PiP (with corner-snap dragging), and active speaker.
- `ZegoAudioSettingsPopover` — AEC/ANS/AGC toggles.
- `ZegoAudioDebugOverlay` — real-time mic level and speaker detection debug panel.
- `ThemeExtension` theming support.
