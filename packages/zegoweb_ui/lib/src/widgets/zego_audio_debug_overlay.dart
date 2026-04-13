import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_controller.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

// ---------------------------------------------------------------------------
// Design constants
// ---------------------------------------------------------------------------

const Color _kBgColor = Color(0xF0080B16);
const Color _kBorderColor = Color(0xFF2A3A60);
const Color _kTitleColor = Color(0xFF4FC3F7);
const Color _kTitleBarBg = Color(0xFF0D1525);
const Color _kGreen = Color(0xFF27AE60);
const Color _kAmber = Color(0xFFF39C12);
const Color _kRed = Color(0xFFE74C3C);
const Color _kPurple = Color(0xFF9B59B6);
const Color _kDimText = Color(0xFF8898AA);
const Color _kLogBg = Color(0xFF060A12);

// ---------------------------------------------------------------------------
// ZegoAudioDebugOverlay
// ---------------------------------------------------------------------------

/// Floating, draggable, minimizable debug panel driven by [ZegoCallController].
///
/// Mounts as part of a [Stack]. Only add this widget when
/// [ZegoCallConfig.debugMode] is true.
class ZegoAudioDebugOverlay extends StatefulWidget {
  const ZegoAudioDebugOverlay({super.key, required this.controller});
  final ZegoCallController controller;

  @override
  State<ZegoAudioDebugOverlay> createState() => _ZegoAudioDebugOverlayState();
}

class _ZegoAudioDebugOverlayState extends State<ZegoAudioDebugOverlay> {
  static const double _panelWidth = 210.0;
  static const double _expandedHeight = 360.0;
  static const double _pillHeight = 28.0;
  static const double _edgePadding = 12.0;
  static const double _bottomClearance = 52.0;
  static const Duration _snapDuration = Duration(milliseconds: 200);

  bool _expanded = true;
  bool _dragging = false;
  double? _left;
  double? _top;
  Size _containerSize = Size.zero;

  double _micLevel = 0.0;
  final List<String> _logLines = [];

  StreamSubscription<double>? _levelSub;
  StreamSubscription<String>? _logSub;

