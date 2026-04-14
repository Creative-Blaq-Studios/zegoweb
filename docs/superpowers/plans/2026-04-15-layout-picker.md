# Layout Picker Dialog & Extended Layouts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the layout cycle button with a Google Meet-style "Adjust view" dialog, add Spotlight/Gallery/Auto layouts, tile size slider, hide-no-video toggle, participant pinning, move mic indicator into name chip, and add PiP shadow.

**Architecture:** Extend the existing `ZegoCallController` ChangeNotifier with new reactive state (`gridColumns`, `hideNoVideoTiles`, `pinnedUserId`, `filteredParticipants`). Add two new layout widgets (`ZegoSpotlightLayout`, `ZegoGalleryLayout`) following the existing stateless pattern. Build a `ZegoLayoutPickerDialog` widget that anchors near the layout button. Auto layout is controller logic that picks a layout based on participant count.

**Tech Stack:** Flutter, zegoweb_ui package, ZegoCallTheme theming, ChangeNotifier state management

---

### Task 1: Extend `ZegoLayoutMode` enum

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/zego_layout_mode.dart`
- Modify: `packages/zegoweb_ui/test/models/zego_layout_mode_test.dart`

- [ ] **Step 1: Update the test to expect 6 values**

```dart
// test/models/zego_layout_mode_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

