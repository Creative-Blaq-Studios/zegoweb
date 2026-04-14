---
sidebar_position: 2
title: Layouts
---

# Layouts

`zegoweb_ui` provides three layout modes for arranging participant video tiles.

## Grid Layout

All participants displayed in a responsive grid that reflows based on count:

- 1 participant: full screen
- 2 participants: side by side
- 3-4 participants: 2x2 grid
- 5+ participants: wrapping grid

Set via `ZegoCallConfig(layoutMode: ZegoLayoutMode.grid)`.

## Sidebar Layout

One participant (the active speaker or a pinned user) takes up the main area. Other participants appear in a smaller sidebar strip.

Set via `ZegoCallConfig(layoutMode: ZegoLayoutMode.sidebar)`.

## PiP (Picture-in-Picture) Layout

The local user's video appears as a small floating overlay on top of the remote participant's full-screen video. Best for 1:1 calls.

Set via `ZegoCallConfig(layoutMode: ZegoLayoutMode.pip)`.

## Switching layouts at runtime

The layout can be changed during a call through the `ZegoCallController`. The `ZegoCallScreen` handles layout switching internally based on user interactions.
