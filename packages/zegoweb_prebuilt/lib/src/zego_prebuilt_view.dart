// packages/zegoweb_prebuilt/lib/src/zego_prebuilt_view.dart

import 'package:flutter/widgets.dart';

import 'zego_prebuilt.dart';
import 'zego_prebuilt_error.dart';

/// Pure renderer for a [ZegoPrebuilt] instance's container div.
///
/// The widget fills whatever space Flutter gives it (constraint-driven).
/// Does not own the instance lifetime — user must call `prebuilt.destroy()`
/// explicitly. Widget unmount detaches but does NOT destroy the call.
class ZegoPrebuiltView extends StatefulWidget {
  const ZegoPrebuiltView({super.key, required this.prebuilt});

  final ZegoPrebuilt prebuilt;

  @override
  State<ZegoPrebuiltView> createState() => _ZegoPrebuiltViewState();
}

class _ZegoPrebuiltViewState extends State<ZegoPrebuiltView> {
  @override
  void initState() {
    super.initState();
    final viewType = widget.prebuilt.debugViewType;
    if (viewType == null) {
      throw const ZegoStateError(
        -1,
        'ZegoPrebuiltView mounted before joinRoom() was called. '
        'Call prebuilt.joinRoom(config) before placing ZegoPrebuiltView '
        'in the widget tree.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: widget.prebuilt.debugViewType!);
  }
}
