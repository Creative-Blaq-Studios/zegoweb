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
