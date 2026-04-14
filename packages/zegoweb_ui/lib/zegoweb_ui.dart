/// zegoweb_ui — Flutter-native call UI built on zegoweb core.
///
/// Not affiliated with or endorsed by ZEGOCLOUD.
library;

// High-level drop-in
export 'src/zego_call_screen.dart' show ZegoCallScreen;

// Controller
export 'src/zego_call_controller.dart' show ZegoCallController;

// Config
export 'src/zego_call_config.dart' show ZegoCallConfig;

// Theme
export 'src/zego_call_theme.dart' show ZegoCallTheme;

// Enums
export 'src/zego_layout_mode.dart' show ZegoLayoutMode;
export 'src/zego_call_state.dart' show ZegoCallState;

// Model
export 'src/zego_participant.dart' show ZegoParticipant;
export 'src/models/zego_audio_settings.dart' show ZegoAudioSettings;

// Layouts (composable)
export 'src/layouts/zego_grid_layout.dart' show ZegoGridLayout;
export 'src/layouts/zego_sidebar_layout.dart' show ZegoSidebarLayout;
export 'src/layouts/zego_pip_layout.dart' show ZegoPipLayout;

// Widgets (composable)
export 'src/widgets/zego_participant_tile.dart' show ZegoParticipantTile;
export 'src/widgets/zego_controls_bar.dart' show ZegoControlsBar;
export 'src/widgets/zego_control_pill.dart' show ZegoControlPill;
export 'src/widgets/zego_control_circle.dart' show ZegoControlCircle;
export 'src/widgets/zego_hang_up_button.dart' show ZegoHangUpButton;
export 'src/widgets/zego_device_popover.dart' show ZegoDevicePopover;
export 'src/widgets/zego_pre_join_view.dart' show ZegoPreJoinView;
export 'src/widgets/zego_layout_picker_dialog.dart'
    show ZegoLayoutPickerDialog;
