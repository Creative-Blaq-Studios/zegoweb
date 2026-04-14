---
sidebar_position: 2
title: Configuration Options
---

# Configuration Options

`ZegoPrebuiltConfig` provides typed access to the most common UIKit options. For anything not covered, use `rawConfig`.

## Typed fields

| Property | Type | Default | Description |
|---|---|---|---|
| `roomId` | `String` | required | Room to join |
| `userId` | `String` | required | User identifier |
| `userName` | `String` | required | Display name |
| `scenario` | `ZegoPrebuiltScenario` | `oneOnOne` | Call type (oneOnOne, group, broadcast) |
| `layout` | `ZegoPrebuiltLayout` | `null` | Layout mode (gridLayout, speakerLayout) |
| `videoResolution` | `ZegoPrebuiltVideoResolution` | `null` | Video quality (180p to 1080p) |
| `language` | `ZegoPrebuiltLanguage` | `english` | UI language |

## Scenarios

| Scenario | Best for |
|---|---|
| `oneOnOne` | 1:1 video calls |
| `group` | Group calls (3+ participants) |
| `broadcast` | Live streaming (one publisher, many viewers) |

## Video resolutions

```dart
ZegoPrebuiltConfig(
  videoResolution: ZegoPrebuiltVideoResolution.v720p,
  // Options: v180p, v360p, v480p, v720p, v1080p
)
```

## Raw config escape hatch

For UIKit options not covered by typed fields, use `rawConfig` to pass a raw JS object:

```dart
ZegoPrebuiltConfig(
  roomId: 'room-1',
  userId: 'user-1',
  userName: 'Alice',
  rawConfig: {
    'showPreJoinView': true,
    'turnOnCameraWhenJoining': false,
  },
)
```

`rawConfig` values are merged with typed fields. Typed fields take precedence if both specify the same option.