void main() {
  group('ZegoLayoutMode', () {
    test('has grid, sidebar, pip, spotlight, gallery, auto in order', () {
      expect(ZegoLayoutMode.values, [
        ZegoLayoutMode.grid,
        ZegoLayoutMode.sidebar,
        ZegoLayoutMode.pip,
        ZegoLayoutMode.spotlight,
        ZegoLayoutMode.gallery,
        ZegoLayoutMode.auto,
      ]);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/zegoweb_ui && flutter test test/models/zego_layout_mode_test.dart -v`
Expected: FAIL — `spotlight`, `gallery`, `auto` not defined

- [ ] **Step 3: Add the new enum values**

```dart
// lib/src/zego_layout_mode.dart
enum ZegoLayoutMode {
  grid,
  sidebar,
  pip,
  spotlight,
  gallery,
  auto,
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/zegoweb_ui && flutter test test/models/zego_layout_mode_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/zego_layout_mode.dart packages/zegoweb_ui/test/models/zego_layout_mode_test.dart
git commit -m "feat: add spotlight, gallery, auto to ZegoLayoutMode enum"
```

---

### Task 2: Update `ZegoCallConfig` — rename `showLayoutSwitcher`, add new fields

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/zego_call_config.dart`
- Modify: `packages/zegoweb_ui/test/models/zego_call_config_test.dart`

- [ ] **Step 1: Update tests for new config shape**

Replace the full test file:

```dart
// test/models/zego_call_config_test.dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

void main() {
  group('ZegoCallConfig', () {
    test('defaults match spec', () {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(config.roomId, 'r1');
      expect(config.userId, 'u1');
      expect(config.userName, isNull);
      expect(config.layout, ZegoLayoutMode.auto);
      expect(config.videoFit, BoxFit.contain);
      expect(config.showPreJoinView, isTrue);
      expect(config.showMicrophoneToggle, isTrue);
      expect(config.showCameraToggle, isTrue);
      expect(config.showScreenShareButton, isFalse);
      expect(config.showLayoutPicker, isTrue);
      expect(config.hideNoVideoTiles, isFalse);
      expect(config.showAudioDebugOverlay, isFalse);
    });

    test('all fields can be overridden', () {
      const config = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        userName: 'Alice',
        layout: ZegoLayoutMode.pip,
        videoFit: BoxFit.cover,
        showPreJoinView: false,
        showMicrophoneToggle: false,
        showCameraToggle: false,
        showScreenShareButton: false,
        showLayoutPicker: false,
        hideNoVideoTiles: true,
        showAudioDebugOverlay: true,
      );
      expect(config.userName, 'Alice');
      expect(config.layout, ZegoLayoutMode.pip);
      expect(config.videoFit, BoxFit.cover);
      expect(config.showPreJoinView, isFalse);
      expect(config.showMicrophoneToggle, isFalse);
      expect(config.showCameraToggle, isFalse);
      expect(config.showScreenShareButton, isFalse);
      expect(config.showLayoutPicker, isFalse);
      expect(config.hideNoVideoTiles, isTrue);
      expect(config.showAudioDebugOverlay, isTrue);
    });

    test('showAudioDebugOverlay defaults to false', () {
      const config = ZegoCallConfig(roomId: 'r1', userId: 'u1');
      expect(config.showAudioDebugOverlay, isFalse);
    });

    test('showAudioDebugOverlay can be set to true', () {
      const config = ZegoCallConfig(
        roomId: 'r1',
        userId: 'u1',
        showAudioDebugOverlay: true,
      );
      expect(config.showAudioDebugOverlay, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/zegoweb_ui && flutter test test/models/zego_call_config_test.dart -v`
Expected: FAIL — `showLayoutPicker` not defined, default `layout` is `grid` not `auto`

- [ ] **Step 3: Update `ZegoCallConfig`**

```dart
// lib/src/zego_call_config.dart
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

@immutable
class ZegoCallConfig {
  const ZegoCallConfig({
    required this.roomId,
    required this.userId,
    this.userName,
    this.layout = ZegoLayoutMode.auto,
    this.videoFit = BoxFit.contain,
    this.showPreJoinView = true,
    this.showMicrophoneToggle = true,
    this.showCameraToggle = true,
    this.showScreenShareButton = false,
    this.showLayoutPicker = true,
    this.hideNoVideoTiles = false,
    this.showAudioDebugOverlay = false,
  });

  final String roomId;
  final String userId;
  final String? userName;
  final ZegoLayoutMode layout;

  /// How video streams are fitted within their tile.
  final BoxFit videoFit;

  final bool showPreJoinView;
  final bool showMicrophoneToggle;
  final bool showCameraToggle;
  final bool showScreenShareButton;

  /// When true, the layout picker dialog button is shown in the controls bar.
  final bool showLayoutPicker;

  /// Initial state for the "hide tiles without video" toggle.
  final bool hideNoVideoTiles;

  /// When true, a floating audio debug overlay is shown in the call screen.
  final bool showAudioDebugOverlay;
}
```

- [ ] **Step 4: Fix all references to `showLayoutSwitcher` across the codebase**

Search and replace `showLayoutSwitcher` → `showLayoutPicker` in:
- `packages/zegoweb_ui/lib/src/widgets/zego_controls_bar.dart`
- `packages/zegoweb_ui/lib/src/zego_call_screen.dart`
- `packages/zegoweb_ui/test/zego_call_screen_test.dart`

- [ ] **Step 5: Run all model tests**

Run: `cd packages/zegoweb_ui && flutter test test/models/ -v`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
git add packages/zegoweb_ui/lib/src/zego_call_config.dart packages/zegoweb_ui/test/models/zego_call_config_test.dart packages/zegoweb_ui/lib/src/widgets/zego_controls_bar.dart packages/zegoweb_ui/lib/src/zego_call_screen.dart packages/zegoweb_ui/test/zego_call_screen_test.dart
git commit -m "feat: update ZegoCallConfig with showLayoutPicker, hideNoVideoTiles, auto default"
```

---

### Task 3: Move mic indicator into name chip on `ZegoParticipantTile`

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/widgets/zego_participant_tile.dart`
- Modify: `packages/zegoweb_ui/test/widgets/zego_participant_tile_test.dart`

- [ ] **Step 1: Update tests for mic-in-name-chip behavior**

Update the mic indicator tests in `test/widgets/zego_participant_tile_test.dart`. The mic icon should appear inside the name overlay (bottom-left) not as a separate top-right widget. Update existing tests:

```dart
// In the test file, update the 'shows mic off icon when muted' test:
testWidgets('shows mic_off icon in name chip when muted', (tester) async {
  const participant = ZegoParticipant(
    userId: 'u1',
    userName: 'Alice',
    isMuted: true,
  );
  await tester.pumpWidget(_wrap(const ZegoParticipantTile(
    participant: participant,
  )));
  // Mic icon should be in the bottom-left name chip, not top-right
  expect(find.byIcon(Icons.mic_off), findsOneWidget);
  expect(find.byIcon(Icons.mic), findsNothing);
});

// Update the 'shows mic icon when not muted' test:
testWidgets('shows mic icon in name chip when not muted', (tester) async {
  const participant = ZegoParticipant(
    userId: 'u1',
    userName: 'Alice',
    isMuted: false,
  );
  await tester.pumpWidget(_wrap(const ZegoParticipantTile(
    participant: participant,
  )));
  expect(find.byIcon(Icons.mic), findsOneWidget);
  expect(find.byIcon(Icons.mic_off), findsNothing);
});

// Update the 'hides mic indicator when showMicIndicator is false' test:
testWidgets('hides mic indicator when showMicIndicator is false', (tester) async {
  const participant = ZegoParticipant(
    userId: 'u1',
    userName: 'Alice',
    isMuted: true,
  );
  await tester.pumpWidget(_wrap(const ZegoParticipantTile(
    participant: participant,
    showMicIndicator: false,
  )));
  expect(find.byIcon(Icons.mic_off), findsNothing);
  expect(find.byIcon(Icons.mic), findsNothing);
});
```

- [ ] **Step 2: Run tests to see current state**

Run: `cd packages/zegoweb_ui && flutter test test/widgets/zego_participant_tile_test.dart -v`

- [ ] **Step 3: Refactor `_buildNameOverlay` to include mic indicator, remove `_buildMicIndicator`**

In `lib/src/widgets/zego_participant_tile.dart`, update the build method and helper methods:

Remove the separate `_buildMicIndicator` positioned at top-right. Merge the mic icon into `_buildNameOverlay`:

```dart
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final themeExt = Theme.of(context).extension<ZegoCallTheme>();
  final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

  final borderRadius = BorderRadius.circular(theme.tileBorderRadius ?? 12.0);

  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      border: isActiveSpeaker
          ? Border.all(color: colorScheme.primary, width: 2.5)
          : null,
    ),
    child: ClipRRect(
      borderRadius: isActiveSpeaker
          ? borderRadius - const BorderRadius.all(Radius.circular(2.5))
          : borderRadius,
      child: Container(
        color: theme.tileBackgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildContent(theme, colorScheme),
            if (showName) _buildNameOverlay(theme),
            // mic indicator is now inside _buildNameOverlay
          ],
        ),
      ),
    ),
  );
}

Widget _buildNameOverlay(ZegoCallTheme theme) {
  return Positioned(
    left: 8,
    bottom: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMicIndicator) ...[
            Icon(
              participant.isMuted ? Icons.mic_off : Icons.mic,
              size: 14,
              color: participant.isMuted
                  ? const Color(0xFFEA4335)
                  : const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            participant.userName ?? participant.userId,
            style: theme.nameTextStyle ??
                const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
```

Delete the old `_buildMicIndicator` method entirely.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/zegoweb_ui && flutter test test/widgets/zego_participant_tile_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/widgets/zego_participant_tile.dart packages/zegoweb_ui/test/widgets/zego_participant_tile_test.dart
git commit -m "feat: move mic indicator into name chip on participant tile"
```

---

### Task 4: Add PiP floating tile shadow

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/layouts/zego_pip_layout.dart`

- [ ] **Step 1: Verify shadow is already coded**

The `DecoratedBox` with `BoxShadow` was added in a previous session. Read the file and confirm the shadow wraps the floating `ZegoParticipantTile` inside the `GestureDetector`.

- [ ] **Step 2: Run PiP layout tests**

Run: `cd packages/zegoweb_ui && flutter test test/layouts/zego_pip_layout_test.dart -v`
Expected: ALL PASS

- [ ] **Step 3: Commit if any changes needed**

If already correct, skip this commit. Otherwise:

```bash
git add packages/zegoweb_ui/lib/src/layouts/zego_pip_layout.dart
git commit -m "fix: add shadow to PiP floating tile for visual separation"
```

---

### Task 5: Build `ZegoSpotlightLayout`

**Files:**
- Create: `packages/zegoweb_ui/lib/src/layouts/zego_spotlight_layout.dart`
- Create: `packages/zegoweb_ui/test/layouts/zego_spotlight_layout_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/layouts/zego_spotlight_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_spotlight_layout.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 800, height: 600, child: child),
    ),
  );
}

void main() {
  group('ZegoSpotlightLayout', () {
    testWidgets('renders single tile for active speaker', (tester) async {
      final participants = List.generate(
        4,
        (i) => ZegoParticipant(userId: 'u$i', userName: 'User $i'),
      );
      await tester.pumpWidget(_wrap(ZegoSpotlightLayout(
        participants: participants,
        activeSpeakerIndex: 2,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
    });

    testWidgets('renders first participant when no active speaker',
        (tester) async {
      final participants = [
        const ZegoParticipant(userId: 'u0', userName: 'First'),
        const ZegoParticipant(userId: 'u1', userName: 'Second'),
      ];
      await tester.pumpWidget(_wrap(ZegoSpotlightLayout(
        participants: participants,
        activeSpeakerIndex: -1,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('renders empty for no participants', (tester) async {
      await tester.pumpWidget(_wrap(const ZegoSpotlightLayout(
        participants: [],
      )));
      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/zegoweb_ui && flutter test test/layouts/zego_spotlight_layout_test.dart -v`
Expected: FAIL — file not found

- [ ] **Step 3: Implement `ZegoSpotlightLayout`**

```dart
// lib/src/layouts/zego_spotlight_layout.dart
import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A layout that shows only the active speaker full-screen.
///
/// When [activeSpeakerIndex] is -1 or out of range, the first participant
/// is displayed. Returns [SizedBox.shrink] when [participants] is empty.
class ZegoSpotlightLayout extends StatelessWidget {
  const ZegoSpotlightLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex = -1,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
  });

  final List<ZegoParticipant> participants;
  final int activeSpeakerIndex;
  final bool showName;
  final bool showMicIndicator;
  final VideoViewBuilder? videoViewBuilder;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final idx = (activeSpeakerIndex >= 0 &&
            activeSpeakerIndex < participants.length)
        ? activeSpeakerIndex
        : 0;
    final speaker = participants[idx];

    return ZegoParticipantTile(
      participant: speaker,
      showName: showName,
      showMicIndicator: showMicIndicator,
      mirror: speaker.isLocal,
      isActiveSpeaker: true,
      videoViewBuilder: videoViewBuilder,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/zegoweb_ui && flutter test test/layouts/zego_spotlight_layout_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/layouts/zego_spotlight_layout.dart packages/zegoweb_ui/test/layouts/zego_spotlight_layout_test.dart
git commit -m "feat: add ZegoSpotlightLayout — full-screen active speaker"
```

---

### Task 6: Build `ZegoGalleryLayout`

**Files:**
- Create: `packages/zegoweb_ui/lib/src/layouts/zego_gallery_layout.dart`
- Create: `packages/zegoweb_ui/test/layouts/zego_gallery_layout_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/layouts/zego_gallery_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_gallery_layout.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 800, height: 600, child: child),
    ),
  );
}

void main() {
  group('ZegoGalleryLayout', () {
    testWidgets('renders main tile and filmstrip for 4 participants',
        (tester) async {
      final participants = List.generate(
        4,
        (i) => ZegoParticipant(userId: 'u$i', userName: 'User $i'),
      );
      await tester.pumpWidget(_wrap(ZegoGalleryLayout(
        participants: participants,
        activeSpeakerIndex: 0,
      )));
      // 1 main tile + 3 filmstrip tiles = 4 total
      expect(find.byType(ZegoParticipantTile), findsNWidgets(4));
    });

    testWidgets('renders single tile when only 1 participant',
        (tester) async {
      const participants = [
        ZegoParticipant(userId: 'u0', userName: 'Solo'),
      ];
      await tester.pumpWidget(_wrap(const ZegoGalleryLayout(
        participants: participants,
        activeSpeakerIndex: 0,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
    });

    testWidgets('renders empty for no participants', (tester) async {
      await tester.pumpWidget(_wrap(const ZegoGalleryLayout(
        participants: [],
      )));
      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/zegoweb_ui && flutter test test/layouts/zego_gallery_layout_test.dart -v`
Expected: FAIL — file not found

- [ ] **Step 3: Implement `ZegoGalleryLayout`**

```dart
// lib/src/layouts/zego_gallery_layout.dart
import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A layout with one large speaker tile and a horizontal filmstrip of
/// thumbnail tiles at the bottom.
///
/// The [activeSpeakerIndex] participant (or first if -1) occupies the main
/// area (~80% height). Remaining participants appear in a scrollable row.
class ZegoGalleryLayout extends StatelessWidget {
  const ZegoGalleryLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex = -1,
    this.filmstripHeight = 100.0,
    this.spacing = 4.0,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
  });

  final List<ZegoParticipant> participants;
  final int activeSpeakerIndex;
  final double filmstripHeight;
  final double spacing;
  final bool showName;
  final bool showMicIndicator;
  final VideoViewBuilder? videoViewBuilder;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final speakerIdx = (activeSpeakerIndex >= 0 &&
            activeSpeakerIndex < participants.length)
        ? activeSpeakerIndex
        : 0;
    final speaker = participants[speakerIdx];
    final others = <ZegoParticipant>[
      for (var i = 0; i < participants.length; i++)
        if (i != speakerIdx) participants[i],
    ];

    if (others.isEmpty) {
      return ZegoParticipantTile(
        participant: speaker,
        showName: showName,
        showMicIndicator: showMicIndicator,
        mirror: speaker.isLocal,
        isActiveSpeaker: true,
        videoViewBuilder: videoViewBuilder,
      );
    }

    return Column(
      children: [
        // Main speaker tile
        Expanded(
          child: ZegoParticipantTile(
            participant: speaker,
            showName: showName,
            showMicIndicator: showMicIndicator,
            mirror: speaker.isLocal,
            isActiveSpeaker: true,
            videoViewBuilder: videoViewBuilder,
          ),
        ),
        SizedBox(height: spacing),
        // Horizontal filmstrip
        SizedBox(
          height: filmstripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: others.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (_, index) {
              final p = others[index];
              return AspectRatio(
                aspectRatio: 4 / 3,
                child: ZegoParticipantTile(
                  participant: p,
                  showName: showName,
                  showMicIndicator: showMicIndicator,
                  mirror: p.isLocal,
                  videoViewBuilder: videoViewBuilder,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/zegoweb_ui && flutter test test/layouts/zego_gallery_layout_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/layouts/zego_gallery_layout.dart packages/zegoweb_ui/test/layouts/zego_gallery_layout_test.dart
git commit -m "feat: add ZegoGalleryLayout — speaker + horizontal filmstrip"
```

---

### Task 7: Add controller state — `gridColumns`, `hideNoVideoTiles`, `pinnedUserId`, `filteredParticipants`, auto layout logic

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/zego_call_controller.dart`

- [ ] **Step 1: Add new reactive state fields and getters**

Add these fields after the existing reactive state section (around line 30-90):

```dart
// --- Layout picker state ---

int? _gridColumns;
/// Grid column override from the tile size slider. Null = auto-calculated.
int? get gridColumns => _gridColumns;

bool _hideNoVideoTiles = false;
/// Whether to hide participants with camera off and no stream.
bool get hideNoVideoTiles => _hideNoVideoTiles;

String? _pinnedUserId;
/// User ID of the pinned participant. Null = no pin.
String? get pinnedUserId => _pinnedUserId;
```

- [ ] **Step 2: Add `filteredParticipants` getter**

```dart
/// Participants after applying the hide-no-video filter.
/// All layout widgets should consume this instead of raw [participants].
List<ZegoParticipant> get filteredParticipants {
  if (!_hideNoVideoTiles) return participants;
  return List.unmodifiable(
    _participants.where(
      (p) => p.isLocal || p.stream != null || !p.isCameraOff,
    ),
  );
}
```

- [ ] **Step 3: Add setter methods**

```dart
/// Set grid columns for the tile size slider.
void setGridColumns(int? columns) {
  _gridColumns = columns?.clamp(2, 6);
  notifyListeners();
}

/// Toggle hiding of tiles without video.
void setHideNoVideoTiles(bool hide) {
  _hideNoVideoTiles = hide;
  notifyListeners();
}

/// Pin a participant by user ID. Pass null to unpin.
void pinParticipant(String? userId) {
  _pinnedUserId = userId;
  notifyListeners();
}
```

- [ ] **Step 4: Add auto layout resolution method**

```dart
/// Resolves the effective layout when [currentLayout] is [ZegoLayoutMode.auto].
/// Returns the current layout unchanged for non-auto modes.
ZegoLayoutMode get resolvedLayout {
  if (_currentLayout != ZegoLayoutMode.auto) return _currentLayout;
  final count = filteredParticipants.length;
  if (_isScreenSharing) return ZegoLayoutMode.sidebar;
  if (count <= 1) return ZegoLayoutMode.spotlight;
  if (count == 2) return ZegoLayoutMode.pip;
  if (count <= 6) return ZegoLayoutMode.grid;
  return ZegoLayoutMode.sidebar;
}
```

- [ ] **Step 5: Update `switchLayout` to handle auto mode**

Find the existing `switchLayout` method and update it:

```dart
void switchLayout(ZegoLayoutMode mode) {
  if (mode == _currentLayout) return;
  _currentLayout = mode;
  ZegoLog.info('CallController layout switched to ${mode.name}');
  notifyListeners();
}
```

- [ ] **Step 6: Initialize `_hideNoVideoTiles` from config in constructor**

In the constructor body, add:

```dart
ZegoCallController({
  required this.engineConfig,
  required this.callConfig,
}) : _currentLayout = callConfig.layout,
     _hideNoVideoTiles = callConfig.hideNoVideoTiles;
```

- [ ] **Step 7: Reset new state in `leave()`**

In the `leave()` method, after the existing state resets, add:

```dart
_gridColumns = null;
_pinnedUserId = null;
```

- [ ] **Step 8: Run existing tests to verify nothing is broken**

Run: `cd packages/zegoweb_ui && flutter test test/models/ test/layouts/ -v`
Expected: ALL PASS

- [ ] **Step 9: Commit**

```bash
git add packages/zegoweb_ui/lib/src/zego_call_controller.dart
git commit -m "feat: add gridColumns, hideNoVideoTiles, pinnedUserId, filteredParticipants, auto layout logic"
```

---

### Task 8: Build `ZegoLayoutPickerDialog`

**Files:**
- Create: `packages/zegoweb_ui/lib/src/widgets/zego_layout_picker_dialog.dart`
- Create: `packages/zegoweb_ui/test/widgets/zego_layout_picker_dialog_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/widgets/zego_layout_picker_dialog_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';
import 'package:zegoweb_ui/src/widgets/zego_layout_picker_dialog.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ZegoLayoutPickerDialog', () {
    testWidgets('renders all layout options', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Picture-in-picture'), findsOneWidget);
      expect(find.text('Spotlight'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('calls onLayoutSelected when tapping a layout',
        (tester) async {
      ZegoLayoutMode? selected;
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (mode) => selected = mode,
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      await tester.tap(find.text('Sidebar'));
      expect(selected, ZegoLayoutMode.sidebar);
    });

    testWidgets('calls onClose when tapping close button', (tester) async {
      var closed = false;
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () => closed = true,
      )));
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('shows tile size slider', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows hide tiles toggle', (tester) async {
      await tester.pumpWidget(_wrap(ZegoLayoutPickerDialog(
        currentLayout: ZegoLayoutMode.grid,
        hideNoVideoTiles: false,
        onLayoutSelected: (_) {},
        onHideNoVideoTilesChanged: (_) {},
        onClose: () {},
      )));
      expect(find.text('Hide tiles without video'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/zegoweb_ui && flutter test test/widgets/zego_layout_picker_dialog_test.dart -v`
Expected: FAIL — file not found

- [ ] **Step 3: Implement `ZegoLayoutPickerDialog`**

```dart
// lib/src/widgets/zego_layout_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

/// Google Meet-style "Adjust view" dialog for selecting layouts and
/// configuring tile options.
class ZegoLayoutPickerDialog extends StatelessWidget {
  const ZegoLayoutPickerDialog({
    super.key,
    required this.currentLayout,
    required this.hideNoVideoTiles,
    required this.onLayoutSelected,
    required this.onHideNoVideoTilesChanged,
    required this.onClose,
    this.gridColumns,
    this.onGridColumnsChanged,
  });

  final ZegoLayoutMode currentLayout;
  final bool hideNoVideoTiles;
  final ValueChanged<ZegoLayoutMode> onLayoutSelected;
  final ValueChanged<bool> onHideNoVideoTilesChanged;
  final VoidCallback onClose;
  final int? gridColumns;
  final ValueChanged<int?>? onGridColumnsChanged;

  static const _layouts = [
    (ZegoLayoutMode.grid, 'Grid', Icons.grid_view),
    (ZegoLayoutMode.sidebar, 'Sidebar', Icons.view_sidebar),
    (ZegoLayoutMode.pip, 'Picture-in-picture', Icons.picture_in_picture),
    (ZegoLayoutMode.spotlight, 'Spotlight', Icons.person),
    (ZegoLayoutMode.gallery, 'Gallery', Icons.view_comfy),
    (ZegoLayoutMode.auto, 'Auto', Icons.auto_awesome),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    final bgColor = theme.controlsBarColor ?? const Color(0xFF2D2E31);
    final textColor = colorScheme.onSurface;
    final subtitleColor = textColor.withValues(alpha: 0.6);
    final sliderEnabled = currentLayout == ZegoLayoutMode.grid ||
        currentLayout == ZegoLayoutMode.auto;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adjust view',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: subtitleColor, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a layout and adjust tile size',
            style: TextStyle(color: subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Layout radio list
          for (final (mode, label, icon) in _layouts)
            _LayoutOption(
              label: label,
              icon: icon,
              isSelected: currentLayout == mode,
              onTap: () => onLayoutSelected(mode),
              textColor: textColor,
              selectedColor: colorScheme.primary,
              subtitleColor: subtitleColor,
            ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: subtitleColor.withValues(alpha: 0.2), height: 1),
          ),

          // Tiles section
          Text(
            'Tiles',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Tile size slider
          Row(
            children: [
              const Icon(Icons.grid_view, size: 16, color: Colors.white54),
              Expanded(
                child: Slider(
                  value: (gridColumns ?? 3).toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  onChanged: sliderEnabled
                      ? (v) => onGridColumnsChanged?.call(v.round())
                      : null,
                ),
              ),
              const Icon(Icons.grid_on, size: 16, color: Colors.white54),
            ],
          ),

          // Hide tiles toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hide tiles without video',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              Switch(
                value: hideNoVideoTiles,
                onChanged: onHideNoVideoTilesChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  const _LayoutOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
    required this.selectedColor,
    required this.subtitleColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;
  final Color selectedColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? selectedColor : subtitleColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
            Icon(icon, size: 20, color: subtitleColor),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/zegoweb_ui && flutter test test/widgets/zego_layout_picker_dialog_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/widgets/zego_layout_picker_dialog.dart packages/zegoweb_ui/test/widgets/zego_layout_picker_dialog_test.dart
git commit -m "feat: add ZegoLayoutPickerDialog — Google Meet-style adjust view"
```

---

### Task 9: Wire everything into `ZegoCallScreen` and `ZegoControlsBar`

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/zego_call_screen.dart`
- Modify: `packages/zegoweb_ui/lib/src/widgets/zego_controls_bar.dart`

- [ ] **Step 1: Update `_handleLayoutSwitch` to show dialog instead of cycling**

In `zego_call_screen.dart`, replace the `_handleLayoutSwitch` method:

```dart
void _handleLayoutSwitch() {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Material(
          type: MaterialType.transparency,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => ZegoLayoutPickerDialog(
              currentLayout: _controller.currentLayout,
              hideNoVideoTiles: _controller.hideNoVideoTiles,
              gridColumns: _controller.gridColumns,
              onLayoutSelected: (mode) {
                _controller.switchLayout(mode);
              },
              onHideNoVideoTilesChanged: (hide) {
                _controller.setHideNoVideoTiles(hide);
              },
              onGridColumnsChanged: (cols) {
                _controller.setGridColumns(cols);
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Add import for the layout picker dialog**

Add to the top of `zego_call_screen.dart`:

```dart
import 'package:zegoweb_ui/src/widgets/zego_layout_picker_dialog.dart';
```

- [ ] **Step 3: Update `_buildLayout()` to use `resolvedLayout` and `filteredParticipants`**

Replace the `_buildLayout()` method to handle all 5 concrete layouts and use `filteredParticipants`:

```dart
Widget _buildLayout() {
  final participants = _controller.filteredParticipants;
  final layout = _controller.resolvedLayout;

  // Determine the effective speaker index, respecting pin.
  int activeSpeaker = _controller.activeSpeakerIndex;
  if (_controller.pinnedUserId != null) {
    final pinIdx = participants.indexWhere(
      (p) => p.userId == _controller.pinnedUserId,
    );
    if (pinIdx >= 0) activeSpeaker = pinIdx;
  }

  switch (layout) {
    case ZegoLayoutMode.grid:
      return ZegoGridLayout(
        participants: participants,
        activeSpeakerIndex: activeSpeaker,
        showName: true,
        showMicIndicator: true,
        videoViewBuilder: _videoViewBuilder,
      );

    case ZegoLayoutMode.sidebar:
      return ZegoSidebarLayout(
        participants: participants,
        activeSpeakerIndex: activeSpeaker >= 0 ? activeSpeaker : 0,
        showName: true,
        showMicIndicator: true,
        videoViewBuilder: _videoViewBuilder,
      );

    case ZegoLayoutMode.pip:
      if (participants.length < 2) {
        return ZegoGridLayout(
          participants: participants,
          activeSpeakerIndex: activeSpeaker,
          videoViewBuilder: _videoViewBuilder,
        );
      }
      final localIdx = participants.indexWhere((p) => p.isLocal);
      final remoteIdx = localIdx == 0 ? 1 : 0;
      return ZegoPipLayout(
        fullScreenParticipant: participants[remoteIdx],
        floatingParticipant: participants[localIdx >= 0 ? localIdx : 0],
        isFullScreenActiveSpeaker: activeSpeaker == remoteIdx,
        isFloatingActiveSpeaker: activeSpeaker == localIdx,
        videoViewBuilder: _videoViewBuilder,
      );

    case ZegoLayoutMode.spotlight:
      return ZegoSpotlightLayout(
        participants: participants,
        activeSpeakerIndex: activeSpeaker,
        showName: true,
        showMicIndicator: true,
        videoViewBuilder: _videoViewBuilder,
      );

    case ZegoLayoutMode.gallery:
      return ZegoGalleryLayout(
        participants: participants,
        activeSpeakerIndex: activeSpeaker >= 0 ? activeSpeaker : 0,
        showName: true,
        showMicIndicator: true,
        videoViewBuilder: _videoViewBuilder,
      );

    case ZegoLayoutMode.auto:
      // Should never reach here — resolvedLayout handles auto.
      return const SizedBox.shrink();
  }
}
```

- [ ] **Step 4: Add imports for new layout widgets**

Add to the top of `zego_call_screen.dart`:

```dart
import 'package:zegoweb_ui/src/layouts/zego_spotlight_layout.dart';
import 'package:zegoweb_ui/src/layouts/zego_gallery_layout.dart';
```

- [ ] **Step 5: Update `ZegoControlsBar` — change `showLayoutSwitcher` to `showLayoutPicker`**

If not already done in Task 2, ensure the controls bar uses `config.showLayoutPicker` instead of `config.showLayoutSwitcher`.

- [ ] **Step 6: Run all tests**

Run: `cd packages/zegoweb_ui && flutter test test/models/ test/layouts/ -v`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add packages/zegoweb_ui/lib/src/zego_call_screen.dart packages/zegoweb_ui/lib/src/widgets/zego_controls_bar.dart
git commit -m "feat: wire layout picker dialog and new layouts into call screen"
```

---

### Task 10: Export new widgets from barrel and update `showLayoutSwitcher` references in tests

**Files:**
- Modify: `packages/zegoweb_ui/lib/zegoweb_ui.dart`
- Modify: any remaining test files with `showLayoutSwitcher`

- [ ] **Step 1: Add exports for new widgets**

Add to `lib/zegoweb_ui.dart`:

```dart
export 'src/layouts/zego_spotlight_layout.dart' show ZegoSpotlightLayout;
export 'src/layouts/zego_gallery_layout.dart' show ZegoGalleryLayout;
export 'src/widgets/zego_layout_picker_dialog.dart' show ZegoLayoutPickerDialog;
```

- [ ] **Step 2: Search for any remaining `showLayoutSwitcher` references**

Run: `grep -r showLayoutSwitcher packages/zegoweb_ui/`

Fix any remaining references to use `showLayoutPicker`.

- [ ] **Step 3: Run all tests**

Run: `cd packages/zegoweb_ui && flutter test test/models/ test/layouts/ -v`
Expected: ALL PASS

- [ ] **Step 4: Commit**

```bash
git add packages/zegoweb_ui/lib/zegoweb_ui.dart
git commit -m "feat: export new layout widgets from barrel"
```

---

### Task 11: Add pin participant support to `ZegoParticipantTile`

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/widgets/zego_participant_tile.dart`

- [ ] **Step 1: Add `isPinned` and `onPin`/`onUnpin` to the tile**

Add optional parameters to `ZegoParticipantTile`:

```dart
const ZegoParticipantTile({
  super.key,
  required this.participant,
  this.showName = true,
  this.showMicIndicator = true,
  this.mirror = false,
  this.isActiveSpeaker = false,
  this.isPinned = false,
  this.onLongPress,
  this.videoViewBuilder,
});

final bool isPinned;
final VoidCallback? onLongPress;
```

- [ ] **Step 2: Wrap the tile in a `GestureDetector` for long-press**

In the `build` method, wrap the outermost `DecoratedBox` in a `GestureDetector`:

```dart
return GestureDetector(
  onLongPress: onLongPress,
  child: DecoratedBox(
    // ... existing decoration ...
  ),
);
```

- [ ] **Step 3: Add a pin indicator overlay when `isPinned` is true**

In the `Stack` children, add a pin chip at top-left:

```dart
if (isPinned)
  Positioned(
    left: 8,
    top: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin, size: 12, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'Unpin',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    ),
  ),
```

- [ ] **Step 4: Run tile tests**

Run: `cd packages/zegoweb_ui && flutter test test/widgets/zego_participant_tile_test.dart -v`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/zegoweb_ui/lib/src/widgets/zego_participant_tile.dart
git commit -m "feat: add pin indicator and long-press support to participant tile"
```

---

### Task 12: Wire pin support into layouts and call screen

**Files:**
- Modify: `packages/zegoweb_ui/lib/src/zego_call_screen.dart`

- [ ] **Step 1: Pass `isPinned` and `onLongPress` through layout builders**

In `_buildLayout()`, each layout creates `ZegoParticipantTile`s internally. The layouts don't currently pass `isPinned` or `onLongPress`. Two approaches:

Option A (simplest): Add `pinnedUserId` and `onPin` callback to each layout widget so they can pass it through to tiles.

Option B: Add these as parameters to the `VideoViewBuilder` typedef — but this changes the API.

Go with Option A. Add `pinnedUserId` and `onPinToggle` to each layout that creates tiles. This is repetitive but follows the existing pattern where each layout creates its own tiles.

For now, add pin support to `ZegoGridLayout`, `ZegoSidebarLayout`, `ZegoGalleryLayout`, and `ZegoSpotlightLayout` by adding optional `pinnedUserId` and `onPinToggle` parameters. Update the call screen to pass them through.

- [ ] **Step 2: Run all tests**

Run: `cd packages/zegoweb_ui && flutter test test/models/ test/layouts/ -v`
Expected: ALL PASS

- [ ] **Step 3: Commit**

```bash
git add packages/zegoweb_ui/lib/src/layouts/ packages/zegoweb_ui/lib/src/zego_call_screen.dart
git commit -m "feat: wire pin participant support into all layouts"
```

---

### Task 13: Version bump, changelog, publish

**Files:**
- Modify: `packages/zegoweb_ui/pubspec.yaml`
- Modify: `packages/zegoweb_ui/CHANGELOG.md`

- [ ] **Step 1: Bump version to 0.1.0 (breaking change — renamed field, new default)**

In `pubspec.yaml`, change `version: 0.0.5` to `version: 0.1.0`.

- [ ] **Step 2: Update CHANGELOG.md**

Add at the top:

```markdown
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
- `videoFit` on `ZegoCallConfig` — configurable `BoxFit` for video tiles.

### Bug Fixes
- Cross-platform stream ID mismatch resolved.
- Audio playback for audio-only remote streams (hidden video element stays mounted).
- Stream-less participants now shown with placeholder tiles.
```

- [ ] **Step 3: Commit**

```bash
git add packages/zegoweb_ui/pubspec.yaml packages/zegoweb_ui/CHANGELOG.md
git commit -m "chore: bump zegoweb_ui to 0.1.0"
```

- [ ] **Step 4: Tag and publish**

```bash
git push origin main
git tag zegoweb_ui-v0.1.0
git push origin zegoweb_ui-v0.1.0
cd packages/zegoweb_ui && dart pub publish --force
```