  @override
  void initState() {
    super.initState();
    _levelSub = widget.controller.debugMicLevel.listen((level) {
      if (mounted) setState(() => _micLevel = level);
    });
    _logSub = widget.controller.debugLog.listen((line) {
      if (mounted) {
        setState(() {
          _logLines.add(line);
          if (_logLines.length > 50) _logLines.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _levelSub?.cancel();
    _logSub?.cancel();
    super.dispose();
  }

  double get _currentHeight => _expanded ? _expandedHeight : _pillHeight;

  void _initPosition(Size size) {
    if (_left != null) return;
    _left = size.width - _panelWidth - _edgePadding;
    _top = size.height - _expandedHeight - _bottomClearance;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    final maxLeft = _containerSize.width - _panelWidth - _edgePadding;
    final maxTop = _containerSize.height - _currentHeight - _edgePadding;
    setState(() {
      _dragging = true;
      _left = ((_left ?? _edgePadding) + details.delta.dx)
          .clamp(_edgePadding, maxLeft);
      _top = ((_top ?? _edgePadding) + details.delta.dy)
          .clamp(_edgePadding, maxTop);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _dragging = false);
    _snapToNearestCorner();
  }

  void _snapToNearestCorner() {
    final h = _currentHeight;
    final leftSnap = _edgePadding;
    final rightSnap = _containerSize.width - _panelWidth - _edgePadding;
    final topSnap = _edgePadding;
    final bottomSnap = _containerSize.height - h - _bottomClearance;

    final centerX = (_left ?? leftSnap) + _panelWidth / 2;
    final centerY = (_top ?? topSnap) + h / 2;

    setState(() {
      _left = centerX < _containerSize.width / 2 ? leftSnap : rightSnap;
      _top = centerY < _containerSize.height / 2 ? topSnap : bottomSnap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _containerSize = size;
      _initPosition(size);

      return Stack(children: [
        AnimatedPositioned(
          duration: _dragging ? Duration.zero : _snapDuration,
          left: _left!,
          top: _top!,
          width: _panelWidth,
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: _expanded
                  ? _DebugPanel(
                      controller: widget.controller,
                      micLevel: _micLevel,
                      logLines: _logLines,
                      onMinimize: () => setState(() => _expanded = false),
                    )
                  : _DebugPill(
                      micLevel: _micLevel,
                      isSpeaking: widget.controller.activeSpeakerIndex >= 0,
                      onExpand: () => setState(() => _expanded = true),
                    ),
            ),
          ),
        ),
      ]);
    });
  }
}

// ---------------------------------------------------------------------------
// Expanded panel
// ---------------------------------------------------------------------------

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({
    required this.controller,
    required this.micLevel,
    required this.logLines,
    required this.onMinimize,
  });

  final ZegoCallController controller;
  final double micLevel;
  final List<String> logLines;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBgColor,
        border: Border.all(color: _kBorderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TitleBar(onMinimize: onMinimize),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LevelMeter(
                  micLevel: micLevel,
                  threshold: controller.debugThreshold,
                  isSpeaking: controller.activeSpeakerIndex >= 0,
                ),
                const SizedBox(height: 6),
                _ActiveSpeakerRow(
                  index: controller.activeSpeakerIndex,
                  participants: controller.participants,
                ),
                const SizedBox(height: 6),
                _SliderRow(
                  label: 'Threshold',
                  value: controller.debugThreshold,
                  displayText: controller.debugThreshold.toStringAsFixed(1),
                  min: 0,
                  max: 50,
                  divisions: 50,
                  onChanged: (v) => controller.debugThreshold = v,
                ),
                const SizedBox(height: 4),
                _SliderRow(
                  label: 'Debounce',
                  value: controller.debugDebounce.inMilliseconds.toDouble(),
                  displayText: '${controller.debugDebounce.inMilliseconds} ms',
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  onChanged: (v) =>
                      controller.debugDebounce =
                          Duration(milliseconds: v.round()),
                ),
                const SizedBox(height: 6),
                _LogBox(lines: logLines),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Title bar
// ---------------------------------------------------------------------------

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.onMinimize});
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: const BoxDecoration(
        color: _kTitleBarBg,
        border: Border(bottom: BorderSide(color: _kBorderColor)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const Text(
            '⠿',
            style: TextStyle(color: Color(0xFF334455), fontSize: 12),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              '🔬 AUDIO DEBUG',
              style: TextStyle(
                color: _kTitleColor,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.06,
              ),
            ),
          ),
          GestureDetector(
            onTap: onMinimize,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFF1C40F),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '–',
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Level meter
// ---------------------------------------------------------------------------

class _LevelMeter extends StatelessWidget {
  const _LevelMeter({
    required this.micLevel,
    required this.threshold,
    required this.isSpeaking,
  });

  final double micLevel;
  final double threshold;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mic Level',
              style: TextStyle(color: _kDimText, fontSize: 7),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSpeaking
                    ? const Color(0xFF1B4D2E)
                    : const Color(0xFF1E2535),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isSpeaking ? 'SPEAKING' : 'SILENT',
                style: TextStyle(
                  color: isSpeaking ? _kGreen : const Color(0xFF445566),
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.07,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LayoutBuilder(builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final fillFraction = micLevel.clamp(0.0, 1.0);
          final thresholdFraction = (threshold / 100).clamp(0.0, 1.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 9,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141C2E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: fillFraction,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kGreen, _kAmber, _kRed],
                            stops: [0.0, 0.6, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      left: barWidth * thresholdFraction - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: TextStyle(color: Color(0xFF444444), fontSize: 6),
                  ),
                  Text(
                    '▲ thr',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 6),
                  ),
                  Text(
                    '100',
                    style: TextStyle(color: Color(0xFF444444), fontSize: 6),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Active speaker row
// ---------------------------------------------------------------------------

class _ActiveSpeakerRow extends StatelessWidget {
  const _ActiveSpeakerRow({
    required this.index,
    required this.participants,
  });

  final int index;
  final List<ZegoParticipant> participants;

  @override
  Widget build(BuildContext context) {
    final String label;
    if (index < 0) {
      label = 'none';
    } else if (index < participants.length) {
      final p = participants[index];
      label = 'idx $index — ${p.userName ?? p.userId}';
    } else {
      label = 'idx $index';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: _kTitleBarBg,
        border: Border.all(color: _kBorderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Speaker',
            style: TextStyle(color: Color(0xFF556677), fontSize: 7),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC0A0E8),
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slider row
// ---------------------------------------------------------------------------

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.displayText,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String displayText;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: _kDimText, fontSize: 7),
            ),
            Text(
              displayText,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            activeTrackColor: const Color(0xFF4F7DEB),
            inactiveTrackColor: const Color(0xFF141C2E),
            thumbColor: const Color(0xFF4F7DEB),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: SizedBox(
            height: 20,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Log box
// ---------------------------------------------------------------------------

class _LogBox extends StatefulWidget {
  const _LogBox({required this.lines});
  final List<String> lines;

  @override
  State<_LogBox> createState() => _LogBoxState();
}

class _LogBoxState extends State<_LogBox> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_LogBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lines.length != oldWidget.lines.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _lineColor(String line) {
    if (line.startsWith('★')) return _kPurple;
    if (line.contains('⏱')) return _kAmber;
    if (line.contains('→ silence') || line.contains('silent')) return _kRed;
    return _kGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: _kLogBg,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lines[index];
          return Text(
            line,
            style: TextStyle(
              color: _lineColor(line),
              fontSize: 7,
              fontFamily: 'monospace',
              height: 1.7,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Minimized pill
// ---------------------------------------------------------------------------

class _DebugPill extends StatelessWidget {
  const _DebugPill({
    required this.micLevel,
    required this.isSpeaking,
    required this.onExpand,
  });

  final double micLevel;
  final bool isSpeaking;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kBgColor,
          border: Border.all(color: _kBorderColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔬', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 6),
            SizedBox(
              width: 40,
              height: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141C2E),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: micLevel.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kGreen, _kAmber],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSpeaking ? _kGreen : Colors.white38,
                shape: BoxShape.circle,
                boxShadow: isSpeaking
                    ? [
                        BoxShadow(
                          color: _kGreen.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '▲',
              style: TextStyle(color: Color(0xFF334455), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
