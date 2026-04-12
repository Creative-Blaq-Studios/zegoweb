import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';

/// A pre-join screen that shows a camera preview (or placeholder), the user's
/// name, an optional loading state, and a "Join" button.
///
/// This view is displayed before the user enters the call, allowing them to
/// verify their camera/mic setup. Uses [ZegoCallTheme] for theming.
class ZegoPreJoinView extends StatelessWidget {
  const ZegoPreJoinView({
    super.key,
    required this.userName,
    required this.onJoin,
    this.previewWidget,
    this.isLoading = false,
  });

  /// The user's display name, shown below the preview area.
  final String userName;

  /// Called when the "Join" button is tapped.
  final VoidCallback onJoin;

  /// Optional widget displayed as the camera preview. When `null`, a
  /// placeholder with a camera icon is shown.
  final Widget? previewWidget;

  /// Whether the view is in a loading state (e.g., joining the room).
  /// When `true`, a [CircularProgressIndicator] replaces the Join button.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera preview area.
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(theme.tileBorderRadius ?? 12.0),
              child: Container(
                color: theme.tileBackgroundColor,
                child: previewWidget ??
                    Center(
                      child: Icon(
                        Icons.videocam,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // User name.
          Text(
            userName,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          // Join button or loading indicator.
          if (isLoading)
            const CircularProgressIndicator()
          else
            FilledButton(
              onPressed: onJoin,
              child: const Text('Join'),
            ),
        ],
      ),
    );
  }
}
