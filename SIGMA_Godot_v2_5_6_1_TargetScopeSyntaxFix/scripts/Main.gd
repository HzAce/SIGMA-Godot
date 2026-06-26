extends Control

const SAVE_PATH := "user://sigma_current_game.save"
const SAVE_FILE_NAME := "sigma_current_game.save"
const TOURNAMENT_SAVE_PATH := "user://sigma_tournament.save"
const TOURNAMENT_SAVE_FILE_NAME := "sigma_tournament.save"
const TOURNAMENT_MATCH_SAVE_PATH := "user://sigma_tournament_current_match.save"
const TOURNAMENT_MATCH_SAVE_FILE_NAME := "sigma_tournament_current_match.save"
const BUILD_VERSION := "v2.5.6"
const PIECE_SET_CLASSIC_SIGMA := "classic_sigma_tokens"
const PIECE_SET_VECTOR := "vector_obelisks"
const PIECE_SET_DRACONIAN := "draconian"
const PIECE_SET_LIONS_DEN := "lions_den"
const BOARD_THEME_CLASSIC_SIGMA := "classic_sigma_board"
const BOARD_THEME_VECTOR := "vector_board"
const BOARD_THEME_DRACONIAN := "draconian_board"
const BOARD_THEME_LIONS_DEN := "lions_den_board"
const SIGMA_AI_SCRIPT := preload("res://scripts/SigmaAI.gd")

var rules: SigmaRules
var board_view: BoardView

var title_label: Label
var turn_banner: Label
var status_label: Label
var counts_label: Label
var selection_label: Label
var result_label: Label
var scenario_label: Label
var qa_status_label: Label
var action_log_label: Label
var piece_help_label: Label
var mobile_hint_label: Label
var top_controls_bar: HBoxContainer
var bottom_controls_bar: HBoxContainer
var board_holder_ref: Control
var menu_page_backdrop: ColorRect
var floating_hud_layer: Control
var hud_turn_chip: Label
var hud_counts_chip: Label
var hud_mode_chip: Label
var hud_hint_chip: Label
var hud_gold_panel_label: Label
var hud_silver_panel_label: Label
var hud_round_chip: Label
var hud_timer_chip: Label
var hud_last_action_chip: Label
var event_word_label: Label
var startup_splash_layer: Control
var startup_splash_art: TextureRect
var main_menu_art_rect: TextureRect
var main_menu_hotspot_layer: Control
var info_bubble_panel: PanelContainer
var info_bubble_title_label: Label
var info_bubble_body_label: Label
var fullscreen_play_chrome: bool = true
var turn_handoff_enabled: bool = false
var board_flip_enabled: bool = false
var turn_handoff_panel: PanelContainer
var handoff_title_label: Label
var handoff_body_label: Label
var handoff_start_button: Button
var turn_handoff_button: Button
var board_flip_button: Button
var tabletop_button: Button
var tabletop_passplay_enabled: bool = true
var tabletop_layer: Control
var tabletop_gold_bar: PanelContainer
var tabletop_silver_bar: PanelContainer
var tabletop_gold_status_label: Label
var tabletop_silver_status_label: Label
var tabletop_gold_rack_label: Label
var tabletop_silver_rack_label: Label
var tabletop_gold_rack_box: HBoxContainer
var tabletop_silver_rack_box: HBoxContainer
var mobile_gold_rack_box: HBoxContainer
var mobile_silver_rack_box: HBoxContainer
var mobile_command_dock: PanelContainer
var mobile_command_row: HBoxContainer
var tabletop_gold_prompt_label: Label
var tabletop_silver_prompt_label: Label
var tabletop_gold_clock_label: Label
var tabletop_silver_clock_label: Label
var tabletop_gold_deploy_button: Button
var tabletop_silver_deploy_button: Button
var tabletop_gold_guide_button: Button
var tabletop_silver_guide_button: Button
var tabletop_gold_pause_button: Button
var tabletop_silver_pause_button: Button
var tabletop_layout_retry_pending: bool = false

var mode_option: OptionButton
var deploy_button: Button
var undo_button: Button
var info_button: Button
var pause_button: Button
var lab_toggle_button: Button
var tutorial_button: Button
var tutorial_load_button: Button
var tutorial_replay_button: Button
var settings_button: Button
var sound_button: Button
var mute_button: Button
var master_volume_slider: HSlider
var sfx_volume_slider: HSlider
var music_volume_slider: HSlider
var audio_status_label: Label
var radio_status_label: Label
var radio_toggle_button: Button
var radio_shuffle_button: Button
var radio_next_button: Button
var radio_reset_button: Button
var radio_track_buttons: Dictionary = {}
var preview_panel: PanelContainer
var preview_title_label: Label
var preview_body_label: Label
var preview_tags_label: Label
var preview_confirm_button: Button
var preview_cancel_button: Button
var pending_preview_action: Dictionary = {}
var pending_preview_result: Dictionary = {}

var elevate_panel: PanelContainer
var elevate_title_label: Label
var elevate_subtitle_label: Label
var elevate_buttons: Dictionary = {}
var scenario_panel: VBoxContainer
var scenario_option: OptionButton
var scenario_ids: Array = []
var result_overlay: PanelContainer
var result_overlay_label: Label
var result_summary_label: Label
var result_rematch_button: Button
var result_new_game_button: Button
var result_home_button: Button
var current_match_config: Dictionary = {}

var tutorial_panel: PanelContainer
var tutorial_backdrop_layer: TutorialBackdropView
var tutorial_title_label: Label
var tutorial_body_label: Label
var tutorial_step_label: Label
var tutorial_phase_label: Label
var tutorial_demo_label: Label
var tutorial_demo_stage: PanelContainer
var tutorial_demo_canvas: Control
var tutorial_demo_tween: Tween
var tutorial_checklist_label: Label
var tutorial_back_button: Button
var tutorial_next_button: Button
var tutorial_close_button: Button
var tutorial_index: int = 0
var tutorial_steps: Array = []

var settings_panel: PanelContainer
var main_menu_panel: PanelContainer
var collections_panel: PanelContainer
var collections_status_label: Label
var collections_active_label: Label
var collections_set_active_button: Button
var collections_set_detail_panel: PanelContainer
var collections_board_detail_panel: PanelContainer
var collections_vector_set_detail_panel: PanelContainer
var collections_vector_board_detail_panel: PanelContainer
var collections_draconian_set_detail_panel: PanelContainer
var collections_draconian_board_detail_panel: PanelContainer
var collections_lions_den_set_detail_panel: PanelContainer
var collections_lions_den_board_detail_panel: PanelContainer
var collections_showcase_panel: PanelContainer
var collections_showcase_title_label: Label
var collections_showcase_subtitle_label: Label
var collections_showcase_note_label: Label
var collections_showcase_gold_preview: TextureRect
var collections_showcase_silver_preview: TextureRect
var collections_selected_kind: String = SigmaRules.KIND_MONARCH
var collection_piece_previews: Array = []
var active_piece_set_id: String = PIECE_SET_CLASSIC_SIGMA
var active_board_theme_id: String = BOARD_THEME_CLASSIC_SIGMA
var ai_engine: SigmaAI
var single_player_enabled: bool = false
var ai_side: int = SigmaRules.OWNER_P2
var human_side: int = SigmaRules.OWNER_P1
var ai_difficulty: String = "Rookie"
var ai_thinking: bool = false
var ai_turn_queued: bool = false
var new_game_panel: PanelContainer
var new_game_blitz_enabled: bool = false
var new_game_ai_enabled: bool = false
var new_game_ai_difficulty: String = "Rookie"
var new_game_selected_mode: String = "classic"
var new_game_mode_buttons: Dictionary = {}
var new_game_blitz_button: Button
var new_game_ai_button: Button
var new_game_ai_difficulty_buttons: Dictionary = {}
var new_game_ai_difficulty_box: GridContainer
var new_game_preview_title_label: Label
var new_game_preview_body_label: Label
var new_game_start_button: Button
var rules_guide_panel: PanelContainer
var rules_guide_title_label: Label
var rules_guide_body_label: Label
var rules_guide_snapshot_label: Label
var rules_guide_snapshot_view: Control
var rules_guide_step_label: Label
var rules_guide_back_button: Button
var rules_guide_next_button: Button
var rules_guide_index: int = 0
var rules_guide_pages: Array = []
var draft_panel: PanelContainer
var draft_content_box: VBoxContainer
var draft_status_label: Label
var draft_stage: int = 0
var draft_p1_picks: Array = []
var draft_p2_picks: Array = []
var draft_p1_row: Array = []
var draft_p2_row: Array = []
var draft_selected_piece: String = ""
var draft_from_custom_game: bool = false
var draft_custom_toggles: Dictionary = {}
var custom_game_panel: PanelContainer
var custom_content_box: VBoxContainer
var custom_status_label: Label
var custom_page_mode: String = "hub"
var custom_selected_mode_id: String = "classic"
var custom_surround_toggle: bool = false
var custom_collapse_toggle: bool = false
var custom_hot_start_toggle: bool = false
var custom_speed_timer_seconds: int = 10
var custom_speed_turn_limit: int = 140
var custom_mode_buttons: Dictionary = {}
var custom_surround_button: Button
var custom_collapse_button: Button
var custom_hot_start_button: Button
var custom_speed_timer_buttons: Dictionary = {}
var custom_speed_turn_buttons: Dictionary = {}
var speed_timer_enabled: bool = false
var speed_turn_seconds: int = 0
var speed_time_left: float = 0.0
var speed_total_turn_limit: int = 0
var resume_countdown_active: bool = false
var resume_countdown_left: float = 0.0
var pending_custom_config: Dictionary = {}
var tournament_name_text: String = "SIGMA Championship"
var tournament_type_id: String = "knockout"
var tournament_player_count: int = 8
var tournament_match_mode_id: String = "classic"
var tournament_best_of: int = 1
var tournament_allow_takeover: bool = true
var tournament_third_place: bool = false
var tournament_swiss_rounds: int = 5
var tournament_blitz_enabled: bool = false
var tournament_blitz_timer_seconds: int = 10
var tournament_blitz_turn_limit: int = 140
var tournament_participants: Array = []
var active_tournament_data: Dictionary = {}
var pending_tournament_match: Dictionary = {}
var tournament_match_takeover_gold: bool = false
var tournament_match_takeover_silver: bool = false
var current_match_is_tournament: bool = false
var current_tournament_match_id: String = ""
var menu_preview_board: BoardView
var menu_preview_rules: SigmaRules
var menu_preview_label: Label
var continue_game_button: Button
var save_status_label: Label
var session_panel: PanelContainer
var pause_cover_rect: ColorRect
var new_game_confirm_cover: ColorRect
var new_game_confirm_panel: PanelContainer
var new_game_confirm_title_label: Label
var new_game_confirm_body_label: Label
var new_game_confirm_primary_button: Button
var pending_new_game_mode: String = ""
var pending_draft_config: Dictionary = {}


var dev_lab_visible_from_settings: bool = false
var sound_enabled: bool = true
var last_sound_cue: String = ""
var last_haptic_cue: String = ""
var tutorial_active: bool = false
var tutorial_step_loaded: bool = false
var tutorial_complete: bool = false
var tutorial_feedback_label: Label
var tutorial_progress_label: Label
var tutorial_completed_steps: Dictionary = {}

var last_selected_kind: String = ""
var last_selected_owner: int = -1
var last_selected_pos: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	rules = SigmaRules.new()
	ai_engine = SIGMA_AI_SCRIPT.new()
	_load_user_progress()
	_init_tutorial_steps()
	_init_rules_guide_pages()
	_build_ui()
	_sync_audio_from_manager()
	_start_new_game(false)
	_show_first_time_menu()

func _process(delta: float) -> void:
	_update_resume_countdown(delta)
	_update_speed_timer(delta)

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.name = "SigmaVoidBackground"
	bg.color = Color("#0B1020")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root: VBoxContainer = VBoxContainer.new()
	root.name = "RootLayout"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	root.offset_left = 14
	root.offset_top = 10
	root.offset_right = -14
	root.offset_bottom = -10
	add_child(root)

	title_label = Label.new()
	title_label.text = "SIGMA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	root.add_child(title_label)

	turn_banner = Label.new()
	turn_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	turn_banner.add_theme_font_size_override("font_size", 23)
	turn_banner.add_theme_color_override("font_color", Color("#F2C14E"))
	root.add_child(turn_banner)

	top_controls_bar = HBoxContainer.new()
	top_controls_bar.name = "TopControls"
	top_controls_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_controls_bar.add_theme_constant_override("separation", 8)
	root.add_child(top_controls_bar)

	# Keep the mode selector as hidden state for the rules engine. The app shell
	# now owns public navigation: Quick Play, Full SIGMA, Draft SIGMA, Tutorial,
	# Rules Guide, and Settings.
	mode_option = OptionButton.new()
	mode_option.add_item("Classic", 0)
	mode_option.add_item("Sentinel", 1)
	mode_option.add_item("Full", 2)
	mode_option.visible = false
	top_controls_bar.add_child(mode_option)

	_add_button(top_controls_bar, "Pause", "Open the in-game session menu.", _on_game_menu_pressed)
	tutorial_button = _add_button(top_controls_bar, "Tutorial", "Open the interactive tutorial.", _on_tutorial_pressed)
	_add_button(top_controls_bar, "Rules", "Open the compact in-game rules guide.", _on_rules_guide_pressed)
	settings_button = _add_button(top_controls_bar, "Settings", "Open settings and development tools.", _on_settings_pressed)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	root.add_child(status_label)

	counts_label = Label.new()
	counts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counts_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	counts_label.add_theme_font_size_override("font_size", 13)
	counts_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	root.add_child(counts_label)

	_build_scenario_lab(root)

	board_holder_ref = Control.new()
	board_holder_ref.name = "BoardHolder"
	board_holder_ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_holder_ref.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(board_holder_ref)

	board_view = BoardView.new()
	board_view.name = "BoardView"
	board_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_view.action_chosen.connect(_on_action_chosen)
	board_view.selection_changed.connect(_on_selection_changed)
	board_view.piece_focus_changed.connect(_on_piece_focus_changed)
	board_view.preview_cancel_requested.connect(_on_preview_cancel_requested_from_board)
	board_view.info_requested.connect(_on_board_info_requested)
	board_holder_ref.add_child(board_view)
	_build_menu_page_backdrop(board_holder_ref)
	_build_floating_gameplay_hud(board_holder_ref)
	_build_tabletop_passplay_layer(board_holder_ref)
	_build_preview_panel(board_holder_ref)
	_build_elevate_panel(board_holder_ref)

	_build_result_overlay(board_holder_ref)

	_build_tutorial_panel(board_holder_ref)
	_build_settings_panel(board_holder_ref)
	_build_rules_guide_panel(board_holder_ref)
	_build_collections_panel(board_holder_ref)
	_build_custom_game_panel(board_holder_ref)
	_build_draft_panel(board_holder_ref)
	_build_session_panel(board_holder_ref)
	_build_turn_handoff_panel(board_holder_ref)
	_build_main_menu_panel(board_holder_ref)
	_build_new_game_panel(board_holder_ref)
	_build_new_game_confirm_dialog()
	_build_startup_splash()
	_apply_active_piece_set_to_board_views()

	selection_label = Label.new()
	selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_label.add_theme_font_size_override("font_size", 15)
	selection_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	root.add_child(selection_label)


	bottom_controls_bar = HBoxContainer.new()
	bottom_controls_bar.name = "BottomActionBar"
	bottom_controls_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_controls_bar.add_theme_constant_override("separation", 12)
	root.add_child(bottom_controls_bar)

	deploy_button = _add_button(bottom_controls_bar, "Deploy: OFF", "Turn on, tap a friendly piece, then tap a green Deploy space.", _on_deploy_button_pressed)
	deploy_button.toggle_mode = true
	deploy_button.custom_minimum_size = Vector2(170, 58)

	# Undo is a developer/test utility. Hide it from the normal thumb-friendly match bar
	# so the player sees only real in-match commands.
	undo_button = _add_button(bottom_controls_bar, "Undo", "Developer utility: undo the last action for local testing.", _on_undo_pressed)
	undo_button.custom_minimum_size = Vector2(96, 50)
	undo_button.visible = false
	info_button = _add_button(bottom_controls_bar, "Guide", "Show rules for the selected piece, or a compact piece guide if none is selected.", _on_info_pressed)
	info_button.custom_minimum_size = Vector2(160, 58)
	info_button.visible = false
	pause_button = _add_button(bottom_controls_bar, "Pause", "Open the match control panel.", _on_game_menu_pressed)
	pause_button.custom_minimum_size = Vector2(160, 58)

	_adopt_mobile_command_buttons()

	piece_help_label = Label.new()
	piece_help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	piece_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	piece_help_label.add_theme_font_size_override("font_size", 14)
	piece_help_label.text = "Piece Guide: tap a piece, then press Guide. Direct Peril uses movement geometry."
	piece_help_label.visible = false
	root.add_child(piece_help_label)

	action_log_label = Label.new()
	action_log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_log_label.add_theme_font_size_override("font_size", 13)
	action_log_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	root.add_child(action_log_label)

	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_font_size_override("font_size", 13)
	result_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	result_label.text = "Pieces are captured. Friendly boxed-in pieces may Retreat. Monarchs surrender."
	root.add_child(result_label)

	mobile_hint_label = Label.new()
	mobile_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mobile_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mobile_hint_label.add_theme_font_size_override("font_size", 12)
	mobile_hint_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	mobile_hint_label.text = "Tap a piece, then tap a highlight. Use Deploy only when placing a Reserve Guardian."
	root.add_child(mobile_hint_label)

	scenario_label = Label.new()
	scenario_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scenario_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scenario_label.add_theme_font_size_override("font_size", 12)
	scenario_label.visible = false
	root.add_child(scenario_label)
	_set_gameplay_chrome_visible(false)


func _build_floating_gameplay_hud(parent: Control) -> void:
	floating_hud_layer = Control.new()
	floating_hud_layer.name = "FloatingGameplayHUD"
	floating_hud_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	floating_hud_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(floating_hud_layer)

	# True non-tabletop command-board presentation: top opponent console,
	# centered event callouts, and a bottom player console with integrated
	# live reserve tray and command dock.
	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.offset_left = 8
	top_margin.offset_right = -8
	top_margin.offset_top = 8
	top_margin.offset_bottom = 120
	top_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floating_hud_layer.add_child(top_margin)

	var top_frame: PanelContainer = PanelContainer.new()
	top_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_frame.add_theme_stylebox_override("panel", _make_rounded_style(Color("#06111D", 0.94), Color("#00D1FF", 0.72), 2, 22))
	top_margin.add_child(top_frame)

	var top_stack: VBoxContainer = VBoxContainer.new()
	top_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	top_stack.add_theme_constant_override("separation", 8)
	top_frame.add_child(top_stack)

	var match_row: HBoxContainer = HBoxContainer.new()
	match_row.alignment = BoxContainer.ALIGNMENT_CENTER
	match_row.add_theme_constant_override("separation", 6)
	top_stack.add_child(match_row)

	hud_silver_panel_label = _make_hud_chip("Rookie Bot · Silver", Color("#D8E2F0"))
	hud_silver_panel_label.get_parent().custom_minimum_size = Vector2(174, 44)
	match_row.add_child(hud_silver_panel_label.get_parent())

	var silver_tray: PanelContainer = PanelContainer.new()
	silver_tray.custom_minimum_size = Vector2(190, 44)
	silver_tray.add_theme_stylebox_override("panel", _make_rounded_style(Color("#030812", 0.98), Color("#D8E2F0"), 1, 18))
	match_row.add_child(silver_tray)
	mobile_silver_rack_box = HBoxContainer.new()
	mobile_silver_rack_box.alignment = BoxContainer.ALIGNMENT_CENTER
	mobile_silver_rack_box.add_theme_constant_override("separation", 3)
	silver_tray.add_child(mobile_silver_rack_box)

	hud_round_chip = _make_hud_chip("Round 1/100", Color("#F2C14E"))
	hud_round_chip.get_parent().custom_minimum_size = Vector2(152, 48)
	hud_round_chip.add_theme_font_size_override("font_size", 16)
	match_row.add_child(hud_round_chip.get_parent())

	hud_timer_chip = _make_hud_chip("Timer OFF", Color("#E8EDF2"))
	hud_timer_chip.get_parent().custom_minimum_size = Vector2(136, 48)
	hud_timer_chip.add_theme_font_size_override("font_size", 16)
	match_row.add_child(hud_timer_chip.get_parent())

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 7)
	top_stack.add_child(status_row)

	hud_turn_chip = _make_hud_chip("Gold Turn", Color("#F2C14E"))
	hud_turn_chip.get_parent().custom_minimum_size = Vector2(148, 36)
	status_row.add_child(hud_turn_chip.get_parent())

	hud_mode_chip = _make_hud_chip("Classic SIGMA", Color("#00D1FF"))
	hud_mode_chip.get_parent().custom_minimum_size = Vector2(218, 36)
	status_row.add_child(hud_mode_chip.get_parent())

	hud_counts_chip = _make_hud_chip("Captures 0/0", Color("#E8EDF2"))
	hud_counts_chip.get_parent().custom_minimum_size = Vector2(168, 38)
	hud_counts_chip.add_theme_font_size_override("font_size", 14)
	status_row.add_child(hud_counts_chip.get_parent())

	var bottom_margin: MarginContainer = MarginContainer.new()
	bottom_margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_margin.offset_left = 16
	bottom_margin.offset_right = -16
	bottom_margin.offset_top = -216
	bottom_margin.offset_bottom = -24
	bottom_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floating_hud_layer.add_child(bottom_margin)

	var bottom_frame: PanelContainer = PanelContainer.new()
	bottom_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_frame.add_theme_stylebox_override("panel", _make_rounded_style(Color("#10081A", 0.95), Color("#F2C14E", 0.88), 2, 24))
	bottom_margin.add_child(bottom_frame)

	var bottom_stack: VBoxContainer = VBoxContainer.new()
	bottom_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_stack.add_theme_constant_override("separation", 8)
	bottom_frame.add_child(bottom_stack)

	var player_row: HBoxContainer = HBoxContainer.new()
	player_row.alignment = BoxContainer.ALIGNMENT_CENTER
	player_row.add_theme_constant_override("separation", 10)
	bottom_stack.add_child(player_row)

	hud_gold_panel_label = _make_hud_chip("You · Gold", Color("#F2C14E"))
	hud_gold_panel_label.get_parent().custom_minimum_size = Vector2(168, 36)
	player_row.add_child(hud_gold_panel_label.get_parent())

	var gold_tray: PanelContainer = PanelContainer.new()
	gold_tray.custom_minimum_size = Vector2(258, 46)
	gold_tray.add_theme_stylebox_override("panel", _make_rounded_style(Color("#030812", 0.98), Color("#F2C14E"), 1, 18))
	player_row.add_child(gold_tray)
	mobile_gold_rack_box = HBoxContainer.new()
	mobile_gold_rack_box.alignment = BoxContainer.ALIGNMENT_CENTER
	mobile_gold_rack_box.add_theme_constant_override("separation", 3)
	gold_tray.add_child(mobile_gold_rack_box)

	hud_hint_chip = _make_hud_chip("Your move. Tap a piece.", Color("#F7F3E8"))
	hud_hint_chip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_hint_chip.get_parent().custom_minimum_size = Vector2(0, 44)
	bottom_stack.add_child(hud_hint_chip.get_parent())

	hud_last_action_chip = _make_hud_chip("Last action: none", Color("#B8C4D8"))
	hud_last_action_chip.get_parent().custom_minimum_size = Vector2(0, 30)
	bottom_stack.add_child(hud_last_action_chip.get_parent())

	mobile_command_dock = PanelContainer.new()
	mobile_command_dock.custom_minimum_size = Vector2(0, 72)
	mobile_command_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_command_dock.add_theme_stylebox_override("panel", _make_rounded_style(Color("#06111D", 0.92), Color("#00D1FF", 0.45), 2, 20))
	bottom_stack.add_child(mobile_command_dock)

	mobile_command_row = HBoxContainer.new()
	mobile_command_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mobile_command_row.add_theme_constant_override("separation", 12)
	mobile_command_dock.add_child(mobile_command_row)

	event_word_label = Label.new()
	event_word_label.name = "SigmaCommandCallout"
	event_word_label.set_anchors_preset(Control.PRESET_CENTER)
	event_word_label.offset_left = -250
	event_word_label.offset_right = 250
	event_word_label.offset_top = -48
	event_word_label.offset_bottom = 48
	event_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_word_label.add_theme_font_size_override("font_size", 34)
	event_word_label.add_theme_color_override("font_color", Color("#F2C14E"))
	event_word_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.78))
	event_word_label.add_theme_constant_override("shadow_offset_x", 3)
	event_word_label.add_theme_constant_override("shadow_offset_y", 4)
	event_word_label.visible = false
	floating_hud_layer.add_child(event_word_label)

	_build_info_bubble(parent)


func _adopt_mobile_command_buttons() -> void:
	if mobile_command_row == null:
		return
	var buttons: Array = [deploy_button, pause_button]
	for button_value in buttons:
		var b: Button = button_value as Button
		if b == null:
			continue
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(max(int(b.custom_minimum_size.x), 188), 64)
		var parent_node: Node = b.get_parent()
		if parent_node != null:
			parent_node.remove_child(b)
		mobile_command_row.add_child(b)
	if bottom_controls_bar != null:
		bottom_controls_bar.visible = false

func _build_tabletop_passplay_layer(parent: Control) -> void:
	tabletop_layer = Control.new()
	tabletop_layer.name = "TabletopPassPlayLayer"
	tabletop_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabletop_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tabletop_layer.visible = false
	parent.add_child(tabletop_layer)

	tabletop_silver_bar = _make_tabletop_side_bar(SigmaRules.OWNER_P2)
	tabletop_silver_bar.name = "SilverTabletopBar"
	tabletop_silver_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tabletop_silver_bar.offset_left = 10
	tabletop_silver_bar.offset_right = -10
	tabletop_silver_bar.offset_top = 8
	tabletop_silver_bar.offset_bottom = 176
	tabletop_layer.add_child(tabletop_silver_bar)

	tabletop_gold_bar = _make_tabletop_side_bar(SigmaRules.OWNER_P1)
	tabletop_gold_bar.name = "GoldTabletopBar"
	tabletop_gold_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	tabletop_gold_bar.offset_left = 10
	tabletop_gold_bar.offset_right = -10
	tabletop_gold_bar.offset_top = -188
	tabletop_gold_bar.offset_bottom = -20
	tabletop_layer.add_child(tabletop_gold_bar)

func _make_tabletop_side_bar(owner: int) -> PanelContainer:
	var accent: Color = Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#D8E2F0")
	var bar: PanelContainer = PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020711", 0.97), accent, 2, 22))

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	bar.add_child(box)

	var header_row: HBoxContainer = HBoxContainer.new()
	header_row.alignment = BoxContainer.ALIGNMENT_CENTER
	header_row.add_theme_constant_override("separation", 12)
	box.add_child(header_row)

	var status: Label = _make_hud_chip("Gold", accent)
	status.get_parent().custom_minimum_size = Vector2(126, 34)
	header_row.add_child(status.get_parent())

	var turn_chip: Label = _make_hud_chip("Ready", accent)
	turn_chip.get_parent().custom_minimum_size = Vector2(178, 42)
	turn_chip.add_theme_font_size_override("font_size", 15)
	header_row.add_child(turn_chip.get_parent())

	var clock: Label = _make_hud_chip("Timer OFF", Color("#E8EDF2"))
	clock.get_parent().custom_minimum_size = Vector2(204, 42)
	clock.add_theme_font_size_override("font_size", 15)
	header_row.add_child(clock.get_parent())

	var reserve_row: HBoxContainer = HBoxContainer.new()
	reserve_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reserve_row.add_theme_constant_override("separation", 10)
	box.add_child(reserve_row)

	var rack_label: Label = Label.new()
	rack_label.text = "Reserve Tray"
	rack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rack_label.custom_minimum_size = Vector2(94, 28)
	rack_label.add_theme_font_size_override("font_size", 12)
	rack_label.add_theme_color_override("font_color", accent)
	reserve_row.add_child(rack_label)

	var rack_tray: PanelContainer = PanelContainer.new()
	rack_tray.custom_minimum_size = Vector2(360, 46)
	rack_tray.add_theme_stylebox_override("panel", _make_rounded_style(Color("#030812", 0.98), accent, 2, 18))
	reserve_row.add_child(rack_tray)

	var rack_box: HBoxContainer = HBoxContainer.new()
	rack_box.alignment = BoxContainer.ALIGNMENT_CENTER
	rack_box.add_theme_constant_override("separation", 4)
	rack_tray.add_child(rack_box)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)

	var deploy: Button = _make_tabletop_button("Deploy", "Turn Deploy on for this player.", func() -> void: _on_tabletop_deploy_pressed(owner), "green")
	var pause: Button = _make_tabletop_button("Pause", "Quick Pause: hide the board and pause the timer.", _on_game_menu_pressed, "gold")
	deploy.custom_minimum_size = Vector2(168, 54)
	pause.custom_minimum_size = Vector2(168, 54)
	row.add_child(deploy)
	row.add_child(pause)
	var guide: Button = null

	var prompt: Label = Label.new()
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 11)
	prompt.add_theme_color_override("font_color", Color("#B8C4D8"))
	prompt.custom_minimum_size = Vector2(0, 18)
	box.add_child(prompt)

	if owner == SigmaRules.OWNER_P1:
		tabletop_gold_status_label = status
		tabletop_gold_rack_label = rack_label
		tabletop_gold_rack_box = rack_box
		tabletop_gold_prompt_label = prompt
		tabletop_gold_clock_label = clock
		tabletop_gold_deploy_button = deploy
		tabletop_gold_guide_button = guide
		tabletop_gold_pause_button = pause
	else:
		tabletop_silver_status_label = status
		tabletop_silver_rack_label = rack_label
		tabletop_silver_rack_box = rack_box
		tabletop_silver_prompt_label = prompt
		tabletop_silver_clock_label = clock
		tabletop_silver_deploy_button = deploy
		tabletop_silver_guide_button = guide
		tabletop_silver_pause_button = pause

	return bar


func _make_tabletop_button(text: String, tooltip: String, callback: Callable, role: String) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.tooltip_text = tooltip
	b.custom_minimum_size = Vector2(150, 52)
	_style_button(b, role)
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	b.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		callback.call()
	)
	return b


func _reserve_token_texture_path(owner: int, kind: String) -> String:
	var side: String = "gold" if owner == SigmaRules.OWNER_P1 else "silver"
	var role: String = "guardian"
	match kind:
		SigmaRules.KIND_MONARCH:
			role = "monarch"
		SigmaRules.KIND_GUARDIAN:
			role = "guardian"
		SigmaRules.KIND_SENTINEL:
			role = "sentinel"
		SigmaRules.KIND_INFILTRATOR:
			role = "infiltrator"
		SigmaRules.KIND_ASSASSIN:
			role = "assassin"
		_:
			role = "guardian"
	return "res://assets/pieces/classic_sigma_tokens/%s_%s.png" % [side, role]

func _make_reserve_piece_tile(owner: int, kind: String, active: bool, tile_size: int = 30) -> PanelContainer:
	# Reserve tray pieces should be the real Classic SIGMA token art, simply
	# scaled down to tray size. This keeps reserves visually identical to the
	# physical pieces on the board instead of using placeholder letter chips.
	var gold_side: bool = owner == SigmaRules.OWNER_P1
	var border: Color = Color("#F2C14E") if gold_side else Color("#D8E2F0")
	var tile: PanelContainer = PanelContainer.new()
	tile.custom_minimum_size = Vector2(tile_size, tile_size)
	tile.size = Vector2(tile_size, tile_size)
	tile.modulate = Color(1, 1, 1, 1) if active else Color(0.64, 0.64, 0.64, 0.78)
	tile.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020711", 0.22), border, 1, int(tile_size * 0.5)))

	var tex: Texture2D = load(_reserve_token_texture_path(owner, kind)) as Texture2D
	if tex != null:
		var img: TextureRect = TextureRect.new()
		img.texture = tex
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.custom_minimum_size = Vector2(tile_size, tile_size)
		img.size = Vector2(tile_size, tile_size)
		tile.add_child(img)
	else:
		var lbl: Label = Label.new()
		lbl.text = kind
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(tile_size, tile_size)
		lbl.add_theme_font_size_override("font_size", int(max(10, int(tile_size * 0.50))))
		lbl.add_theme_color_override("font_color", Color("#F7F3E8"))
		tile.add_child(lbl)
	return tile

func _reserve_piece_codes(owner: int) -> Array:
	var pieces: Array = []
	if rules == null:
		return pieces
	for i in range(int(rules.reserves[owner])):
		pieces.append(SigmaRules.KIND_GUARDIAN)
	# Future-ready: advanced pieces that Retreat can be displayed here when
	# the rules engine exposes an off-board advanced reserve list.
	return pieces


func _refresh_reserve_rack_box(rack_box: HBoxContainer, owner: int, active: bool, max_visible: int = 12, tile_size: int = 22) -> void:
	if rack_box == null or rules == null:
		return
	for child in rack_box.get_children():
		child.queue_free()
	var pieces: Array = _reserve_piece_codes(owner)
	if pieces.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 11)
		empty_label.add_theme_color_override("font_color", Color("#7A8796"))
		rack_box.add_child(empty_label)
		return
	var shown: int = int(min(int(pieces.size()), max_visible))
	for i in range(shown):
		rack_box.add_child(_make_reserve_piece_tile(owner, String(pieces[i]), active, tile_size))
	if pieces.size() > shown:
		var more_label: Label = Label.new()
		more_label.text = "+%d" % int(pieces.size() - shown)
		more_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		more_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		more_label.custom_minimum_size = Vector2(30, tile_size)
		more_label.add_theme_font_size_override("font_size", 12)
		more_label.add_theme_color_override("font_color", Color("#F7F3E8"))
		rack_box.add_child(more_label)


func _refresh_tabletop_rack(owner: int, active: bool) -> void:
	var rack_box: HBoxContainer = tabletop_gold_rack_box if owner == SigmaRules.OWNER_P1 else tabletop_silver_rack_box
	# Reserve trays can grow above 5 in rare Retreat cases. Show as many live
	# tokens as the tray can comfortably hold, then summarize overflow.
	_refresh_reserve_rack_box(rack_box, owner, active, 10, 30)


func _tabletop_rack_tiles(owner: int) -> String:
	if rules == null:
		return "Reserve: [ ]"
	var count: int = int(rules.reserves[owner])
	var tiles: Array = []
	for i in range(count):
		tiles.append("[G]")
	if tiles.is_empty():
		return "Reserve: [empty]"
	return "Reserve: %s" % " ".join(tiles)

func _defer_tabletop_layout_refresh() -> void:
	if tabletop_layout_retry_pending:
		return
	tabletop_layout_retry_pending = true
	call_deferred("_run_deferred_tabletop_layout_refresh")

func _run_deferred_tabletop_layout_refresh() -> void:
	tabletop_layout_retry_pending = false
	_update_tabletop_passplay_ui()
	if board_view != null:
		board_view.queue_redraw()

func _apply_tabletop_bar_orientation(bar: PanelContainer, owner: int, active: bool) -> void:
	if bar == null:
		return
	# During the first frame after loading/resuming, anchored Control sizes can
	# still be zero. Rotating Silver around a zero-size pivot causes the command
	# center to appear huge, shifted, and half off-screen until the next update.
	# Wait one deferred layout pass, then rotate around the real center.
	if bar.size.x <= 2.0 or bar.size.y <= 2.0:
		bar.visible = false
		bar.rotation_degrees = 0
		bar.pivot_offset = Vector2.ZERO
		_defer_tabletop_layout_refresh()
		return
	bar.visible = true
	bar.modulate = Color(1, 1, 1, 1) if active else Color(0.52, 0.52, 0.52, 0.58)
	bar.pivot_offset = bar.size * 0.5
	bar.rotation_degrees = 180 if owner == SigmaRules.OWNER_P2 else 0

func _update_tabletop_side(owner: int) -> void:
	if rules == null:
		return
	if rules.board.is_empty():
		return
	var active: bool = rules.turn == owner and not rules.game_over and not rules.has_pending_elevation()
	var bar: PanelContainer = tabletop_gold_bar if owner == SigmaRules.OWNER_P1 else tabletop_silver_bar
	var status: Label = tabletop_gold_status_label if owner == SigmaRules.OWNER_P1 else tabletop_silver_status_label
	var rack: Label = tabletop_gold_rack_label if owner == SigmaRules.OWNER_P1 else tabletop_silver_rack_label
	var prompt: Label = tabletop_gold_prompt_label if owner == SigmaRules.OWNER_P1 else tabletop_silver_prompt_label
	var clock: Label = tabletop_gold_clock_label if owner == SigmaRules.OWNER_P1 else tabletop_silver_clock_label
	var deploy: Button = tabletop_gold_deploy_button if owner == SigmaRules.OWNER_P1 else tabletop_silver_deploy_button
	var guide: Button = tabletop_gold_guide_button if owner == SigmaRules.OWNER_P1 else tabletop_silver_guide_button
	var pause: Button = tabletop_gold_pause_button if owner == SigmaRules.OWNER_P1 else tabletop_silver_pause_button
	var name: String = _player_name(owner)

	if status != null:
		status.text = "%s%s" % [("▶ " if active else "• "), name]
	if clock != null:
		clock.text = _player_clock_text(owner)
		clock.add_theme_color_override("font_color", _player_clock_color(owner))
	if rack != null:
		rack.text = "Reserves"
		rack.add_theme_color_override("font_color", Color("#B8C4D8") if active else Color("#5B6674"))
	_refresh_tabletop_rack(owner, active)
	if prompt != null:
		if active:
			if board_view != null and board_view.deploy_mode:
				prompt.text = "Deploy ON · choose a green space"
			elif rules.is_monarch_in_peril(owner):
				prompt.text = "PERIL! Save your Monarch"
			else:
				prompt.text = "Your move"
		else:
			prompt.text = "Waiting"
	_apply_tabletop_bar_orientation(bar, owner, active)
	if deploy != null:
		deploy.disabled = not active
		deploy.text = "Deploy: ON" if (active and board_view != null and board_view.deploy_mode) else "Deploy"
		deploy.tooltip_text = "Deploy from %s Reserves." % name
	if guide != null:
		guide.disabled = false
	if pause != null:
		pause.disabled = rules.game_over


func _is_tabletop_active_for_current_context() -> bool:
	# v2.2.0 hard product rule:
	# - Offline Human vs Human is always Tabletop.
	# - Single Player vs AI is always Non-tabletop/mobile.
	# - Future Online play should also stay Non-tabletop/mobile.
	if single_player_enabled:
		return false
	if tutorial_active:
		return false
	if bool(current_match_config.get("online_match", false)):
		return false
	var showing_menu: bool = (main_menu_panel != null and main_menu_panel.visible) or (menu_page_backdrop != null and menu_page_backdrop.visible)
	if showing_menu:
		return false
	return true

func _update_tabletop_passplay_ui() -> void:
	var showing_menu: bool = (main_menu_panel != null and main_menu_panel.visible) or (menu_page_backdrop != null and menu_page_backdrop.visible)
	# Keep legacy settings variables safe internally, but do not expose layout toggles.
	tabletop_passplay_enabled = not single_player_enabled
	board_flip_enabled = false
	turn_handoff_enabled = false
	var active_tabletop: bool = _is_tabletop_active_for_current_context()
	if tabletop_layer != null:
		tabletop_layer.visible = active_tabletop
	if board_view != null:
		board_view.set_tabletop_arena_mode(active_tabletop)
	_update_tabletop_side(SigmaRules.OWNER_P1)
	_update_tabletop_side(SigmaRules.OWNER_P2)
	_layout_preview_panel()
	if rules != null and rules.has_pending_elevation():
		_layout_elevate_panel(rules.get_pending_elevation_owner())

	if bottom_controls_bar != null:
		bottom_controls_bar.visible = false
	if floating_hud_layer != null:
		floating_hud_layer.visible = not active_tabletop and not showing_menu


func _make_hud_chip(text: String, accent: Color) -> Label:
	var chip: PanelContainer = PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.custom_minimum_size = Vector2(100, 34)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#12091E", 0.86)
	style.border_color = accent
	style.set_border_width_all(2)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	chip.add_theme_stylebox_override("panel", style)
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", accent)
	chip.add_child(label)
	return label

func _build_info_bubble(parent: Control) -> void:
	info_bubble_panel = _make_center_panel("LongPressInfoBubble", Vector2(520, 230))
	info_bubble_panel.visible = false
	info_bubble_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(info_bubble_panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	info_bubble_panel.add_child(box)
	info_bubble_title_label = Label.new()
	info_bubble_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_bubble_title_label.add_theme_font_size_override("font_size", 22)
	info_bubble_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(info_bubble_title_label)
	info_bubble_body_label = Label.new()
	info_bubble_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_bubble_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_bubble_body_label.add_theme_font_size_override("font_size", 15)
	info_bubble_body_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	box.add_child(info_bubble_body_label)
	var close_row: HBoxContainer = HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(close_row)
	_add_button(close_row, "Close", "Close info bubble.", func() -> void:
		info_bubble_panel.visible = false
	)


func _build_menu_page_backdrop(parent: Control) -> void:
	menu_page_backdrop = ColorRect.new()
	menu_page_backdrop.name = "MenuPageBackdrop"
	menu_page_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_page_backdrop.color = Color("#050715")
	menu_page_backdrop.visible = false
	menu_page_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(menu_page_backdrop)

func _show_menu_page_backdrop(page_context: String = "main") -> void:
	# Non-game pages are true menu locations, not game-board overlays.
	# The active board stays hidden behind this full backdrop until gameplay starts.
	if menu_page_backdrop != null:
		menu_page_backdrop.visible = true
		match page_context:
			"settings":
				menu_page_backdrop.color = Color("#050B17")
			"rules":
				menu_page_backdrop.color = Color("#070717")
			"tutorial":
				menu_page_backdrop.color = Color("#060A18")
			"setup":
				menu_page_backdrop.color = Color("#080017")
			_:
				menu_page_backdrop.color = Color("#050715")
	_update_tabletop_passplay_ui()

func _hide_menu_page_backdrop() -> void:
	if menu_page_backdrop != null:
		menu_page_backdrop.visible = false


func _build_turn_handoff_panel(parent: Control) -> void:
	turn_handoff_panel = _make_center_panel("TurnHandoffPanel", Vector2(500, 250))
	turn_handoff_panel.visible = false
	turn_handoff_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(turn_handoff_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	turn_handoff_panel.add_child(box)

	handoff_title_label = Label.new()
	handoff_title_label.text = "PASS DEVICE"
	handoff_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	handoff_title_label.add_theme_font_size_override("font_size", 32)
	handoff_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(handoff_title_label)

	handoff_body_label = Label.new()
	handoff_body_label.text = "Turn complete. Hand the device to the next player."
	handoff_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	handoff_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	handoff_body_label.add_theme_font_size_override("font_size", 16)
	handoff_body_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	box.add_child(handoff_body_label)

	handoff_start_button = _add_button(box, "Start Turn", "Begin the next player's turn.", _on_start_next_turn_pressed)
	handoff_start_button.custom_minimum_size = Vector2(240, 58)

	var note: Label = Label.new()
	note.text = "SIGMA layout is automatic: Human vs Human uses Tabletop. AI/Online uses mobile command mode."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(note)

func _add_button(parent: Container, text: String, tooltip: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	var is_back_button: bool = text.strip_edges().to_lower() == "back"
	button.text = "←" if is_back_button else text
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(72, 58) if is_back_button else Vector2(160, 68)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if is_back_button else Control.SIZE_EXPAND_FILL
	button.clip_text = true
	button.focus_mode = Control.FOCUS_NONE
	_style_button(button, _button_role_from_text(text))
	if is_back_button:
		button.add_theme_font_size_override("font_size", 28)
	button.mouse_entered.connect(func() -> void:
		_play_sound_cue("button_hover")
	)
	button.focus_entered.connect(func() -> void:
		_play_sound_cue("button_hover")
	)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		_punch_button(button)
		callback.call()
	)
	parent.add_child(button)
	return button

func _add_top_right_close_button(parent: Container, tooltip: String, callback: Callable) -> Button:
	# Familiar page close pattern for non-game screens: X lives at the top-right.
	# Pause remains reserved for active gameplay only.
	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 0)
	parent.add_child(row)
	var button: Button = Button.new()
	button.text = "X"
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(60, 56)
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_stylebox_override("normal", _make_rounded_style(Color("#060A14", 0.96), Color("#4A5D75"), 1, 24))
	button.add_theme_stylebox_override("hover", _make_rounded_style(Color("#172033", 0.98), Color("#D4AF37"), 2, 24))
	button.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#030611", 0.98), Color("#00D1FF"), 2, 24))
	button.mouse_entered.connect(func() -> void:
		_play_sound_cue("button_hover")
	)
	button.focus_entered.connect(func() -> void:
		_play_sound_cue("button_hover")
	)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		callback.call()
	)
	row.add_child(button)
	return button

func _make_center_panel(panel_name: String, min_size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = min_size
	# PRESET_CENTER anchors the top-left corner at the center unless offsets are set.
	# These offsets make tutorial/settings/result overlays truly centered on the board holder.
	panel.offset_left = -min_size.x * 0.5
	panel.offset_top = -min_size.y * 0.5
	panel.offset_right = min_size.x * 0.5
	panel.offset_bottom = min_size.y * 0.5
	panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.97), Color("#D4AF37"), 2, 28))
	return panel



func _make_rounded_style(bg: Color, border: Color, border_width: int = 2, radius: int = 14) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 3)
	style.anti_aliasing = true
	return style

func _style_button(button: Button, role: String = "blue") -> void:
	var normal_bg: Color = Color("#071225")
	var hover_bg: Color = Color("#0B213D")
	var pressed_bg: Color = Color("#030915")
	var border: Color = Color("#00D1FF")
	var font: Color = Color("#F7F3E8")
	var radius: int = 20
	if role == "gold":
		normal_bg = Color("#A86D16")
		hover_bg = Color("#D9A93A")
		pressed_bg = Color("#6D4309")
		border = Color("#FFF3A6")
		font = Color("#180D03")
		radius = 26
	elif role == "green":
		normal_bg = Color("#0A2F24")
		hover_bg = Color("#0E573D")
		pressed_bg = Color("#041E15")
		border = Color("#31E58B")
	elif role == "red":
		normal_bg = Color("#34101A")
		hover_bg = Color("#651B32")
		pressed_bg = Color("#21070E")
		border = Color("#FF5E78")
	elif role == "violet":
		normal_bg = Color("#211241")
		hover_bg = Color("#3B2475")
		pressed_bg = Color("#130A28")
		border = Color("#A78BFA")
	elif role == "dark":
		normal_bg = Color("#070B14")
		hover_bg = Color("#111827")
		pressed_bg = Color("#02040A")
		border = Color("#4A5D75")
	elif role == "menu":
		normal_bg = Color("#0C1328")
		hover_bg = Color("#172748")
		pressed_bg = Color("#050815")
		border = Color("#D4AF37")
		radius = 26
	button.add_theme_stylebox_override("normal", _make_rounded_style(normal_bg, border, 2, radius))
	button.add_theme_stylebox_override("hover", _make_rounded_style(hover_bg, border.lightened(0.18), 2, radius))
	button.add_theme_stylebox_override("pressed", _make_rounded_style(pressed_bg, Color("#00D1FF"), 2, radius))
	button.add_theme_stylebox_override("focus", _make_rounded_style(hover_bg, Color("#00D1FF"), 2, radius))
	button.add_theme_stylebox_override("disabled", _make_rounded_style(Color("#080D18"), Color("#283142"), 1, radius))
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font.lightened(0.10))
	button.add_theme_color_override("font_pressed_color", font)
	button.add_theme_color_override("font_disabled_color", Color("#667085"))
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.62))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)

func _punch_button(button: Button) -> void:
	if button == null:
		return
	button.pivot_offset = button.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.96, 0.96), 0.045).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _button_role_from_text(text: String) -> String:
	var lower: String = text.to_lower()
	if lower.find("quick") >= 0 or lower.find("start") >= 0 or lower.find("next") >= 0 or lower.find("play") >= 0:
		return "gold"
	if lower.find("deploy") >= 0:
		return "green"
	if lower.find("cancel") >= 0 or lower.find("back") >= 0 or lower.find("close") >= 0:
		return "dark"
	if lower.find("undo") >= 0 or lower.find("illegal") >= 0 or lower.find("reset") >= 0:
		return "red"
	if lower.find("tutorial") >= 0 or lower.find("guide") >= 0 or lower.find("settings") >= 0 or lower.find("draft") >= 0 or lower.find("full") >= 0:
		return "violet"
	return "blue"

func _trigger_haptic(cue: String) -> void:
	# Placeholder hook for future mobile / console haptics. Godot platform-specific
	# vibration can connect here later without touching rules or UI flow.
	last_haptic_cue = cue

func _build_preview_panel(parent: Control) -> void:
	preview_panel = PanelContainer.new()
	preview_panel.name = "FloatingActionPreviewPanel"
	preview_panel.visible = false
	preview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	preview_panel.custom_minimum_size = Vector2(430, 112)
	preview_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#101722", 0.94), Color("#F2C14E"), 2, 20))
	parent.add_child(preview_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	preview_panel.add_child(box)

	preview_title_label = Label.new()
	preview_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title_label.add_theme_font_size_override("font_size", 14)
	preview_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	preview_title_label.text = "Preview"
	box.add_child(preview_title_label)

	preview_tags_label = Label.new()
	preview_tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_tags_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_tags_label.add_theme_font_size_override("font_size", 12)
	preview_tags_label.add_theme_color_override("font_color", Color("#00D1FF"))
	box.add_child(preview_tags_label)

	preview_body_label = Label.new()
	preview_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_body_label.add_theme_font_size_override("font_size", 12)
	preview_body_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(preview_body_label)

	var note: Label = Label.new()
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	note.text = "Routine moves commit by tap. Confirm buttons are reserved for destructive choices."
	box.add_child(note)
	preview_confirm_button = null
	preview_cancel_button = null
	_layout_preview_panel()

func _preview_prompt_owner() -> int:
	if not pending_preview_action.is_empty():
		return int(pending_preview_action.get("owner", rules.turn if rules != null else SigmaRules.OWNER_P1))
	if rules != null:
		return rules.turn
	return SigmaRules.OWNER_P1

func _gap_prompt_y(owner: int, panel_h: float) -> float:
	var holder_h: float = board_holder_ref.size.y if board_holder_ref != null else get_viewport_rect().size.y
	var board_top: float = 0.0
	var board_bottom: float = holder_h * 0.5
	if board_view != null:
		board_top = board_view.board_rect.position.y
		board_bottom = board_view.board_rect.position.y + board_view.board_rect.size.y

	if owner == SigmaRules.OWNER_P2:
		var top_bar_bottom: float = 112.0
		if tabletop_silver_bar != null and tabletop_silver_bar.size.y > 0.0:
			top_bar_bottom = tabletop_silver_bar.position.y + tabletop_silver_bar.size.y
		var gap: float = max(8.0, board_top - top_bar_bottom)
		return top_bar_bottom + max(4.0, (gap - panel_h) * 0.5)

	var bottom_bar_top: float = holder_h - 112.0
	if tabletop_gold_bar != null and tabletop_gold_bar.size.y > 0.0:
		bottom_bar_top = tabletop_gold_bar.position.y
	var gap_bottom: float = max(8.0, bottom_bar_top - board_bottom)
	return board_bottom + max(4.0, (gap_bottom - panel_h) * 0.5)

func _layout_player_prompt_panel(panel: Control, owner: int, panel_w: float, panel_h: float, rotate_for_player: bool = true) -> void:
	if panel == null:
		return
	var holder_w: float = board_holder_ref.size.x if board_holder_ref != null else get_viewport_rect().size.x
	var holder_h: float = board_holder_ref.size.y if board_holder_ref != null else get_viewport_rect().size.y
	var tabletop_active: bool = tabletop_layer != null and tabletop_layer.visible

	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = (holder_w - panel_w) * 0.5
	panel.offset_right = panel.offset_left + panel_w
	panel.offset_top = 0.0
	panel.offset_bottom = panel_h

	if tabletop_active:
		var y: float = _gap_prompt_y(owner, panel_h)
		panel.offset_top = clamp(y, 4.0, max(4.0, holder_h - panel_h - 4.0))
		panel.offset_bottom = panel.offset_top + panel_h
		if rotate_for_player and owner == SigmaRules.OWNER_P2:
			panel.pivot_offset = Vector2(panel_w * 0.5, panel_h * 0.5)
			panel.rotation_degrees = 180
		else:
			panel.pivot_offset = Vector2(panel_w * 0.5, panel_h * 0.5)
			panel.rotation_degrees = 0
	else:
		panel.anchor_left = 0.5
		panel.anchor_right = 0.5
		panel.anchor_top = 1.0
		panel.anchor_bottom = 1.0
		panel.offset_left = -panel_w * 0.5
		panel.offset_right = panel_w * 0.5
		panel.offset_top = -panel_h - 18.0
		panel.offset_bottom = -18.0
		panel.pivot_offset = Vector2(panel_w * 0.5, panel_h * 0.5)
		panel.rotation_degrees = 0

func _layout_preview_panel() -> void:
	if preview_panel == null:
		return
	var holder_w: float = board_holder_ref.size.x if board_holder_ref != null else get_viewport_rect().size.x
	var panel_w: float = min(430.0, max(320.0, holder_w - 44.0))
	var panel_h: float = 112.0
	_layout_player_prompt_panel(preview_panel, _preview_prompt_owner(), panel_w, panel_h, true)



func _build_elevate_panel(parent: Control) -> void:
	elevate_panel = PanelContainer.new()
	elevate_panel.name = "ElevateChoicePanel"
	elevate_panel.visible = false
	elevate_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	elevate_panel.custom_minimum_size = Vector2(540, 228)
	elevate_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#10091D", 0.94), Color("#F2C14E"), 3, 22))
	parent.add_child(elevate_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	elevate_panel.add_child(box)

	elevate_title_label = Label.new()
	elevate_title_label.text = "ELEVATE!"
	elevate_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elevate_title_label.add_theme_font_size_override("font_size", 26)
	elevate_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	elevate_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	elevate_title_label.add_theme_constant_override("shadow_offset_x", 2)
	elevate_title_label.add_theme_constant_override("shadow_offset_y", 3)
	box.add_child(elevate_title_label)

	elevate_subtitle_label = Label.new()
	elevate_subtitle_label.text = "Choose your new advanced piece."
	elevate_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	elevate_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	elevate_subtitle_label.add_theme_font_size_override("font_size", 13)
	elevate_subtitle_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(elevate_subtitle_label)

	var card_row: HBoxContainer = HBoxContainer.new()
	card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_row.add_theme_constant_override("separation", 10)
	box.add_child(card_row)

	for kind_value in [SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]:
		var kind: String = String(kind_value)
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(148, 118)
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "Advanced Cap: max 3 of this advanced piece on board."
		button.pressed.connect(_on_elevate_selected.bind(kind))
		_style_button(button, _elevate_card_role(kind))
		button.add_theme_font_size_override("font_size", 13)
		elevate_buttons[kind] = button
		card_row.add_child(button)
	_layout_elevate_panel(SigmaRules.OWNER_P1)



func _build_scenario_lab(root: VBoxContainer) -> void:
	scenario_panel = VBoxContainer.new()
	scenario_panel.name = "ScenarioLab"
	scenario_panel.visible = false
	scenario_panel.add_theme_constant_override("separation", 4)
	root.add_child(scenario_panel)

	var header: Label = Label.new()
	header.text = "Rules QA Test Menu — development only"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scenario_panel.add_child(header)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	scenario_panel.add_child(row)

	scenario_option = OptionButton.new()
	scenario_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenario_option.custom_minimum_size = Vector2(360, 46)
	row.add_child(scenario_option)

	_add_scenario_option("Classic Setup", "classic_setup")
	_add_scenario_option("Guardian: Orthogonal Move", "guardian_move")
	_add_scenario_option("Guardian: Orthogonal Capture", "guardian_capture")
	_add_scenario_option("Guardian: Orthogonal Deploy", "guardian_deploy")
	_add_scenario_option("Sentinel Movement", "sentinel_movement")
	_add_scenario_option("BLITZ Timeout", "blitz_timeout")
	_add_scenario_option("Result Screen: Surrender", "result_surrender")
	_add_scenario_option("Direct Peril: Guardian", "peril_guardian")
	_add_scenario_option("Direct Peril: Sentinel", "peril_sentinel")
	_add_scenario_option("Direct Peril: Infiltrator 2", "peril_infiltrator_2")
	_add_scenario_option("Direct Peril: Assassin 2", "peril_assassin_2")
	_add_scenario_option("Infiltrator Reach Capture", "infiltrator_reach_capture")
	_add_scenario_option("Assassin Reach Capture", "assassin_reach_capture")
	_add_scenario_option("Direct Peril: Blocked Path", "peril_blocked_path")
	_add_scenario_option("Direct Peril: Monarch Adjacent", "peril_monarch_adjacent")
	_add_scenario_option("Surrender", "surrender")
	_add_scenario_option("Escape From Peril", "escape_peril")
	_add_scenario_option("Deploy", "deploy")
	_add_scenario_option("Illegal Deploy", "illegal_deploy")
	_add_scenario_option("Retreat", "retreat")
	_add_scenario_option("Enemy Surround", "enemy_surround")
	_add_scenario_option("Elevate", "elevate")
	_add_scenario_option("No Cycle", "no_cycle")
	_add_scenario_option("Overtime", "overtime")
	_add_scenario_option("Fallback: Capture Lead", "fallback_capture_lead")
	_add_scenario_option("Fallback: First Blood", "fallback_first_blood")
	_add_scenario_option("Fallback: Survival", "fallback_survival")

	var load_button: Button = Button.new()
	load_button.text = "Load"
	load_button.custom_minimum_size = Vector2(96, 46)
	load_button.pressed.connect(_on_load_scenario_pressed)
	row.add_child(load_button)

	var debug_row: HBoxContainer = HBoxContainer.new()
	debug_row.alignment = BoxContainer.ALIGNMENT_CENTER
	debug_row.add_theme_constant_override("separation", 8)
	scenario_panel.add_child(debug_row)

	_add_button(debug_row, "QA Smoke", "Run a quick rules sanity check without changing the current game.", _on_qa_smoke_pressed)
	_add_button(debug_row, "Test Result", "Load a completed Surrender result screen.", _on_qa_result_pressed)
	_add_button(debug_row, "Force Overtime", "Force the current game into Overtime for validation.", _on_force_overtime_pressed)
	_add_button(debug_row, "Resolve Fallback", "Resolve current debug fallback values.", _on_resolve_fallback_pressed)

	qa_status_label = Label.new()
	qa_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qa_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qa_status_label.add_theme_font_size_override("font_size", 12)
	qa_status_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	scenario_panel.add_child(qa_status_label)

func _add_scenario_option(text: String, scenario_id: String) -> void:
	scenario_option.add_item(text)
	scenario_ids.append(scenario_id)

func _build_result_overlay(parent: Control) -> void:
	result_overlay = _make_center_panel("ResultOverlay", Vector2(520, 275))
	result_overlay.visible = false
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(result_overlay)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	result_overlay.add_child(box)

	result_overlay_label = Label.new()
	result_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_overlay_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_overlay_label.add_theme_font_size_override("font_size", 32)
	result_overlay_label.add_theme_color_override("font_color", Color("#F2C14E"))
	result_overlay_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	result_overlay_label.add_theme_constant_override("shadow_offset_x", 2)
	result_overlay_label.add_theme_constant_override("shadow_offset_y", 3)
	box.add_child(result_overlay_label)

	result_summary_label = Label.new()
	result_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_summary_label.add_theme_font_size_override("font_size", 14)
	result_summary_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	result_summary_label.custom_minimum_size = Vector2(460, 10)
	box.add_child(result_summary_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)

	result_rematch_button = _add_button(row, "Rematch", "Start the same mode again.", _on_result_rematch)
	result_rematch_button.custom_minimum_size = Vector2(132, 48)
	result_new_game_button = _add_button(row, "New Game", "Open the New Game screen.", _on_result_new_game)
	result_new_game_button.custom_minimum_size = Vector2(132, 48)
	result_home_button = _add_button(row, "Return Home", "Return to the Main Page.", _on_result_home)
	result_home_button.custom_minimum_size = Vector2(150, 48)


func _build_tutorial_panel(parent: Control) -> void:
	tutorial_backdrop_layer = TutorialBackdropView.new()
	tutorial_backdrop_layer.name = "TutorialBackdropLayer"
	tutorial_backdrop_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_backdrop_layer.offset_left = 0
	tutorial_backdrop_layer.offset_top = 0
	tutorial_backdrop_layer.offset_right = 0
	tutorial_backdrop_layer.offset_bottom = 0
	tutorial_backdrop_layer.visible = false
	tutorial_backdrop_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(tutorial_backdrop_layer)

	tutorial_panel = _make_center_panel("TutorialPanel", Vector2(540, 440))
	tutorial_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#070B18", 0.98), Color("#F2C14E"), 2, 18))
	tutorial_panel.visible = false
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(tutorial_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	tutorial_panel.add_child(box)
	_add_top_right_close_button(box, "Close tutorial and return to Main Menu.", _on_tutorial_close)

	tutorial_title_label = Label.new()
	tutorial_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_title_label.add_theme_font_size_override("font_size", 24)
	tutorial_title_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	box.add_child(tutorial_title_label)

	tutorial_step_label = Label.new()
	tutorial_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_step_label.add_theme_font_size_override("font_size", 14)
	tutorial_step_label.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(tutorial_step_label)

	tutorial_phase_label = Label.new()
	tutorial_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_phase_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_phase_label.add_theme_font_size_override("font_size", 13)
	tutorial_phase_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(tutorial_phase_label)

	tutorial_progress_label = Label.new()
	tutorial_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_progress_label.add_theme_font_size_override("font_size", 12)
	tutorial_progress_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(tutorial_progress_label)

	tutorial_checklist_label = Label.new()
	tutorial_checklist_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_checklist_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_checklist_label.add_theme_font_size_override("font_size", 12)
	tutorial_checklist_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(tutorial_checklist_label)
	tutorial_checklist_label.visible = false
	tutorial_checklist_label.custom_minimum_size = Vector2(0, 0)

	tutorial_body_label = Label.new()
	tutorial_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_body_label.add_theme_font_size_override("font_size", 15)
	tutorial_body_label.add_theme_color_override("font_color", Color("#FFFFFF"))
	box.add_child(tutorial_body_label)

	tutorial_demo_label = Label.new()
	tutorial_demo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_demo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_demo_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_demo_label.custom_minimum_size = Vector2(0, 20)
	tutorial_demo_label.add_theme_font_size_override("font_size", 15)
	tutorial_demo_label.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(tutorial_demo_label)

	tutorial_demo_stage = PanelContainer.new()
	tutorial_demo_stage.custom_minimum_size = Vector2(0, 105)
	tutorial_demo_stage.clip_contents = true
	tutorial_demo_stage.add_theme_stylebox_override("panel", _make_rounded_style(Color("#031321", 0.98), Color("#1D3557"), 1, 16))
	box.add_child(tutorial_demo_stage)
	tutorial_demo_canvas = Control.new()
	tutorial_demo_canvas.custom_minimum_size = Vector2(0, 105)
	tutorial_demo_canvas.clip_contents = true
	tutorial_demo_stage.add_child(tutorial_demo_canvas)

	tutorial_feedback_label = Label.new()
	tutorial_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_feedback_label.add_theme_font_size_override("font_size", 15)
	tutorial_feedback_label.add_theme_color_override("font_color", Color("#22C55E"))
	box.add_child(tutorial_feedback_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)

	tutorial_back_button = _add_button(row, "Back", "Previous tutorial step.", _on_tutorial_back)
	tutorial_next_button = _add_button(row, "I Understand", "Confirm this lesson or move to the next step.", _on_tutorial_next)
	tutorial_load_button = _add_button(row, "Start Practice", "Load the board scenario for this tutorial step.", _on_tutorial_load_step)
	tutorial_replay_button = _add_button(row, "Replay Step", "Replay this completed training mission.", _on_tutorial_replay_step)

func _build_settings_panel(parent: Control) -> void:
	# Settings is now a true one-page mobile dashboard. Nothing in this screen uses a
	# fixed desktop width, so it cannot push off the right edge on phones.
	settings_panel = PanelContainer.new()
	settings_panel.name = "SettingsPanel"
	settings_panel.visible = false
	settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_panel.offset_left = 0
	settings_panel.offset_top = 0
	settings_panel.offset_right = 0
	settings_panel.offset_bottom = 0
	settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#02050C", 0.98), Color("#D4AF37", 0.56), 1, 0))
	parent.add_child(settings_panel)

	var safe_margin: MarginContainer = MarginContainer.new()
	safe_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_theme_constant_override("margin_left", 14)
	safe_margin.add_theme_constant_override("margin_right", 14)
	safe_margin.add_theme_constant_override("margin_top", 14)
	safe_margin.add_theme_constant_override("margin_bottom", 14)
	settings_panel.add_child(safe_margin)

	var page: VBoxContainer = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8)
	safe_margin.add_child(page)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 8)
	page.add_child(top_row)

	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 0)
	top_row.add_child(title_box)

	var title: Label = Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	title_box.add_child(title)

	var note: Label = Label.new()
	note.text = "Sound. Radio. Quick tools."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	title_box.add_child(note)

	var close_button: Button = Button.new()
	close_button.text = "X"
	close_button.tooltip_text = "Close Settings."
	close_button.custom_minimum_size = Vector2(58, 54)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", 20)
	_style_button(close_button, "menu")
	close_button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		_on_settings_close()
	)
	top_row.add_child(close_button)

	var card_grid: GridContainer = GridContainer.new()
	card_grid.columns = 1
	card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_grid.add_theme_constant_override("h_separation", 10)
	card_grid.add_theme_constant_override("v_separation", 10)
	page.add_child(card_grid)

	var audio_card: PanelContainer = PanelContainer.new()
	audio_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	audio_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.96), Color("#00D1FF", 0.65), 2, 24))
	card_grid.add_child(audio_card)
	var audio_margin: MarginContainer = MarginContainer.new()
	audio_margin.add_theme_constant_override("margin_left", 10)
	audio_margin.add_theme_constant_override("margin_right", 10)
	audio_margin.add_theme_constant_override("margin_top", 10)
	audio_margin.add_theme_constant_override("margin_bottom", 10)
	audio_card.add_child(audio_margin)
	var audio_box: VBoxContainer = VBoxContainer.new()
	audio_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	audio_box.add_theme_constant_override("separation", 7)
	audio_margin.add_child(audio_box)

	var audio_label: Label = Label.new()
	audio_label.text = "Audio"
	audio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_label.add_theme_font_size_override("font_size", 22)
	audio_label.add_theme_color_override("font_color", Color("#F2C14E"))
	audio_box.add_child(audio_label)

	sound_button = _add_button(audio_box, "Sound: ON", "Toggle sound effects.", _on_settings_sound)
	sound_button.custom_minimum_size = Vector2(0, 50)
	mute_button = _add_button(audio_box, "Mute: OFF", "Mute all audio.", _on_settings_mute)
	mute_button.custom_minimum_size = Vector2(0, 50)

	audio_status_label = Label.new()
	audio_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	audio_status_label.add_theme_font_size_override("font_size", 12)
	audio_status_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	audio_box.add_child(audio_status_label)

	var master_row: HBoxContainer = HBoxContainer.new()
	master_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master_row.add_theme_constant_override("separation", 6)
	audio_box.add_child(master_row)
	var master_label: Label = Label.new()
	master_label.text = "Master"
	master_label.custom_minimum_size = Vector2(62, 0)
	master_label.add_theme_font_size_override("font_size", 14)
	master_row.add_child(master_label)
	master_volume_slider = HSlider.new()
	master_volume_slider.min_value = 0.0
	master_volume_slider.max_value = 1.0
	master_volume_slider.step = 0.05
	master_volume_slider.value = 0.90
	master_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master_volume_slider.custom_minimum_size = Vector2(0, 34)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	master_row.add_child(master_volume_slider)

	var sfx_row: HBoxContainer = HBoxContainer.new()
	sfx_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_row.add_theme_constant_override("separation", 6)
	audio_box.add_child(sfx_row)
	var sfx_label: Label = Label.new()
	sfx_label.text = "SFX"
	sfx_label.custom_minimum_size = Vector2(62, 0)
	sfx_label.add_theme_font_size_override("font_size", 14)
	sfx_row.add_child(sfx_label)
	sfx_volume_slider = HSlider.new()
	sfx_volume_slider.min_value = 0.0
	sfx_volume_slider.max_value = 1.0
	sfx_volume_slider.step = 0.05
	sfx_volume_slider.value = 0.85
	sfx_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_volume_slider.custom_minimum_size = Vector2(0, 34)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_row.add_child(sfx_volume_slider)

	var music_row: HBoxContainer = HBoxContainer.new()
	music_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_row.add_theme_constant_override("separation", 6)
	audio_box.add_child(music_row)
	var music_label: Label = Label.new()
	music_label.text = "Music"
	music_label.custom_minimum_size = Vector2(62, 0)
	music_label.add_theme_font_size_override("font_size", 14)
	music_row.add_child(music_label)
	music_volume_slider = HSlider.new()
	music_volume_slider.min_value = 0.0
	music_volume_slider.max_value = 1.0
	music_volume_slider.step = 0.05
	music_volume_slider.value = 0.70
	music_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_volume_slider.custom_minimum_size = Vector2(0, 34)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	music_row.add_child(music_volume_slider)

	var radio_card: PanelContainer = PanelContainer.new()
	radio_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	radio_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	radio_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.96), Color("#D4AF37", 0.72), 2, 24))
	card_grid.add_child(radio_card)
	var radio_margin: MarginContainer = MarginContainer.new()
	radio_margin.add_theme_constant_override("margin_left", 10)
	radio_margin.add_theme_constant_override("margin_right", 10)
	radio_margin.add_theme_constant_override("margin_top", 10)
	radio_margin.add_theme_constant_override("margin_bottom", 10)
	radio_card.add_child(radio_margin)
	var radio_box: VBoxContainer = VBoxContainer.new()
	radio_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	radio_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	radio_box.add_theme_constant_override("separation", 7)
	radio_margin.add_child(radio_box)

	var radio_label: Label = Label.new()
	radio_label.text = "SIGMA Radio"
	radio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	radio_label.add_theme_font_size_override("font_size", 22)
	radio_label.add_theme_color_override("font_color", Color("#F2C14E"))
	radio_box.add_child(radio_label)

	radio_status_label = Label.new()
	radio_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	radio_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	radio_status_label.add_theme_font_size_override("font_size", 12)
	radio_status_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	radio_box.add_child(radio_status_label)

	radio_toggle_button = _add_button(radio_box, "Radio: OFF", "Use your music pool.", _on_radio_toggle)
	radio_toggle_button.custom_minimum_size = Vector2(0, 48)
	radio_shuffle_button = _add_button(radio_box, "Shuffle: ON", "Shuffle radio.", _on_radio_shuffle_toggle)
	radio_shuffle_button.custom_minimum_size = Vector2(0, 48)
	radio_next_button = _add_button(radio_box, "Next Track", "Skip track.", _on_radio_next_track)
	radio_next_button.custom_minimum_size = Vector2(0, 48)

	var pool_label: Label = Label.new()
	pool_label.text = "My Music Pool"
	pool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pool_label.add_theme_font_size_override("font_size", 14)
	pool_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	radio_box.add_child(pool_label)

	var radio_grid: GridContainer = GridContainer.new()
	radio_grid.columns = 2
	radio_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	radio_grid.add_theme_constant_override("h_separation", 6)
	radio_grid.add_theme_constant_override("v_separation", 6)
	radio_box.add_child(radio_grid)
	radio_track_buttons.clear()
	for track in AudioManager.get_radio_tracks():
		if typeof(track) != TYPE_DICTIONARY:
			continue
		var id: String = String(track.get("id", ""))
		if id.is_empty():
			continue
		var title_text: String = String(track.get("title", id))
		var track_button: Button = _add_button(radio_grid, title_text, "Tap to include or remove this song.", Callable(self, "_on_radio_track_pressed").bind(id))
		track_button.custom_minimum_size = Vector2(0, 42)
		track_button.add_theme_font_size_override("font_size", 12)
		radio_track_buttons[id] = track_button

	var tools_card: PanelContainer = PanelContainer.new()
	tools_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.95), Color("#4A5D75", 0.9), 2, 22))
	page.add_child(tools_card)
	var tools_margin: MarginContainer = MarginContainer.new()
	tools_margin.add_theme_constant_override("margin_left", 10)
	tools_margin.add_theme_constant_override("margin_right", 10)
	tools_margin.add_theme_constant_override("margin_top", 8)
	tools_margin.add_theme_constant_override("margin_bottom", 8)
	tools_card.add_child(tools_margin)
	var tools_grid: GridContainer = GridContainer.new()
	tools_grid.columns = 3
	tools_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools_grid.add_theme_constant_override("h_separation", 8)
	tools_grid.add_theme_constant_override("v_separation", 8)
	tools_margin.add_child(tools_grid)

	lab_toggle_button = _add_button(tools_grid, "QA Tests", "Show QA Test Menu.", _toggle_scenario_lab)
	lab_toggle_button.custom_minimum_size = Vector2(0, 46)
	radio_reset_button = _add_button(tools_grid, "Reset Radio", "Reset SIGMA Radio.", _on_radio_reset)
	radio_reset_button.custom_minimum_size = Vector2(0, 46)
	var reset_audio_btn: Button = _add_button(tools_grid, "Reset Audio", "Restore audio.", _on_settings_reset_audio)
	reset_audio_btn.custom_minimum_size = Vector2(0, 46)
	var test_music_btn: Button = _add_button(tools_grid, "Test Music", "Play a music check.", _on_settings_test_music)
	test_music_btn.custom_minimum_size = Vector2(0, 46)
	var reset_tutorial_btn: Button = _add_button(tools_grid, "Reset Tutorial", "Clear tutorial progress.", _on_settings_reset_tutorial)
	reset_tutorial_btn.custom_minimum_size = Vector2(0, 46)

	turn_handoff_button = null
	board_flip_button = null
	tabletop_button = null
	_update_audio_settings_ui()
	_update_radio_settings_ui()
	_update_passplay_settings_ui()

func _init_tutorial_steps() -> void:
	tutorial_steps = [
		{"title": "Mission 1: Meet the Monarch", "short": "Monarch", "scenario": "", "kind": SigmaRules.KIND_MONARCH, "body": "Protect your Monarch. If it is trapped in Peril with no legal escape, it Surrenders.", "confirm": "Monarch locked in! Protect it at all costs.", "next": "Next mission: meet the Guardian."},
		{"title": "Mission 2: Hold the Line", "short": "Guardian", "scenario": "", "kind": SigmaRules.KIND_GUARDIAN, "body": "Guardians are your core pieces. They move orthogonally, capture orthogonally, Deploy, and can Elevate.", "confirm": "Guardian ready! Your line is stronger.", "next": "Next mission: meet the Sentinel."},
		{"title": "Mission 3: Watch Every Angle", "short": "Sentinel", "scenario": "", "kind": SigmaRules.KIND_SENTINEL, "body": "Sentinels move and capture one space in any direction. They control nearby space.", "confirm": "Sentinel online! All directions covered.", "next": "Next mission: meet the Infiltrator."},
		{"title": "Mission 4: Slip Through", "short": "Infiltrator", "scenario": "", "kind": SigmaRules.KIND_INFILTRATOR, "body": "Infiltrators move up to two spaces orthogonally through clear spaces and can use a clear first orthogonal space to line up an orthogonal jump-capture.", "confirm": "Infiltrator ready! Lines are open.", "next": "Next mission: meet the Assassin."},
		{"title": "Mission 5: Strike Diagonal", "short": "Assassin", "scenario": "", "kind": SigmaRules.KIND_ASSASSIN, "body": "Assassins move up to two spaces diagonally through clear spaces and can use a clear first diagonal space to line up a diagonal jump-capture.", "confirm": "Assassin ready! Diagonals are dangerous.", "next": "Next mission: move a Guardian."},
		{"title": "Mission 6: Guardian Drill", "short": "Move", "scenario": "tutorial_move_guardian", "kind": SigmaRules.KIND_GUARDIAN, "body": "Move your Guardian to the glowing square.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(4, 4), "to": Vector2i(4, 5), "success": "Nice move! Guardians hold the line.", "next": "Next mission: jump-capture."},
		{"title": "Mission 7: Jump-Capture!", "short": "Jump", "scenario": "tutorial_jump_capture", "kind": SigmaRules.KIND_GUARDIAN, "body": "Jump over the enemy piece and land on the glowing square.", "expected_type": SigmaRules.ACTION_JUMP, "from": Vector2i(4, 4), "to": Vector2i(2, 4), "success": "CAPTURE! That piece is gone.", "next": "Next mission: Deploy backup."},
		{"title": "Mission 8: Deploy Backup", "short": "Deploy", "scenario": "tutorial_deploy", "kind": SigmaRules.KIND_GUARDIAN, "body": "Turn Deploy ON, tap your piece, then place a Reserve Guardian on the glowing square.", "expected_type": SigmaRules.ACTION_DEPLOY, "from": Vector2i(4, 4), "to": Vector2i(4, 5), "deploy": true, "success": "Backup deployed! Reserve Guardian enters the fight.", "next": "Next mission: create Peril."},
		{"title": "Mission 9: Create Peril", "short": "Peril", "scenario": "tutorial_direct_peril", "kind": SigmaRules.KIND_SENTINEL, "body": "Move your Sentinel so it directly threatens the enemy Monarch.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(6, 4), "to": Vector2i(5, 4), "success": "PERIL! Monarch under pressure.", "next": "Next mission: escape Peril."},
		{"title": "Mission 10: Escape!", "short": "Escape", "scenario": "tutorial_escape_peril", "kind": SigmaRules.KIND_MONARCH, "body": "Your Monarch is in Peril. Move to the glowing safe square.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(4, 4), "to": Vector2i(5, 4), "success": "Clean escape! Your Monarch is safe.", "next": "Next mission: force Surrender."},
		{"title": "Mission 11: No Escape", "short": "Surrender", "scenario": "tutorial_surrender", "kind": SigmaRules.KIND_SENTINEL, "body": "Move your Sentinel diagonally to the glowing square. PERIL! If the Monarch has no legal escape, it Surrenders.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(2, 2), "to": Vector2i(1, 1), "success": "SURRENDER! No escape remains.", "next": "Next mission: trigger Retreat."},
		{"title": "Mission 12: Safe Retreat", "short": "Retreat", "scenario": "tutorial_retreat", "kind": SigmaRules.KIND_SENTINEL, "body": "Box in your own Guardian. Friendly boxed-in pieces Retreat instead of being removed.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(5, 3), "to": Vector2i(4, 3), "success": "Safe retreat! Guardian returns to reserve.", "next": "Next mission: Elevate."},
		{"title": "Mission 13: Elevate!", "short": "Elevate", "scenario": "tutorial_elevate", "kind": SigmaRules.KIND_GUARDIAN, "body": "Move your Guardian to the enemy back row, then choose what it becomes.", "expected_type": SigmaRules.ACTION_MOVE, "from": Vector2i(1, 4), "to": Vector2i(0, 4), "requires_elevation": true, "success": "Elevate ready! Choose Sentinel, Infiltrator, or Assassin.", "next": "Next mission: final checkpoint."},
		{"title": "Final Checkpoint: How to Win", "short": "Review", "scenario": "", "kind": SigmaRules.KIND_MONARCH, "body": "You know the loop: move by piece geometry, jump-capture enemy non-Monarch pieces, Deploy Reserve Guardians, Retreat friendly boxed-in pieces, and Elevate Guardians. The main objective is simple: pressure the enemy Monarch. If it is in Peril with no legal escape, it Surrenders and you win.", "confirm": "Final checkpoint clear! You know how SIGMA is won.", "next": "Final mission: Welcome to SIGMA."},
		{"title": "Welcome to SIGMA", "short": "Complete", "scenario": "", "kind": SigmaRules.KIND_MONARCH, "finish": true, "body": "Training complete! Every piece adds influence. Every move adds pressure. The sum of every move is the game.", "confirm": "Welcome to SIGMA!", "next": "Return Home"},
	]

func _start_new_game(auto_save: bool = false) -> void:
	current_match_is_tournament = false
	current_tournament_match_id = ""
	_play_board_audio_scene()
	_reset_board_visual_state(true, true)
	var config: Dictionary = SigmaRules.classic_config()
	match mode_option.get_selected_id():
		1:
			config = SigmaRules.sentinel_config()
		2:
			config = SigmaRules.full_config()
		_:
			config = SigmaRules.classic_config()

	config["surround_toggle"] = false
	config["collapse_toggle"] = false
	config["hot_start_toggle"] = false
	current_match_config = config.duplicate(true)
	_configure_single_player_from_config(config)
	rules.new_game(config)
	_configure_speed_timer_from_config(config)
	_update_adaptive_board_music()
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	if turn_handoff_panel != null:
		turn_handoff_panel.visible = false
	_set_deploy_mode(false)
	last_selected_kind = ""
	last_selected_owner = -1
	last_selected_pos = Vector2i(-1, -1)
	selection_label.text = "Your move, Gold! Tap a piece. Blue moves, red captures, green Deploys."
	piece_help_label.visible = false
	result_overlay.visible = false
	_set_tutorial_card_visible(false)
	settings_panel.visible = false
	if rules_guide_panel != null:
		rules_guide_panel.visible = false
	_reset_board_visual_state(true, true)
	tutorial_active = false
	tutorial_step_loaded = false
	_update_labels()
	if auto_save:
		_autosave_current_game("Game saved")

func _should_apply_action_immediately() -> bool:
	# v2.2.0 UX rule: if the tap already expresses the player's intent, do not ask twice.
	# All routine legal board actions commit directly after SigmaRules.preview_action() approves them.
	# Confirmation is kept for destructive/non-routine choices such as Restart, Return Home, or Surrender UI.
	return true

func _on_action_chosen(action: Dictionary) -> void:
	if not _can_board_accept_input():
		_sync_board_input_lock()
		return
	if _is_ai_turn_active():
		selection_label.text = "%s Bot is thinking..." % ai_difficulty
		_play_sound_cue("illegal")
		return
	var action_type: String = String(action.get("type", ""))
	if not pending_preview_action.is_empty() and _actions_match(pending_preview_action, action):
		_on_preview_confirm_pressed()
		return
	if tutorial_active and tutorial_step_loaded and not _tutorial_action_matches(action):
		var wrong_text: String = _tutorial_try_again_text()
		selection_label.text = wrong_text
		if tutorial_feedback_label != null:
			tutorial_feedback_label.text = wrong_text
		if board_view != null:
			board_view.show_illegal_marker(action.get("to", Vector2i(-1, -1)), wrong_text, false)
		_play_sound_cue("tutorial_wrong")
		return

	var preview: Dictionary = rules.preview_action(action)
	if not bool(preview.get("ok", false)):
		var reason: String = String(preview.get("reason", "Illegal action."))
		selection_label.text = reason
		if board_view != null:
			var major: bool = reason.find("Monarch") >= 0 or reason.find("Peril") >= 0 or reason.find("Surrender") >= 0
			board_view.show_illegal_marker(action.get("to", Vector2i(-1, -1)), reason, major)
		_play_sound_cue("illegal")
		_update_labels()
		return

	# Tap-to-commit is now the standard SIGMA board flow. Legality still comes from SigmaRules.preview_action().
	if _should_apply_action_immediately():
		pending_preview_action = action.duplicate(true)
		pending_preview_result = preview.duplicate(true)
		_on_preview_confirm_pressed()
		return

	pending_preview_action = action.duplicate(true)
	pending_preview_result = preview.duplicate(true)
	if board_view != null:
		board_view.set_action_preview(action, preview)
	_show_preview_panel(action_type, preview)
	_play_sound_cue("preview")
	_update_labels()


func _on_board_info_requested(kind: String, owner: int, pos: Vector2i) -> void:
	if not _can_board_accept_input():
		_sync_board_input_lock()
		return
	if kind == "" or owner < 0:
		return
	if info_bubble_panel == null:
		return
	info_bubble_title_label.text = "%s · r%d c%d" % [_piece_name(kind), pos.x + 1, pos.y + 1]
	info_bubble_body_label.text = _piece_help_text(kind)
	info_bubble_panel.visible = true
	_play_sound_cue("button_hover")

func _show_event_word(text: String, role: String = "gold") -> void:
	if event_word_label == null:
		return
	var col: Color = Color("#F2C14E")
	if role == "red":
		col = Color("#E84A5F")
	elif role == "green":
		col = Color("#22C55E")
	elif role == "violet":
		col = Color("#A78BFA")
	elif role == "cyan" or role == "silver":
		col = Color("#00D1FF")
	else:
		col = Color("#F2C14E")
	event_word_label.text = text
	event_word_label.add_theme_color_override("font_color", col)
	event_word_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.82))
	event_word_label.add_theme_constant_override("outline_size", 3)
	# Gold/player callouts sit lower in the thumb command zone. AI/Silver callouts
	# appear above the board. Critical events stay centered.
	if role == "silver" or role == "cyan":
		event_word_label.offset_top = -230
		event_word_label.offset_bottom = -130
	elif role == "red" or role == "violet":
		event_word_label.offset_top = -58
		event_word_label.offset_bottom = 58
	else:
		event_word_label.offset_top = 122
		event_word_label.offset_bottom = 222
	event_word_label.visible = true
	event_word_label.modulate = Color(1, 1, 1, 0)
	event_word_label.scale = Vector2(0.84, 0.84)
	var tween: Tween = create_tween()
	tween.tween_property(event_word_label, "modulate", Color(1, 1, 1, 1), 0.09)
	tween.parallel().tween_property(event_word_label, "scale", Vector2(1.04, 1.04), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.42)
	tween.tween_property(event_word_label, "modulate", Color(1, 1, 1, 0), 0.20)
	tween.tween_callback(func() -> void:
		event_word_label.visible = false
		event_word_label.scale = Vector2.ONE
	)

func _is_opening_back_row_normal_move(action: Dictionary) -> bool:
	if rules == null:
		return false
	if String(action.get("type", "")) != SigmaRules.ACTION_MOVE:
		return false
	var owner: int = int(action.get("owner", -1))
	var from_pos: Vector2i = action.get("from", Vector2i(-1, -1))
	if from_pos.x < 0:
		return false
	var back_row: int = 8 if owner == SigmaRules.OWNER_P1 else 0
	return from_pos.x == back_row and int(rules.full_rounds) <= 1

func _last_action_has_true_retreat() -> bool:
	if rules == null:
		return false
	return _should_show_retreat_callout(String(rules.last_action.get("type", "")))

func _should_show_retreat_callout(action_type: String) -> bool:
	if rules == null:
		return false
	if int(rules.last_resolution.get("friendly_retreats", 0)) <= 0:
		return false
	var retreat_positions: Array = rules.last_resolution.get("friendly_retreat_positions", []) as Array
	if retreat_positions.is_empty():
		return false
	# Deploy can create an immediate real Retreat and should always call out.
	if action_type == SigmaRules.ACTION_DEPLOY:
		return true
	# Opening back-row movement can falsely feel like Retreat. Keep early match
	# normal moves quiet unless they were Deploy-driven.
	if _is_opening_back_row_normal_move(rules.last_action):
		return false
	if action_type == SigmaRules.ACTION_MOVE and int(rules.full_rounds) < 4:
		return false
	return true

func _play_event_word_sequence(events: Array) -> void:
	if events.is_empty():
		return
	for i in range(events.size()):
		var ev: Dictionary = events[i] as Dictionary
		var delay: float = 0.0 if i == 0 else 0.68 * float(i)
		var text: String = String(ev.get("text", ""))
		var role: String = String(ev.get("role", "gold"))
		get_tree().create_timer(delay).timeout.connect(_show_event_word.bind(text, role))

func _show_resolution_event_word(action_type: String, actor: int = -1) -> void:
	var events: Array = []
	if rules.game_over:
		if rules.ending == SigmaRules.END_SURRENDER:
			events.append({"text": "SURRENDER", "role": "red"})
		else:
			events.append({"text": "VICTORY", "role": "gold"})
		_play_event_word_sequence(events)
		return
	if action_type == SigmaRules.ACTION_DEPLOY:
		events.append({"text": "DEPLOY", "role": "green"})
	if action_type == SigmaRules.ACTION_JUMP or int(rules.last_resolution.get("captures", 0)) > 0 or int(rules.last_resolution.get("enemy_surround_removed", 0)) > 0:
		events.append({"text": "CAPTURE", "role": "red"})
	if _should_show_retreat_callout(action_type):
		events.append({"text": "RETREAT", "role": "green"})
	if bool(rules.last_resolution.get("pending_elevation", false)):
		events.append({"text": "ELEVATE", "role": "violet"})
	var enemy_owner: int = SigmaRules.OWNER_P1 if actor == SigmaRules.OWNER_P2 else SigmaRules.OWNER_P2
	if actor == SigmaRules.OWNER_P1 or actor == SigmaRules.OWNER_P2:
		if rules.is_monarch_in_peril(enemy_owner):
			events.append({"text": "PERIL", "role": "red"})
	else:
		if rules.is_monarch_in_peril(rules.turn):
			events.append({"text": "PERIL", "role": "red"})
	_play_event_word_sequence(events)

func _actions_match(a: Dictionary, b: Dictionary) -> bool:
	if String(a.get("type", "")) != String(b.get("type", "")):
		return false
	if int(a.get("owner", -1)) != int(b.get("owner", -2)):
		return false
	if a.get("from", Vector2i(-1, -1)) != b.get("from", Vector2i(-1, -1)):
		return false
	if a.get("to", Vector2i(-1, -1)) != b.get("to", Vector2i(-1, -1)):
		return false
	if a.has("capture") or b.has("capture"):
		return a.get("capture", Vector2i(-1, -1)) == b.get("capture", Vector2i(-1, -1))
	return true

func _show_preview_panel(action_type: String, preview: Dictionary) -> void:
	if preview_panel == null:
		return
	_layout_preview_panel()
	preview_panel.visible = true
	var title: String = "Preview Action"
	match action_type:
		SigmaRules.ACTION_MOVE:
			title = "Preview Move"
		SigmaRules.ACTION_JUMP:
			title = "Preview Capture"
		SigmaRules.ACTION_DEPLOY:
			title = "Preview Deploy"
	preview_title_label.text = title
	var tags: Array = preview.get("tags", []) as Array
	preview_tags_label.text = " · ".join(tags) if not tags.is_empty() else "No special consequence"
	preview_body_label.text = String(preview.get("description", "Preview ready."))
	if preview_confirm_button != null:
		preview_confirm_button.text = String(preview.get("confirm_text", "Confirm"))
		if bool(preview.get("surrender", false)):
			preview_confirm_button.add_theme_color_override("font_color", Color("#F2C14E"))
		else:
			preview_confirm_button.add_theme_color_override("font_color", Color("#FFFFFF"))


func _play_coin_motion_for_action(action: Dictionary, action_type: String) -> void:
	if board_view == null or rules == null:
		return
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	if to_pos.x < 0:
		return
	var motion_type: String = "move"
	if action_type == SigmaRules.ACTION_JUMP or int(rules.last_resolution.get("captures", 0)) > 0 or int(rules.last_resolution.get("enemy_surround_removed", 0)) > 0:
		motion_type = "capture"
	elif action_type == SigmaRules.ACTION_DEPLOY:
		motion_type = "deploy"
	var p = rules.get_piece(to_pos)
	var piece: Dictionary = {}
	if p != null:
		piece = p.duplicate(true)
	board_view.play_coin_motion(action, piece, motion_type)

func _on_preview_confirm_pressed() -> void:
	if pending_preview_action.is_empty():
		return
	var action: Dictionary = pending_preview_action.duplicate(true)
	var action_type: String = String(action.get("type", ""))
	_clear_preview_state(false)
	if rules.apply_action(action):
		_refresh_all_reserve_trays()
		_play_resolution_audio(action_type)
		_show_resolution_event_word(action_type, int(action.get("owner", -1)))
		_play_coin_motion_for_action(action, action_type)
		_set_deploy_mode(false)
		if tutorial_active and tutorial_step_loaded:
			_tutorial_after_successful_action(action)
		else:
			board_view.refresh()
		if rules.has_pending_elevation():
			_force_show_elevate_prompt_if_pending()
			if not tutorial_active:
				_autosave_current_game("Game saved")
			_update_labels()
			return
		_reset_speed_timer_for_turn()
		if not tutorial_active:
			_autosave_current_game("Game saved")
			_show_turn_handoff_if_needed(action_type)
			_maybe_queue_ai_turn()
	else:
		# Training guardrail: the Force Surrender mission should never strand the
		# player if the scripted tap reaches this path.
		if tutorial_active and tutorial_step_loaded:
			var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
			if String(step.get("scenario", "")) == "tutorial_surrender" and _tutorial_action_matches(action):
				_mark_tutorial_step_complete(String(step.get("success", "SURRENDER! Mission complete.")))
				_update_labels()
				return
		selection_label.text = rules.get_illegal_reason(action)
		if board_view != null:
			board_view.show_illegal_marker(action.get("to", Vector2i(-1, -1)), selection_label.text, true)
		_play_sound_cue("illegal")
	_update_labels()

func _on_preview_cancel_pressed() -> void:
	_clear_preview_state(true)
	selection_label.text = "Preview canceled. Choose another highlighted action."
	_play_sound_cue("cancel")
	_update_labels()

func _on_preview_cancel_requested_from_board(message: String) -> void:
	if not _can_board_accept_input():
		_sync_board_input_lock()
		return
	_clear_preview_state(false)
	selection_label.text = message
	_play_sound_cue("cancel")
	_update_labels()

func _clear_preview_state(clear_board_preview: bool = true) -> void:
	pending_preview_action = {}
	pending_preview_result = {}
	if preview_panel != null:
		preview_panel.visible = false
	if board_view != null and clear_board_preview:
		board_view.clear_action_preview()

func _on_elevate_selected(kind: String) -> void:
	var elevate_pos: Vector2i = Vector2i(-1, -1)
	if rules.has_pending_elevation():
		elevate_pos = rules.pending_elevation.get("pos", Vector2i(-1, -1))
	if rules.choose_pending_elevation(kind):
		if elevate_panel != null:
			elevate_panel.visible = false
		_play_sound_cue("elevate")
		if rules.game_over:
			_play_sound_cue("game_result")
		elif rules.is_monarch_in_peril(rules.turn):
			_play_sound_cue("peril")
		if elevate_pos.x >= 0 and board_view != null:
			var elevated_piece = rules.get_piece(elevate_pos)
			var action: Dictionary = {"type": "elevate", "from": elevate_pos, "to": elevate_pos, "owner": rules.enemy(rules.turn)}
			var piece_dict: Dictionary = {}
			if elevated_piece != null:
				piece_dict = elevated_piece.duplicate(true)
			board_view.play_coin_motion(action, piece_dict, "elevate")
		board_view.refresh()
		selection_label.text = "ELEVATE! Guardian became a %s." % _piece_name(kind)
		if tutorial_active and tutorial_step_loaded and bool((tutorial_steps[tutorial_index] as Dictionary).get("requires_elevation", false)):
			_mark_tutorial_step_complete("Good. Elevation complete — your Guardian became a %s." % _piece_name(kind))
		_reset_speed_timer_for_turn()
		if not tutorial_active:
			_autosave_current_game("Game saved")
			_show_turn_handoff_if_needed("elevate")
			_maybe_queue_ai_turn()
	else:
		selection_label.text = "CAP REACHED — choose an available advanced piece."
		_play_sound_cue("illegal")
	_update_labels()

func _on_undo_pressed() -> void:
	_clear_preview_state(true)
	if rules.undo():
		_reset_speed_timer_for_turn()
		_set_deploy_mode(false)
		board_view.refresh()
		_autosave_current_game("Game saved after Undo")
		_update_labels()
	else:
		selection_label.text = "Nothing to undo."

func _on_tabletop_deploy_pressed(owner: int) -> void:
	if rules == null or rules.game_over:
		return
	if owner != rules.turn:
		selection_label.text = "Waiting — %s is acting." % rules.get_turn_name()
		_play_sound_cue("illegal")
		_update_tabletop_passplay_ui()
		return
	_clear_preview_state(true)
	var next_value: bool = true
	if board_view != null:
		next_value = not board_view.deploy_mode
	_set_deploy_mode(next_value)
	selection_label.text = "%s" % ("Deploy ON — %s Reserves ready." % rules.get_turn_name() if next_value else "Deploy OFF.")
	_update_labels()

func _on_deploy_button_pressed() -> void:
	_clear_preview_state(true)
	var next_value: bool = false
	if deploy_button != null and deploy_button.visible:
		next_value = deploy_button.button_pressed
	elif board_view != null:
		next_value = not board_view.deploy_mode
	_set_deploy_mode(next_value)
	_update_labels()

func _reset_board_visual_state(clear_tutorial_markers: bool = true, clear_deploy_mode: bool = true) -> void:
	pending_preview_action = {}
	pending_preview_result = {}
	if preview_panel != null:
		preview_panel.visible = false
	if elevate_panel != null and (rules == null or not rules.has_pending_elevation()):
		elevate_panel.visible = false
	last_selected_kind = ""
	last_selected_owner = -1
	last_selected_pos = Vector2i(-1, -1)
	if piece_help_label != null:
		piece_help_label.visible = false
	if board_view != null:
		board_view.reset_visual_state(clear_tutorial_markers)
	if clear_deploy_mode:
		if deploy_button != null:
			deploy_button.button_pressed = false
			deploy_button.text = "Deploy: OFF"
			deploy_button.add_theme_color_override("font_color", Color("#FFFFFF"))
		if board_view != null:
			board_view.set_deploy_mode(false)

func _set_deploy_mode(value: bool) -> void:
	if deploy_button != null:
		deploy_button.button_pressed = value
		deploy_button.text = "Deploy: ON" if value else "Deploy: OFF"
		if value:
			deploy_button.add_theme_color_override("font_color", Color("#22C55E"))
		else:
			deploy_button.add_theme_color_override("font_color", Color("#FFFFFF"))
	if board_view != null:
		board_view.set_deploy_mode(value)
	_update_tabletop_passplay_ui()

func _on_selection_changed(text: String) -> void:
	if not _can_board_accept_input():
		_sync_board_input_lock()
		return
	selection_label.text = text

func _on_piece_focus_changed(kind: String, owner: int, pos: Vector2i) -> void:
	if not _can_board_accept_input():
		_sync_board_input_lock()
		return
	var changed: bool = pos != last_selected_pos or kind != last_selected_kind or owner != last_selected_owner
	last_selected_kind = kind
	last_selected_owner = owner
	last_selected_pos = pos
	if changed and pos.x >= 0:
		_play_sound_cue("select_piece")

func _on_info_pressed() -> void:
	piece_help_label.visible = not piece_help_label.visible
	if piece_help_label.visible:
		piece_help_label.text = _piece_help_text(last_selected_kind)

func _qa_has_action(pos: Vector2i, action_type: String, to_pos: Vector2i, capture_pos: Vector2i = Vector2i(-1, -1)) -> bool:
	var actions: Array = rules.get_legal_actions_for_piece(pos)
	for action_value in actions:
		var action: Dictionary = action_value
		if String(action.get("type", "")) != action_type:
			continue
		if Vector2i(action.get("to", Vector2i(-9, -9))) != to_pos:
			continue
		if capture_pos.x >= 0 and Vector2i(action.get("capture", Vector2i(-9, -9))) != capture_pos:
			continue
		return true
	return false

func _qa_line(name: String, passed: bool) -> String:
	return "%s %s" % ["✓" if passed else "✗", name]

func _run_rules_qa_smoke() -> Array:
	var saved_state: Dictionary = rules.export_save_state()
	var lines: Array = []

	rules.load_scenario("guardian_move")
	lines.append(_qa_line("Guardian orthogonal move", _qa_has_action(Vector2i(4, 4), SigmaRules.ACTION_MOVE, Vector2i(3, 4))))

	rules.load_scenario("guardian_capture")
	lines.append(_qa_line("Guardian orthogonal jump-capture", _qa_has_action(Vector2i(4, 4), SigmaRules.ACTION_JUMP, Vector2i(2, 4), Vector2i(3, 4))))

	rules.load_scenario("deploy")
	lines.append(_qa_line("Deploy from Reserves", _qa_has_action(Vector2i(4, 4), SigmaRules.ACTION_DEPLOY, Vector2i(3, 4))))

	rules.load_scenario("illegal_lshape_infiltrator")
	lines.append(_qa_line("No L-shaped Infiltrator captures", not _qa_has_action(Vector2i(4, 2), SigmaRules.ACTION_JUMP, Vector2i(3, 4), Vector2i(3, 3))))

	rules.load_scenario("illegal_lshape_assassin")
	lines.append(_qa_line("No bent Assassin captures", not _qa_has_action(Vector2i(5, 1), SigmaRules.ACTION_JUMP, Vector2i(3, 4), Vector2i(4, 3))))

	rules.load_scenario("infiltrator_reach_capture")
	lines.append(_qa_line("Infiltrator straight reach-capture", _qa_has_action(Vector2i(4, 2), SigmaRules.ACTION_JUMP, Vector2i(4, 5), Vector2i(4, 4))))

	rules.load_scenario("assassin_reach_capture")
	lines.append(_qa_line("Assassin diagonal reach-capture", _qa_has_action(Vector2i(5, 1), SigmaRules.ACTION_JUMP, Vector2i(2, 4), Vector2i(3, 3))))

	rules.load_scenario("tutorial_force_surrender")
	var surrender_action: Dictionary = {"type": SigmaRules.ACTION_MOVE, "owner": SigmaRules.OWNER_P1, "from": Vector2i(2, 2), "to": Vector2i(1, 1)}
	var surrender_preview: Dictionary = rules.preview_action(surrender_action)
	lines.append(_qa_line("Surrender action legal", bool(surrender_preview.get("ok", false))))

	rules.load_scenario("blitz_timeout")
	var before_turn: int = rules.turn
	var timeout_ok: bool = rules.apply_turn_timeout()
	lines.append(_qa_line("BLITZ timeout ends turn", timeout_ok and rules.turn != before_turn and not rules.game_over))

	rules.import_save_state(saved_state)
	board_view.set_rules(rules)
	return lines

func _on_qa_smoke_pressed() -> void:
	_play_sound_cue("confirm")
	var lines: Array = _run_rules_qa_smoke()
	var pass_count: int = 0
	for line_value in lines:
		if String(line_value).begins_with("✓"):
			pass_count += 1
	var summary: String = "Rules QA Smoke: %d/%d passed" % [pass_count, lines.size()]
	if qa_status_label != null:
		qa_status_label.text = "%s\n%s" % [summary, "\n".join(lines)]
	selection_label.text = summary
	_update_labels()

func _on_qa_result_pressed() -> void:
	_clear_preview_state(true)
	rules.load_scenario("result_surrender")
	board_view.set_rules(rules)
	_set_deploy_mode(false)
	selection_label.text = "QA result screen loaded."
	if qa_status_label != null:
		qa_status_label.text = "Loaded Result Screen: Surrender."
	_update_labels()


func _on_load_scenario_pressed() -> void:
	var index: int = scenario_option.get_selected()
	if index < 0 or index >= scenario_ids.size():
		return
	var scenario_id: String = String(scenario_ids[index])
	_reset_board_visual_state(true, true)
	rules.load_scenario(scenario_id)
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	selection_label.text = "QA setup loaded. Tap the test piece or follow the prompt."
	_update_labels()

func _on_force_overtime_pressed() -> void:
	rules.force_overtime_debug()
	_update_labels()

func _on_resolve_fallback_pressed() -> void:
	rules.resolve_overtime_fallback_debug()
	board_view.refresh()
	_update_labels()

func _toggle_scenario_lab() -> void:
	scenario_panel.visible = not scenario_panel.visible
	dev_lab_visible_from_settings = scenario_panel.visible
	scenario_label.visible = scenario_panel.visible
	if lab_toggle_button != null:
		lab_toggle_button.text = "Hide QA Tests" if scenario_panel.visible else "Show QA Tests"


func _set_tutorial_card_visible(value: bool) -> void:
	if tutorial_backdrop_layer != null:
		tutorial_backdrop_layer.visible = value
	if tutorial_panel != null:
		tutorial_panel.visible = value
	_sync_board_input_lock()

func _hide_tutorial_panel_for_board_action() -> void:
	# The tutorial panel explains the step, then gets out of the way so the
	# player can tap the highlighted piece/square on the board. The current
	# objective remains visible in the normal hint/status labels.
	_set_tutorial_card_visible(false)

func _show_tutorial_panel_after_step() -> void:
	if tutorial_active:
		_set_tutorial_card_visible(true)

func _on_tutorial_pressed() -> void:
	_play_tutorial_audio_scene()
	_play_sound_cue("page_open")
	_reset_board_visual_state(true, true)
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	tutorial_active = true
	tutorial_step_loaded = false
	_set_tutorial_card_visible(true)
	_update_tutorial_panel()
	_animate_tutorial_demo()

func _on_tutorial_next() -> void:
	if tutorial_steps.is_empty():
		return
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var is_done: bool = tutorial_completed_steps.has(tutorial_index)
	var has_practice: bool = String(step.get("scenario", "")) != ""
	if bool(step.get("finish", false)):
		_mark_tutorial_step_complete(String(step.get("confirm", "Welcome to SIGMA!")))
		_finish_tutorial_to_home()
		return
	if not is_done:
		if has_practice:
			if not tutorial_step_loaded:
				_on_tutorial_load_step()
			else:
				selection_label.text = "Finish the glowing mission on the board first."
				if tutorial_feedback_label != null:
					tutorial_feedback_label.text = selection_label.text
			return
		_mark_tutorial_step_complete(String(step.get("confirm", "Mission complete!")))
		return
	if tutorial_index < tutorial_steps.size() - 1:
		tutorial_index += 1
		tutorial_step_loaded = false
		_reset_board_visual_state(true, true)
		selection_label.text = "Next mission: %s" % String((tutorial_steps[tutorial_index] as Dictionary).get("title", "SIGMA Training"))
	else:
		_finish_tutorial_to_home()
		return
	_update_tutorial_panel()
	_animate_tutorial_demo()

func _finish_tutorial_to_home() -> void:
	tutorial_complete = true
	tutorial_active = false
	tutorial_step_loaded = false
	_save_user_progress()
	_reset_board_visual_state(true, true)
	selection_label.text = "Welcome to SIGMA! Choose New Game to begin."
	_play_sound_cue("tutorial_complete")
	_show_main_menu()

func _on_tutorial_replay_step() -> void:
	if tutorial_steps.is_empty():
		return
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	if String(step.get("scenario", "")) == "":
		selection_label.text = "This mission is a training card. Use Back or Next Step."
		if tutorial_feedback_label != null:
			tutorial_feedback_label.text = selection_label.text
		return
	selection_label.text = "Replay Mission! Try it again."
	_on_tutorial_load_step()

func _on_tutorial_back() -> void:
	if tutorial_index > 0:
		tutorial_index -= 1
		tutorial_step_loaded = false
		if board_view != null:
			board_view.clear_tutorial_markers()
	_update_tutorial_panel()
	_animate_tutorial_demo()

func _on_tutorial_close() -> void:
	_set_tutorial_card_visible(false)
	tutorial_active = false
	tutorial_step_loaded = false
	_reset_board_visual_state(true, true)
	_show_main_menu()

func _on_tutorial_load_step() -> void:
	if tutorial_steps.is_empty():
		return
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var scenario_id: String = String(step.get("scenario", ""))
	if scenario_id == "":
		_mark_tutorial_step_complete(String(step.get("confirm", "Lesson confirmed.")))
		return
	_reset_board_visual_state(true, true)
	rules.load_scenario(scenario_id)
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	tutorial_active = true
	tutorial_step_loaded = true
	last_selected_kind = ""
	last_selected_owner = -1
	last_selected_pos = Vector2i(-1, -1)
	var from_pos: Vector2i = step.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = step.get("to", Vector2i(-1, -1))
	board_view.set_tutorial_markers(from_pos, to_pos, String(step.get("title", "")))
	_set_deploy_mode(bool(step.get("deploy", false)))
	selection_label.text = _tutorial_loaded_text(step)
	if tutorial_feedback_label != null:
		tutorial_feedback_label.text = "Mission live! Tap the glowing action to complete it."
	_update_labels()
	_hide_tutorial_panel_for_board_action()
	_sync_board_input_lock()

func _update_tutorial_panel() -> void:
	if tutorial_steps.is_empty():
		return
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var is_done: bool = tutorial_completed_steps.has(tutorial_index)
	var has_practice: bool = String(step.get("scenario", "")) != ""
	var is_finish: bool = bool(step.get("finish", false))
	tutorial_title_label.text = "SIGMA Training"
	var done_mark: String = " ✓" if is_done else ""
	tutorial_step_label.text = "%s  ·  Mission %d of %d%s" % [String(step.get("title", "Learn SIGMA")), tutorial_index + 1, tutorial_steps.size(), done_mark]
	if tutorial_phase_label != null:
		tutorial_phase_label.text = _tutorial_phase_text(step, is_done, has_practice)
	if tutorial_body_label != null:
		tutorial_body_label.text = _tutorial_body_text(step, is_done)
	if tutorial_demo_label != null:
		tutorial_demo_label.text = _tutorial_demo_text(step)
	if tutorial_progress_label != null:
		tutorial_progress_label.text = _tutorial_progress_text()
	if tutorial_checklist_label != null:
		tutorial_checklist_label.text = ""
	if tutorial_feedback_label != null:
		if is_finish:
			tutorial_feedback_label.text = "Welcome to SIGMA! Ready for your first match?"
		elif is_done:
			tutorial_feedback_label.text = "%s\n%s" % [String(tutorial_completed_steps[tutorial_index]), String(step.get("next", "Next mission unlocked."))]
		elif tutorial_step_loaded:
			tutorial_feedback_label.text = "Mission live! Tap the glowing action to complete it."
		elif has_practice:
			tutorial_feedback_label.text = "Tap Start Practice to play this mission."
		else:
			tutorial_feedback_label.text = "Review the token, then tap I Understand."
	if tutorial_load_button != null:
		tutorial_load_button.visible = has_practice and not is_done
		tutorial_load_button.text = "Start Practice" if not tutorial_step_loaded else "Restart Step"
	if tutorial_replay_button != null:
		tutorial_replay_button.visible = has_practice and is_done
		tutorial_replay_button.disabled = false
	if tutorial_next_button != null:
		tutorial_next_button.visible = (not has_practice) or is_done or tutorial_complete or is_finish
		if is_finish:
			tutorial_next_button.text = "Return Home"
		elif not is_done:
			tutorial_next_button.text = "I Understand"
		elif tutorial_index < tutorial_steps.size() - 1:
			tutorial_next_button.text = "Next Mission"
		else:
			tutorial_next_button.text = "Return Home"
	if tutorial_back_button != null:
		tutorial_back_button.disabled = tutorial_index <= 0

func _on_settings_pressed() -> void:
	_play_menu_audio_scene("settings")
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("settings")
	settings_panel.visible = true
	_update_audio_settings_ui()
	_update_radio_settings_ui()

func _on_settings_restart() -> void:
	settings_panel.visible = false
	if _should_confirm_replacing_game():
		_show_new_game_confirm("restart_current")
	else:
		_restart_current_match_now()

func _on_settings_sound() -> void:
	sound_enabled = not sound_enabled
	AudioManager.set_muted(not sound_enabled)
	selection_label.text = "Sound effects: %s." % ("ON" if sound_enabled else "OFF")
	_update_audio_settings_ui()
	_play_sound_cue("confirm")

func _on_settings_mute() -> void:
	var is_muted: bool = AudioManager.toggle_muted()
	sound_enabled = not is_muted
	selection_label.text = "Audio muted." if is_muted else "Audio unmuted."
	_update_audio_settings_ui()
	if not is_muted:
		_play_sound_cue("confirm")

func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	_update_audio_settings_ui()

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	_update_audio_settings_ui()

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
	_update_audio_settings_ui()

func _on_settings_reset_audio() -> void:
	AudioManager.reset_audio_settings()
	sound_enabled = not AudioManager.muted
	_update_audio_settings_ui()
	_update_radio_settings_ui()
	selection_label.text = "Audio settings reset."
	_play_sound_cue("confirm")

func _sync_audio_from_manager() -> void:
	sound_enabled = not AudioManager.muted
	_update_audio_settings_ui()

func _update_audio_settings_ui() -> void:
	if sound_button != null:
		sound_button.text = "Sound: ON" if sound_enabled else "Sound: OFF"
	if mute_button != null:
		mute_button.text = "Mute: ON" if AudioManager.muted else "Mute: OFF"
	if master_volume_slider != null:
		master_volume_slider.value = AudioManager.master_volume
	if sfx_volume_slider != null:
		sfx_volume_slider.value = AudioManager.sfx_volume
	if music_volume_slider != null:
		music_volume_slider.value = AudioManager.music_volume
	if audio_status_label != null:
		audio_status_label.text = AudioManager.get_status_text()

func _on_radio_toggle() -> void:
	var enabled: bool = AudioManager.toggle_radio_enabled()
	selection_label.text = "SIGMA Radio ON." if enabled else "SIGMA Radio OFF."
	_update_radio_settings_ui()
	_play_sound_cue("confirm")

func _on_radio_shuffle_toggle() -> void:
	var enabled: bool = AudioManager.toggle_radio_shuffle()
	selection_label.text = "Radio shuffle ON." if enabled else "Radio plays in order."
	_update_radio_settings_ui()
	_play_sound_cue("confirm")

func _on_radio_next_track() -> void:
	AudioManager.next_radio_track()
	selection_label.text = "SIGMA Radio skipped to the next track."
	_update_audio_settings_ui()
	_update_radio_settings_ui()
	_play_sound_cue("confirm")

func _on_radio_reset() -> void:
	AudioManager.reset_radio_settings()
	selection_label.text = "SIGMA Radio reset."
	_update_audio_settings_ui()
	_update_radio_settings_ui()
	_play_sound_cue("confirm")

func _on_radio_track_pressed(id: String) -> void:
	AudioManager.toggle_radio_track(id)
	_update_radio_settings_ui()
	_play_sound_cue("confirm")

func _update_radio_settings_ui() -> void:
	if radio_toggle_button != null:
		radio_toggle_button.text = "SIGMA Radio: ON" if AudioManager.radio_enabled else "SIGMA Radio: OFF"
	if radio_shuffle_button != null:
		radio_shuffle_button.text = "Shuffle: ON" if AudioManager.radio_shuffle else "Shuffle: OFF"
	if radio_status_label != null:
		radio_status_label.text = AudioManager.get_radio_status_text()
	for id in radio_track_buttons.keys():
		var button: Button = radio_track_buttons[id]
		if button == null:
			continue
		var enabled: bool = AudioManager.is_radio_track_enabled(String(id))
		var clean_title: String = button.text
		if clean_title.begins_with("ON · ") or clean_title.begins_with("OFF · "):
			clean_title = clean_title.substr(5)
		button.text = ("ON · " if enabled else "OFF · ") + clean_title

func _on_settings_test_music() -> void:
	AudioManager.play_music_test_burst()
	_update_audio_settings_ui()
	_update_radio_settings_ui()
	selection_label.text = "Music check active."

func _on_settings_reset_tutorial() -> void:
	tutorial_complete = false
	tutorial_completed_steps.clear()
	tutorial_index = 0
	tutorial_step_loaded = false
	_save_user_progress()
	if board_view != null:
		board_view.clear_tutorial_markers()
	selection_label.text = "Tutorial progress reset. Press Learn to start from Step 1."
	_update_tutorial_panel()

func _on_settings_close() -> void:
	settings_panel.visible = false
	_show_main_menu()


func _on_settings_turn_handoff() -> void:
	turn_handoff_enabled = false
	board_flip_enabled = false
	tabletop_passplay_enabled = not single_player_enabled
	_save_user_progress()
	_update_passplay_settings_ui()
	selection_label.text = "Layout is automatic. Handoff is no longer needed."
	_play_sound_cue("confirm")

func _on_settings_tabletop_passplay() -> void:
	turn_handoff_enabled = false
	board_flip_enabled = false
	tabletop_passplay_enabled = not single_player_enabled
	_save_user_progress()
	_update_passplay_settings_ui()
	_update_board_flip()
	_update_tabletop_passplay_ui()
	selection_label.text = "Layout is automatic: Human vs Human Tabletop, AI/Online mobile."
	_play_sound_cue("confirm")

func _on_settings_board_flip() -> void:
	board_flip_enabled = false
	_save_user_progress()
	_update_passplay_settings_ui()
	_update_board_flip()
	selection_label.text = "Board Flip is retired. Layout is automatic."
	_play_sound_cue("confirm")

func _update_passplay_settings_ui() -> void:
	# Public layout controls were removed in v2.2.0. These legacy variables are
	# still normalized so old saves cannot put the UI into an unsupported layout.
	turn_handoff_enabled = false
	board_flip_enabled = false
	tabletop_passplay_enabled = not single_player_enabled
	if turn_handoff_button != null:
		turn_handoff_button.text = "Layout: Auto"
	if board_flip_button != null:
		board_flip_button.text = "Board Flip: Auto"
	if tabletop_button != null:
		tabletop_button.text = "Tabletop: Auto"

func _show_turn_handoff_if_needed(_action_type: String = "") -> void:
	if single_player_enabled:
		_update_board_flip()
		_maybe_queue_ai_turn()
		return
	if _is_ai_turn_active():
		_update_board_flip()
		_maybe_queue_ai_turn()
		return
	# Offline Human vs Human is always shared Tabletop now, so no phone-passing
	# handoff screen is needed. Keep the board live and player-facing.
	_update_board_flip()

func _on_start_next_turn_pressed() -> void:
	if turn_handoff_panel != null:
		turn_handoff_panel.visible = false
	if pause_cover_rect != null:
		pause_cover_rect.visible = false
	_update_board_flip()
	selection_label.text = "%s to act. Tap a piece, long press any piece for info." % rules.get_turn_name()
	if speed_timer_enabled:
		_start_resume_countdown()
	else:
		_play_sound_cue("confirm")
	_update_labels()

func _update_board_flip() -> void:
	if board_view == null or rules == null:
		return
	# Keep the old orientation while the handoff screen is up.
	# The board flips only after the next player presses Start Turn.
	if turn_handoff_panel != null and turn_handoff_panel.visible:
		return
	var should_flip: bool = board_flip_enabled and not single_player_enabled and not _is_tabletop_active_for_current_context() and not tutorial_active and not rules.mode_name.begins_with("Scenario Lab") and rules.turn == SigmaRules.OWNER_P2
	board_view.set_board_flipped(should_flip)


func _on_play_pressed() -> void:
	_on_main_menu_new_game()

func _build_startup_splash() -> void:
	startup_splash_layer = Control.new()
	startup_splash_layer.name = "SigmaStartupSplash"
	startup_splash_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	startup_splash_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	startup_splash_layer.visible = false
	add_child(startup_splash_layer)

	var bg_fill: ColorRect = ColorRect.new()
	bg_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_fill.color = Color("#02050D")
	bg_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startup_splash_layer.add_child(bg_fill)

	startup_splash_art = TextureRect.new()
	startup_splash_art.name = "SigmaStartupSplashArt"
	startup_splash_art.texture = load("res://assets/ui/branding/sigma_startup_splash.png")
	startup_splash_art.stretch_mode = TextureRect.STRETCH_SCALE
	startup_splash_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	startup_splash_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startup_splash_layer.add_child(startup_splash_art)
	startup_splash_layer.resized.connect(_layout_startup_splash_art)
	_layout_startup_splash_art()

func _layout_startup_splash_art() -> void:
	if startup_splash_layer == null or startup_splash_art == null or startup_splash_art.texture == null:
		return
	var viewport_size: Vector2 = startup_splash_layer.size
	var texture_size: Vector2 = startup_splash_art.texture.get_size()
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale_value: float = min(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	var draw_size: Vector2 = texture_size * scale_value
	startup_splash_art.position = (viewport_size - draw_size) * 0.5
	startup_splash_art.size = draw_size

func _show_startup_intro() -> void:
	if startup_splash_layer == null:
		_show_main_menu()
		return
	# Place the Main Menu behind the splash before the fade-out begins.
	# This prevents a one-frame flash of the live board between intro and menu.
	if main_menu_panel == null or not main_menu_panel.visible:
		_show_main_menu()
	startup_splash_layer.visible = true
	startup_splash_layer.modulate = Color(1, 1, 1, 0)
	startup_splash_layer.move_to_front()
	_play_sound_cue("logo_intro")
	var tween: Tween = create_tween()
	tween.tween_property(startup_splash_layer, "modulate", Color(1, 1, 1, 1), 0.45)
	tween.tween_interval(1.25)
	tween.tween_property(startup_splash_layer, "modulate", Color(1, 1, 1, 0), 0.35)
	tween.tween_callback(func() -> void:
		startup_splash_layer.visible = false
	)

func _show_first_time_menu() -> void:
	_show_startup_intro()

func _hide_app_overlays() -> void:
	# Hide game chrome first, then hide every full-screen/menu overlay.
	# Important: Continue Game is pressed while Main Menu is still visible.
	# _set_gameplay_chrome_visible(false) calls _update_tabletop_passplay_ui(),
	# which sees the Main Menu and temporarily disables tabletop mode. After the
	# menu is hidden below, run the tabletop layout pass again so resumed games
	# return to the real tabletop arena instead of the phone/handoff layout.
	_set_gameplay_chrome_visible(false)
	_hide_menu_page_backdrop()
	if main_menu_panel != null:
		main_menu_panel.visible = false
	if new_game_panel != null:
		new_game_panel.visible = false
	if draft_panel != null:
		draft_panel.visible = false
	if custom_game_panel != null:
		custom_game_panel.visible = false
	if tutorial_panel != null:
		tutorial_panel.visible = false
	if tutorial_backdrop_layer != null:
		tutorial_backdrop_layer.visible = false
	if rules_guide_panel != null:
		rules_guide_panel.visible = false
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	if collections_set_detail_panel != null:
		collections_set_detail_panel.visible = false
	if collections_board_detail_panel != null:
		collections_board_detail_panel.visible = false
	if collections_vector_set_detail_panel != null:
		collections_vector_set_detail_panel.visible = false
	if collections_vector_board_detail_panel != null:
		collections_vector_board_detail_panel.visible = false
	if collections_draconian_set_detail_panel != null:
		collections_draconian_set_detail_panel.visible = false
	if collections_draconian_board_detail_panel != null:
		collections_draconian_board_detail_panel.visible = false
	if collections_lions_den_set_detail_panel != null:
		collections_lions_den_set_detail_panel.visible = false
	if collections_lions_den_board_detail_panel != null:
		collections_lions_den_board_detail_panel.visible = false
	if collections_panel != null:
		collections_panel.visible = false
	if settings_panel != null:
		settings_panel.visible = false
	if session_panel != null:
		session_panel.visible = false
	if pause_cover_rect != null:
		pause_cover_rect.visible = false
	if turn_handoff_panel != null:
		turn_handoff_panel.visible = false
	_update_tabletop_passplay_ui()
	_sync_board_input_lock()
	if board_view != null:
		board_view.queue_redraw()

func _show_main_menu() -> void:
	AudioManager.stop_pause_music()
	_hide_new_game_confirm()
	_play_menu_audio_scene("main")
	_play_sound_cue("page_open")
	_reset_board_visual_state(true, true)
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	if main_menu_panel != null:
		main_menu_panel.visible = true
		_layout_main_menu_art()
	_sync_board_input_lock()
	# Re-evaluate tabletop UI now that the landing page is visible so gameplay
	# controls do not remain active behind the menu.
	_update_tabletop_passplay_ui()
	_update_continue_button()
	_set_menu_preview("quick")

func _build_main_menu_panel(parent: Control) -> void:
	main_menu_panel = PanelContainer.new()
	main_menu_panel.name = "MainMenuLandingPage"
	main_menu_panel.visible = false
	main_menu_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu_panel.offset_left = 0
	main_menu_panel.offset_top = 0
	main_menu_panel.offset_right = 0
	main_menu_panel.offset_bottom = 0
	main_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main_menu_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#02050C", 1.0), Color("#D4AF37", 0.42), 0, 0))
	add_child(main_menu_panel)

	var bg: ColorRect = ColorRect.new()
	bg.name = "AnimatedCrestBackdrop"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#02050C", 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(bg)

	var crest: Label = Label.new()
	crest.name = "LiveSigmaCrest"
	crest.text = "Σ"
	crest.set_anchors_preset(Control.PRESET_CENTER)
	crest.custom_minimum_size = Vector2(420, 420)
	crest.offset_left = -210
	crest.offset_top = -260
	crest.offset_right = 210
	crest.offset_bottom = 160
	crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crest.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crest.add_theme_font_size_override("font_size", 260)
	crest.add_theme_color_override("font_color", Color("#D4AF37", 0.15))
	crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(crest)
	var crest_tween: Tween = create_tween()
	crest_tween.set_loops()
	crest_tween.tween_property(crest, "modulate:a", 0.42, 1.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	crest_tween.tween_property(crest, "modulate:a", 0.18, 1.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	main_menu_panel.add_child(margin)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var center: CenterContainer = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(390, 0)
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var title: Label = Label.new()
	title.text = "SIGMA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(title)

	var tagline: Label = Label.new()
	tagline.text = "The sum of every move."
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.add_theme_font_size_override("font_size", 18)
	tagline.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(tagline)

	var preview_shell: PanelContainer = PanelContainer.new()
	preview_shell.custom_minimum_size = Vector2(360, 160)
	preview_shell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_shell.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.88), Color("#D4AF37", 0.72), 2, 28))
	box.add_child(preview_shell)
	var preview_margin: MarginContainer = MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 12)
	preview_margin.add_theme_constant_override("margin_right", 12)
	preview_margin.add_theme_constant_override("margin_top", 10)
	preview_margin.add_theme_constant_override("margin_bottom", 10)
	preview_shell.add_child(preview_margin)
	menu_preview_board = BoardView.new()
	menu_preview_board.custom_minimum_size = Vector2(340, 140)
	menu_preview_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_preview_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_preview_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_margin.add_child(menu_preview_board)

	menu_preview_label = Label.new()
	menu_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_preview_label.add_theme_font_size_override("font_size", 15)
	menu_preview_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(menu_preview_label)

	continue_game_button = _add_menu_button(box, "Continue", "Jump back into your saved match.", _on_main_menu_continue_game, "quick")
	_add_menu_button(box, "New Game", "Start Classic, Full, Draft, or Custom SIGMA.", _on_main_menu_new_game, "quick")
	_add_menu_button(box, "Tournament", "Create or continue a SIGMA tournament.", _on_main_menu_tournament, "custom")
	_add_menu_button(box, "Collections", "Choose your board and pieces.", _on_collections_pressed, "collections")
	_add_menu_button(box, "Tutorial", "Learn SIGMA in quick missions.", _on_main_menu_tutorial, "tutorial")
	_add_menu_button(box, "Rules", "Simple rule guide.", _on_rules_guide_pressed, "rules")
	_add_menu_button(box, "Settings", "Audio, display, and controls.", _on_settings_pressed, "settings")

	main_menu_hotspot_layer = null
	_set_menu_preview("quick")
	_update_continue_button()


func _layout_main_menu_art() -> void:
	if main_menu_panel == null or main_menu_art_rect == null or main_menu_art_rect.texture == null:
		return
	var viewport_size: Vector2 = main_menu_panel.size
	var texture_size: Vector2 = main_menu_art_rect.texture.get_size()
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale_value: float = min(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	var draw_size: Vector2 = texture_size * scale_value
	var draw_position: Vector2 = (viewport_size - draw_size) * 0.5
	main_menu_art_rect.position = draw_position
	main_menu_art_rect.size = draw_size
	if main_menu_hotspot_layer != null:
		main_menu_hotspot_layer.position = draw_position
		main_menu_hotspot_layer.size = draw_size

func _add_main_menu_hotspot(parent: Control, title: String, art_rect: Rect2, callback: Callable, preview_id: String = "quick") -> Button:
	var button: Button = Button.new()
	button.name = "%sHotspot" % title.replace(" ", "")
	button.text = ""
	# Keep tooltips off the invisible artwork buttons so desktop hover previews do
	# not add extra floating labels over the calibrated menu art.
	button.tooltip_text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.anchor_left = art_rect.position.x
	button.anchor_right = art_rect.position.x + art_rect.size.x
	button.anchor_top = art_rect.position.y
	button.anchor_bottom = art_rect.position.y + art_rect.size.y
	button.offset_left = 0
	button.offset_right = 0
	button.offset_top = 0
	button.offset_bottom = 0
	var transparent: StyleBoxFlat = StyleBoxFlat.new()
	transparent.bg_color = Color(0, 0, 0, 0.01)
	transparent.border_color = Color(0, 0, 0, 0)
	transparent.set_border_width_all(0)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color("#F2C14E", 0.10)
	hover.border_color = Color("#F2C14E", 0.55)
	hover.set_border_width_all(2)
	hover.corner_radius_top_left = 22
	hover.corner_radius_top_right = 22
	hover.corner_radius_bottom_left = 22
	hover.corner_radius_bottom_right = 22
	button.add_theme_stylebox_override("normal", transparent)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.mouse_entered.connect(func() -> void:
		_set_menu_preview(preview_id)
		_play_sound_cue("button_hover")
	)
	button.focus_entered.connect(func() -> void:
		_set_menu_preview(preview_id)
		_play_sound_cue("button_hover")
	)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		callback.call()
	)
	parent.add_child(button)
	return button

func _add_menu_button(parent: Container, title: String, subtitle: String, callback: Callable, preview_id: String = "quick") -> Button:
	var button: Button = Button.new()
	button.text = title
	button.tooltip_text = subtitle
	button.custom_minimum_size = Vector2(320, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 19)
	_style_button(button, "gold" if preview_id == "quick" else "menu")
	button.mouse_entered.connect(func() -> void:
		_set_menu_preview(preview_id)
		_play_sound_cue("button_hover")
	)
	button.focus_entered.connect(func() -> void:
		_set_menu_preview(preview_id)
		_play_sound_cue("button_hover")
	)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		_punch_button(button)
		callback.call()
	)
	parent.add_child(button)
	return button

func _set_menu_preview(preview_id: String) -> void:
	if menu_preview_board == null:
		return
	menu_preview_rules = SigmaRules.new()
	var label_text: String = "New Game · Classic / Full / Draft + BLITZ!"
	match preview_id:
		"full":
			menu_preview_rules.new_game(SigmaRules.full_config())
			label_text = "Full SIGMA · premium full-board pressure"
		"draft":
			menu_preview_rules.new_game(SigmaRules.full_config())
			label_text = "Draft SIGMA · choose your power cards"
		"blitz":
			var blitz_config: Dictionary = _apply_blitz_to_config(SigmaRules.classic_config())
			menu_preview_rules.new_game(blitz_config)
			label_text = "Classic SIGMA BLITZ! · 10 sec / 140 turns / Overtime"
		"custom":
			menu_preview_rules.new_game(SigmaRules.full_config())
			label_text = "Custom Game · choose mode cards and toggles"
		"tutorial":
			menu_preview_rules.new_game(SigmaRules.classic_config())
			label_text = "Tutorial · guided piece showcase"
		"rules":
			menu_preview_rules.load_scenario("peril_guardian")
			label_text = "Rules Guide · Peril / Retreat / Elevate pays off"
		"settings":
			menu_preview_rules.new_game(SigmaRules.classic_config())
			label_text = "Settings · premium control table"
		"collections":
			menu_preview_rules.new_game(SigmaRules.full_config())
			label_text = "Collections · Classic SIGMA Tokens"
		_:
			menu_preview_rules.new_game(SigmaRules.classic_config())
			label_text = "New Game · choose a mode, then preview"
	menu_preview_board.set_rules(menu_preview_rules)
	menu_preview_board.set_living_preview(true, preview_id)
	if menu_preview_label != null:
		menu_preview_label.text = label_text



func _build_new_game_panel(_parent: Control) -> void:
	new_game_panel = PanelContainer.new()
	new_game_panel.name = "NewGamePage"
	new_game_panel.visible = false
	new_game_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_game_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	new_game_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.98), Color("#D4AF37"), 2, 28))
	add_child(new_game_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	new_game_panel.add_child(margin)

	var center: CenterContainer = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(center)

	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(360, 0)
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	center.add_child(box)

	_add_top_right_close_button(box, "Close this page and return to Main Menu.", _show_main_menu)

	var title: Label = Label.new()
	title.text = "New Game"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Choose your mode."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(subtitle)

	var card_stack: VBoxContainer = VBoxContainer.new()
	card_stack.add_theme_constant_override("separation", 9)
	card_stack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(card_stack)

	new_game_mode_buttons = {}
	_add_new_game_card(card_stack, "Classic SIGMA", _on_new_game_classic, "classic")
	_add_new_game_card(card_stack, "Full SIGMA", _on_new_game_full, "full")
	_add_new_game_card(card_stack, "Draft SIGMA", _on_new_game_draft, "draft")
	_add_new_game_card(card_stack, "Custom Game", _on_new_game_custom, "custom")

	var blitz_stack: VBoxContainer = VBoxContainer.new()
	blitz_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	blitz_stack.add_theme_constant_override("separation", 9)
	blitz_stack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(blitz_stack)
	new_game_blitz_button = _add_button(blitz_stack, "BLITZ!: OFF", "Toggle BLITZ! format for the selected base mode.", _on_new_game_blitz_toggle)
	_make_new_game_uniform_button(new_game_blitz_button)
	new_game_ai_button = _add_button(blitz_stack, "Opponent: Human", "Toggle offline Single Player vs AI. Human plays Gold; AI plays Silver.", _on_new_game_ai_toggle)
	_make_new_game_uniform_button(new_game_ai_button)

	new_game_ai_difficulty_box = GridContainer.new()
	new_game_ai_difficulty_box.columns = 2
	new_game_ai_difficulty_box.add_theme_constant_override("h_separation", 8)
	new_game_ai_difficulty_box.add_theme_constant_override("v_separation", 8)
	new_game_ai_difficulty_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	new_game_ai_difficulty_box.visible = false
	box.add_child(new_game_ai_difficulty_box)
	new_game_ai_difficulty_buttons = {}
	for difficulty in ["Beginner", "Rookie", "Intermediate", "Professional", "Expert", "Champion"]:
		var difficulty_button: Button = _add_button(new_game_ai_difficulty_box, difficulty, "%s bot: offline AI with its own search depth and variety." % difficulty, _on_new_game_ai_difficulty_pressed.bind(difficulty))
		difficulty_button.custom_minimum_size = Vector2(156, 46)
		difficulty_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		new_game_ai_difficulty_buttons[difficulty] = difficulty_button

	var preview_shell: PanelContainer = PanelContainer.new()
	preview_shell.custom_minimum_size = Vector2(340, 230)
	preview_shell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_shell.add_theme_stylebox_override("panel", _make_rounded_style(Color("#08101F", 0.97), Color("#00D1FF"), 2, 22))
	box.add_child(preview_shell)

	var preview_margin: MarginContainer = MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 14)
	preview_margin.add_theme_constant_override("margin_right", 14)
	preview_margin.add_theme_constant_override("margin_top", 12)
	preview_margin.add_theme_constant_override("margin_bottom", 12)
	preview_shell.add_child(preview_margin)

	var preview_box: VBoxContainer = VBoxContainer.new()
	preview_box.alignment = BoxContainer.ALIGNMENT_CENTER
	preview_box.add_theme_constant_override("separation", 8)
	preview_margin.add_child(preview_box)

	new_game_preview_title_label = Label.new()
	new_game_preview_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_game_preview_title_label.add_theme_font_size_override("font_size", 24)
	new_game_preview_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	preview_box.add_child(new_game_preview_title_label)

	new_game_preview_body_label = Label.new()
	new_game_preview_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	new_game_preview_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_game_preview_body_label.add_theme_font_size_override("font_size", 15)
	new_game_preview_body_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	new_game_preview_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_box.add_child(new_game_preview_body_label)

	new_game_start_button = _add_button(preview_box, "Start Game", "Start the previewed SIGMA game.", _on_new_game_start_pressed)
	new_game_start_button.custom_minimum_size = Vector2(300, 52)
	new_game_start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_update_new_game_preview()

func _make_new_game_uniform_button(button: Button) -> void:
	if button == null:
		return
	button.custom_minimum_size = Vector2(320, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.clip_text = true

func _add_new_game_card(parent: Container, title: String, callback: Callable, mode_id: String) -> Button:
	var button: Button = Button.new()
	button.text = title
	button.tooltip_text = "Select %s and review it below." % title
	button.custom_minimum_size = Vector2(320, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 19)
	_style_button(button, "gold" if new_game_selected_mode == mode_id else "menu")
	button.mouse_entered.connect(func() -> void:
		_set_menu_preview(mode_id)
		_play_sound_cue("button_hover")
	)
	button.focus_entered.connect(func() -> void:
		_set_menu_preview(mode_id)
		_play_sound_cue("button_hover")
	)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		callback.call()
	)
	parent.add_child(button)
	new_game_mode_buttons[mode_id] = button
	return button

func _on_main_menu_new_game() -> void:
	_play_menu_audio_scene("setup")
	_play_sound_cue("page_open")
	_hide_app_overlays()
	if new_game_panel != null:
		new_game_panel.visible = true
	_sync_board_input_lock()
	_set_menu_preview(new_game_selected_mode)
	_update_new_game_preview()

func _on_new_game_classic() -> void:
	new_game_selected_mode = "classic"
	_update_new_game_preview()

func _on_new_game_full() -> void:
	new_game_selected_mode = "full"
	_update_new_game_preview()

func _on_new_game_draft() -> void:
	new_game_selected_mode = "draft"
	_update_new_game_preview()

func _on_new_game_blitz_toggle() -> void:
	new_game_blitz_enabled = not new_game_blitz_enabled
	_play_sound_cue("button_tap")
	_update_new_game_preview()

func _on_new_game_ai_toggle() -> void:
	new_game_ai_enabled = not new_game_ai_enabled
	_play_sound_cue("button_tap")
	_update_new_game_preview()

func _on_new_game_ai_difficulty_pressed(difficulty: String) -> void:
	new_game_ai_difficulty = difficulty
	if not new_game_ai_enabled:
		new_game_ai_enabled = true
	_play_sound_cue("button_tap")
	_update_new_game_preview()

func _update_new_game_preview() -> void:
	for mode_key in new_game_mode_buttons.keys():
		var b: Button = new_game_mode_buttons[mode_key] as Button
		if b != null:
			_style_button(b, "gold" if String(mode_key) == new_game_selected_mode else "menu")
	if new_game_blitz_button != null:
		new_game_blitz_button.text = "BLITZ!: ON" if new_game_blitz_enabled else "BLITZ!: OFF"
		_style_button(new_game_blitz_button, "red" if new_game_blitz_enabled else "menu")
	if new_game_ai_button != null:
		new_game_ai_button.text = "Opponent: %s" % ("%s Bot" % new_game_ai_difficulty if new_game_ai_enabled else "Human")
		_style_button(new_game_ai_button, "cyan" if new_game_ai_enabled else "menu")
	if new_game_ai_difficulty_box != null:
		new_game_ai_difficulty_box.visible = new_game_ai_enabled
	for diff_key in new_game_ai_difficulty_buttons.keys():
		var db: Button = new_game_ai_difficulty_buttons[diff_key] as Button
		if db != null:
			db.disabled = not new_game_ai_enabled
			_style_button(db, "gold" if new_game_ai_enabled and String(diff_key) == new_game_ai_difficulty else "menu")
	var base_name: String = _new_game_base_name(new_game_selected_mode)
	var display_name: String = base_name
	if new_game_blitz_enabled:
		display_name = "%s BLITZ!" % base_name
	if new_game_ai_enabled:
		display_name = "%s vs %s Bot" % [display_name, new_game_ai_difficulty]
	if new_game_preview_title_label != null:
		new_game_preview_title_label.text = display_name
	if new_game_preview_body_label != null:
		new_game_preview_body_label.text = _new_game_preview_body(new_game_selected_mode, new_game_blitz_enabled)
	if new_game_start_button != null:
		new_game_start_button.text = "Start %s" % ("Draft" if new_game_selected_mode == "draft" else "Game")

func _new_game_base_name(mode_id: String) -> String:
	match mode_id:
		"full":
			return "Full SIGMA"
		"draft":
			return "Draft SIGMA"
		_:
			return "Classic SIGMA"

func _new_game_preview_body(mode_id: String, blitz_on: bool) -> String:
	var lines: Array = []
	match mode_id:
		"full":
			lines.append("Setup: G I A S M S A I G")
			lines.append("Reserves: 5")
		"draft":
			lines.append("Draft advanced pieces, then build your row.")
			lines.append("Reserves: 5")
		"custom":
			lines.append("Build your own SIGMA match.")
			lines.append("Choose mode, rules, BLITZ!, and opponent.")
		_:
			lines.append("Setup: G G G S M S G G G")
			lines.append("Reserves: 5")
	lines.append("BLITZ!: %s" % ("ON · 10s / 140 turns / Overtime" if blitz_on else "OFF · normal timing"))
	if new_game_ai_enabled:
		lines.append("Opponent: %s Bot" % new_game_ai_difficulty)
	else:
		lines.append("Offline Human vs Human uses Tabletop automatically.")
	return "\n".join(lines)

func _on_new_game_start_pressed() -> void:
	if new_game_selected_mode == "draft":
		draft_from_custom_game = new_game_blitz_enabled or new_game_ai_enabled
		draft_custom_toggles = {}
		if new_game_blitz_enabled:
			draft_custom_toggles = _blitz_settings_dictionary()
			# This mode name is applied after rows are built.
			draft_custom_toggles["mode_name"] = "Draft SIGMA BLITZ!"
		if new_game_ai_enabled:
			draft_custom_toggles["single_player_ai"] = true
			draft_custom_toggles["ai_side"] = SigmaRules.OWNER_P2
			draft_custom_toggles["human_side"] = SigmaRules.OWNER_P1
			draft_custom_toggles["ai_difficulty"] = new_game_ai_difficulty
		_play_sound_cue("page_open")
		_hide_app_overlays()
		_show_menu_page_backdrop("setup")
		_reset_draft_builder()
		if draft_panel != null:
			draft_panel.visible = true
		return
	var config: Dictionary = _new_game_config_for_selection()
	pending_custom_config = config
	if _should_confirm_replacing_game():
		_show_new_game_confirm("custom")
		return
	_start_custom_now(config)

func _new_game_config_for_selection() -> Dictionary:
	var config: Dictionary = SigmaRules.classic_config()
	if new_game_selected_mode == "full":
		config = SigmaRules.full_config()
	if new_game_blitz_enabled:
		config = _apply_blitz_to_config(config)
	if new_game_ai_enabled:
		config["single_player_ai"] = true
		config["ai_side"] = SigmaRules.OWNER_P2
		config["human_side"] = SigmaRules.OWNER_P1
		config["ai_difficulty"] = new_game_ai_difficulty
		config["mode_name"] = "%s vs %s Bot" % [String(config.get("mode_name", "Classic SIGMA")), new_game_ai_difficulty]
	else:
		config["single_player_ai"] = false
	return config

func _blitz_settings_dictionary() -> Dictionary:
	return {
		"speed_sigma": true,
		"turn_timer_seconds": 10,
		"turn_limit_total": 140,
		"round_limit": 70,
	}

func _apply_blitz_to_config(config: Dictionary) -> Dictionary:
	var out: Dictionary = config.duplicate(true)
	var base_name: String = String(out.get("mode_name", "Classic SIGMA"))
	out["mode_name"] = "%s BLITZ!" % base_name
	var settings: Dictionary = _blitz_settings_dictionary()
	for k in settings.keys():
		out[k] = settings[k]
	return out

func _start_blitz_now() -> void:
	# Compatibility path for old saved menus: Classic SIGMA with BLITZ! enabled.
	var config: Dictionary = _apply_blitz_to_config(SigmaRules.classic_config())
	_start_custom_now(config)
	selection_label.text = "Classic SIGMA BLITZ! started: 10 seconds, 140 total turns, Overtime ON."

func _build_new_game_confirm_dialog() -> void:
	new_game_confirm_cover = ColorRect.new()
	new_game_confirm_cover.name = "NewGameConfirmCover"
	new_game_confirm_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_game_confirm_cover.color = Color(0, 0, 0, 0.68)
	new_game_confirm_cover.visible = false
	new_game_confirm_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(new_game_confirm_cover)

	new_game_confirm_panel = _make_center_panel("NewGameConfirmPanel", Vector2(440, 228))
	new_game_confirm_panel.visible = false
	new_game_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(new_game_confirm_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	new_game_confirm_panel.add_child(box)

	var header: HBoxContainer = HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	new_game_confirm_title_label = Label.new()
	new_game_confirm_title_label.text = "Start New Game?"
	new_game_confirm_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_game_confirm_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_game_confirm_title_label.add_theme_font_size_override("font_size", 24)
	new_game_confirm_title_label.add_theme_color_override("font_color", Color("#F2C14E"))
	header.add_child(new_game_confirm_title_label)

	var close_btn: Button = Button.new()
	close_btn.text = "X"
	close_btn.tooltip_text = "Close this confirmation."
	close_btn.custom_minimum_size = Vector2(46, 44)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.add_theme_stylebox_override("normal", _make_rounded_style(Color("#060A14", 0.96), Color("#4A5D75"), 1, 20))
	close_btn.add_theme_stylebox_override("hover", _make_rounded_style(Color("#172033", 0.98), Color("#D4AF37"), 2, 20))
	close_btn.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#030611", 0.98), Color("#00D1FF"), 2, 20))
	close_btn.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		_hide_new_game_confirm()
	)
	header.add_child(close_btn)

	new_game_confirm_body_label = Label.new()
	new_game_confirm_body_label.text = "This will replace your current saved game."
	new_game_confirm_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_game_confirm_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_game_confirm_body_label.add_theme_font_size_override("font_size", 16)
	new_game_confirm_body_label.add_theme_color_override("font_color", Color("#F7F3E8"))
	box.add_child(new_game_confirm_body_label)

	var note: Label = Label.new()
	note.text = "Starting a new match replaces the current autosave."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(note)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	box.add_child(button_row)

	_add_button(button_row, "Cancel", "Keep your current match.", _hide_new_game_confirm)
	new_game_confirm_primary_button = _add_button(button_row, "Start New Game", "Replace the current match and begin the selected mode.", _on_new_game_confirmed)
	new_game_confirm_primary_button.custom_minimum_size = Vector2(190, 58)

func _hide_new_game_confirm() -> void:
	if new_game_confirm_cover != null:
		new_game_confirm_cover.visible = false
	if new_game_confirm_panel != null:
		new_game_confirm_panel.visible = false
	_sync_board_input_lock()
	

func _build_session_panel(parent: Control) -> void:
	pause_cover_rect = ColorRect.new()
	pause_cover_rect.name = "PauseBoardCover"
	pause_cover_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_cover_rect.color = Color(0, 0, 0, 0.82)
	pause_cover_rect.visible = false
	pause_cover_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(pause_cover_rect)

	session_panel = _make_center_panel("SessionMenuPanel", Vector2(540, 400))
	session_panel.visible = false
	session_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(session_panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	session_panel.add_child(box)
	var title: Label = Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(title)
	var note: Label = Label.new()
	note.text = "Take a breath. The match is paused."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("#E8EDF2"))
	note.custom_minimum_size = Vector2(0, 54)
	box.add_child(note)
	var resume_button: Button = _add_button(box, "Resume", "Close this menu and continue the match.", _on_session_resume)
	resume_button.custom_minimum_size = Vector2(0, 70)
	var rules_button: Button = _add_button(box, "Guide", "Open the rules guide.", _on_rules_guide_pressed)
	rules_button.custom_minimum_size = Vector2(0, 66)
	var settings_button_pause: Button = _add_button(box, "Settings", "Open settings.", _on_settings_pressed)
	settings_button_pause.custom_minimum_size = Vector2(0, 66)
	var end_match_button: Button = _add_button(box, "End Match", "End this match and return to the Main Menu.", _on_session_end_match)
	end_match_button.custom_minimum_size = Vector2(0, 66)
	var main_menu_button_pause: Button = _add_button(box, "Main Menu", "Return to the landing page.", _show_main_menu)
	main_menu_button_pause.custom_minimum_size = Vector2(0, 66)

func _on_game_menu_pressed() -> void:
	_clear_preview_state(true)
	resume_countdown_active = false
	AudioManager.pause_game_music()
	AudioManager.play_pause_music(true)
	if pause_cover_rect != null:
		pause_cover_rect.visible = true
	if session_panel != null:
		session_panel.visible = true
	_sync_board_input_lock()
	_play_sound_cue("page_open")

func _on_session_resume() -> void:
	AudioManager.stop_pause_music()
	AudioManager.resume_game_music()
	if session_panel != null:
		session_panel.visible = false
	if pause_cover_rect != null:
		pause_cover_rect.visible = false
	if turn_handoff_panel != null:
		turn_handoff_panel.visible = false
	_sync_board_input_lock()
	if speed_timer_enabled and rules != null and not rules.game_over:
		_start_resume_countdown()
	else:
		_play_sound_cue("cancel")

func _on_session_end_match() -> void:
	_clear_current_game_save()
	AudioManager.stop_pause_music()
	AudioManager.play_menu_music("main")
	if session_panel != null:
		session_panel.visible = false
	if pause_cover_rect != null:
		pause_cover_rect.visible = false
	selection_label.text = "Match ended. Ready for the next move."
	_show_main_menu()
	_sync_board_input_lock()
	_play_sound_cue("cancel")

func _on_session_restart() -> void:
	if rules.mode_name.find("Draft SIGMA") >= 0 and current_match_config.is_empty():
		selection_label.text = "Draft restart uses the Draft SIGMA page so rows can be confirmed again."
		_show_main_menu()
		_on_main_menu_new_game()
		new_game_selected_mode = "draft"
		new_game_blitz_enabled = speed_timer_enabled
		new_game_ai_enabled = single_player_enabled
		new_game_ai_difficulty = ai_difficulty
		_update_new_game_preview()
		return
	_show_new_game_confirm("restart_current")

func _start_classic_now() -> void:
	_play_sound_cue("confirm")
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	mode_option.select(0)
	_start_new_game(true)
	selection_label.text = "Classic SIGMA started. Tap a Gold piece."

func _start_full_now() -> void:
	_play_sound_cue("confirm")
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	mode_option.select(2)
	_start_new_game(true)
	selection_label.text = "Full SIGMA started. All advanced piece types begin on the board."

func _start_draft_now(config: Dictionary) -> void:
	current_match_is_tournament = false
	current_tournament_match_id = ""
	_play_sound_cue("confirm")
	_play_board_audio_scene()
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	_reset_board_visual_state(true, true)
	current_match_config = config.duplicate(true)
	_configure_single_player_from_config(config)
	rules.new_game(config)
	_configure_speed_timer_from_config(config)
	_update_adaptive_board_music()
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	selection_label.text = "%s started. Tap a Gold piece." % String(config.get("mode_name", "Draft SIGMA"))
	draft_from_custom_game = false
	draft_custom_toggles = {}
	piece_help_label.visible = false
	result_overlay.visible = false
	tutorial_active = false
	tutorial_step_loaded = false
	_update_labels()
	_autosave_current_game("Game saved")

func _show_new_game_confirm(mode: String) -> void:
	pending_new_game_mode = mode
	if new_game_confirm_panel == null:
		_on_new_game_confirmed()
		return
	var mode_text: String = "Classic SIGMA"
	if mode == "full":
		mode_text = "Full SIGMA"
	elif mode == "draft":
		mode_text = "Draft SIGMA"
	elif mode == "blitz":
		mode_text = "Classic SIGMA BLITZ!"
	elif mode == "custom":
		mode_text = String(pending_custom_config.get("mode_name", "Custom SIGMA"))
	elif mode == "restart_current":
		mode_text = "Restart Current Match"
	new_game_confirm_title_label.text = "Start New Game?"
	new_game_confirm_body_label.text = "Start %s?\nYour current saved game will be replaced." % mode_text
	if new_game_confirm_cover != null:
		new_game_confirm_cover.visible = true
		new_game_confirm_cover.move_to_front()
	if new_game_confirm_panel != null:
		# Re-apply center offsets in case the viewport size changed after export/window resize.
		new_game_confirm_panel.offset_left = -new_game_confirm_panel.custom_minimum_size.x * 0.5
		new_game_confirm_panel.offset_right = new_game_confirm_panel.custom_minimum_size.x * 0.5
		new_game_confirm_panel.offset_top = -new_game_confirm_panel.custom_minimum_size.y * 0.5
		new_game_confirm_panel.offset_bottom = new_game_confirm_panel.custom_minimum_size.y * 0.5
		new_game_confirm_panel.visible = true
		new_game_confirm_panel.move_to_front()
	_play_sound_cue("page_open")

func _on_new_game_confirmed() -> void:
	_hide_new_game_confirm()
	_clear_current_game_save()
	match pending_new_game_mode:
		"full":
			_start_full_now()
		"draft":
			_start_draft_now(pending_draft_config)
		"custom":
			_start_custom_now(pending_custom_config)
		"blitz":
			_start_blitz_now()
		"restart_current":
			_restart_current_match_now()
		_:
			_start_classic_now()
	pending_new_game_mode = ""

func _current_restart_config() -> Dictionary:
	var config: Dictionary = current_match_config.duplicate(true)
	if config.is_empty():
		config = SigmaRules.full_config() if rules != null and rules.mode_name.find("Full SIGMA") >= 0 else SigmaRules.classic_config()
		if speed_timer_enabled:
			config = _apply_blitz_to_config(config)
		if single_player_enabled:
			config["single_player_ai"] = true
			config["ai_side"] = ai_side
			config["human_side"] = human_side
			config["ai_difficulty"] = ai_difficulty
			var base_name: String = String(config.get("mode_name", "Classic SIGMA"))
			if base_name.find("Bot") < 0:
				config["mode_name"] = "%s vs %s Bot" % [base_name, ai_difficulty]
	return config

func _restart_current_match_now() -> void:
	var config: Dictionary = _current_restart_config()
	_start_custom_now(config)
	selection_label.text = "%s restarted." % String(config.get("mode_name", "SIGMA"))

func _active_game_save_path() -> String:
	return TOURNAMENT_MATCH_SAVE_PATH if current_match_is_tournament else SAVE_PATH

func _has_tournament_save() -> bool:
	if not FileAccess.file_exists(TOURNAMENT_SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TOURNAMENT_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	return bool((data as Dictionary).get("active", false))

func _has_active_tournament_match_save() -> bool:
	if not FileAccess.file_exists(TOURNAMENT_MATCH_SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TOURNAMENT_MATCH_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	return bool((data as Dictionary).get("active", false))

func _save_tournament_data(data: Dictionary, message: String = "Tournament saved") -> void:
	var file: FileAccess = FileAccess.open(TOURNAMENT_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		if custom_status_label != null:
			custom_status_label.text = "Tournament save failed."
		return
	var save_data: Dictionary = data.duplicate(true)
	save_data["active"] = true
	save_data["version"] = BUILD_VERSION
	save_data["saved_at_unix"] = Time.get_unix_time_from_system()
	file.store_var(save_data, true)
	active_tournament_data = save_data.duplicate(true)
	if custom_status_label != null:
		custom_status_label.text = message

func _load_tournament_data() -> bool:
	if not FileAccess.file_exists(TOURNAMENT_SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TOURNAMENT_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	var tournament_data: Dictionary = data as Dictionary
	if not bool(tournament_data.get("active", false)):
		return false
	active_tournament_data = tournament_data.duplicate(true)
	tournament_name_text = String(active_tournament_data.get("name", tournament_name_text))
	tournament_type_id = String(active_tournament_data.get("type_id", tournament_type_id))
	tournament_player_count = int(active_tournament_data.get("player_count", tournament_player_count))
	tournament_match_mode_id = String(active_tournament_data.get("match_mode_id", tournament_match_mode_id))
	tournament_best_of = int(active_tournament_data.get("best_of", tournament_best_of))
	tournament_allow_takeover = bool(active_tournament_data.get("allow_takeover", tournament_allow_takeover))
	tournament_third_place = bool(active_tournament_data.get("third_place", tournament_third_place))
	tournament_swiss_rounds = int(active_tournament_data.get("swiss_rounds", tournament_swiss_rounds))
	tournament_blitz_enabled = bool(active_tournament_data.get("blitz_enabled", tournament_blitz_enabled))
	tournament_blitz_timer_seconds = int(active_tournament_data.get("blitz_timer_seconds", tournament_blitz_timer_seconds))
	tournament_blitz_turn_limit = int(active_tournament_data.get("blitz_turn_limit", tournament_blitz_turn_limit))
	tournament_participants = (active_tournament_data.get("participants", []) as Array).duplicate(true)
	_ensure_tournament_participants_count()
	return true

func _load_tournament_data_from_active_match_save() -> bool:
	if not FileAccess.file_exists(TOURNAMENT_MATCH_SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TOURNAMENT_MATCH_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	var save_data: Dictionary = data as Dictionary
	if not bool(save_data.get("active", false)):
		return false
	var tournament_data: Dictionary = save_data.get("tournament_data", {}) as Dictionary
	if tournament_data.is_empty():
		return false
	active_tournament_data = tournament_data.duplicate(true)
	tournament_name_text = String(active_tournament_data.get("name", tournament_name_text))
	tournament_type_id = String(active_tournament_data.get("type_id", tournament_type_id))
	tournament_player_count = int(active_tournament_data.get("player_count", tournament_player_count))
	tournament_match_mode_id = String(active_tournament_data.get("match_mode_id", tournament_match_mode_id))
	tournament_best_of = int(active_tournament_data.get("best_of", tournament_best_of))
	tournament_allow_takeover = bool(active_tournament_data.get("allow_takeover", tournament_allow_takeover))
	tournament_third_place = bool(active_tournament_data.get("third_place", tournament_third_place))
	tournament_swiss_rounds = int(active_tournament_data.get("swiss_rounds", tournament_swiss_rounds))
	tournament_blitz_enabled = bool(active_tournament_data.get("blitz_enabled", tournament_blitz_enabled))
	tournament_blitz_timer_seconds = int(active_tournament_data.get("blitz_timer_seconds", tournament_blitz_timer_seconds))
	tournament_blitz_turn_limit = int(active_tournament_data.get("blitz_turn_limit", tournament_blitz_turn_limit))
	tournament_participants = (active_tournament_data.get("participants", []) as Array).duplicate(true)
	_ensure_tournament_participants_count()
	return true

func _load_saved_tournament_match() -> bool:
	if not FileAccess.file_exists(TOURNAMENT_MATCH_SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TOURNAMENT_MATCH_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	var save_data: Dictionary = data as Dictionary
	if not bool(save_data.get("active", false)):
		return false
	var rules_state: Dictionary = save_data.get("rules", {}) as Dictionary
	if rules_state.is_empty():
		return false
	if not rules.import_save_state(rules_state):
		return false
	current_match_is_tournament = true
	active_tournament_data = (save_data.get("tournament_data", {}) as Dictionary).duplicate(true)
	pending_tournament_match = (save_data.get("tournament_pending_match", {}) as Dictionary).duplicate(true)
	current_tournament_match_id = String(save_data.get("tournament_match_id", ""))
	speed_timer_enabled = bool(save_data.get("speed_timer_enabled", false))
	speed_turn_seconds = int(save_data.get("speed_turn_seconds", int(rules.turn_timer_seconds)))
	speed_time_left = float(save_data.get("speed_time_left", float(speed_turn_seconds)))
	speed_total_turn_limit = int(save_data.get("speed_total_turn_limit", int(rules.turn_limit_total)))
	single_player_enabled = bool(save_data.get("single_player_enabled", false))
	ai_side = int(save_data.get("ai_side", SigmaRules.OWNER_P2))
	human_side = int(save_data.get("human_side", SigmaRules.OWNER_P1))
	ai_difficulty = String(save_data.get("ai_difficulty", "Rookie"))
	ai_thinking = false
	ai_turn_queued = false
	_reset_board_visual_state(true, true)
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	result_overlay.visible = false
	tutorial_active = false
	tutorial_step_loaded = false
	_play_board_audio_scene()
	_update_adaptive_board_music()
	_update_labels()
	if save_status_label != null:
		save_status_label.text = "Tournament match resumed"
	_maybe_queue_ai_turn()
	return true

func _clear_tournament_match_save() -> void:
	if not FileAccess.file_exists(TOURNAMENT_MATCH_SAVE_PATH):
		return
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null:
		dir.remove(TOURNAMENT_MATCH_SAVE_FILE_NAME)

func _should_confirm_replacing_game() -> bool:
	return _has_active_game_save()

func _has_active_game_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	return bool((data as Dictionary).get("active", false))

func _on_main_menu_continue_game() -> void:
	if _load_saved_game():
		_hide_app_overlays()
		# Force one final resumed-game layout pass after overlays are gone.
		# This preserves Tabletop ON by default when returning from the landing page.
		_update_labels()
		selection_label.text = "Saved game resumed."
		_play_sound_cue("confirm")
	else:
		selection_label.text = "No active saved game found."
		_update_continue_button()
		_play_sound_cue("illegal")

func _update_continue_button() -> void:
	if continue_game_button != null:
		continue_game_button.visible = _has_active_game_save()

func _autosave_current_game(message: String = "Game saved") -> void:
	if rules == null:
		return
	if not _is_save_eligible_game():
		return
	if rules.game_over:
		if current_match_is_tournament:
			_record_completed_tournament_match_from_rules()
			_clear_tournament_match_save()
			if save_status_label != null:
				save_status_label.text = "Tournament match complete. Tournament Hub updated."
		else:
			_clear_current_game_save()
			if save_status_label != null:
				save_status_label.text = "Match complete. Save cleared."
		_update_continue_button()
		return
	var file: FileAccess = FileAccess.open(_active_game_save_path(), FileAccess.WRITE)
	if file == null:
		if save_status_label != null:
			save_status_label.text = "Save failed."
		return
	var data: Dictionary = {
		"version": BUILD_VERSION,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"active": true,
		"mode_name": rules.mode_name,
		"speed_timer_enabled": speed_timer_enabled,
		"speed_turn_seconds": speed_turn_seconds,
		"speed_time_left": speed_time_left,
		"speed_total_turn_limit": speed_total_turn_limit,
		"single_player_enabled": single_player_enabled,
		"ai_side": ai_side,
		"human_side": human_side,
		"ai_difficulty": ai_difficulty,
		"tournament_match": current_match_is_tournament,
		"tournament_data": active_tournament_data.duplicate(true),
		"tournament_pending_match": pending_tournament_match.duplicate(true),
		"tournament_match_id": current_tournament_match_id,
		"rules": rules.export_save_state(),
	}
	file.store_var(data, true)
	if save_status_label != null:
		save_status_label.text = message
	_update_continue_button()


func _is_save_eligible_game() -> bool:
	if tutorial_active:
		return false
	if rules == null:
		return false
	if rules.mode_name.begins_with("Scenario Lab"):
		return false
	return true

func _load_saved_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data: Variant = file.get_var(true)
	if not (data is Dictionary):
		return false
	var save_data: Dictionary = data as Dictionary
	if not bool(save_data.get("active", false)):
		return false
	var rules_state: Dictionary = save_data.get("rules", {}) as Dictionary
	if rules_state.is_empty():
		return false
	if not rules.import_save_state(rules_state):
		return false
	current_match_is_tournament = false
	current_tournament_match_id = ""
	speed_timer_enabled = bool(save_data.get("speed_timer_enabled", false))
	speed_turn_seconds = int(save_data.get("speed_turn_seconds", int(rules.turn_timer_seconds)))
	speed_time_left = float(save_data.get("speed_time_left", float(speed_turn_seconds)))
	speed_total_turn_limit = int(save_data.get("speed_total_turn_limit", int(rules.turn_limit_total)))
	single_player_enabled = bool(save_data.get("single_player_enabled", false))
	ai_side = int(save_data.get("ai_side", SigmaRules.OWNER_P2))
	human_side = int(save_data.get("human_side", SigmaRules.OWNER_P1))
	ai_difficulty = String(save_data.get("ai_difficulty", "Rookie"))
	ai_thinking = false
	ai_turn_queued = false
	_reset_board_visual_state(true, true)
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	result_overlay.visible = false
	tutorial_active = false
	tutorial_step_loaded = false
	_play_board_audio_scene()
	_update_adaptive_board_music()
	_update_labels()
	if save_status_label != null:
		save_status_label.text = "Game resumed"
	_maybe_queue_ai_turn()
	return true

func _clear_current_game_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null:
		dir.remove(SAVE_FILE_NAME)
	_update_continue_button()

func _update_save_status_label() -> void:
	if save_status_label == null:
		return
	if rules.game_over:
		return
	if _has_active_game_save():
		if save_status_label.text == "":
			save_status_label.text = "Autosave ready"
	else:
		if rules.last_action.is_empty():
			save_status_label.text = "No saved match yet"

func _on_main_menu_quick_play() -> void:
	_on_main_menu_new_game()

func _on_main_menu_full_sigma() -> void:
	if _should_confirm_replacing_game():
		_show_new_game_confirm("full")
		return
	_start_full_now()

func _on_main_menu_draft() -> void:
	_play_menu_audio_scene("setup")
	draft_from_custom_game = false
	draft_custom_toggles = {}
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("setup")
	_reset_draft_builder()
	if draft_panel != null:
		draft_panel.visible = true

func _on_main_menu_tutorial() -> void:
	_play_tutorial_audio_scene()
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	tutorial_index = 0
	tutorial_active = true
	tutorial_step_loaded = false
	if board_view != null:
		board_view.clear_tutorial_markers()
	_set_tutorial_card_visible(true)
	_update_tutorial_panel()

func _on_main_menu_play() -> void:
	_on_main_menu_new_game()

func _on_main_menu_learn() -> void:
	_on_main_menu_tutorial()


func _on_main_menu_custom_game() -> void:
	_play_menu_audio_scene("setup")
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("setup")
	custom_page_mode = "single"
	if custom_game_panel != null:
		custom_game_panel.visible = true
	_rebuild_custom_game_panel()

func _on_main_menu_tournament() -> void:
	_play_menu_audio_scene("setup")
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("setup")
	custom_page_mode = "tournament_home"
	if custom_game_panel != null:
		custom_game_panel.visible = true
	_rebuild_custom_game_panel()

func _on_new_game_custom() -> void:
	if new_game_panel != null:
		new_game_panel.visible = false
	_on_main_menu_custom_game()

func _build_custom_game_panel(_parent: Control) -> void:
	custom_game_panel = PanelContainer.new()
	custom_game_panel.name = "CustomGamePage"
	custom_game_panel.visible = false
	custom_game_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	custom_game_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style: StyleBoxFlat = _make_rounded_style(Color("#050917", 0.98), Color("#D4AF37"), 2, 28)
	custom_game_panel.add_theme_stylebox_override("panel", style)
	add_child(custom_game_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	custom_game_panel.add_child(margin)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	margin.add_child(scroll)

	custom_content_box = VBoxContainer.new()
	custom_content_box.custom_minimum_size = Vector2(0, 0)
	custom_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_content_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_content_box.alignment = BoxContainer.ALIGNMENT_CENTER
	custom_content_box.add_theme_constant_override("separation", 10)
	scroll.add_child(custom_content_box)
	_rebuild_custom_game_panel()

func _rebuild_custom_game_panel() -> void:
	if custom_page_mode == "single":
		_rebuild_custom_single_match_panel()
		return
	if custom_page_mode == "tournament_home":
		_rebuild_tournament_home_panel()
		return
	if custom_page_mode == "tournament":
		_rebuild_tournament_builder_panel()
		return
	if custom_page_mode == "tournament_hub":
		_rebuild_tournament_hub_panel()
		return
	if custom_page_mode == "tournament_pregame":
		_rebuild_tournament_pregame_panel()
		return
	_rebuild_custom_games_hub_panel()

func _clear_custom_content() -> void:
	if custom_content_box == null:
		return
	for child_value in custom_content_box.get_children():
		var child: Node = child_value as Node
		custom_content_box.remove_child(child)
		child.queue_free()

func _rebuild_tournament_home_panel() -> void:
	if custom_content_box == null:
		return
	_clear_custom_content()
	_add_top_right_close_button(custom_content_box, "Close Tournament and return to Main Menu.", _show_main_menu)
	var title: Label = Label.new()
	title.text = "Tournament"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(title)
	var intro: Label = Label.new()
	intro.text = "Build a bracket. Play the next match. Keep the action moving."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override("font_size", 17)
	intro.add_theme_color_override("font_color", Color("#E8EDF2"))
	custom_content_box.add_child(intro)
	_add_custom_hub_button(custom_content_box, "Create Tournament", "Pick format, players, match rules, then start.", _on_custom_create_tournament_pressed, "gold")
	var continue_tip: String = "Open the Tournament Hub."
	if not _has_tournament_save() and not _has_active_tournament_match_save():
		continue_tip = "No tournament saved yet."
	var continue_btn: Button = _add_custom_hub_button(custom_content_box, "Continue Tournament", continue_tip, _on_custom_continue_tournament_pressed, "menu")
	continue_btn.disabled = not _has_tournament_save() and not _has_active_tournament_match_save()
	_add_button(custom_content_box, "Back", "Return to Main Menu.", _show_main_menu)

func _rebuild_custom_games_hub_panel() -> void:
	if custom_content_box == null:
		return
	_clear_custom_content()
	_add_top_right_close_button(custom_content_box, "Close Custom Games and return to Main Menu.", _show_main_menu)
	var title: Label = Label.new()
	title.text = "Custom Game"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(title)
	var intro: Label = Label.new()
	intro.text = "Build one match your way."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_color_override("font_color", Color("#E8EDF2"))
	custom_content_box.add_child(intro)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_set_tournament_center_child_width(grid)
	custom_content_box.add_child(grid)
	_add_custom_hub_button(grid, "Single Custom Match", "Official modes, BLITZ!, and official toggles.", _on_custom_single_match_pressed, "gold")
	_add_custom_hub_button(grid, "Create Tournament", "Build knockout, double knockout, round robin, ladder, or Swiss events.", _on_custom_create_tournament_pressed, "cyan")
	var continue_tip: String = "Open the Tournament Hub: standings, schedule, ladder, stats, and next match."
	if not _has_tournament_save() and not _has_active_tournament_match_save():
		continue_tip = "No tournament saved yet. Create one first."
	var continue_btn: Button = _add_custom_hub_button(grid, "Continue Tournament", continue_tip, _on_custom_continue_tournament_pressed, "menu")
	continue_btn.disabled = not _has_tournament_save() and not _has_active_tournament_match_save()
	_add_custom_hub_button(grid, "Draft SIGMA", "Draft advanced pieces, then build rows.", _on_custom_hub_draft_pressed, "menu")
	var separate_note: Label = Label.new()
	separate_note.text = "Save rule: tournament matches use their own tournament autosave. Your normal Continue Game save stays separate."
	separate_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separate_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	separate_note.add_theme_color_override("font_color", Color("#B8C4D8"))
	custom_content_box.add_child(separate_note)

func _add_custom_hub_button(parent: Container, title: String, subtitle: String, callback: Callable, role: String = "menu") -> Button:
	var button: Button = Button.new()
	button.text = "%s\n%s" % [title, subtitle]
	button.tooltip_text = subtitle
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.clip_text = true
	_style_button(button, role)
	button.pressed.connect(func() -> void:
		_play_sound_cue("button_tap")
		_punch_button(button)
		callback.call()
	)
	parent.add_child(button)
	return button

func _on_custom_single_match_pressed() -> void:
	custom_page_mode = "single"
	_rebuild_custom_game_panel()

func _on_custom_create_tournament_pressed() -> void:
	custom_page_mode = "tournament"
	if tournament_participants.is_empty():
		_ensure_tournament_participants_count()
	_rebuild_custom_game_panel()

func _on_custom_continue_tournament_pressed() -> void:
	# Continue Tournament opens the tournament command hub. It should not
	# automatically resume a paused tournament match; the player chooses from
	# the hub whether to resume, view standings, or start the next scheduled match.
	var loaded: bool = _load_tournament_data()
	if not loaded and _has_active_tournament_match_save():
		loaded = _load_tournament_data_from_active_match_save()
	if loaded:
		custom_page_mode = "tournament_hub"
		_rebuild_custom_game_panel()
		_play_sound_cue("confirm")
	else:
		_play_sound_cue("illegal")

func _on_custom_hub_draft_pressed() -> void:
	draft_from_custom_game = false
	draft_custom_toggles = {}
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("setup")
	_reset_draft_builder()
	if draft_panel != null:
		draft_panel.visible = true

func _rebuild_custom_single_match_panel() -> void:
	if custom_content_box == null:
		return
	for child_value in custom_content_box.get_children():
		var child: Node = child_value as Node
		custom_content_box.remove_child(child)
		child.queue_free()

	_add_top_right_close_button(custom_content_box, "Close this page and return to Main Menu.", _show_main_menu)
	var hub_back_row: HBoxContainer = HBoxContainer.new()
	hub_back_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	custom_content_box.add_child(hub_back_row)
	_add_button(hub_back_row, "Back", "Return to Custom Games.", _on_tournament_back_to_hub)

	var title: Label = Label.new()
	title.text = "Single Custom Match"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(title)

	custom_status_label = Label.new()
	custom_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_status_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	custom_content_box.add_child(custom_status_label)

	_add_custom_section_label("Recommended")
	_add_custom_mode_grid([
		{"id":"classic", "title":"Classic SIGMA", "subtitle":"G G G S M S G G G"},
		{"id":"speed", "title":"BLITZ! Custom", "subtitle":"10/15/20/30 sec · 80/140/220 turns"},
	])

	_add_custom_section_label("Single SIGMA")
	_add_custom_mode_grid([
		{"id":"sentinel", "title":"Sentinel SIGMA", "subtitle":"Sentinel elevation only"},
		{"id":"infiltrator", "title":"Infiltrator SIGMA", "subtitle":"Infiltrator elevation only"},
		{"id":"assassin", "title":"Assassin SIGMA", "subtitle":"Assassin elevation only"},
	])

	_add_custom_section_label("Double SIGMA")
	_add_custom_mode_grid([
		{"id":"sentinel_infiltrator", "title":"Sentinel-Infiltrator", "subtitle":"S + I elevation"},
		{"id":"sentinel_assassin", "title":"Sentinel-Assassin", "subtitle":"S + A elevation"},
		{"id":"infiltrator_assassin", "title":"Infiltrator-Assassin", "subtitle":"I + A elevation"},
	])

	_add_custom_section_label("Full / Draft")
	_add_custom_mode_grid([
		{"id":"full", "title":"Full SIGMA", "subtitle":"G I A S M S A I G"},
		{"id":"draft", "title":"Draft SIGMA", "subtitle":"Draft 4 advanced pieces, then build rows"},
	])

	var toggle_label: Label = Label.new()
	toggle_label.text = "Official Toggles"
	toggle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toggle_label.add_theme_font_size_override("font_size", 20)
	toggle_label.add_theme_color_override("font_color", Color("#D4AF37"))
	custom_content_box.add_child(toggle_label)

	var toggle_row: VBoxContainer = VBoxContainer.new()
	toggle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	toggle_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle_row.add_theme_constant_override("separation", 8)
	custom_content_box.add_child(toggle_row)
	custom_surround_button = _add_button(toggle_row, _toggle_text("Surround to Win", custom_surround_toggle), "If ON, surrounding an enemy non-Monarch wins immediately.", _on_custom_surround_toggle)
	custom_collapse_button = _add_button(toggle_row, _toggle_text("Collapse", custom_collapse_toggle), "If ON, a player loses when they have no advanced pieces on board.", _on_custom_collapse_toggle)
	custom_hot_start_button = _add_button(toggle_row, _toggle_text("Hot Start", custom_hot_start_toggle), "If ON, starting Guardians may move up to 2 orthogonal spaces on their first move.", _on_custom_hot_start_toggle)

	if custom_selected_mode_id == "speed":
		_add_custom_section_label("BLITZ! Custom")
		var timer_label: Label = Label.new()
		timer_label.text = "Turn Timer"
		timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		timer_label.add_theme_color_override("font_color", Color("#F2C14E"))
		custom_content_box.add_child(timer_label)
		var timer_row: HBoxContainer = HBoxContainer.new()
		timer_row.alignment = BoxContainer.ALIGNMENT_CENTER
		timer_row.add_theme_constant_override("separation", 8)
		custom_content_box.add_child(timer_row)
		custom_speed_timer_buttons = {}
		for seconds_value in [10, 15, 20, 30]:
			var seconds: int = int(seconds_value)
			var btn: Button = _add_button(timer_row, "%ds" % seconds, "BLITZ! turn timer.", _on_custom_speed_timer_pressed.bind(seconds))
			_style_button(btn, "gold" if custom_speed_timer_seconds == seconds else "menu")
			custom_speed_timer_buttons[seconds] = btn
		var turns_label: Label = Label.new()
		turns_label.text = "Player Turns · Overtime ON"
		turns_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		turns_label.add_theme_color_override("font_color", Color("#F2C14E"))
		custom_content_box.add_child(turns_label)
		var turns_row: HBoxContainer = HBoxContainer.new()
		turns_row.alignment = BoxContainer.ALIGNMENT_CENTER
		turns_row.add_theme_constant_override("separation", 8)
		custom_content_box.add_child(turns_row)
		custom_speed_turn_buttons = {}
		for turns_value in [80, 140, 220]:
			var turns: int = int(turns_value)
			var btn2: Button = _add_button(turns_row, "%d" % turns, "BLITZ! total turn limit before Overtime.", _on_custom_speed_turn_limit_pressed.bind(turns))
			_style_button(btn2, "gold" if custom_speed_turn_limit == turns else "menu")
			custom_speed_turn_buttons[turns] = btn2

	var note: Label = Label.new()
	note.text = "Custom Game uses official SIGMA modes and official toggles only. Draft SIGMA is included here so toggles can be applied before drafting."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	custom_content_box.add_child(note)

	var controls: HBoxContainer = HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 10)
	custom_content_box.add_child(controls)
	_add_button(controls, "Start Custom", "Start the selected custom mode, or open Draft Builder for Draft SIGMA.", _on_custom_start_pressed)

	_update_custom_status_label()

func _add_custom_section_label(text: String, parent: Container = null) -> void:
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("#00D1FF"))
	target.add_child(label)

func _add_custom_mode_grid(items: Array) -> void:
	# Mobile-first: Custom Game cards stack vertically so there is never horizontal scrolling.
	var grid: GridContainer = GridContainer.new()
	grid.columns = 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	custom_content_box.add_child(grid)
	for item_value in items:
		var item: Dictionary = item_value as Dictionary
		var mode_id: String = String(item.get("id", "classic"))
		var title: String = String(item.get("title", "SIGMA"))
		var subtitle: String = String(item.get("subtitle", ""))
		var button: Button = Button.new()
		button.text = "%s\n%s" % [title, subtitle]
		button.tooltip_text = subtitle
		button.custom_minimum_size = Vector2(0, 72)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.focus_mode = Control.FOCUS_NONE
		_style_button(button, "gold" if custom_selected_mode_id == mode_id else "menu")
		button.pressed.connect(_on_custom_mode_pressed.bind(mode_id))
		grid.add_child(button)
		custom_mode_buttons[mode_id] = button

func _on_custom_mode_pressed(mode_id: String) -> void:
	custom_selected_mode_id = mode_id
	_play_sound_cue("button_tap")
	_rebuild_custom_game_panel()

func _on_custom_surround_toggle() -> void:
	custom_surround_toggle = not custom_surround_toggle
	_rebuild_custom_game_panel()

func _on_custom_collapse_toggle() -> void:
	custom_collapse_toggle = not custom_collapse_toggle
	_rebuild_custom_game_panel()

func _on_custom_hot_start_toggle() -> void:
	custom_hot_start_toggle = not custom_hot_start_toggle
	_rebuild_custom_game_panel()

func _on_custom_speed_timer_pressed(seconds: int) -> void:
	custom_speed_timer_seconds = seconds
	_play_sound_cue("button_tap")
	_rebuild_custom_game_panel()

func _on_custom_speed_turn_limit_pressed(turns: int) -> void:
	custom_speed_turn_limit = turns
	_play_sound_cue("button_tap")
	_rebuild_custom_game_panel()

func _toggle_text(label: String, value: bool) -> String:
	return "%s: %s" % [label, "ON" if value else "OFF"]

func _update_custom_status_label() -> void:
	if custom_status_label == null:
		return
	var mode_name: String = _custom_selected_mode_name()
	var toggles: Array = []
	if custom_surround_toggle:
		toggles.append("Surround to Win")
	if custom_collapse_toggle:
		toggles.append("Collapse")
	if custom_hot_start_toggle:
		toggles.append("Hot Start")
	var toggle_text: String = "No toggles" if toggles.is_empty() else ", ".join(toggles)
	if custom_selected_mode_id == "speed":
		custom_status_label.text = "Selected: %s · %ds · %d turns · Overtime" % [mode_name, custom_speed_timer_seconds, custom_speed_turn_limit]
	else:
		custom_status_label.text = "Selected: %s · %s" % [mode_name, toggle_text]

func _custom_selected_mode_name() -> String:
	if custom_selected_mode_id == "draft":
		return "Draft SIGMA"
	if custom_selected_mode_id == "speed":
		return "BLITZ! Custom"
	var config: Dictionary = SigmaRules.config_for_mode_id(custom_selected_mode_id)
	return String(config.get("mode_name", "Classic SIGMA"))

func _custom_toggles_dictionary() -> Dictionary:
	return {
		"surround_toggle": custom_surround_toggle,
		"collapse_toggle": custom_collapse_toggle,
		"hot_start_toggle": custom_hot_start_toggle,
	}

func _apply_custom_toggles(config: Dictionary) -> Dictionary:
	var out: Dictionary = config.duplicate(true)
	out["surround_toggle"] = custom_surround_toggle
	out["collapse_toggle"] = custom_collapse_toggle
	out["hot_start_toggle"] = custom_hot_start_toggle
	return out

func _on_custom_start_pressed() -> void:
	if custom_selected_mode_id == "speed":
		pending_custom_config = _apply_custom_toggles(SigmaRules.classic_config())
		pending_custom_config["mode_name"] = "BLITZ! Custom"
		pending_custom_config["speed_sigma"] = true
		pending_custom_config["turn_timer_seconds"] = custom_speed_timer_seconds
		pending_custom_config["turn_limit_total"] = custom_speed_turn_limit
		pending_custom_config["round_limit"] = int(custom_speed_turn_limit / 2)
		if _should_confirm_replacing_game():
			_show_new_game_confirm("custom")
			return
		_start_custom_now(pending_custom_config)
		return
	if custom_selected_mode_id == "draft":
		draft_from_custom_game = true
		draft_custom_toggles = _custom_toggles_dictionary()
		_play_sound_cue("page_open")
		_hide_app_overlays()
		_show_menu_page_backdrop("setup")
		_reset_draft_builder()
		if draft_panel != null:
			draft_panel.visible = true
		return
	pending_custom_config = _apply_custom_toggles(SigmaRules.config_for_mode_id(custom_selected_mode_id))
	if _should_confirm_replacing_game():
		_show_new_game_confirm("custom")
		return
	_start_custom_now(pending_custom_config)

func _start_custom_now(config: Dictionary) -> void:
	current_match_is_tournament = bool(config.get("tournament_match", false))
	current_tournament_match_id = String(config.get("tournament_match_id", ""))
	_play_sound_cue("confirm")
	_play_board_audio_scene()
	_hide_app_overlays()
	_hide_menu_page_backdrop()
	_reset_board_visual_state(true, true)
	current_match_config = config.duplicate(true)
	_configure_single_player_from_config(config)
	rules.new_game(config)
	_configure_speed_timer_from_config(config)
	_update_adaptive_board_music()
	board_view.set_rules(rules)
	_apply_active_piece_set_to_board_views()
	_update_board_flip()
	_reset_board_visual_state(true, true)
	selection_label.text = "%s started. You are Gold. Tap a Gold piece." % String(config.get("mode_name", "Custom SIGMA")) if single_player_enabled else "%s started. Tap a Gold piece." % String(config.get("mode_name", "Custom SIGMA"))
	result_overlay.visible = false
	tutorial_active = false
	tutorial_step_loaded = false
	_update_labels()
	_autosave_current_game("Game saved")

func _tournament_type_options() -> Array:
	return [
		{"id":"knockout", "title":"Knockout", "tip":"Single-elimination bracket."},
		{"id":"double_knockout", "title":"Double Knockout", "tip":"Two losses eliminate a player."},
		{"id":"round_robin", "title":"Round Robin", "tip":"Everyone plays everyone once."},
		{"id":"double_round_robin", "title":"Double Round Robin", "tip":"Everyone plays everyone twice."},
		{"id":"ladder", "title":"Ladder", "tip":"Ranked challenge ladder foundation."},
		{"id":"swiss", "title":"Swiss", "tip":"Fixed rounds, matched by score later."},
	]

func _tournament_match_mode_options() -> Array:
	return [
		{"id":"classic", "title":"Classic SIGMA", "tip":"Official Classic setup."},
		{"id":"full", "title":"Full SIGMA", "tip":"All advanced pieces start on the board."},
	]

func _ai_difficulty_options() -> Array:
	return ["Beginner", "Rookie", "Intermediate", "Professional", "Expert", "Champion"]

func _tournament_option_title(options: Array, option_id: String) -> String:
	for item_value in options:
		var item: Dictionary = item_value as Dictionary
		if String(item.get("id", "")) == option_id:
			return String(item.get("title", option_id))
	return option_id.capitalize()

func _ensure_tournament_participants_count() -> void:
	while tournament_participants.size() < tournament_player_count:
		var index: int = tournament_participants.size()
		var is_human: bool = index < 2
		tournament_participants.append({
			"name": "Player %d" % (index + 1),
			"type": "Human" if is_human else "AI",
			"ai_difficulty": "Rookie",
			"seed": index + 1,
			"active": true,
		})
	while tournament_participants.size() > tournament_player_count:
		tournament_participants.pop_back()
	for i in range(tournament_participants.size()):
		var participant: Dictionary = tournament_participants[i] as Dictionary
		participant["seed"] = i + 1
		tournament_participants[i] = participant

func _rebuild_tournament_builder_panel() -> void:
	if custom_content_box == null:
		return
	_clear_custom_content()
	_ensure_tournament_participants_count()
	_add_top_right_close_button(custom_content_box, "Close Tournament Builder and return to Main Menu.", _show_main_menu)
	var back_button: Button = _add_button(custom_content_box, "Back", "Return to Tournament.", _on_tournament_back_to_hub)
	back_button.custom_minimum_size = Vector2(0, 58)

	var title: Label = Label.new()
	title.text = "Create Tournament"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(title)

	var summary: Label = Label.new()
	summary.text = "Pick a format. Add players. Start the bracket."
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 15)
	summary.add_theme_color_override("font_color", Color("#E8EDF2"))
	custom_content_box.add_child(summary)

	_add_custom_section_label("Tournament Name")
	var name_edit: LineEdit = LineEdit.new()
	name_edit.text = tournament_name_text
	name_edit.placeholder_text = "Tournament name"
	name_edit.custom_minimum_size = Vector2(0, 54)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(_on_tournament_name_changed)
	custom_content_box.add_child(name_edit)

	_add_custom_section_label("Format")
	var type_grid: GridContainer = GridContainer.new()
	type_grid.columns = 1
	type_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_grid.add_theme_constant_override("h_separation", 8)
	type_grid.add_theme_constant_override("v_separation", 8)
	custom_content_box.add_child(type_grid)
	for item_value in _tournament_type_options():
		var item: Dictionary = item_value as Dictionary
		var id: String = String(item.get("id", "knockout"))
		var button: Button = Button.new()
		button.text = "%s\n%s" % [String(item.get("title", id)), String(item.get("tip", ""))]
		button.custom_minimum_size = Vector2(0, 70)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_text = true
		button.focus_mode = Control.FOCUS_NONE
		_style_button(button, "gold" if id == tournament_type_id else "menu")
		button.pressed.connect(_on_tournament_type_pressed.bind(id))
		type_grid.add_child(button)

	_add_custom_section_label("Participants")
	var count_grid: GridContainer = GridContainer.new()
	count_grid.columns = 2
	count_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_grid.add_theme_constant_override("h_separation", 8)
	count_grid.add_theme_constant_override("v_separation", 8)
	custom_content_box.add_child(count_grid)
	_add_button(count_grid, "-4", "Remove four participants.", _on_tournament_count_delta.bind(-4))
	_add_button(count_grid, "-1", "Remove one participant.", _on_tournament_count_delta.bind(-1))
	_add_button(count_grid, "+1", "Add one participant.", _on_tournament_count_delta.bind(1))
	_add_button(count_grid, "+4", "Add four participants.", _on_tournament_count_delta.bind(4))
	var count_label: Label = Label.new()
	count_label.text = "%d players" % tournament_player_count
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.custom_minimum_size = Vector2(0, 42)
	count_label.add_theme_font_size_override("font_size", 22)
	count_label.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(count_label)

	_add_custom_section_label("Match Setup")
	var match_grid: GridContainer = GridContainer.new()
	match_grid.columns = 1
	match_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_grid.add_theme_constant_override("h_separation", 8)
	match_grid.add_theme_constant_override("v_separation", 8)
	custom_content_box.add_child(match_grid)
	for mode_value in _tournament_match_mode_options():
		var mode_item: Dictionary = mode_value as Dictionary
		var mode_id: String = String(mode_item.get("id", "classic"))
		var mode_button: Button = Button.new()
		mode_button.text = "%s\n%s" % [String(mode_item.get("title", mode_id)), String(mode_item.get("tip", ""))]
		mode_button.custom_minimum_size = Vector2(0, 70)
		mode_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mode_button.clip_text = true
		mode_button.focus_mode = Control.FOCUS_NONE
		_style_button(mode_button, "gold" if mode_id == tournament_match_mode_id else "menu")
		mode_button.pressed.connect(_on_tournament_match_mode_pressed.bind(mode_id))
		match_grid.add_child(mode_button)

	var option_grid: GridContainer = GridContainer.new()
	option_grid.columns = 1
	option_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_grid.add_theme_constant_override("h_separation", 8)
	option_grid.add_theme_constant_override("v_separation", 8)
	custom_content_box.add_child(option_grid)
	_add_button(option_grid, "Best of %d" % tournament_best_of, "Cycle match length.", _on_tournament_best_of_cycle)
	_add_button(option_grid, _toggle_text("Human Takeover", tournament_allow_takeover), "Allow humans to take over AI seats before a match.", _on_tournament_takeover_toggle)
	_add_button(option_grid, _toggle_text("Third Place", tournament_third_place), "Optional third-place match.", _on_tournament_third_place_toggle)

	_add_custom_section_label("Tournament BLITZ!")
	var blitz_button: Button = _add_button(custom_content_box, _toggle_text("BLITZ!", tournament_blitz_enabled), "Use BLITZ! timing for every tournament match.", _on_tournament_blitz_toggle)
	_style_button(blitz_button, "red" if tournament_blitz_enabled else "menu")	
	if tournament_blitz_enabled:
		_add_custom_section_label("Turn Timer")
		var timer_grid: GridContainer = GridContainer.new()
		timer_grid.columns = 2
		timer_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		timer_grid.add_theme_constant_override("h_separation", 8)
		timer_grid.add_theme_constant_override("v_separation", 8)
		custom_content_box.add_child(timer_grid)
		for seconds_value in [10, 15, 20, 30]:
			var seconds: int = int(seconds_value)
			var timer_button: Button = _add_button(timer_grid, "%ds" % seconds, "BLITZ! turn timer.", _on_tournament_blitz_timer_pressed.bind(seconds))
			_style_button(timer_button, "gold" if tournament_blitz_timer_seconds == seconds else "menu")
		_add_custom_section_label("Player Turns · Overtime ON")
		var turns_grid: GridContainer = GridContainer.new()
		turns_grid.columns = 1
		turns_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		turns_grid.add_theme_constant_override("h_separation", 8)
		turns_grid.add_theme_constant_override("v_separation", 8)
		custom_content_box.add_child(turns_grid)
		for turns_value in [80, 140, 220]:
			var turns: int = int(turns_value)
			var turns_button: Button = _add_button(turns_grid, "%d turns" % turns, "Turn limit before Overtime.", _on_tournament_blitz_turn_limit_pressed.bind(turns))
			_style_button(turns_button, "gold" if tournament_blitz_turn_limit == turns else "menu")
	if tournament_type_id == "swiss":
		_add_button(custom_content_box, "Swiss Rounds: %d" % tournament_swiss_rounds, "Cycle Swiss round count.", _on_tournament_swiss_rounds_cycle)

	var warning: Label = Label.new()
	warning.text = _tournament_size_warning()
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.add_theme_font_size_override("font_size", 14)
	warning.add_theme_color_override("font_color", Color("#B8C4D8"))
	custom_content_box.add_child(warning)

	_add_custom_section_label("Players")
	for i in range(tournament_participants.size()):
		_add_tournament_participant_row(i)

	var controls: VBoxContainer = VBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 10)
	custom_content_box.add_child(controls)
	_add_button(controls, "Save Tournament", "Save this tournament setup.", _on_tournament_save_setup)
	_add_button(controls, "Review First Match", "Open pregame confirmation.", _on_tournament_review_first_match)

func _add_tournament_participant_row(index: int) -> void:
	if index < 0 or index >= tournament_participants.size():
		return
	var participant: Dictionary = tournament_participants[index] as Dictionary
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#07101D", 0.92), Color("#304057", 0.75), 1, 18))
	custom_content_box.add_child(card)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)

	var seed_label: Label = Label.new()
	seed_label.text = "Player %02d" % (index + 1)
	seed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	seed_label.add_theme_font_size_override("font_size", 14)
	seed_label.add_theme_color_override("font_color", Color("#F2C14E"))
	box.add_child(seed_label)

	var name_edit: LineEdit = LineEdit.new()
	name_edit.text = String(participant.get("name", "Player %d" % (index + 1)))
	name_edit.custom_minimum_size = Vector2(0, 46)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(_on_tournament_participant_name_changed.bind(index))
	box.add_child(name_edit)

	var type_button: Button = _add_button(box, String(participant.get("type", "Human")), "Cycle Human / AI for this participant.", _on_tournament_participant_type_cycle.bind(index))
	type_button.custom_minimum_size = Vector2(0, 50)
	_style_button(type_button, "cyan" if String(participant.get("type", "Human")) == "AI" else "menu")
	var diff_button: Button = _add_button(box, String(participant.get("ai_difficulty", "Rookie")), "Cycle AI difficulty for this participant.", _on_tournament_participant_difficulty_cycle.bind(index))
	diff_button.custom_minimum_size = Vector2(0, 50)
	diff_button.disabled = String(participant.get("type", "Human")) != "AI"
	_style_button(diff_button, "gold" if String(participant.get("type", "Human")) == "AI" else "menu")

func _on_tournament_back_to_hub() -> void:
	custom_page_mode = "tournament_home"
	_rebuild_custom_game_panel()

func _on_tournament_name_changed(new_text: String) -> void:
	tournament_name_text = new_text

func _on_tournament_type_pressed(id: String) -> void:
	tournament_type_id = id
	_rebuild_custom_game_panel()

func _on_tournament_match_mode_pressed(id: String) -> void:
	tournament_match_mode_id = id
	_rebuild_custom_game_panel()

func _on_tournament_count_delta(delta: int) -> void:
	tournament_player_count = clampi(tournament_player_count + delta, 2, 64)
	_ensure_tournament_participants_count()
	_rebuild_custom_game_panel()

func _on_tournament_best_of_cycle() -> void:
	if tournament_best_of == 1:
		tournament_best_of = 3
	elif tournament_best_of == 3:
		tournament_best_of = 5
	else:
		tournament_best_of = 1
	_rebuild_custom_game_panel()

func _on_tournament_takeover_toggle() -> void:
	tournament_allow_takeover = not tournament_allow_takeover
	_rebuild_custom_game_panel()

func _on_tournament_third_place_toggle() -> void:
	tournament_third_place = not tournament_third_place
	_rebuild_custom_game_panel()

func _on_tournament_swiss_rounds_cycle() -> void:
	tournament_swiss_rounds += 1
	if tournament_swiss_rounds > 9:
		tournament_swiss_rounds = 3
	_rebuild_custom_game_panel()

func _on_tournament_blitz_toggle() -> void:
	tournament_blitz_enabled = not tournament_blitz_enabled
	_rebuild_custom_game_panel()

func _on_tournament_blitz_timer_pressed(seconds: int) -> void:
	tournament_blitz_timer_seconds = seconds
	_rebuild_custom_game_panel()

func _on_tournament_blitz_turn_limit_pressed(turns: int) -> void:
	tournament_blitz_turn_limit = turns
	_rebuild_custom_game_panel()

func _tournament_blitz_summary(data: Dictionary) -> String:
	if not bool(data.get("blitz_enabled", false)):
		return "BLITZ! OFF"
	return "BLITZ! %ds · %d turns · Overtime ON" % [int(data.get("blitz_timer_seconds", 10)), int(data.get("blitz_turn_limit", 140))]

func _on_tournament_participant_name_changed(new_text: String, index: int) -> void:
	if index < 0 or index >= tournament_participants.size():
		return
	var participant: Dictionary = tournament_participants[index] as Dictionary
	participant["name"] = new_text
	tournament_participants[index] = participant

func _on_tournament_participant_type_cycle(index: int) -> void:
	if index < 0 or index >= tournament_participants.size():
		return
	var participant: Dictionary = tournament_participants[index] as Dictionary
	participant["type"] = "AI" if String(participant.get("type", "Human")) == "Human" else "Human"
	tournament_participants[index] = participant
	_rebuild_custom_game_panel()

func _on_tournament_participant_difficulty_cycle(index: int) -> void:
	if index < 0 or index >= tournament_participants.size():
		return
	var participant: Dictionary = tournament_participants[index] as Dictionary
	var diffs: Array = _ai_difficulty_options()
	var current: String = String(participant.get("ai_difficulty", "Rookie"))
	var next_index: int = (diffs.find(current) + 1) % diffs.size()
	participant["ai_difficulty"] = String(diffs[next_index])
	participant["type"] = "AI"
	tournament_participants[index] = participant
	_rebuild_custom_game_panel()

func _tournament_size_warning() -> String:
	var matches: int = _estimate_tournament_match_count(tournament_type_id, tournament_player_count)
	var name: String = _tournament_option_title(_tournament_type_options(), tournament_type_id)
	if matches > 512:
		return "%s with %d players creates about %d matches. That is a huge event, but SIGMA will save it separately." % [name, tournament_player_count, matches]
	return "%s · %d players · about %d tournament matches." % [name, tournament_player_count, matches]

func _estimate_tournament_match_count(type_id: String, count: int) -> int:
	if type_id == "round_robin":
		return int(count * (count - 1) / 2)
	if type_id == "double_round_robin":
		return int(count * (count - 1))
	if type_id == "double_knockout":
		return max(1, count * 2 - 2)
	if type_id == "swiss":
		return int(ceil(float(count) * float(tournament_swiss_rounds) / 2.0))
	if type_id == "ladder":
		return max(1, count - 1)
	return max(1, count - 1)

func _build_tournament_data() -> Dictionary:
	_ensure_tournament_participants_count()
	var data: Dictionary = {
		"version": BUILD_VERSION,
		"active": true,
		"name": tournament_name_text.strip_edges() if not tournament_name_text.strip_edges().is_empty() else "SIGMA Tournament",
		"type_id": tournament_type_id,
		"type_name": _tournament_option_title(_tournament_type_options(), tournament_type_id),
		"player_count": tournament_player_count,
		"match_mode_id": tournament_match_mode_id,
		"match_mode_name": _tournament_option_title(_tournament_match_mode_options(), tournament_match_mode_id),
		"best_of": tournament_best_of,
		"allow_takeover": tournament_allow_takeover,
		"third_place": tournament_third_place,
		"swiss_rounds": tournament_swiss_rounds,
		"blitz_enabled": tournament_blitz_enabled,
		"blitz_timer_seconds": tournament_blitz_timer_seconds,
		"blitz_turn_limit": tournament_blitz_turn_limit,
		"blitz_summary": _tournament_blitz_summary({"blitz_enabled": tournament_blitz_enabled, "blitz_timer_seconds": tournament_blitz_timer_seconds, "blitz_turn_limit": tournament_blitz_turn_limit}),
		"participants": tournament_participants.duplicate(true),
		"created_at_unix": Time.get_unix_time_from_system(),
	}
	data["matches"] = _generate_tournament_matches(data)
	return data

func _generate_tournament_matches(data: Dictionary) -> Array:
	var count: int = int(data.get("player_count", 2))
	var type_id: String = String(data.get("type_id", "knockout"))
	var matches: Array = []
	var match_id: int = 1
	if type_id == "round_robin" or type_id == "double_round_robin":
		for i in range(count):
			for j in range(i + 1, count):
				matches.append(_make_tournament_match(match_id, 1, "Round Robin", i, j))
				match_id += 1
		if type_id == "double_round_robin":
			for i in range(count):
				for j in range(i + 1, count):
					matches.append(_make_tournament_match(match_id, 2, "Double Round Robin", j, i))
					match_id += 1
	elif type_id == "swiss":
		for i in range(0, count - 1, 2):
			matches.append(_make_tournament_match(match_id, 1, "Swiss Round 1", i, i + 1))
			match_id += 1
	elif type_id == "ladder":
		for i in range(0, count - 1, 2):
			matches.append(_make_tournament_match(match_id, 1, "Opening Ladder", i, i + 1))
			match_id += 1
	else:
		for i in range(0, count - 1, 2):
			matches.append(_make_tournament_match(match_id, 1, "Bracket Round 1", i, i + 1))
			match_id += 1
	return matches

func _make_tournament_match(match_id: int, round_index: int, round_name: String, p1_index: int, p2_index: int) -> Dictionary:
	return {
		"id": "M%04d" % match_id,
		"round": round_index,
		"round_name": round_name,
		"gold_index": p1_index,
		"silver_index": p2_index,
		"status": "pending",
		"winner_index": -1,
	}

func _find_next_tournament_match(data: Dictionary) -> Dictionary:
	var matches: Array = data.get("matches", []) as Array
	for match_value in matches:
		var match_data: Dictionary = match_value as Dictionary
		if String(match_data.get("status", "pending")) == "pending":
			return match_data.duplicate(true)
	return {}

func _on_tournament_save_setup() -> void:
	_clear_tournament_match_save()
	active_tournament_data = _build_tournament_data()
	_save_tournament_data(active_tournament_data, "Tournament saved")
	custom_page_mode = "tournament_hub"
	_rebuild_custom_game_panel()

func _on_tournament_review_first_match() -> void:
	_clear_tournament_match_save()
	active_tournament_data = _build_tournament_data()
	_save_tournament_data(active_tournament_data, "Tournament saved")
	pending_tournament_match = _find_next_tournament_match(active_tournament_data)
	tournament_match_takeover_gold = false
	tournament_match_takeover_silver = false
	custom_page_mode = "tournament_pregame"
	_rebuild_custom_game_panel()

func _make_tournament_center_column() -> VBoxContainer:
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_content_box.add_child(center)
	var column: VBoxContainer = VBoxContainer.new()
	column.custom_minimum_size = Vector2(0, 0)
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_theme_constant_override("separation", 10)
	center.add_child(column)
	return column

func _set_tournament_center_child_width(node: Control, width: float = 620.0) -> void:
	node.custom_minimum_size.x = width
	node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _rebuild_tournament_hub_panel() -> void:
	if custom_content_box == null:
		return
	_clear_custom_content()
	if active_tournament_data.is_empty():
		_load_tournament_data()
	_add_top_right_close_button(custom_content_box, "Close Tournament Hub and return to Main Menu.", _show_main_menu)

	var hub_column: VBoxContainer = _make_tournament_center_column()
	var back_row: HBoxContainer = HBoxContainer.new()
	back_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	back_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hub_column.add_child(back_row)
	_add_button(back_row, "Back", "Return to Custom Games.", _on_tournament_back_to_hub)

	var title: Label = Label.new()
	title.text = "Tournament Hub"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	hub_column.add_child(title)

	var name_label: Label = Label.new()
	name_label.text = String(active_tournament_data.get("name", "SIGMA Tournament"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	hub_column.add_child(name_label)

	var summary: Label = Label.new()
	summary.text = _tournament_hub_summary(active_tournament_data)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#B8C4D8"))
	hub_column.add_child(summary)

	var primary_row: HBoxContainer = HBoxContainer.new()
	primary_row.alignment = BoxContainer.ALIGNMENT_CENTER
	primary_row.add_theme_constant_override("separation", 10)
	primary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hub_column.add_child(primary_row)
	if _has_active_tournament_match_save():
		_add_button(primary_row, "Resume Paused Match", "Resume the tournament match currently in progress.", _on_tournament_hub_resume_match)
	var next_match: Dictionary = _find_next_tournament_match(active_tournament_data)
	if not next_match.is_empty():
		_add_button(primary_row, "Next Match", "Open pregame confirmation for the next scheduled tournament match.", _on_tournament_hub_next_match)
	_add_button(primary_row, "Edit Setup", "Return to the tournament builder for this event.", _on_tournament_hub_edit_setup)

	_add_custom_section_label("Active Tournament Details", hub_column)
	_add_tournament_hub_cards(active_tournament_data, hub_column)

	_add_custom_section_label("Next Match", hub_column)
	_add_tournament_next_match_card(active_tournament_data, hub_column)

	_add_custom_section_label("Upcoming Schedule", hub_column)
	_add_tournament_schedule_list(active_tournament_data, 8, hub_column)

	_add_custom_section_label("Standings / Ladder", hub_column)
	_add_tournament_standings_list(active_tournament_data, 10, hub_column)

	_add_custom_section_label("Records + Stats", hub_column)
	_add_tournament_stats_list(active_tournament_data, hub_column)

	var note: Label = Label.new()
	note.text = "Tournament Hub never auto-starts a match. Choose Next Match, Resume Paused Match, or Edit Setup when you are ready. Tournament saves remain separate from normal Continue Game."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	hub_column.add_child(note)

func _add_tournament_hub_cards(data: Dictionary, parent: Container = null) -> void:
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_set_tournament_center_child_width(grid)
	target.add_child(grid)
	_add_tournament_info_card(grid, "Format", String(data.get("type_name", "Tournament")))
	_add_tournament_info_card(grid, "Players", "%d participants" % int(data.get("player_count", 0)))
	_add_tournament_info_card(grid, "Match Mode", "%s · Best of %d" % [String(data.get("match_mode_name", "Classic SIGMA")), int(data.get("best_of", 1))])
	_add_tournament_info_card(grid, "BLITZ!", _tournament_blitz_summary(data))
	_add_tournament_info_card(grid, "Progress", _tournament_progress_text(data))
	_add_tournament_info_card(grid, "Paused Match", "Ready to resume" if _has_active_tournament_match_save() else "None")

func _add_tournament_info_card(parent: Container, heading: String, body: String) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 84)
	panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#071225", 0.94), Color("#304A66", 1.0), 1, 18))
	parent.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var h: Label = Label.new()
	h.text = heading
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_size_override("font_size", 15)
	h.add_theme_color_override("font_color", Color("#00D1FF"))
	box.add_child(h)
	var b: Label = Label.new()
	b.text = body
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color("#E8EDF2"))
	box.add_child(b)

func _tournament_hub_summary(data: Dictionary) -> String:
	return "%s · %s · %s" % [String(data.get("type_name", "Tournament")), String(data.get("match_mode_name", "Classic SIGMA")), _tournament_blitz_summary(data)]

func _tournament_progress_text(data: Dictionary) -> String:
	var matches: Array = data.get("matches", []) as Array
	var completed: int = 0
	var pending: int = 0
	for match_value in matches:
		var m: Dictionary = match_value as Dictionary
		if String(m.get("status", "pending")) == "completed":
			completed += 1
		else:
			pending += 1
	return "%d/%d complete · %d pending" % [completed, matches.size(), pending]

func _tournament_participant_name(data: Dictionary, index: int) -> String:
	var participants: Array = data.get("participants", []) as Array
	if index >= 0 and index < participants.size():
		var participant: Dictionary = participants[index] as Dictionary
		return String(participant.get("name", "Player %d" % (index + 1)))
	return "TBD"

func _tournament_participant_descriptor(data: Dictionary, index: int) -> String:
	var participants: Array = data.get("participants", []) as Array
	if index >= 0 and index < participants.size():
		var participant: Dictionary = participants[index] as Dictionary
		var type_text: String = String(participant.get("type", "Human"))
		if type_text == "AI":
			type_text = "%s Bot" % String(participant.get("ai_difficulty", "Rookie"))
		return "%s (%s)" % [String(participant.get("name", "Player %d" % (index + 1))), type_text]
	return "TBD"

func _tournament_match_line(data: Dictionary, match_data: Dictionary, include_status: bool = true) -> String:
	var gold_idx: int = int(match_data.get("gold_index", -1))
	var silver_idx: int = int(match_data.get("silver_index", -1))
	var status: String = String(match_data.get("status", "pending")).capitalize()
	var line: String = "%s · %s: %s vs %s" % [String(match_data.get("id", "M0000")), String(match_data.get("round_name", "Round")), _tournament_participant_name(data, gold_idx), _tournament_participant_name(data, silver_idx)]
	if include_status:
		line = "%s · %s" % [line, status]
	return line

func _add_tournament_next_match_card(data: Dictionary, parent: Container = null) -> void:
	var next_match: Dictionary = _find_next_tournament_match(data)
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("#F7F3E8"))
	if next_match.is_empty():
		label.text = "No pending matches. Tournament schedule complete."
	else:
		var gold_idx: int = int(next_match.get("gold_index", -1))
		var silver_idx: int = int(next_match.get("silver_index", -1))
		label.text = "%s\nGold: %s\nSilver: %s" % [String(next_match.get("round_name", "Next Match")), _tournament_participant_descriptor(data, gold_idx), _tournament_participant_descriptor(data, silver_idx)]
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	_set_tournament_center_child_width(label)
	target.add_child(label)

func _add_tournament_schedule_list(data: Dictionary, limit: int = 8, parent: Container = null) -> void:
	var matches: Array = data.get("matches", []) as Array
	var shown: int = 0
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_set_tournament_center_child_width(box)
	target.add_child(box)
	for match_value in matches:
		var match_data: Dictionary = match_value as Dictionary
		if String(match_data.get("status", "pending")) != "pending":
			continue
		var row: Label = Label.new()
		row.text = _tournament_match_line(data, match_data, false)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_color_override("font_color", Color("#E8EDF2"))
		box.add_child(row)
		shown += 1
		if shown >= limit:
			break
	if shown == 0:
		var empty: Label = Label.new()
		empty.text = "No upcoming matches."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", Color("#B8C4D8"))
		box.add_child(empty)

func _tournament_records(data: Dictionary) -> Array:
	var participants: Array = data.get("participants", []) as Array
	var records: Array = []
	for i in range(participants.size()):
		var participant: Dictionary = participants[i] as Dictionary
		records.append({
			"index": i,
			"name": String(participant.get("name", "Player %d" % (i + 1))),
			"type": String(participant.get("type", "Human")),
			"ai_difficulty": String(participant.get("ai_difficulty", "Rookie")),
			"wins": 0,
			"losses": 0,
			"played": 0,
		})
	var matches: Array = data.get("matches", []) as Array
	for match_value in matches:
		var match_data: Dictionary = match_value as Dictionary
		if String(match_data.get("status", "pending")) != "completed":
			continue
		var gold_idx: int = int(match_data.get("gold_index", -1))
		var silver_idx: int = int(match_data.get("silver_index", -1))
		var winner_idx: int = int(match_data.get("winner_index", -1))
		for idx in [gold_idx, silver_idx]:
			if idx >= 0 and idx < records.size():
				var rec_played: Dictionary = records[idx] as Dictionary
				rec_played["played"] = int(rec_played.get("played", 0)) + 1
				records[idx] = rec_played
		if winner_idx >= 0 and winner_idx < records.size():
			var win_rec: Dictionary = records[winner_idx] as Dictionary
			win_rec["wins"] = int(win_rec.get("wins", 0)) + 1
			records[winner_idx] = win_rec
		var loser_idx: int = silver_idx if winner_idx == gold_idx else gold_idx
		if loser_idx >= 0 and loser_idx < records.size():
			var loss_rec: Dictionary = records[loser_idx] as Dictionary
			loss_rec["losses"] = int(loss_rec.get("losses", 0)) + 1
			records[loser_idx] = loss_rec
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var aw: int = int(a.get("wins", 0))
		var bw: int = int(b.get("wins", 0))
		if aw != bw:
			return aw > bw
		var al: int = int(a.get("losses", 0))
		var bl: int = int(b.get("losses", 0))
		if al != bl:
			return al < bl
		return int(a.get("index", 0)) < int(b.get("index", 0))
	)
	return records

func _add_tournament_standings_list(data: Dictionary, limit: int = 10, parent: Container = null) -> void:
	var records: Array = _tournament_records(data)
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	_set_tournament_center_child_width(box)
	target.add_child(box)
	var max_rows: int = min(limit, records.size())
	for i in range(max_rows):
		var rec: Dictionary = records[i] as Dictionary
		var type_text: String = String(rec.get("type", "Human"))
		if type_text == "AI":
			type_text = "%s Bot" % String(rec.get("ai_difficulty", "Rookie"))
		var label: Label = Label.new()
		label.text = "%02d. %s · %d-%d · %s" % [i + 1, String(rec.get("name", "Player")), int(rec.get("wins", 0)), int(rec.get("losses", 0)), type_text]
		label.add_theme_color_override("font_color", Color("#E8EDF2"))
		box.add_child(label)
	if records.size() > limit:
		var more: Label = Label.new()
		more.text = "+ %d more participants" % (records.size() - limit)
		more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		more.add_theme_color_override("font_color", Color("#B8C4D8"))
		box.add_child(more)

func _add_tournament_stats_list(data: Dictionary, parent: Container = null) -> void:
	var matches: Array = data.get("matches", []) as Array
	var completed: int = 0
	for match_value in matches:
		var match_data: Dictionary = match_value as Dictionary
		if String(match_data.get("status", "pending")) == "completed":
			completed += 1
	var participants: Array = data.get("participants", []) as Array
	var human_count: int = 0
	var ai_count: int = 0
	for participant_value in participants:
		var participant: Dictionary = participant_value as Dictionary
		if String(participant.get("type", "Human")) == "AI":
			ai_count += 1
		else:
			human_count += 1
	var records: Array = _tournament_records(data)
	var leader_text: String = "No leader yet"
	if not records.is_empty():
		var leader: Dictionary = records[0] as Dictionary
		leader_text = "%s · %d-%d" % [String(leader.get("name", "Player")), int(leader.get("wins", 0)), int(leader.get("losses", 0))]
	var stats: Label = Label.new()
	stats.text = "Matches: %d complete / %d total\nPlayers: %d human · %d AI\nLeader: %s\nFormat note: %s" % [completed, matches.size(), human_count, ai_count, leader_text, _tournament_format_note(String(data.get("type_id", "knockout")))]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats.add_theme_color_override("font_color", Color("#E8EDF2"))
	var target: Container = parent if parent != null else custom_content_box
	if target == null:
		return
	_set_tournament_center_child_width(stats)
	target.add_child(stats)

func _tournament_format_note(type_id: String) -> String:
	if type_id == "round_robin":
		return "Every participant is scheduled against every other participant once."
	if type_id == "double_round_robin":
		return "Every pairing appears twice with sides reversed."
	if type_id == "double_knockout":
		return "Double elimination progression will expand in a future bracket pass."
	if type_id == "swiss":
		return "Swiss pairings start with Round 1; score-based pairing comes next."
	if type_id == "ladder":
		return "Ladder order and challenge movement will expand in a future pass."
	return "Single elimination bracket foundation."

func _on_tournament_hub_resume_match() -> void:
	if _load_saved_tournament_match():
		_hide_app_overlays()
		_update_labels()
		selection_label.text = "Tournament match resumed."
		_play_sound_cue("confirm")
	else:
		_play_sound_cue("illegal")

func _on_tournament_hub_next_match() -> void:
	pending_tournament_match = _find_next_tournament_match(active_tournament_data)
	if pending_tournament_match.is_empty():
		_play_sound_cue("illegal")
		return
	tournament_match_takeover_gold = false
	tournament_match_takeover_silver = false
	custom_page_mode = "tournament_pregame"
	_rebuild_custom_game_panel()
	_play_sound_cue("confirm")

func _on_tournament_hub_edit_setup() -> void:
	# Keep the saved data loaded into builder controls, but let the player edit
	# deliberately instead of auto-starting a match.
	_load_tournament_data()
	custom_page_mode = "tournament"
	_rebuild_custom_game_panel()
	_play_sound_cue("page_open")

func _record_completed_tournament_match_from_rules() -> void:
	if active_tournament_data.is_empty():
		_load_tournament_data()
	if active_tournament_data.is_empty() or pending_tournament_match.is_empty() or current_tournament_match_id.is_empty():
		return
	var winner_index: int = -1
	if rules.winner == SigmaRules.OWNER_P1:
		winner_index = int(pending_tournament_match.get("gold_index", -1))
	elif rules.winner == SigmaRules.OWNER_P2:
		winner_index = int(pending_tournament_match.get("silver_index", -1))
	var matches: Array = active_tournament_data.get("matches", []) as Array
	for i in range(matches.size()):
		var match_data: Dictionary = matches[i] as Dictionary
		if String(match_data.get("id", "")) == current_tournament_match_id:
			match_data["status"] = "completed"
			match_data["winner_index"] = winner_index
			match_data["result_text"] = rules.result_text
			match_data["completed_at_unix"] = Time.get_unix_time_from_system()
			matches[i] = match_data
			break
	active_tournament_data["matches"] = matches
	active_tournament_data["last_completed_match_id"] = current_tournament_match_id
	active_tournament_data["updated_at_unix"] = Time.get_unix_time_from_system()
	_save_tournament_data(active_tournament_data, "Tournament Hub updated")

func _rebuild_tournament_pregame_panel() -> void:
	if custom_content_box == null:
		return
	_clear_custom_content()
	_add_top_right_close_button(custom_content_box, "Close Tournament Match Preview and return to Main Menu.", _show_main_menu)
	var back_row: HBoxContainer = HBoxContainer.new()
	back_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	custom_content_box.add_child(back_row)
	_add_button(back_row, "Back", "Return to Tournament Builder.", _on_tournament_back_to_builder)
	var title: Label = Label.new()
	title.text = "Tournament Match"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	custom_content_box.add_child(title)
	if pending_tournament_match.is_empty() or active_tournament_data.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No pending tournament match found."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color("#E8EDF2"))
		custom_content_box.add_child(empty_label)
		return
	var gold_participant: Dictionary = _tournament_participant_for_match_side("gold")
	var silver_participant: Dictionary = _tournament_participant_for_match_side("silver")
	var details: Label = Label.new()
	details.text = "%s · %s · %s · Best of %d\n%s" % [String(active_tournament_data.get("name", "SIGMA Tournament")), String(pending_tournament_match.get("round_name", "Round")), String(active_tournament_data.get("match_mode_name", "Classic SIGMA")), int(active_tournament_data.get("best_of", 1)), _tournament_blitz_summary(active_tournament_data)]
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_color_override("font_color", Color("#E8EDF2"))
	custom_content_box.add_child(details)
	var versus: Label = Label.new()
	versus.text = "Gold: %s\nSilver: %s" % [_participant_match_label(gold_participant, tournament_match_takeover_gold), _participant_match_label(silver_participant, tournament_match_takeover_silver)]
	versus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	versus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	versus.add_theme_font_size_override("font_size", 22)
	versus.add_theme_color_override("font_color", Color("#F7F3E8"))
	custom_content_box.add_child(versus)
	var takeover_row: HBoxContainer = HBoxContainer.new()
	takeover_row.alignment = BoxContainer.ALIGNMENT_CENTER
	takeover_row.add_theme_constant_override("separation", 8)
	custom_content_box.add_child(takeover_row)
	if bool(active_tournament_data.get("allow_takeover", true)):
		var gold_type: String = String(gold_participant.get("type", "Human"))
		var silver_type: String = String(silver_participant.get("type", "Human"))
		if gold_type == "AI":
			_add_button(takeover_row, "Take Over Gold", "Human takes over this AI before the match starts.", _on_tournament_takeover_gold)
		if silver_type == "AI":
			_add_button(takeover_row, "Take Over Silver", "Human takes over this AI before the match starts.", _on_tournament_takeover_silver)
	var start_note: Label = Label.new()
	start_note.text = "Human vs Human tournament matches use Tabletop. Human vs AI tournament matches use mobile Single Player. Tournament autosave is separate from normal Continue Game."
	start_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_note.add_theme_color_override("font_color", Color("#B8C4D8"))
	custom_content_box.add_child(start_note)
	var control_row: HBoxContainer = HBoxContainer.new()
	control_row.alignment = BoxContainer.ALIGNMENT_CENTER
	custom_content_box.add_child(control_row)
	_add_button(control_row, "Start Match", "Start this tournament match.", _on_tournament_start_match)

func _on_tournament_back_to_builder() -> void:
	custom_page_mode = "tournament_hub" if not active_tournament_data.is_empty() else "tournament"
	_rebuild_custom_game_panel()

func _on_tournament_takeover_gold() -> void:
	tournament_match_takeover_gold = not tournament_match_takeover_gold
	_rebuild_custom_game_panel()

func _on_tournament_takeover_silver() -> void:
	tournament_match_takeover_silver = not tournament_match_takeover_silver
	_rebuild_custom_game_panel()

func _tournament_participant_for_match_side(side: String) -> Dictionary:
	var participants: Array = active_tournament_data.get("participants", []) as Array
	var idx_key: String = "gold_index" if side == "gold" else "silver_index"
	var idx: int = int(pending_tournament_match.get(idx_key, -1))
	if idx >= 0 and idx < participants.size():
		return (participants[idx] as Dictionary).duplicate(true)
	return {"name":"Missing Player", "type":"Human", "ai_difficulty":"Rookie"}

func _participant_match_label(participant: Dictionary, takeover: bool) -> String:
	var type_text: String = String(participant.get("type", "Human"))
	if takeover:
		type_text = "Human takeover"
	elif type_text == "AI":
		type_text = "%s Bot" % String(participant.get("ai_difficulty", "Rookie"))
	return "%s (%s)" % [String(participant.get("name", "Player")), type_text]

func _on_tournament_start_match() -> void:
	if active_tournament_data.is_empty() or pending_tournament_match.is_empty():
		_play_sound_cue("illegal")
		return
	var gold_participant: Dictionary = _tournament_participant_for_match_side("gold")
	var silver_participant: Dictionary = _tournament_participant_for_match_side("silver")
	var gold_human: bool = String(gold_participant.get("type", "Human")) == "Human" or tournament_match_takeover_gold
	var silver_human: bool = String(silver_participant.get("type", "Human")) == "Human" or tournament_match_takeover_silver
	if not gold_human and not silver_human:
		selection_label.text = "Take over one AI player to start this tournament match. AI-vs-AI simulation comes later."
		_play_sound_cue("illegal")
		return
	var config: Dictionary = SigmaRules.classic_config() if String(active_tournament_data.get("match_mode_id", "classic")) == "classic" else SigmaRules.full_config()
	config["mode_name"] = "%s · %s" % [String(active_tournament_data.get("name", "SIGMA Tournament")), String(pending_tournament_match.get("round_name", "Tournament Match"))]
	config["tournament_match"] = true
	config["tournament_name"] = String(active_tournament_data.get("name", "SIGMA Tournament"))
	config["tournament_match_id"] = String(pending_tournament_match.get("id", "M0001"))
	config["best_of"] = int(active_tournament_data.get("best_of", 1))
	if bool(active_tournament_data.get("blitz_enabled", false)):
		config["mode_name"] = "%s BLITZ!" % String(config.get("mode_name", "Tournament Match"))
		config["speed_sigma"] = true
		config["turn_timer_seconds"] = int(active_tournament_data.get("blitz_timer_seconds", 10))
		config["turn_limit_total"] = int(active_tournament_data.get("blitz_turn_limit", 140))
		config["round_limit"] = int(int(active_tournament_data.get("blitz_turn_limit", 140)) / 2)
	if gold_human and not silver_human:
		config["single_player_ai"] = true
		config["human_side"] = SigmaRules.OWNER_P1
		config["ai_side"] = SigmaRules.OWNER_P2
		config["ai_difficulty"] = String(silver_participant.get("ai_difficulty", "Rookie"))
	elif silver_human and not gold_human:
		config["single_player_ai"] = true
		config["human_side"] = SigmaRules.OWNER_P2
		config["ai_side"] = SigmaRules.OWNER_P1
		config["ai_difficulty"] = String(gold_participant.get("ai_difficulty", "Rookie"))
	else:
		config["single_player_ai"] = false
	current_tournament_match_id = String(pending_tournament_match.get("id", "M0001"))
	_start_custom_now(config)
	selection_label.text = "Tournament match started: %s vs %s. %s" % [String(gold_participant.get("name", "Gold")), String(silver_participant.get("name", "Silver")), _tournament_blitz_summary(active_tournament_data)]

func _build_draft_panel(_parent: Control) -> void:
	# Draft SIGMA is a full app page, not a gameplay overlay.
	draft_panel = PanelContainer.new()
	draft_panel.name = "DraftSigmaPage"
	draft_panel.visible = false
	draft_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	draft_panel.offset_left = 0
	draft_panel.offset_top = 0
	draft_panel.offset_right = 0
	draft_panel.offset_bottom = 0
	draft_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#080017")
	style.border_color = Color("#F2C14E")
	style.set_border_width_all(3)
	draft_panel.add_theme_stylebox_override("panel", style)
	add_child(draft_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	draft_panel.add_child(margin)

	var center: CenterContainer = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(center)

	draft_content_box = VBoxContainer.new()
	draft_content_box.custom_minimum_size = Vector2(390, 0)
	draft_content_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	draft_content_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	draft_content_box.alignment = BoxContainer.ALIGNMENT_CENTER
	draft_content_box.add_theme_constant_override("separation", 10)
	center.add_child(draft_content_box)
	_reset_draft_builder()

func _reset_draft_builder() -> void:
	draft_stage = 0
	draft_p1_picks = []
	draft_p2_picks = []
	draft_p1_row = ["", "", "", "", "M", "", "", "", ""]
	draft_p2_row = ["", "", "", "", "M", "", "", "", ""]
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _rebuild_draft_panel() -> void:
	if draft_content_box == null:
		return
	for child_value in draft_content_box.get_children():
		var child: Node = child_value as Node
		draft_content_box.remove_child(child)
		child.queue_free()

	_add_top_right_close_button(draft_content_box, "Close Draft SIGMA and return to Main Menu.", _show_main_menu)

	var title: Label = Label.new()
	title.text = "Draft SIGMA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	draft_content_box.add_child(title)

	draft_status_label = Label.new()
	draft_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	draft_status_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	draft_content_box.add_child(draft_status_label)

	match draft_stage:
		0:
			_build_draft_pick_stage("Gold", draft_p1_picks)
		1:
			_build_draft_pick_stage("Silver", draft_p2_picks)
		2:
			_build_draft_row_stage("Gold", draft_p1_picks, draft_p1_row)
		3:
			_build_draft_row_stage("Silver", draft_p2_picks, draft_p2_row)
		_:
			_build_draft_review_stage()

func _build_draft_pick_stage(player_name: String, picks: Array) -> void:
	draft_status_label.text = "%s draft: choose 4 advanced pieces from 2 Sentinels, 2 Infiltrators, and 2 Assassins." % player_name

	var picks_label: Label = Label.new()
	picks_label.text = "Selected: %s" % _draft_picks_text(picks)
	picks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_content_box.add_child(picks_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	draft_content_box.add_child(row)

	for kind_value in [SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]:
		var kind: String = String(kind_value)
		var remaining: int = 2 - _draft_count_kind(picks, kind)
		var button: Button = Button.new()
		button.text = "%s\n%s left" % [_piece_name(kind), remaining]
		button.custom_minimum_size = Vector2(164, 78)
		_style_button(button, "menu")
		button.disabled = remaining <= 0 or picks.size() >= 4
		button.pressed.connect(_on_draft_pick_pressed.bind(kind))
		row.add_child(button)

	var note: Label = Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	note.text = "Drafted pieces will be combined with 4 Guardians and 1 center Monarch during row building."
	draft_content_box.add_child(note)

	var controls: HBoxContainer = HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 8)
	draft_content_box.add_child(controls)
	_add_button(controls, "Undo Pick", "Remove the last drafted piece.", _on_draft_undo_pick)
	_add_button(controls, "Clear", "Clear this player's draft picks.", _on_draft_clear_current)
	var next_button: Button = _add_button(controls, "Next", "Continue when 4 pieces are selected.", _on_draft_next_pressed)
	next_button.disabled = picks.size() != 4

func _build_draft_row_stage(player_name: String, picks: Array, row_data: Array) -> void:
	draft_status_label.text = "%s row builder: place 4 Guardians and your 4 drafted pieces. The Monarch is locked in the center." % player_name

	var row_visual: HBoxContainer = HBoxContainer.new()
	row_visual.alignment = BoxContainer.ALIGNMENT_CENTER
	row_visual.add_theme_constant_override("separation", 4)
	draft_content_box.add_child(row_visual)

	for i in range(SigmaRules.BOARD_SIZE):
		var slot_button: Button = Button.new()
		var slot_text: String = String(row_data[i])
		if slot_text == "":
			slot_text = "_"
		slot_button.text = slot_text
		slot_button.custom_minimum_size = Vector2(62, 62)
		_style_button(slot_button, "gold" if i == 4 else "dark")
		slot_button.disabled = i == 4
		slot_button.pressed.connect(_on_draft_slot_pressed.bind(i))
		row_visual.add_child(slot_button)

	var pool_label: Label = Label.new()
	pool_label.text = "Selected piece: %s" % ("none" if draft_selected_piece == "" else _piece_name(draft_selected_piece))
	pool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_content_box.add_child(pool_label)

	var pool_row: HBoxContainer = HBoxContainer.new()
	pool_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pool_row.add_theme_constant_override("separation", 8)
	draft_content_box.add_child(pool_row)

	for kind_value in [SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]:
		var kind: String = String(kind_value)
		var remaining: int = _draft_remaining_for_row(kind, picks, row_data)
		var piece_button: Button = Button.new()
		piece_button.text = "%s\n%s left" % [_piece_name(kind), remaining]
		piece_button.custom_minimum_size = Vector2(140, 70)
		_style_button(piece_button, "green" if kind == SigmaRules.KIND_GUARDIAN else "menu")
		piece_button.disabled = remaining <= 0
		piece_button.pressed.connect(_on_draft_select_piece_pressed.bind(kind))
		pool_row.add_child(piece_button)

	var hint: Label = Label.new()
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("#B8C4D8"))
	hint.text = "Tap a piece type, then tap a row slot. Tap a filled slot with no piece selected to clear it. Rows are shown screen-left to screen-right."
	draft_content_box.add_child(hint)

	var controls: HBoxContainer = HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 8)
	draft_content_box.add_child(controls)
	_add_button(controls, "Clear Row", "Clear this row except the center Monarch.", _on_draft_clear_row)
	_add_button(controls, "Back", "Go back one Draft step.", _on_draft_back_pressed)
	var next_button: Button = _add_button(controls, "Next", "Continue when the row is valid.", _on_draft_next_pressed)
	next_button.disabled = not _draft_row_valid(row_data, picks)

func _build_draft_review_stage() -> void:
	draft_status_label.text = "Review Draft SIGMA rows, then start the game."

	var gold_label: Label = Label.new()
	gold_label.text = "Gold row:  %s" % " ".join(draft_p1_row)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_content_box.add_child(gold_label)

	var silver_label: Label = Label.new()
	silver_label.text = "Silver row: %s" % " ".join(draft_p2_row)
	silver_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draft_content_box.add_child(silver_label)

	var note: Label = Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", Color("#B8C4D8"))
	var toggle_note: String = "No toggles selected."
	if draft_from_custom_game:
		var active_toggles: Array = []
		if bool(draft_custom_toggles.get("surround_toggle", false)):
			active_toggles.append("Surround to Win")
		if bool(draft_custom_toggles.get("collapse_toggle", false)):
			active_toggles.append("Collapse")
		if bool(draft_custom_toggles.get("hot_start_toggle", false)):
			active_toggles.append("Hot Start")
		toggle_note = "Custom toggles: %s." % ("None" if active_toggles.is_empty() else ", ".join(active_toggles))
	note.text = "Draft SIGMA uses current rules after setup: Guardian orthogonal movement, Direct Monarch Peril, Retreat, Deploy, Elevate, No Cycle, and Overtime. %s" % toggle_note
	draft_content_box.add_child(note)

	var controls: HBoxContainer = HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 8)
	draft_content_box.add_child(controls)
	_add_button(controls, "Back", "Return to Silver row builder.", _on_draft_back_pressed)
	_add_button(controls, "Start Draft SIGMA", "Start local pass-and-play with these drafted rows.", _on_draft_start_game)
	_add_button(controls, "Reset Draft", "Restart the Draft builder.", _reset_draft_builder)

func _on_draft_pick_pressed(kind: String) -> void:
	var picks: Array = _current_draft_picks()
	if picks.size() >= 4:
		return
	if _draft_count_kind(picks, kind) >= 2:
		return
	picks.append(kind)
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_undo_pick() -> void:
	var picks: Array = _current_draft_picks()
	if not picks.is_empty():
		picks.pop_back()
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_clear_current() -> void:
	var picks: Array = _current_draft_picks()
	picks.clear()
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_select_piece_pressed(kind: String) -> void:
	var picks: Array = _current_row_builder_picks()
	var row_data: Array = _current_row_builder_row()
	if _draft_remaining_for_row(kind, picks, row_data) <= 0:
		return
	draft_selected_piece = kind
	_rebuild_draft_panel()

func _on_draft_slot_pressed(index: int) -> void:
	if index == 4:
		return
	var row_data: Array = _current_row_builder_row()
	var picks: Array = _current_row_builder_picks()
	if draft_selected_piece == "":
		row_data[index] = ""
		_rebuild_draft_panel()
		return
	if _draft_remaining_for_row(draft_selected_piece, picks, row_data) <= 0 and String(row_data[index]) != draft_selected_piece:
		return
	row_data[index] = draft_selected_piece
	if _draft_remaining_for_row(draft_selected_piece, picks, row_data) <= 0:
		draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_clear_row() -> void:
	var row_data: Array = _current_row_builder_row()
	for i in range(SigmaRules.BOARD_SIZE):
		row_data[i] = "M" if i == 4 else ""
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_next_pressed() -> void:
	match draft_stage:
		0:
			if draft_p1_picks.size() == 4:
				draft_stage = 1
		1:
			if draft_p2_picks.size() == 4:
				draft_stage = 2
		2:
			if _draft_row_valid(draft_p1_row, draft_p1_picks):
				draft_stage = 3
		3:
			if _draft_row_valid(draft_p2_row, draft_p2_picks):
				draft_stage = 4
		_:
			pass
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_back_pressed() -> void:
	if draft_stage > 0:
		draft_stage -= 1
	draft_selected_piece = ""
	_rebuild_draft_panel()

func _on_draft_start_game() -> void:
	if not _draft_row_valid(draft_p1_row, draft_p1_picks):
		return
	if not _draft_row_valid(draft_p2_row, draft_p2_picks):
		return
	pending_draft_config = SigmaRules.draft_config(draft_p1_row.duplicate(true), draft_p2_row.duplicate(true))
	if draft_from_custom_game:
		pending_draft_config["single_player_ai"] = bool(draft_custom_toggles.get("single_player_ai", false))
		pending_draft_config["ai_side"] = int(draft_custom_toggles.get("ai_side", SigmaRules.OWNER_P2))
		pending_draft_config["human_side"] = int(draft_custom_toggles.get("human_side", SigmaRules.OWNER_P1))
		pending_draft_config["ai_difficulty"] = String(draft_custom_toggles.get("ai_difficulty", "Rookie"))
		pending_draft_config["surround_toggle"] = bool(draft_custom_toggles.get("surround_toggle", false))
		pending_draft_config["collapse_toggle"] = bool(draft_custom_toggles.get("collapse_toggle", false))
		pending_draft_config["hot_start_toggle"] = bool(draft_custom_toggles.get("hot_start_toggle", false))
		if bool(draft_custom_toggles.get("speed_sigma", false)):
			pending_draft_config["speed_sigma"] = true
			pending_draft_config["turn_timer_seconds"] = int(draft_custom_toggles.get("turn_timer_seconds", 10))
			pending_draft_config["turn_limit_total"] = int(draft_custom_toggles.get("turn_limit_total", 140))
			pending_draft_config["round_limit"] = int(draft_custom_toggles.get("round_limit", 70))
			pending_draft_config["mode_name"] = String(draft_custom_toggles.get("mode_name", "Draft SIGMA BLITZ!"))
		else:
			pending_draft_config["mode_name"] = "Custom Draft SIGMA"
		if bool(pending_draft_config.get("single_player_ai", false)):
			pending_draft_config["mode_name"] = "%s vs %s Bot" % [String(pending_draft_config.get("mode_name", "Draft SIGMA")), String(pending_draft_config.get("ai_difficulty", "Rookie"))]
	if _should_confirm_replacing_game():
		_show_new_game_confirm("draft")
		return
	_start_draft_now(pending_draft_config)

func _current_draft_picks() -> Array:
	if draft_stage == 0:
		return draft_p1_picks
	return draft_p2_picks

func _current_row_builder_picks() -> Array:
	if draft_stage == 2:
		return draft_p1_picks
	return draft_p2_picks

func _current_row_builder_row() -> Array:
	if draft_stage == 2:
		return draft_p1_row
	return draft_p2_row

func _draft_count_kind(items: Array, kind: String) -> int:
	var count: int = 0
	for item_value in items:
		if String(item_value) == kind:
			count += 1
	return count

func _draft_remaining_for_row(kind: String, picks: Array, row_data: Array) -> int:
	var allowed: int = 4 if kind == SigmaRules.KIND_GUARDIAN else _draft_count_kind(picks, kind)
	var placed: int = _draft_count_kind(row_data, kind)
	return int(max(0, allowed - placed))

func _draft_row_valid(row_data: Array, picks: Array) -> bool:
	if row_data.size() != SigmaRules.BOARD_SIZE:
		return false
	if String(row_data[4]) != SigmaRules.KIND_MONARCH:
		return false
	if _draft_count_kind(row_data, SigmaRules.KIND_GUARDIAN) != 4:
		return false
	for kind_value in [SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]:
		var kind: String = String(kind_value)
		if _draft_count_kind(row_data, kind) != _draft_count_kind(picks, kind):
			return false
	for i in range(SigmaRules.BOARD_SIZE):
		if String(row_data[i]) == "":
			return false
	return true

func _draft_picks_text(picks: Array) -> String:
	if picks.is_empty():
		return "none yet"
	var parts: Array = []
	for item_value in picks:
		parts.append(_piece_name(String(item_value)))
	return ", ".join(parts)

func _init_rules_guide_pages() -> void:
	rules_guide_pages = [
		{"title": "Goal", "snapshot_id": "goal", "body": "Win by forcing the enemy Monarch to Surrender. A Monarch Surrenders when it is in direct Peril and has no legal escape. The Monarch is not physically captured or removed."},
		{"title": "Classic Setup", "snapshot_id": "setup", "body": "The official Classic SIGMA Set uses Classic SIGMA Pieces on the Classic SIGMA Board. Gold is Player 1 and always starts. Silver is Player 2. Each side has 5 Reserve Guardians."},
		{"title": "Turn Actions", "snapshot_id": "actions", "body": "On your player turn, take one legal action: move one piece, jump-capture with one piece, or Deploy one Reserve Guardian. Captures are optional. Classic play uses Preview, then Confirm. BLITZ! skips Preview for speed."},
		{"title": "Rounds & Timer", "snapshot_id": "rounds", "body": "A full round means both sides acted once: Gold takes one player turn, then Silver takes one player turn. Gold always starts. The active game HUD shows Round, current player, timer, and Overtime status prominently."},
		{"title": "Monarch", "snapshot_id": "monarch", "body": "Monarch: moves 1 space in any direction. A Monarch is in Peril when an enemy piece directly threatens its square. If there is no legal escape, the Monarch Surrenders."},
		{"title": "Guardian", "snapshot_id": "guardian", "body": "Guardian: moves 1 space orthogonally, jump-captures orthogonally, Deploys orthogonally, and checks Surround by orthogonal movement spaces. A Guardian may Elevate on the enemy back row."},
		{"title": "Sentinel", "snapshot_id": "sentinel", "body": "Sentinel: moves 1 space in any direction and jump-captures in any direction. It is the simplest advanced piece and controls nearby space."},
		{"title": "Infiltrator", "snapshot_id": "infiltrator", "body": "Infiltrator: moves 1 or 2 spaces orthogonally with a clear path. It can use a clear first orthogonal space to line up an orthogonal jump-capture. No diagonal or L-shaped captures."},
		{"title": "Assassin", "snapshot_id": "assassin", "body": "Assassin: moves 1 or 2 spaces diagonally with a clear path. It can use a clear first diagonal space to line up a diagonal jump-capture. No orthogonal or L-shaped captures."},
		{"title": "Deploy", "snapshot_id": "deploy", "body": "Press Deploy, choose a friendly piece, then place a Reserve Guardian on an empty adjacent square in a direction that piece can move. Deploy is adjacent only."},
		{"title": "Peril", "snapshot_id": "peril", "body": "A Monarch is in Peril when an enemy piece directly threatens its square by movement geometry. If your Monarch is in Peril, your next action must remove that direct threat."},
		{"title": "Surrender", "snapshot_id": "surrender", "body": "If a Monarch is in Peril and has no legal escape, that Monarch Surrenders. Monarchs are not physically captured or removed."},
		{"title": "Retreat", "snapshot_id": "retreat", "body": "If your own action boxes in one of your own non-Monarch pieces, that friendly piece Retreats instead of being removed. Enemy boxed-in non-Monarch pieces are removed and count as enemy removals."},
		{"title": "Elevate", "snapshot_id": "elevate", "body": "A Guardian that reaches the enemy back row and survives resolution may Elevate into a Sentinel, Infiltrator, or Assassin. Elevation respects Advanced Cap."},
		{"title": "Advanced Cap", "snapshot_id": "advanced_cap", "body": "Each player may have at most 3 Sentinels, 3 Infiltrators, and 3 Assassins on the board at one time. Captured or Retreated advanced pieces return to advanced supply and may re-enter only through Elevation."},
		{"title": "Overtime", "snapshot_id": "overtime", "body": "After 100 full rounds, the game enters Overtime. Enemy removals from jump-captures and enemy Surround removals can win by Overtime Capture. Retreat does not count as an enemy removal."},
	]


func _build_collections_panel(_parent: Control) -> void:
	# v1.7.0: Collections tracks full SIGMA Sets. Classic SIGMA Set is unlocked/equipped by default.
	# Main page shows complete categories/cards only. Piece and board details open in
	# modal-style screens with X close controls. No rules logic lives here.
	collections_panel = PanelContainer.new()
	collections_panel.name = "CollectionsPage"
	collections_panel.visible = false
	collections_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	collections_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	collections_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050917", 0.98), Color("#D4AF37"), 2, 28))
	add_child(collections_panel)

	var page_margin: MarginContainer = MarginContainer.new()
	page_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_margin.add_theme_constant_override("margin_left", 18)
	page_margin.add_theme_constant_override("margin_right", 28)
	page_margin.add_theme_constant_override("margin_top", 14)
	page_margin.add_theme_constant_override("margin_bottom", 14)
	collections_panel.add_child(page_margin)

	var page_box: VBoxContainer = VBoxContainer.new()
	page_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_box.add_theme_constant_override("separation", 10)
	page_margin.add_child(page_box)
	_add_top_right_close_button(page_box, "Close Collections and return to Main Menu.", _show_main_menu)

	var header: VBoxContainer = VBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 4)
	page_box.add_child(header)

	var title: Label = Label.new()
	title.text = "Collections"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	header.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Equip your pieces. Choose your board."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#E8EDF2"))
	header.add_child(subtitle)

	collections_active_label = Label.new()
	collections_active_label.text = "Classic SIGMA Set · Unlocked · Equipped"
	collections_active_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	collections_active_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	collections_active_label.add_theme_font_size_override("font_size", 17)
	collections_active_label.add_theme_color_override("font_color", Color("#F2C14E"))
	header.add_child(collections_active_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "CollectionsTrackerScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_box.add_child(scroll)

	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 14)
	scroll.add_child(scroll_box)

	_add_collection_category_label(scroll_box, "My Piece Sets")
	_add_collection_set_card(scroll_box)
	_add_collection_vector_set_card(scroll_box)
	_add_collection_draconian_set_card(scroll_box)
	_add_collection_lions_den_set_card(scroll_box)
	_add_collection_category_label(scroll_box, "My Boards")
	_add_collection_board_card(scroll_box)
	_add_collection_vector_board_card(scroll_box)
	_add_collection_draconian_board_card(scroll_box)
	_add_collection_lions_den_board_card(scroll_box)

	collections_status_label = Label.new()
	collections_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	collections_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	collections_status_label.add_theme_font_size_override("font_size", 13)
	collections_status_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	scroll_box.add_child(collections_status_label)

	var future_note: Label = Label.new()
	future_note.text = "Tap a set to preview it. Equip a full set for matching pieces + board."
	future_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	future_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	future_note.add_theme_font_size_override("font_size", 13)
	future_note.add_theme_color_override("font_color", Color("#8FA6C3"))
	scroll_box.add_child(future_note)

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	page_box.add_child(footer)
	collections_set_active_button = _add_button(footer, "Equipped", "Classic SIGMA Set is unlocked and active by default.", _on_collections_set_classic_active)
	collections_set_active_button.custom_minimum_size = Vector2(140, 50)

	_build_collections_set_detail_page()
	_build_collections_board_detail_page()
	_build_collections_vector_set_detail_page()
	_build_collections_vector_board_detail_page()
	_build_collections_draconian_set_detail_page()
	_build_collections_draconian_board_detail_page()
	_build_collections_lions_den_set_detail_page()
	_build_collections_lions_den_board_detail_page()
	_build_collections_showcase_popup()
	_update_collections_panel()

func _add_collection_category_label(parent: Container, text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#F2C14E"))
	parent.add_child(label)

func _add_collection_set_card(parent: Container) -> void:
	var set_card: Button = Button.new()
	set_card.name = "ClassicSigmaSetCard"
	set_card.text = ""
	set_card.tooltip_text = "Open Classic SIGMA Set."
	set_card.focus_mode = Control.FOCUS_NONE
	set_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_card.custom_minimum_size = Vector2(0, 190)
	set_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#081226", 0.98), Color("#F2C14E"), 2, 22))
	set_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#0B1D36", 0.99), Color("#FFF4B8"), 2, 22))
	set_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#12091F", 0.99), Color("#28E0FF"), 2, 22))
	set_card.pressed.connect(_open_collection_set_detail)
	parent.add_child(set_card)
	_add_collection_card_content(set_card, "Σ", "SET 1", "Classic SIGMA Set", "Unlocked · Equipped", "Default official full set: Classic SIGMA Pieces Set plus Classic SIGMA Board Set. Premium casino-chip pieces on the official Classic board theme.", "Tap to view the full set, inspect pieces, and review the official board.", Color("#F2C14E"), Color("#06101F"))

func _add_collection_board_card(parent: Container) -> void:
	var board_card: Button = Button.new()
	board_card.name = "ClassicSigmaBoardCard"
	board_card.text = ""
	board_card.tooltip_text = "Open Classic SIGMA Board Set."
	board_card.focus_mode = Control.FOCUS_NONE
	board_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_card.custom_minimum_size = Vector2(0, 190)
	board_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#071421", 0.98), Color("#28E0FF"), 2, 22))
	board_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#0A2034", 0.99), Color("#FFF4B8"), 2, 22))
	board_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#12091F", 0.99), Color("#F2C14E"), 2, 22))
	board_card.pressed.connect(_open_collection_board_detail)
	parent.add_child(board_card)
	_add_collection_card_content(board_card, "▦", "BOARD SET", "Classic SIGMA Board", "Included · Equipped", "Official board theme for the Classic SIGMA Set: premium 2.5D control-center board, dark slate grid, gold/cyan frame, adaptive board music, and weighty motion hooks.", "Tap to view board theme details, Tabletop/Non-tabletop layout notes, and the included 3D blockout foundation.", Color("#28E0FF"), Color("#04111F"))

func _add_collection_vector_set_card(parent: Container) -> void:
	var set_card: Button = Button.new()
	set_card.name = "VectorSetCard"
	set_card.text = ""
	set_card.tooltip_text = "Open Obelisk Set."
	set_card.focus_mode = Control.FOCUS_NONE
	set_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_card.custom_minimum_size = Vector2(0, 190)
	set_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#05070B", 0.98), Color("#00E5FF"), 2, 22))
	set_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#08111C", 0.99), Color("#D4AF37"), 2, 22))
	set_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#13091F", 0.99), Color("#A3FF12"), 2, 22))
	set_card.pressed.connect(_open_collection_vector_set_detail)
	parent.add_child(set_card)
	_add_collection_card_content(set_card, "V", "SET 2", "Obelisk Set", "Unlocked · Full Set", "Onyx obelisk pieces with neon laser-cut lines plus the Obelisk Board: an obsidian laser arena with angular frame geometry, glowing channels, and precision sci-fi set identity.", "Tap to view the full set, inspect Obelisk pieces, review the Obelisk board, and equip the set.", Color("#00E5FF"), Color("#04111F"))

func _add_collection_vector_board_card(parent: Container) -> void:
	var board_card: Button = Button.new()
	board_card.name = "VectorBoardCard"
	board_card.text = ""
	board_card.tooltip_text = "Open Obelisk Board Set."
	board_card.focus_mode = Control.FOCUS_NONE
	board_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_card.custom_minimum_size = Vector2(0, 190)
	board_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#05070B", 0.98), Color("#E8EDF2"), 2, 22))
	board_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#08111C", 0.99), Color("#00E5FF"), 2, 22))
	board_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#12091F", 0.99), Color("#D4AF37"), 2, 22))
	board_card.pressed.connect(_open_collection_vector_board_detail)
	parent.add_child(board_card)
	_add_collection_card_content(board_card, "◇", "BOARD SET", "Obelisk Board", "Included in Obelisk", "Black onyx / obsidian board theme with neon laser grid cuts, angular faceted frame, gold/silver vector lanes, central SIGMA sigil, and sleek futuristic control-center identity.", "Tap to view the Obelisk Board details and equip the board theme. It changes visuals only, never rules.", Color("#E8EDF2"), Color("#05070B"))


func _add_collection_draconian_set_card(parent: Container) -> void:
	var set_card: Button = Button.new()
	set_card.name = "DraconianSetCard"
	set_card.text = ""
	set_card.tooltip_text = "Open Dragons Set."
	set_card.focus_mode = Control.FOCUS_NONE
	set_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_card.custom_minimum_size = Vector2(0, 190)
	set_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#100407", 0.98), Color("#FFB000"), 2, 22))
	set_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#1A080C", 0.99), Color("#FF3B30"), 2, 22))
	set_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#180720", 0.99), Color("#7C3AED"), 2, 22))
	set_card.pressed.connect(_open_collection_draconian_set_detail)
	parent.add_child(set_card)
	_add_collection_card_content(set_card, "D", "SET 3", "Dragons Set", "Unlocked · Full Set", "Dragon-inspired pieces with colorful flames, wings, glowing eyes, and the Dragons Board: an obsidian dragon-scale arena with gemmed flame channels and carved wing frame identity.", "Tap to view the full set, inspect Dragon pieces, review the board, and equip the set.", Color("#FFB000"), Color("#120507"))

func _add_collection_draconian_board_card(parent: Container) -> void:
	var board_card: Button = Button.new()
	board_card.name = "DraconianBoardCard"
	board_card.text = ""
	board_card.tooltip_text = "Open Dragons Board Set."
	board_card.focus_mode = Control.FOCUS_NONE
	board_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_card.custom_minimum_size = Vector2(0, 190)
	board_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#0B0506", 0.98), Color("#D4AF37"), 2, 22))
	board_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#14070A", 0.99), Color("#28E0FF"), 2, 22))
	board_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#13091F", 0.99), Color("#A3FF12"), 2, 22))
	board_card.pressed.connect(_open_collection_draconian_board_detail)
	parent.add_child(board_card)
	_add_collection_card_content(board_card, "◆", "BOARD SET", "Dragons Board", "Included in Dragons", "Obsidian dragon-scale board theme with carved wings, claw-like frame armor, gold/silver trim, colored flame channels, and role-gem accents.", "Tap to view the Dragons Board details and equip the board theme. It changes visuals only, never rules.", Color("#D4AF37"), Color("#0B0506"))

func _add_collection_lions_den_set_card(parent: Container) -> void:
	var set_card: Button = Button.new()
	set_card.name = "LionsDenSetCard"
	set_card.text = ""
	set_card.tooltip_text = "Open Lion's Den Set."
	set_card.focus_mode = Control.FOCUS_NONE
	set_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_card.custom_minimum_size = Vector2(0, 190)
	set_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#120806", 0.98), Color("#D4AF37"), 2, 22))
	set_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#1A0C08", 0.99), Color("#FFD84D"), 2, 22))
	set_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#1B0711", 0.99), Color("#A3FF12"), 2, 22))
	set_card.pressed.connect(_open_collection_lions_den_set_detail)
	parent.add_child(set_card)
	_add_collection_card_content(set_card, "L", "SET 4", "Lion's Den Set", "Unlocked · Full Set", "Regal lion pieces with colorful flames, elegant royal manes, glowing colored eyes, and the Lion's Den Board: a black stone royal arena with golden structure, jewel corners, and mane-inspired energy accents.", "Tap to view the full set, inspect Lion's Den pieces, review the board, and equip the set.", Color("#D4AF37"), Color("#120806"))

func _add_collection_lions_den_board_card(parent: Container) -> void:
	var board_card: Button = Button.new()
	board_card.name = "LionsDenBoardCard"
	board_card.text = ""
	board_card.tooltip_text = "Open Lion's Den Board Set."
	board_card.focus_mode = Control.FOCUS_NONE
	board_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_card.custom_minimum_size = Vector2(0, 190)
	board_card.add_theme_stylebox_override("normal", _make_rounded_style(Color("#0C0504", 0.98), Color("#D4AF37"), 2, 22))
	board_card.add_theme_stylebox_override("hover", _make_rounded_style(Color("#160A07", 0.99), Color("#28E0FF"), 2, 22))
	board_card.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#13091F", 0.99), Color("#FF7A18"), 2, 22))
	board_card.pressed.connect(_open_collection_lions_den_board_detail)
	parent.add_child(board_card)
	_add_collection_card_content(board_card, "♔", "BOARD SET", "Lion's Den Board", "Included in Lion's Den", "Royal lion-themed board set with black stone cells, elegant gold frame architecture, lion crests, colorful jewel corners, and subtle mane-flame energy accents.", "Tap to view the Lion's Den Board details and equip the board theme. It changes visuals only, never rules.", Color("#D4AF37"), Color("#0C0504"))

func _add_collection_card_content(card: Button, logo_text: String, tag_text: String, title_text: String, badge_text: String, desc_text: String, hint_text: String, accent: Color, badge_text_color: Color) -> void:
	var card_margin: MarginContainer = MarginContainer.new()
	card_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_margin.add_theme_constant_override("margin_left", 18)
	card_margin.add_theme_constant_override("margin_right", 28)
	card_margin.add_theme_constant_override("margin_top", 14)
	card_margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(card_margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_margin.add_child(row)

	var logo_panel: PanelContainer = PanelContainer.new()
	logo_panel.custom_minimum_size = Vector2(128, 128)
	logo_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	logo_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	logo_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020817", 0.96), accent, 2, 64))
	row.add_child(logo_panel)

	var logo_center: CenterContainer = CenterContainer.new()
	logo_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_panel.add_child(logo_center)

	var logo_box: VBoxContainer = VBoxContainer.new()
	logo_box.alignment = BoxContainer.ALIGNMENT_CENTER
	logo_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_center.add_child(logo_box)

	var mark: Label = Label.new()
	mark.text = logo_text
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.add_theme_font_size_override("font_size", 48)
	mark.add_theme_color_override("font_color", accent)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_box.add_child(mark)

	var tag: Label = Label.new()
	tag.text = tag_text
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 11)
	tag.add_theme_color_override("font_color", Color("#8DD7FF"))
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_box.add_child(tag)

	var copy_box: VBoxContainer = VBoxContainer.new()
	copy_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	copy_box.alignment = BoxContainer.ALIGNMENT_CENTER
	copy_box.add_theme_constant_override("separation", 8)
	copy_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(copy_box)

	var top_line: HBoxContainer = HBoxContainer.new()
	top_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_line.alignment = BoxContainer.ALIGNMENT_CENTER
	top_line.add_theme_constant_override("separation", 10)
	top_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy_box.add_child(top_line)

	var set_title: Label = Label.new()
	set_title.text = title_text
	set_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	set_title.add_theme_font_size_override("font_size", 24)
	set_title.add_theme_color_override("font_color", Color("#F7F3E8"))
	set_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_line.add_child(set_title)

	var badge: Label = Label.new()
	badge.text = badge_text
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(128, 34)
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", badge_text_color)
	badge.add_theme_stylebox_override("normal", _make_rounded_style(accent, Color("#FFF4B8"), 1, 16))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_line.add_child(badge)

	var desc: Label = Label.new()
	desc.text = desc_text
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color("#B8C4D8"))
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy_box.add_child(desc)

	var action_hint: Label = Label.new()
	action_hint.text = hint_text
	action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	action_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_hint.add_theme_font_size_override("font_size", 13)
	action_hint.add_theme_color_override("font_color", accent)
	action_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy_box.add_child(action_hint)

func _build_collections_set_detail_page() -> void:
	collections_set_detail_panel = _make_collection_modal_panel("CollectionsSetDetail")
	collections_panel.add_child(collections_set_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_set_detail_panel, Vector2(680, 520))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Classic SIGMA Set", "Full Set · Unlocked by Default · Equipped", _close_collection_set_detail)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_owner_preview_section(scroll_box, "Gold Pieces · Player 1", SigmaRules.OWNER_P1)
	_add_collection_owner_preview_section(scroll_box, "Silver Pieces · Player 2", SigmaRules.OWNER_P2)
	_add_collection_small_note(scroll_box, "Included Board Set: Classic SIGMA Board — premium 2.5D control-center board, gold/cyan frame, adaptive retro-premium board music, ambience, Tabletop and Non-tabletop layout foundations, and future 3D board viewer support.")
	_add_collection_small_note(scroll_box, "Future true 3D rotation can plug into the piece and board viewers. Gameplay uses optimized 2.5D presentation for clarity and performance.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equipped_button: Button = _add_button(footer, "Equipped", "Classic SIGMA Set is active.", _on_collections_set_classic_active)
	equipped_button.custom_minimum_size = Vector2(140, 48)
	equipped_button.disabled = true
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_set_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _build_collections_board_detail_page() -> void:
	collections_board_detail_panel = _make_collection_modal_panel("CollectionsBoardDetail")
	collections_panel.add_child(collections_board_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_board_detail_panel, Vector2(680, 520))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Classic SIGMA Board Set", "Included in Classic SIGMA Set · Equipped", _close_collection_board_detail)
	_add_collection_info_card(box, "Boards are collectible complete themes. The Classic SIGMA Board Set is unlocked by default as part of the Classic SIGMA Set. A board theme controls visuals, Tabletop and Non-tabletop layouts, board audio profile, in-game theme music, ambience, and board-specific animation hooks. It does not change SIGMA rules.")

	var showcase: PanelContainer = PanelContainer.new()
	showcase.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	showcase.size_flags_vertical = Control.SIZE_EXPAND_FILL
	showcase.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020817", 0.98), Color("#24435F"), 1, 18))
	box.add_child(showcase)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	showcase.add_child(margin)
	var board_box: VBoxContainer = VBoxContainer.new()
	board_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_box.add_theme_constant_override("separation", 10)
	margin.add_child(board_box)
	var board_logo: Label = Label.new()
	board_logo.text = "▦"
	board_logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	board_logo.add_theme_font_size_override("font_size", 72)
	board_logo.add_theme_color_override("font_color", Color("#28E0FF"))
	board_box.add_child(board_logo)
	_add_collection_small_note(board_box, "Classic SIGMA Board: dark luxury control-center tabletop, blue-black beveled tiles, gold/cyan frame bands, static energy rails, jewel corners, centered alternating underglow support, retro-premium board music, and weighty token motion.")
	_add_collection_small_note(board_box, "Board themes include both Tabletop and Non-tabletop profiles. Offline Human vs Human always uses mirrored Tabletop; AI/Online always uses one-player-facing mobile command mode.")
	_add_collection_small_note(board_box, "A first 3D OBJ blockout is included in assets/boards/classic_sigma_board_3d. Future board collections can add unique visual animations, adaptive board music, ambient board sound, capture/deploy/elevate flavors, and premium 3D board previews.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equipped_button: Button = _add_button(footer, "Equipped", "Classic SIGMA Board is currently active.", _on_collections_board_classic_active)
	equipped_button.custom_minimum_size = Vector2(140, 48)
	equipped_button.disabled = true
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_board_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _build_collections_vector_set_detail_page() -> void:
	collections_vector_set_detail_panel = _make_collection_modal_panel("CollectionsVectorSetDetail")
	collections_panel.add_child(collections_vector_set_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_vector_set_detail_panel, Vector2(680, 540))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Obelisk Set", "Full Set · Obelisk Pieces + Obelisk Board", _close_collection_vector_set_detail)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_vector_owner_preview_section(scroll_box, "Gold Obelisk Pieces · Player 1", SigmaRules.OWNER_P1)
	_add_collection_vector_owner_preview_section(scroll_box, "Silver Obelisk Pieces · Player 2", SigmaRules.OWNER_P2)
	_add_collection_small_note(scroll_box, "Included Board Set: Obelisk Board — obsidian/onyx laser grid, angular frame, gold/silver vector lanes, central SIGMA sigil, and sleek future-tactical command center identity.")
	_add_collection_small_note(scroll_box, "Vector uses the same official SIGMA rules. Only the board and piece presentation changes.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Obelisk", "Equip Obelisk Pieces + Obelisk Board.", _on_collections_set_vector_active)
	equip_button.custom_minimum_size = Vector2(170, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_vector_set_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _build_collections_vector_board_detail_page() -> void:
	collections_vector_board_detail_panel = _make_collection_modal_panel("CollectionsVectorBoardDetail")
	collections_panel.add_child(collections_vector_board_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_vector_board_detail_panel, Vector2(680, 560))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Obelisk Board Set", "Included in Obelisk Set", _close_collection_vector_board_detail)
	_add_collection_info_card(box, "Obelisk Board is the board half of the Obelisk Set: a black onyx/obsidian arena with neon laser grid cuts, angular frame geometry, gold/silver vector lanes, and a central SIGMA sigil. Visuals only — rules do not change.")

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_image_showcase(scroll_box, "res://assets/collections/vector/vector_board_promo.png", Vector2(0, 300), "Obelisk Board · Official SIGMA board set preview")
	_add_collection_small_note(scroll_box, "Board identity: black onyx slab, thin neon grid channels, faceted corners, premium vector rails, and a sleek control-center foundation.")
	_add_collection_small_note(scroll_box, "Works in both Tabletop Pass-and-Play and upright mobile/AI layouts. Offline Human vs Human still uses tabletop; AI games still use mobile command view.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Board", "Equip the Obelisk Board theme.", _on_collections_board_vector_active)
	equip_button.custom_minimum_size = Vector2(170, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_vector_board_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _add_collection_image_showcase(parent: Container, path: String, min_size: Vector2, caption_text: String) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020817", 0.98), Color("#24435F"), 1, 18))
	parent.add_child(panel)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	var rect: TextureRect = TextureRect.new()
	rect.custom_minimum_size = min_size
	rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rect.expand_mode = 1
	rect.stretch_mode = 5
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		rect.texture = load(path) as Texture2D
	box.add_child(rect)
	var caption: Label = Label.new()
	caption.text = caption_text
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 13)
	caption.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(caption)


func _build_collections_draconian_set_detail_page() -> void:
	collections_draconian_set_detail_panel = _make_collection_modal_panel("CollectionsDraconianSetDetail")
	collections_panel.add_child(collections_draconian_set_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_draconian_set_detail_panel, Vector2(680, 540))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Dragons Set", "Full Set · Dragon Pieces + Dragons Board", _close_collection_draconian_set_detail)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_draconian_owner_preview_section(scroll_box, "Gold Dragon Pieces · Player 1", SigmaRules.OWNER_P1)
	_add_collection_draconian_owner_preview_section(scroll_box, "Silver Dragon Pieces · Player 2", SigmaRules.OWNER_P2)
	_add_collection_small_note(scroll_box, "Included Board Set: Dragons Board — obsidian dragon-scale arena, carved wing frame, colored flame channels, gemmed role accents, and premium fantasy set identity.")
	_add_collection_small_note(scroll_box, "Dragons uses the same official SIGMA rules. Only the board and piece presentation changes.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Dragons", "Equip Dragon Pieces + Dragons Board.", _on_collections_set_draconian_active)
	equip_button.custom_minimum_size = Vector2(180, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_draconian_set_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _build_collections_draconian_board_detail_page() -> void:
	collections_draconian_board_detail_panel = _make_collection_modal_panel("CollectionsDraconianBoardDetail")
	collections_panel.add_child(collections_draconian_board_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_draconian_board_detail_panel, Vector2(680, 560))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Dragons Board Set", "Included in Dragons Set", _close_collection_draconian_board_detail)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_image_showcase(scroll_box, "res://assets/collections/draconian/draconian_board_promo.png", Vector2(0, 300), "Dragons Board · Official SIGMA board set preview")
	_add_collection_small_note(scroll_box, "Board identity: obsidian dragon-scale surface, ornate wing-and-claw frame, gold/silver trim, colored flame channels, and gemmed role-color accents.")
	_add_collection_small_note(scroll_box, "Works in both Tabletop Pass-and-Play and upright mobile/AI layouts. Offline Human vs Human still uses tabletop; AI games still use mobile command view.")

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Board", "Equip Dragons Board theme.", _on_collections_board_draconian_active)
	equip_button.custom_minimum_size = Vector2(160, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_draconian_board_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _add_collection_draconian_owner_preview_section(parent: Container, title_text: String, owner: int) -> void:
	var section_card: PanelContainer = PanelContainer.new()
	section_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#06030A", 0.96), Color("#D4AF37", 0.62), 1, 14))
	parent.add_child(section_card)
	var section_margin: MarginContainer = MarginContainer.new()
	section_margin.add_theme_constant_override("margin_left", 10)
	section_margin.add_theme_constant_override("margin_right", 10)
	section_margin.add_theme_constant_override("margin_top", 10)
	section_margin.add_theme_constant_override("margin_bottom", 10)
	section_card.add_child(section_margin)
	var section_box: VBoxContainer = VBoxContainer.new()
	section_box.add_theme_constant_override("separation", 8)
	section_margin.add_child(section_box)
	var section_label: Label = Label.new()
	section_label.text = title_text
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_label.add_theme_font_size_override("font_size", 16)
	section_label.add_theme_color_override("font_color", Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2"))
	section_box.add_child(section_label)
	var center_row: CenterContainer = CenterContainer.new()
	center_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_box.add_child(center_row)
	var preview_grid: GridContainer = GridContainer.new()
	preview_grid.columns = 5
	preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_grid.add_theme_constant_override("h_separation", 8)
	preview_grid.add_theme_constant_override("v_separation", 8)
	center_row.add_child(preview_grid)
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	for kind_value in kinds:
		_add_collection_draconian_piece_preview(preview_grid, String(kind_value), owner)

func _add_collection_draconian_piece_preview(parent: Container, kind: String, owner: int) -> void:
	var holder: Button = Button.new()
	holder.text = ""
	holder.tooltip_text = "%s Dragon %s — tap to inspect." % ["Gold" if owner == SigmaRules.OWNER_P1 else "Silver", _piece_name(kind)]
	holder.focus_mode = Control.FOCUS_NONE
	holder.custom_minimum_size = Vector2(92, 124)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.clip_contents = true
	holder.add_theme_stylebox_override("normal", _make_rounded_style(Color("#09050A", 0.98), Color("#3B1F14"), 1, 14))
	holder.add_theme_stylebox_override("hover", _make_rounded_style(Color("#12070A", 0.99), Color("#FFB000"), 2, 14))
	holder.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#1B0711", 0.99), Color("#FF3B30"), 2, 14))
	holder.pressed.connect(func() -> void:
		_open_collection_draconian_piece_showcase(kind)
	)
	parent.add_child(holder)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(box)
	var center: CenterContainer = CenterContainer.new()
	center.custom_minimum_size = Vector2(88, 90)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(center)
	var texture_rect: TextureRect = _make_collection_draconian_piece_texture_rect(kind, owner, Vector2(78, 88))
	center.add_child(texture_rect)
	var label: Label = Label.new()
	label.text = _piece_name(kind)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("#E8EDF2"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)

func _build_collections_lions_den_set_detail_page() -> void:
	collections_lions_den_set_detail_panel = _make_collection_modal_panel("CollectionsLionsDenSetDetail")
	collections_panel.add_child(collections_lions_den_set_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_lions_den_set_detail_panel, Vector2(680, 540))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Lion's Den Set", "Full Set · Lion's Den Pieces + Lion's Den Board", _close_collection_lions_den_set_detail)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_lions_den_owner_preview_section(scroll_box, "Gold Lion's Den Pieces · Player 1", SigmaRules.OWNER_P1)
	_add_collection_lions_den_owner_preview_section(scroll_box, "Silver Lion's Den Pieces · Player 2", SigmaRules.OWNER_P2)
	_add_collection_small_note(scroll_box, "Included Board Set: Lion's Den Board — regal black-stone arena, elegant golden frame, lion crests, colorful jewel corners, and mane-inspired energy accents.")
	_add_collection_small_note(scroll_box, "Lion's Den uses the same official SIGMA rules. Only the board and piece presentation changes.")
	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Lion's Den", "Equip Lion's Den Pieces + Lion's Den Board.", _on_collections_set_lions_den_active)
	equip_button.custom_minimum_size = Vector2(180, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_lions_den_set_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _build_collections_lions_den_board_detail_page() -> void:
	collections_lions_den_board_detail_panel = _make_collection_modal_panel("CollectionsLionsDenBoardDetail")
	collections_panel.add_child(collections_lions_den_board_detail_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_lions_den_board_detail_panel, Vector2(680, 560))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Lion's Den Board Set", "Included in Lion's Den Set", _close_collection_lions_den_board_detail)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var scroll_box: VBoxContainer = VBoxContainer.new()
	scroll_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_box.add_theme_constant_override("separation", 12)
	scroll.add_child(scroll_box)
	_add_collection_image_showcase(scroll_box, "res://assets/collections/lions_den/lions_den_board_promo.png", Vector2(0, 300), "Lion's Den Board · Official SIGMA board set preview")
	_add_collection_small_note(scroll_box, "Board identity: royal black stone, elegant golden frame, lion crest architecture, gemmed corners, and colorful mane-energy accents.")
	_add_collection_small_note(scroll_box, "Works in both Tabletop Pass-and-Play and upright mobile/AI layouts. Offline Human vs Human still uses tabletop; AI games still use mobile command view.")
	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)
	var equip_button: Button = _add_button(footer, "Equip Board", "Equip Lion's Den Board theme.", _on_collections_board_lions_den_active)
	equip_button.custom_minimum_size = Vector2(160, 48)
	var back_button: Button = _add_button(footer, "Back", "Return to Collections.", _close_collection_lions_den_board_detail)
	back_button.custom_minimum_size = Vector2(140, 48)

func _add_collection_lions_den_owner_preview_section(parent: Container, title_text: String, owner: int) -> void:
	var section_card: PanelContainer = PanelContainer.new()
	section_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#080504", 0.96), Color("#D4AF37", 0.62), 1, 14))
	parent.add_child(section_card)
	var section_margin: MarginContainer = MarginContainer.new()
	section_margin.add_theme_constant_override("margin_left", 10)
	section_margin.add_theme_constant_override("margin_right", 10)
	section_margin.add_theme_constant_override("margin_top", 10)
	section_margin.add_theme_constant_override("margin_bottom", 10)
	section_card.add_child(section_margin)
	var section_box: VBoxContainer = VBoxContainer.new()
	section_box.add_theme_constant_override("separation", 8)
	section_margin.add_child(section_box)
	var section_label: Label = Label.new()
	section_label.text = title_text
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_label.add_theme_font_size_override("font_size", 16)
	section_label.add_theme_color_override("font_color", Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2"))
	section_box.add_child(section_label)
	var center_row: CenterContainer = CenterContainer.new()
	center_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_box.add_child(center_row)
	var preview_grid: GridContainer = GridContainer.new()
	preview_grid.columns = 5
	preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_grid.add_theme_constant_override("h_separation", 8)
	preview_grid.add_theme_constant_override("v_separation", 8)
	center_row.add_child(preview_grid)
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	for kind_value in kinds:
		_add_collection_lions_den_piece_preview(preview_grid, String(kind_value), owner)

func _add_collection_lions_den_piece_preview(parent: Container, kind: String, owner: int) -> void:
	var holder: Button = Button.new()
	holder.text = ""
	holder.tooltip_text = "%s Lion's Den %s — tap to inspect." % ["Gold" if owner == SigmaRules.OWNER_P1 else "Silver", _piece_name(kind)]
	holder.focus_mode = Control.FOCUS_NONE
	holder.custom_minimum_size = Vector2(92, 124)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.clip_contents = true
	holder.add_theme_stylebox_override("normal", _make_rounded_style(Color("#090504", 0.98), Color("#5A3512"), 1, 14))
	holder.add_theme_stylebox_override("hover", _make_rounded_style(Color("#120907", 0.99), Color("#D4AF37"), 2, 14))
	holder.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#1A0A08", 0.99), Color("#28E0FF"), 2, 14))
	holder.pressed.connect(func() -> void:
		_open_collection_lions_den_piece_showcase(kind)
	)
	parent.add_child(holder)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(box)
	var center: CenterContainer = CenterContainer.new()
	center.custom_minimum_size = Vector2(88, 90)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(center)
	var texture_rect: TextureRect = _make_collection_lions_den_piece_texture_rect(kind, owner, Vector2(78, 88))
	center.add_child(texture_rect)
	var label: Label = Label.new()
	label.text = _piece_name(kind)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("#E8EDF2"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)

func _add_collection_vector_owner_preview_section(parent: Container, title_text: String, owner: int) -> void:
	var section_card: PanelContainer = PanelContainer.new()
	section_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#030719", 0.96), Color("#24435F"), 1, 16))
	parent.add_child(section_card)
	var section_margin: MarginContainer = MarginContainer.new()
	section_margin.add_theme_constant_override("margin_left", 10)
	section_margin.add_theme_constant_override("margin_right", 10)
	section_margin.add_theme_constant_override("margin_top", 10)
	section_margin.add_theme_constant_override("margin_bottom", 10)
	section_card.add_child(section_margin)
	var section_box: VBoxContainer = VBoxContainer.new()
	section_box.add_theme_constant_override("separation", 8)
	section_margin.add_child(section_box)
	var section_label: Label = Label.new()
	section_label.text = title_text
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_label.add_theme_font_size_override("font_size", 16)
	section_label.add_theme_color_override("font_color", Color("#00E5FF") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2"))
	section_box.add_child(section_label)
	var center_row: CenterContainer = CenterContainer.new()
	center_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_box.add_child(center_row)
	var preview_grid: GridContainer = GridContainer.new()
	preview_grid.columns = 5
	preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_grid.add_theme_constant_override("h_separation", 8)
	preview_grid.add_theme_constant_override("v_separation", 8)
	center_row.add_child(preview_grid)
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	for kind_value in kinds:
		_add_collection_vector_piece_preview(preview_grid, String(kind_value), owner)

func _add_collection_vector_piece_preview(parent: Container, kind: String, owner: int) -> void:
	var holder: Button = Button.new()
	holder.text = ""
	holder.tooltip_text = "%s Vector %s — tap to inspect." % ["Gold" if owner == SigmaRules.OWNER_P1 else "Silver", _piece_name(kind)]
	holder.focus_mode = Control.FOCUS_NONE
	holder.custom_minimum_size = Vector2(92, 124)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.clip_contents = true
	holder.add_theme_stylebox_override("normal", _make_rounded_style(Color("#040A12", 0.98), Color("#24435F"), 1, 14))
	holder.add_theme_stylebox_override("hover", _make_rounded_style(Color("#071421", 0.99), Color("#00E5FF"), 2, 14))
	holder.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#12091F", 0.99), Color("#A3FF12"), 2, 14))
	holder.pressed.connect(func() -> void:
		_open_collection_vector_piece_showcase(kind)
	)
	parent.add_child(holder)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(box)
	var center: CenterContainer = CenterContainer.new()
	center.custom_minimum_size = Vector2(88, 90)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(center)
	var texture_rect: TextureRect = _make_collection_vector_piece_texture_rect(kind, owner, Vector2(78, 88))
	center.add_child(texture_rect)
	var label: Label = Label.new()
	label.text = _piece_name(kind)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("#E8EDF2"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)

func _make_collection_modal_panel(panel_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.visible = false
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#000000", 0.72), Color("#000000", 0.0), 0, 0))
	return panel

func _add_collection_modal_card(parent: Control, min_size: Vector2) -> PanelContainer:
	var outer_margin: MarginContainer = MarginContainer.new()
	outer_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer_margin.add_theme_constant_override("margin_left", 18)
	outer_margin.add_theme_constant_override("margin_right", 28)
	outer_margin.add_theme_constant_override("margin_top", 18)
	outer_margin.add_theme_constant_override("margin_bottom", 18)
	parent.add_child(outer_margin)
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_margin.add_child(center)
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = min_size
	card.clip_contents = true
	card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#050715", 0.995), Color("#F2C14E"), 2, 22))
	center.add_child(card)
	return card

func _collection_modal_box(card: PanelContainer) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	return box

func _add_collection_modal_header(parent: Container, title_text: String, subtitle_text: String, close_callable: Callable) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	row.add_child(title_box)
	var title: Label = Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("#F2C14E"))
	title_box.add_child(title)
	var subtitle: Label = Label.new()
	subtitle.text = subtitle_text
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("#E8EDF2"))
	title_box.add_child(subtitle)
	var close_button: Button = Button.new()
	close_button.text = "X"
	close_button.tooltip_text = "Close"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.custom_minimum_size = Vector2(42, 38)
	close_button.add_theme_stylebox_override("normal", _make_rounded_style(Color("#111827", 0.95), Color("#B8C4D8"), 1, 18))
	close_button.add_theme_stylebox_override("hover", _make_rounded_style(Color("#2B1D1D", 0.98), Color("#F2C14E"), 1, 18))
	close_button.pressed.connect(close_callable)
	row.add_child(close_button)

func _add_collection_info_card(parent: Container, text: String) -> void:
	var info_card: PanelContainer = PanelContainer.new()
	info_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#081226", 0.98), Color("#24435F"), 1, 16))
	parent.add_child(info_card)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	info_card.add_child(margin)
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("#B8C4D8"))
	margin.add_child(label)

func _add_collection_small_note(parent: Container, text: String) -> void:
	var note: Label = Label.new()
	note.text = text
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#8FA6C3"))
	parent.add_child(note)

func _add_collection_owner_preview_section(parent: Container, title_text: String, owner: int) -> void:
	var section_card: PanelContainer = PanelContainer.new()
	section_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_card.add_theme_stylebox_override("panel", _make_rounded_style(Color("#030719", 0.96), Color("#24435F"), 1, 16))
	parent.add_child(section_card)
	var section_margin: MarginContainer = MarginContainer.new()
	section_margin.add_theme_constant_override("margin_left", 10)
	section_margin.add_theme_constant_override("margin_right", 10)
	section_margin.add_theme_constant_override("margin_top", 10)
	section_margin.add_theme_constant_override("margin_bottom", 10)
	section_card.add_child(section_margin)
	var section_box: VBoxContainer = VBoxContainer.new()
	section_box.add_theme_constant_override("separation", 8)
	section_margin.add_child(section_box)
	var section_label: Label = Label.new()
	section_label.text = title_text
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_label.add_theme_font_size_override("font_size", 16)
	section_label.add_theme_color_override("font_color", Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2"))
	section_box.add_child(section_label)
	var center_row: CenterContainer = CenterContainer.new()
	center_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_box.add_child(center_row)
	var preview_grid: GridContainer = GridContainer.new()
	preview_grid.columns = 5
	preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_grid.add_theme_constant_override("h_separation", 8)
	preview_grid.add_theme_constant_override("v_separation", 8)
	center_row.add_child(preview_grid)
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	for kind_value in kinds:
		_add_collection_piece_preview(preview_grid, String(kind_value), owner)

func _add_collection_piece_preview(parent: Container, kind: String, owner: int) -> void:
	var holder: Button = Button.new()
	holder.text = ""
	holder.tooltip_text = "%s %s — tap to inspect." % ["Gold" if owner == SigmaRules.OWNER_P1 else "Silver", _piece_name(kind)]
	holder.focus_mode = Control.FOCUS_NONE
	holder.custom_minimum_size = Vector2(92, 114)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.clip_contents = true
	holder.add_theme_stylebox_override("normal", _make_rounded_style(Color("#07101F", 0.96), Color("#24435F"), 1, 14))
	holder.add_theme_stylebox_override("hover", _make_rounded_style(Color("#09213A", 0.98), Color("#28E0FF"), 2, 14))
	holder.add_theme_stylebox_override("pressed", _make_rounded_style(Color("#12091F", 0.98), Color("#F2C14E"), 2, 14))
	holder.pressed.connect(func() -> void:
		_open_collection_piece_showcase(kind)
	)
	parent.add_child(holder)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(box)
	var center: CenterContainer = CenterContainer.new()
	center.custom_minimum_size = Vector2(88, 82)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(center)
	var texture_rect: TextureRect = _make_collection_piece_texture_rect(kind, owner, Vector2(78, 78))
	center.add_child(texture_rect)
	var label: Label = Label.new()
	label.text = _piece_name(kind)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("#E8EDF2"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)

func _make_collection_piece_texture_rect(kind: String, owner: int, min_size: Vector2) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.custom_minimum_size = min_size
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.expand_mode = 1
	texture_rect.stretch_mode = 5
	texture_rect.texture = _classic_piece_texture(kind, owner)
	return texture_rect

func _make_collection_vector_piece_texture_rect(kind: String, owner: int, min_size: Vector2) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.custom_minimum_size = min_size
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.expand_mode = 1
	texture_rect.stretch_mode = 5
	texture_rect.texture = _vector_piece_texture(kind, owner)
	return texture_rect

func _make_collection_draconian_piece_texture_rect(kind: String, owner: int, min_size: Vector2) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.custom_minimum_size = min_size
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.expand_mode = 1
	texture_rect.stretch_mode = 5
	texture_rect.texture = _draconian_piece_texture(kind, owner)
	return texture_rect

func _make_collection_lions_den_piece_texture_rect(kind: String, owner: int, min_size: Vector2) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.custom_minimum_size = min_size
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.expand_mode = 1
	texture_rect.stretch_mode = 5
	texture_rect.texture = _lions_den_piece_texture(kind, owner)
	return texture_rect

func _classic_piece_texture(kind: String, owner: int) -> Texture2D:
	return _piece_texture_from_base("res://assets/pieces/classic_sigma_tokens/", kind, owner)

func _vector_piece_texture(kind: String, owner: int) -> Texture2D:
	return _piece_texture_from_base("res://assets/pieces/vector_obelisks/", kind, owner)

func _draconian_piece_texture(kind: String, owner: int) -> Texture2D:
	return _piece_texture_from_base("res://assets/pieces/draconian/", kind, owner)

func _lions_den_piece_texture(kind: String, owner: int) -> Texture2D:
	return _piece_texture_from_base("res://assets/pieces/lions_den/", kind, owner)

func _piece_texture_from_base(base_path: String, kind: String, owner: int) -> Texture2D:
	var owner_name: String = "gold" if owner == SigmaRules.OWNER_P1 else "silver"
	var file_name: String = _classic_piece_file_name(kind)
	var path: String = "%s%s_%s.png" % [base_path, owner_name, file_name]
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _classic_piece_file_name(kind: String) -> String:
	match kind:
		SigmaRules.KIND_MONARCH:
			return "monarch"
		SigmaRules.KIND_GUARDIAN:
			return "guardian"
		SigmaRules.KIND_SENTINEL:
			return "sentinel"
		SigmaRules.KIND_INFILTRATOR:
			return "infiltrator"
		SigmaRules.KIND_ASSASSIN:
			return "assassin"
	return "guardian"

func _build_collections_showcase_popup() -> void:
	collections_showcase_panel = _make_collection_modal_panel("CollectionsPieceViewer")
	collections_panel.add_child(collections_showcase_panel)
	var card: PanelContainer = _add_collection_modal_card(collections_showcase_panel, Vector2(660, 560))
	var box: VBoxContainer = _collection_modal_box(card)
	_add_collection_modal_header(box, "Monarch Model Viewer", "Classic SIGMA Tokens", _close_collection_piece_showcase)
	collections_showcase_title_label = box.get_child(0).get_child(0).get_child(0) as Label
	collections_showcase_subtitle_label = box.get_child(0).get_child(0).get_child(1) as Label

	var preview_grid: GridContainer = GridContainer.new()
	preview_grid.columns = 2
	preview_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_grid.add_theme_constant_override("h_separation", 14)
	preview_grid.add_theme_constant_override("v_separation", 10)
	var preview_center: CenterContainer = CenterContainer.new()
	preview_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_center.add_child(preview_grid)
	box.add_child(preview_center)
	collections_showcase_gold_preview = _make_showcase_preview_card(preview_grid, "Gold · Player 1", SigmaRules.OWNER_P1)
	collections_showcase_silver_preview = _make_showcase_preview_card(preview_grid, "Silver · Player 2", SigmaRules.OWNER_P2)
	collections_showcase_note_label = Label.new()
	collections_showcase_note_label.text = "HD 3D-style piece viewer. Gameplay uses optimized owner-facing tokens."
	collections_showcase_note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	collections_showcase_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	collections_showcase_note_label.add_theme_font_size_override("font_size", 12)
	collections_showcase_note_label.add_theme_color_override("font_color", Color("#B8C4D8"))
	box.add_child(collections_showcase_note_label)
	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 10)
	box.add_child(buttons)
	var close_button: Button = _add_button(buttons, "Close", "Return to the set detail.", _close_collection_piece_showcase)
	close_button.custom_minimum_size = Vector2(150, 48)

func _make_showcase_preview_card(parent: Container, label_text: String, owner: int) -> TextureRect:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(270, 300)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", _make_rounded_style(Color("#020817", 0.96), Color("#24435F"), 1, 18))
	parent.add_child(panel)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)
	var center: CenterContainer = CenterContainer.new()
	center.custom_minimum_size = Vector2(250, 235)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(center)
	var preview: TextureRect = _make_collection_piece_texture_rect(SigmaRules.KIND_MONARCH, owner, Vector2(230, 230))
	center.add_child(preview)
	var label: Label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2"))
	box.add_child(label)
	return preview

func _open_collection_set_detail() -> void:
	_play_sound_cue("page_open")
	if collections_set_detail_panel != null:
		collections_set_detail_panel.visible = true
	_update_collections_panel()
	_apply_active_piece_set_to_board_views()

func _close_collection_set_detail() -> void:
	_play_sound_cue("page_back")
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	if collections_set_detail_panel != null:
		collections_set_detail_panel.visible = false

func _open_collection_board_detail() -> void:
	_play_sound_cue("page_open")
	if collections_board_detail_panel != null:
		collections_board_detail_panel.visible = true
	_update_collections_panel()

func _close_collection_board_detail() -> void:
	_play_sound_cue("page_back")
	if collections_board_detail_panel != null:
		collections_board_detail_panel.visible = false

func _open_collection_piece_showcase(kind: String) -> void:
	collections_selected_kind = kind
	_play_sound_cue("page_open")
	if collections_showcase_title_label != null:
		collections_showcase_title_label.text = "%s Model Viewer" % _piece_name(kind)
	if collections_showcase_subtitle_label != null:
		collections_showcase_subtitle_label.text = "Classic SIGMA Set · Classic SIGMA Pieces · Gold and Silver versions"
	if collections_showcase_note_label != null:
		collections_showcase_note_label.text = "%s belongs to the Classic SIGMA Set: official Classic Pieces plus the official Classic Board. The token uses owner metal, role accent, icon language, and centered alternating underglow." % _piece_name(kind)
	if collections_showcase_gold_preview != null:
		collections_showcase_gold_preview.texture = _classic_piece_texture(kind, SigmaRules.OWNER_P1)
	if collections_showcase_silver_preview != null:
		collections_showcase_silver_preview.texture = _classic_piece_texture(kind, SigmaRules.OWNER_P2)
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = true

func _close_collection_piece_showcase() -> void:
	_play_sound_cue("page_back")
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false

func _open_collection_vector_set_detail() -> void:
	_play_sound_cue("page_open")
	if collections_vector_set_detail_panel != null:
		collections_vector_set_detail_panel.visible = true
	_update_collections_panel()
	_apply_active_piece_set_to_board_views()

func _close_collection_vector_set_detail() -> void:
	_play_sound_cue("page_back")
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	if collections_vector_set_detail_panel != null:
		collections_vector_set_detail_panel.visible = false

func _open_collection_vector_board_detail() -> void:
	_play_sound_cue("page_open")
	if collections_vector_board_detail_panel != null:
		collections_vector_board_detail_panel.visible = true
	_update_collections_panel()

func _close_collection_vector_board_detail() -> void:
	_play_sound_cue("page_back")
	if collections_vector_board_detail_panel != null:
		collections_vector_board_detail_panel.visible = false

func _open_collection_vector_piece_showcase(kind: String) -> void:
	collections_selected_kind = kind
	_play_sound_cue("page_open")
	if collections_showcase_title_label != null:
		collections_showcase_title_label.text = "%s Obelisk Viewer" % _piece_name(kind)
	if collections_showcase_subtitle_label != null:
		collections_showcase_subtitle_label.text = "Obelisk Set · Onyx obelisk pieces · Gold and Silver variants"
	if collections_showcase_note_label != null:
		collections_showcase_note_label.text = "%s belongs to the Obelisk Set: black onyx obelisk body, neon laser-cut role lines, faceted metal trim, and the official Obelisk Board. This is visual only; rules do not change." % _piece_name(kind)
	if collections_showcase_gold_preview != null:
		collections_showcase_gold_preview.texture = _vector_piece_texture(kind, SigmaRules.OWNER_P1)
	if collections_showcase_silver_preview != null:
		collections_showcase_silver_preview.texture = _vector_piece_texture(kind, SigmaRules.OWNER_P2)
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = true


func _open_collection_draconian_set_detail() -> void:
	_play_sound_cue("page_open")
	if collections_draconian_set_detail_panel != null:
		collections_draconian_set_detail_panel.visible = true
	_update_collections_panel()
	_apply_active_piece_set_to_board_views()

func _close_collection_draconian_set_detail() -> void:
	_play_sound_cue("page_back")
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	if collections_draconian_set_detail_panel != null:
		collections_draconian_set_detail_panel.visible = false

func _open_collection_draconian_board_detail() -> void:
	_play_sound_cue("page_open")
	if collections_draconian_board_detail_panel != null:
		collections_draconian_board_detail_panel.visible = true
	_update_collections_panel()

func _close_collection_draconian_board_detail() -> void:
	_play_sound_cue("page_back")
	if collections_draconian_board_detail_panel != null:
		collections_draconian_board_detail_panel.visible = false

func _open_collection_draconian_piece_showcase(kind: String) -> void:
	collections_selected_kind = kind
	_play_sound_cue("page_open")
	if collections_showcase_title_label != null:
		collections_showcase_title_label.text = "%s Dragons Viewer" % _piece_name(kind)
	if collections_showcase_subtitle_label != null:
		collections_showcase_subtitle_label.text = "Dragons Set · Dragon pieces · Gold and Silver variants"
	if collections_showcase_note_label != null:
		collections_showcase_note_label.text = "%s belongs to the Dragons Set: dragon-inspired sculpted armor, colored flame aura, glowing eyes, and the official Dragons Board. This is visual only; rules do not change." % _piece_name(kind)
	if collections_showcase_gold_preview != null:
		collections_showcase_gold_preview.texture = _draconian_piece_texture(kind, SigmaRules.OWNER_P1)
	if collections_showcase_silver_preview != null:
		collections_showcase_silver_preview.texture = _draconian_piece_texture(kind, SigmaRules.OWNER_P2)
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = true

func _open_collection_lions_den_set_detail() -> void:
	_play_sound_cue("page_open")
	if collections_lions_den_set_detail_panel != null:
		collections_lions_den_set_detail_panel.visible = true
	_update_collections_panel()
	_apply_active_piece_set_to_board_views()

func _close_collection_lions_den_set_detail() -> void:
	_play_sound_cue("page_back")
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	if collections_lions_den_set_detail_panel != null:
		collections_lions_den_set_detail_panel.visible = false

func _open_collection_lions_den_board_detail() -> void:
	_play_sound_cue("page_open")
	if collections_lions_den_board_detail_panel != null:
		collections_lions_den_board_detail_panel.visible = true
	_update_collections_panel()

func _close_collection_lions_den_board_detail() -> void:
	_play_sound_cue("page_back")
	if collections_lions_den_board_detail_panel != null:
		collections_lions_den_board_detail_panel.visible = false

func _open_collection_lions_den_piece_showcase(kind: String) -> void:
	collections_selected_kind = kind
	_play_sound_cue("page_open")
	if collections_showcase_title_label != null:
		collections_showcase_title_label.text = "%s Lion's Den Viewer" % _piece_name(kind)
	if collections_showcase_subtitle_label != null:
		collections_showcase_subtitle_label.text = "Lion's Den Set · Regal lion pieces · Gold and Silver variants"
	if collections_showcase_note_label != null:
		collections_showcase_note_label.text = "%s belongs to the Lion's Den Set: royal lion sculpted armor, colorful mane-flame energy, glowing eyes, and the official Lion's Den Board. This is visual only; rules do not change." % _piece_name(kind)
	if collections_showcase_gold_preview != null:
		collections_showcase_gold_preview.texture = _lions_den_piece_texture(kind, SigmaRules.OWNER_P1)
	if collections_showcase_silver_preview != null:
		collections_showcase_silver_preview.texture = _lions_den_piece_texture(kind, SigmaRules.OWNER_P2)
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = true

func _on_collections_pressed() -> void:
	_play_collections_audio_scene()
	_play_sound_cue("page_open")
	_hide_app_overlays()
	if collections_panel != null:
		collections_panel.visible = true
	if collections_set_detail_panel != null:
		collections_set_detail_panel.visible = false
	if collections_board_detail_panel != null:
		collections_board_detail_panel.visible = false
	if collections_vector_set_detail_panel != null:
		collections_vector_set_detail_panel.visible = false
	if collections_vector_board_detail_panel != null:
		collections_vector_board_detail_panel.visible = false
	if collections_draconian_set_detail_panel != null:
		collections_draconian_set_detail_panel.visible = false
	if collections_draconian_board_detail_panel != null:
		collections_draconian_board_detail_panel.visible = false
	if collections_lions_den_set_detail_panel != null:
		collections_lions_den_set_detail_panel.visible = false
	if collections_lions_den_board_detail_panel != null:
		collections_lions_den_board_detail_panel.visible = false
	if collections_showcase_panel != null:
		collections_showcase_panel.visible = false
	_update_collections_panel()
	_apply_active_piece_set_to_board_views()

func _on_collections_set_classic_active() -> void:
	active_piece_set_id = PIECE_SET_CLASSIC_SIGMA
	active_board_theme_id = BOARD_THEME_CLASSIC_SIGMA
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_set_vector_active() -> void:
	active_piece_set_id = PIECE_SET_VECTOR
	active_board_theme_id = BOARD_THEME_VECTOR
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_set_draconian_active() -> void:
	active_piece_set_id = PIECE_SET_DRACONIAN
	active_board_theme_id = BOARD_THEME_DRACONIAN
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_board_classic_active() -> void:
	active_board_theme_id = BOARD_THEME_CLASSIC_SIGMA
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_board_vector_active() -> void:
	active_board_theme_id = BOARD_THEME_VECTOR
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_board_draconian_active() -> void:
	active_board_theme_id = BOARD_THEME_DRACONIAN
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")


func _on_collections_set_lions_den_active() -> void:
	active_piece_set_id = PIECE_SET_LIONS_DEN
	active_board_theme_id = BOARD_THEME_LIONS_DEN
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _on_collections_board_lions_den_active() -> void:
	active_board_theme_id = BOARD_THEME_LIONS_DEN
	_save_user_progress()
	_apply_active_piece_set_to_board_views()
	_update_collections_panel()
	_play_sound_cue("confirm")

func _active_full_set_name() -> String:
	if active_piece_set_id == PIECE_SET_LIONS_DEN and active_board_theme_id == BOARD_THEME_LIONS_DEN:
		return "Lion's Den Set"
	if active_piece_set_id == PIECE_SET_DRACONIAN and active_board_theme_id == BOARD_THEME_DRACONIAN:
		return "Dragons Set"
	if active_piece_set_id == PIECE_SET_VECTOR and active_board_theme_id == BOARD_THEME_VECTOR:
		return "Obelisk Set"
	return "Classic SIGMA Set"

func _active_pieces_set_name() -> String:
	if active_piece_set_id == PIECE_SET_LIONS_DEN:
		return "Lion's Den Pieces"
	if active_piece_set_id == PIECE_SET_DRACONIAN:
		return "Dragon Pieces"
	if active_piece_set_id == PIECE_SET_VECTOR:
		return "Obelisk Pieces"
	return "Classic SIGMA Tokens"

func _active_board_set_name() -> String:
	if active_board_theme_id == BOARD_THEME_LIONS_DEN:
		return "Lion's Den Board"
	if active_board_theme_id == BOARD_THEME_DRACONIAN:
		return "Dragons Board"
	if active_board_theme_id == BOARD_THEME_VECTOR:
		return "Obelisk Board"
	return "Classic SIGMA Board"

func _update_collections_panel() -> void:
	var active_set_name: String = _active_full_set_name()
	var active_pieces_name: String = _active_pieces_set_name()
	var active_board_name: String = _active_board_set_name()
	if collections_active_label != null:
		collections_active_label.text = "Active Piece Set: %s\nActive Board: %s" % [active_pieces_name, active_board_name]
	if collections_set_active_button != null:
		if active_piece_set_id == PIECE_SET_CLASSIC_SIGMA and active_board_theme_id == BOARD_THEME_CLASSIC_SIGMA:
			collections_set_active_button.text = "Classic Equipped"
			collections_set_active_button.disabled = true
		else:
			collections_set_active_button.text = "Equip Classic"
			collections_set_active_button.disabled = false
	if collections_status_label != null:
		collections_status_label.text = "Full Set: %s" % active_set_name

func _apply_active_piece_set_to_board_views() -> void:
	if active_piece_set_id != PIECE_SET_CLASSIC_SIGMA and active_piece_set_id != PIECE_SET_VECTOR and active_piece_set_id != PIECE_SET_DRACONIAN and active_piece_set_id != PIECE_SET_LIONS_DEN:
		active_piece_set_id = PIECE_SET_CLASSIC_SIGMA
	if active_board_theme_id != BOARD_THEME_CLASSIC_SIGMA and active_board_theme_id != BOARD_THEME_VECTOR and active_board_theme_id != BOARD_THEME_DRACONIAN and active_board_theme_id != BOARD_THEME_LIONS_DEN:
		active_board_theme_id = BOARD_THEME_CLASSIC_SIGMA
	if board_view != null:
		board_view.set_active_piece_set(active_piece_set_id)
		board_view.set_active_board_theme(active_board_theme_id)
	if menu_preview_board != null:
		menu_preview_board.set_active_piece_set(active_piece_set_id)
		menu_preview_board.set_active_board_theme(active_board_theme_id)

func _build_rules_guide_panel(parent: Control) -> void:
	rules_guide_panel = _make_center_panel("RulesGuidePanel", Vector2(560, 430))
	rules_guide_panel.visible = false
	parent.add_child(rules_guide_panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	rules_guide_panel.add_child(box)
	_add_top_right_close_button(box, "Close rules guide and return to Main Menu.", _on_rules_guide_close)
	rules_guide_title_label = Label.new()
	rules_guide_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules_guide_title_label.add_theme_font_size_override("font_size", 22)
	box.add_child(rules_guide_title_label)
	rules_guide_step_label = Label.new()
	rules_guide_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(rules_guide_step_label)
	rules_guide_snapshot_view = preload("res://scripts/RulesSnapshotView.gd").new()
	rules_guide_snapshot_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_guide_snapshot_view.custom_minimum_size = Vector2(0, 148)
	box.add_child(rules_guide_snapshot_view)
	rules_guide_body_label = Label.new()
	rules_guide_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules_guide_body_label.add_theme_font_size_override("font_size", 16)
	box.add_child(rules_guide_body_label)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	rules_guide_back_button = _add_button(row, "Back", "Previous rules page.", _on_rules_guide_back)
	rules_guide_next_button = _add_button(row, "Next", "Next rules page.", _on_rules_guide_next)

func _on_rules_guide_pressed() -> void:
	_play_menu_audio_scene("rules")
	_play_sound_cue("page_open")
	_hide_app_overlays()
	_show_menu_page_backdrop("rules")
	rules_guide_panel.visible = true
	_sync_board_input_lock()
	_update_rules_guide_panel()

func _on_rules_guide_next() -> void:
	if rules_guide_index < rules_guide_pages.size() - 1:
		rules_guide_index += 1
	_update_rules_guide_panel()

func _on_rules_guide_back() -> void:
	if rules_guide_index > 0:
		rules_guide_index -= 1
	_update_rules_guide_panel()

func _on_rules_guide_close() -> void:
	rules_guide_panel.visible = false
	_show_main_menu()

func _update_rules_guide_panel() -> void:
	if rules_guide_pages.is_empty():
		return
	var page: Dictionary = rules_guide_pages[rules_guide_index] as Dictionary
	rules_guide_title_label.text = String(page.get("title", "Rules Guide"))
	if rules_guide_snapshot_label != null:
		rules_guide_snapshot_label.text = ""
	if rules_guide_snapshot_view != null and rules_guide_snapshot_view.has_method("set_snapshot"):
		rules_guide_snapshot_view.call("set_snapshot", String(page.get("snapshot_id", "goal")))
	rules_guide_body_label.text = String(page.get("body", ""))
	rules_guide_step_label.text = "Page %d of %d" % [rules_guide_index + 1, rules_guide_pages.size()]
	if rules_guide_back_button != null:
		rules_guide_back_button.visible = true
		rules_guide_back_button.disabled = rules_guide_index <= 0
	if rules_guide_next_button != null:
		# Final Rules Guide page uses the top-right X plus Back only.
		rules_guide_next_button.visible = rules_guide_index < rules_guide_pages.size() - 1
		rules_guide_next_button.disabled = rules_guide_index >= rules_guide_pages.size() - 1

func _tutorial_phase_text(step: Dictionary, is_done: bool, has_practice: bool) -> String:
	if bool(step.get("finish", false)):
		return "Training complete · Welcome to SIGMA"
	if is_done:
		return "Mission Complete! ✓"
	if has_practice:
		return "Mini-game mission · hit the glowing target"
	return "Training card · review the token, then confirm"

func _tutorial_short_body(step: Dictionary) -> String:
	var body: String = String(step.get("body", ""))
	if body != "":
		return body
	var scenario: String = String(step.get("scenario", ""))
	var kind: String = String(step.get("kind", ""))
	if scenario == "tutorial_move_guardian":
		return "Guardian Drill! Move to the glowing square."
	if scenario == "tutorial_jump_capture":
		return "Jump-Capture! Leap over the enemy piece."
	if scenario == "tutorial_deploy":
		return "Deploy backup from your Reserve Guardian tray."
	if scenario == "tutorial_direct_peril":
		return "Create Peril by directly threatening the Monarch."
	if scenario == "tutorial_escape_peril":
		return "Escape Peril by moving your Monarch to safety."
	if scenario == "tutorial_surrender":
		return "Force Surrender by creating a threat with no escape."
	if scenario == "tutorial_retreat":
		return "Trigger Retreat by boxing in your own friendly piece."
	if scenario == "tutorial_elevate":
		return "Reach the enemy back row and Elevate."
	match kind:
		SigmaRules.KIND_MONARCH:
			return "Protect the Monarch. Pressure theirs."
		SigmaRules.KIND_GUARDIAN:
			return "Guardians hold the line."
		SigmaRules.KIND_SENTINEL:
			return "Sentinels watch every direction."
		SigmaRules.KIND_INFILTRATOR:
			return "Infiltrators slip through lanes."
		SigmaRules.KIND_ASSASSIN:
			return "Assassins strike diagonally."
		_:
			return "Complete the mission."

func _tutorial_body_text(step: Dictionary, is_done: bool) -> String:
	if tutorial_complete and tutorial_index >= tutorial_steps.size() - 1:
		return "Training Complete! You finished the SIGMA checklist.\n\nWelcome to SIGMA — the sum of every move."
	return _tutorial_short_body(step)

func _tutorial_demo_text(step: Dictionary) -> String:
	if bool(step.get("finish", false)):
		return "Training complete"
	if String(step.get("short", "")) == "Review":
		return "Final checkpoint"
	if String(step.get("scenario", "")) != "":
		return "Mission token"
	return "Token preview"

func _tutorial_progress_text() -> String:
	var dots: Array = []
	for i in range(tutorial_steps.size()):
		if tutorial_completed_steps.has(i):
			dots.append("●")
		elif i == tutorial_index:
			dots.append("◆")
		else:
			dots.append("○")
	return "Step %d/%d   %s" % [tutorial_index + 1, tutorial_steps.size(), " ".join(dots)]

func _tutorial_checklist_text() -> String:
	return ""

func _demo_grid_pos(col: int, row: int) -> Vector2:
	var cell_size: float = 30.0
	var gap: float = 5.0
	var cols: int = 5
	var rows: int = 4
	var total_w: float = float(cols) * cell_size + float(cols - 1) * gap
	var total_h: float = float(rows) * cell_size + float(rows - 1) * gap
	var origin_x: float = (500.0 - total_w) * 0.5
	var origin_y: float = (136.0 - total_h) * 0.5
	return Vector2(origin_x + float(col) * (cell_size + gap), origin_y + float(row) * (cell_size + gap))

func _clear_tutorial_demo_canvas() -> void:
	if tutorial_demo_tween != null:
		tutorial_demo_tween.kill()
		tutorial_demo_tween = null
	if tutorial_demo_canvas == null:
		return
	for child in tutorial_demo_canvas.get_children():
		child.queue_free()

func _tutorial_token_letter(kind: String) -> String:
	match kind:
		SigmaRules.KIND_MONARCH:
			return "M"
		SigmaRules.KIND_GUARDIAN:
			return "G"
		SigmaRules.KIND_SENTINEL:
			return "S"
		SigmaRules.KIND_INFILTRATOR:
			return "I"
		SigmaRules.KIND_ASSASSIN:
			return "A"
		_:
			return "G"

func _tutorial_token_fill_color(kind: String) -> Color:
	match kind:
		SigmaRules.KIND_MONARCH:
			return Color("#B33652")
		SigmaRules.KIND_GUARDIAN:
			return Color("#C78A1A")
		SigmaRules.KIND_SENTINEL:
			return Color("#20A8D8")
		SigmaRules.KIND_INFILTRATOR:
			return Color("#1A8E66")
		SigmaRules.KIND_ASSASSIN:
			return Color("#7A3FDB")
		_:
			return Color("#566C86")

func _tutorial_token_ring_color(kind: String) -> Color:
	match kind:
		SigmaRules.KIND_MONARCH:
			return Color("#F2C14E")
		SigmaRules.KIND_GUARDIAN:
			return Color("#FFE1A8")
		SigmaRules.KIND_SENTINEL:
			return Color("#9EE9FF")
		SigmaRules.KIND_INFILTRATOR:
			return Color("#97FFD5")
		SigmaRules.KIND_ASSASSIN:
			return Color("#D7B5FF")
		_:
			return Color("#D8E2F0")

func _tutorial_token_tagline(kind: String) -> String:
	match kind:
		SigmaRules.KIND_MONARCH:
			return "Protect it."
		SigmaRules.KIND_GUARDIAN:
			return "Core defender."
		SigmaRules.KIND_SENTINEL:
			return "Controls all adjacent space."
		SigmaRules.KIND_INFILTRATOR:
			return "Orthogonal ranger."
		SigmaRules.KIND_ASSASSIN:
			return "Diagonal striker."
		_:
			return "Practice piece."

func _animate_tutorial_demo() -> void:
	if tutorial_demo_canvas == null or tutorial_steps.is_empty():
		return
	_clear_tutorial_demo_canvas()

	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var kind: String = String(step.get("kind", SigmaRules.KIND_GUARDIAN))
	var piece_name: String = _piece_name(kind)
	# Official tutorial token preview: use the real Classic SIGMA piece art,
	# scaled down, so training matches the actual game pieces.
	var icon_size: float = 82.0
	var icon_x: float = (500.0 - icon_size) * 0.5
	var icon_y: float = 4.0

	var icon_shadow: PanelContainer = PanelContainer.new()
	icon_shadow.position = Vector2(icon_x + 0.0, icon_y + 7.0)
	icon_shadow.custom_minimum_size = Vector2(icon_size, icon_size)
	icon_shadow.size = Vector2(icon_size, icon_size)
	icon_shadow.add_theme_stylebox_override("panel", _make_rounded_style(Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 0, int(icon_size * 0.5)))
	tutorial_demo_canvas.add_child(icon_shadow)

	var icon: TextureRect = TextureRect.new()
	icon.position = Vector2(icon_x, icon_y)
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = _classic_piece_texture(kind, SigmaRules.OWNER_P1)
	tutorial_demo_canvas.add_child(icon)

	var name_label: Label = Label.new()
	name_label.text = "%s · %s" % [piece_name, _tutorial_token_tagline(kind)]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(0, 87)
	name_label.size = Vector2(500, 18)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	tutorial_demo_canvas.add_child(name_label)

func _tutorial_action_matches(action: Dictionary) -> bool:
	if tutorial_steps.is_empty():
		return true
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var expected_type: String = String(step.get("expected_type", ""))
	if expected_type != "" and String(action.get("type", "")) != expected_type:
		return false
	var expected_from: Vector2i = step.get("from", Vector2i(-1, -1))
	if expected_from.x >= 0 and action.get("from", Vector2i(-1, -1)) != expected_from:
		return false
	var expected_to: Vector2i = step.get("to", Vector2i(-1, -1))
	if expected_to.x >= 0 and action.get("to", Vector2i(-1, -1)) != expected_to:
		return false
	return true

func _tutorial_after_successful_action(action: Dictionary) -> void:
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	board_view.refresh()
	board_view.clear_tutorial_markers()
	if bool(step.get("requires_elevation", false)) and rules.has_pending_elevation():
		selection_label.text = "Correct move. Now choose an Elevate option."
		tutorial_feedback_label.text = String(step.get("success", "Choose an Elevate option."))
		_hide_tutorial_panel_for_board_action()
		return
	var good: bool = true
	var action_type: String = String(action.get("type", ""))
	if action_type == SigmaRules.ACTION_JUMP:
		good = int(rules.last_resolution.get("captures", 0)) > 0
	elif action_type == SigmaRules.ACTION_DEPLOY:
		good = true
	if String(step.get("scenario", "")) == "tutorial_direct_peril":
		good = rules.is_monarch_in_peril(SigmaRules.OWNER_P2)
	elif String(step.get("scenario", "")) == "tutorial_escape_peril":
		good = not rules.is_monarch_in_peril(SigmaRules.OWNER_P1)
	elif String(step.get("scenario", "")) == "tutorial_surrender":
		# Step 11 is a scripted training mission. If the player performs the
		# highlighted action, complete the lesson even if the full game-result
		# resolver does not report Surrender in this scenario lab position.
		good = _tutorial_action_matches(action)
		if not good:
			good = rules.game_over and (rules.ending == SigmaRules.END_SURRENDER or String(rules.ending).find("Surrender") >= 0 or String(rules.result_text).find("Surrender") >= 0)
	elif String(step.get("scenario", "")) == "tutorial_retreat":
		good = int(rules.last_resolution.get("friendly_retreats", 0)) > 0
	if good:
		_mark_tutorial_step_complete(String(step.get("success", "Good. Step complete.")))
	else:
		selection_label.text = "Action accepted, but this step did not produce the expected rule result. Use Undo and try again."
		tutorial_feedback_label.text = selection_label.text

func _tutorial_try_again_text() -> String:
	var step: Dictionary = tutorial_steps[tutorial_index] as Dictionary
	var from_pos: Vector2i = step.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = step.get("to", Vector2i(-1, -1))
	var expected_type: String = String(step.get("expected_type", "action"))
	var action_word: String = "action"
	match expected_type:
		SigmaRules.ACTION_MOVE:
			action_word = "move"
		SigmaRules.ACTION_JUMP:
			action_word = "jump-capture"
		SigmaRules.ACTION_DEPLOY:
			action_word = "Deploy"
		_:
			action_word = "action"
	if from_pos.x >= 0 and to_pos.x >= 0:
		return "Try the highlighted %s: r%d c%d to r%d c%d. Use the marked source and target." % [action_word, from_pos.x + 1, from_pos.y + 1, to_pos.x + 1, to_pos.y + 1]
	return "Try the highlighted tutorial action."

func _tutorial_loaded_text(step: Dictionary) -> String:
	var from_pos: Vector2i = step.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = step.get("to", Vector2i(-1, -1))
	if from_pos.x >= 0 and to_pos.x >= 0:
		return "Mission loaded! Use r%d c%d → r%d c%d." % [from_pos.x + 1, from_pos.y + 1, to_pos.x + 1, to_pos.y + 1]
	return "Mission loaded. Follow the glowing target."

func _mark_tutorial_step_complete(message: String) -> void:
	_play_sound_cue("tutorial_step_complete")
	tutorial_completed_steps[tutorial_index] = message
	tutorial_step_loaded = false
	selection_label.text = message
	tutorial_feedback_label.text = message
	if tutorial_completed_steps.size() >= tutorial_steps.size():
		tutorial_complete = true
		_save_user_progress()
		_play_sound_cue("tutorial_complete")
		tutorial_feedback_label.text = "Welcome to SIGMA!"
	_update_tutorial_panel()
	_animate_tutorial_demo()
	_show_tutorial_panel_after_step()

func _load_user_progress() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load("user://sigma_user.cfg")
	if err == OK:
		tutorial_complete = bool(cfg.get_value("progress", "tutorial_complete", false))
		turn_handoff_enabled = false
		board_flip_enabled = false
		tabletop_passplay_enabled = true
		active_piece_set_id = String(cfg.get_value("collections", "active_piece_set", PIECE_SET_CLASSIC_SIGMA))
		active_board_theme_id = String(cfg.get_value("collections", "active_board_theme", BOARD_THEME_CLASSIC_SIGMA))
	else:
		tutorial_complete = false
		turn_handoff_enabled = false
		board_flip_enabled = false
		tabletop_passplay_enabled = true
		active_piece_set_id = PIECE_SET_CLASSIC_SIGMA
		active_board_theme_id = BOARD_THEME_CLASSIC_SIGMA

func _save_user_progress() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("progress", "tutorial_complete", tutorial_complete)
	cfg.set_value("passplay", "turn_handoff_enabled", false)
	cfg.set_value("passplay", "board_flip_enabled", false)
	cfg.set_value("passplay", "tabletop_enabled", true)
	cfg.set_value("collections", "active_piece_set", active_piece_set_id)
	cfg.set_value("collections", "active_board_theme", active_board_theme_id)
	cfg.save("user://sigma_user.cfg")

func _configure_single_player_from_config(config: Dictionary) -> void:
	single_player_enabled = bool(config.get("single_player_ai", false))
	ai_side = int(config.get("ai_side", SigmaRules.OWNER_P2))
	human_side = int(config.get("human_side", SigmaRules.OWNER_P1))
	ai_difficulty = String(config.get("ai_difficulty", "Rookie"))
	ai_thinking = false
	ai_turn_queued = false
	turn_handoff_enabled = false
	board_flip_enabled = false
	tabletop_passplay_enabled = not single_player_enabled
	if single_player_enabled and turn_handoff_panel != null:
		turn_handoff_panel.visible = false
	if single_player_enabled and pause_cover_rect != null:
		pause_cover_rect.visible = false
	_update_tabletop_passplay_ui()

func _configure_speed_timer_from_config(config: Dictionary) -> void:
	speed_timer_enabled = bool(config.get("speed_sigma", false))
	speed_turn_seconds = int(config.get("turn_timer_seconds", 0))
	speed_total_turn_limit = int(config.get("turn_limit_total", 0))
	speed_time_left = float(speed_turn_seconds)

func _reset_speed_timer_for_turn() -> void:
	if speed_timer_enabled:
		speed_time_left = float(speed_turn_seconds)


func _start_resume_countdown() -> void:
	resume_countdown_active = true
	resume_countdown_left = 3.0
	_show_resume_countdown_text("3")
	_play_sound_cue("confirm")

func _update_resume_countdown(delta: float) -> void:
	if not resume_countdown_active:
		return
	resume_countdown_left -= delta
	if resume_countdown_left > 2.0:
		_show_resume_countdown_text("3")
	elif resume_countdown_left > 1.0:
		_show_resume_countdown_text("2")
	elif resume_countdown_left > 0.0:
		_show_resume_countdown_text("1")
	else:
		resume_countdown_active = false
		if event_word_label != null:
			event_word_label.visible = false
		selection_label.text = "%s to move." % rules.get_turn_name()
		_update_labels()

func _show_resume_countdown_text(text: String) -> void:
	if event_word_label == null:
		return
	event_word_label.text = text
	event_word_label.add_theme_color_override("font_color", Color("#F2C14E"))
	event_word_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	event_word_label.add_theme_constant_override("outline_size", 3)
	event_word_label.visible = true
	event_word_label.modulate = Color(1, 1, 1, 1)
	event_word_label.scale = Vector2.ONE

func _update_speed_timer(delta: float) -> void:
	if resume_countdown_active:
		return
	if not speed_timer_enabled:
		return
	if rules == null or rules.game_over or rules.has_pending_elevation():
		return
	if tutorial_active:
		return
	if main_menu_panel != null and main_menu_panel.visible:
		return
	if new_game_panel != null and new_game_panel.visible:
		return
	if custom_game_panel != null and custom_game_panel.visible:
		return
	if draft_panel != null and draft_panel.visible:
		return
	if settings_panel != null and settings_panel.visible:
		return
	if rules_guide_panel != null and rules_guide_panel.visible:
		return
	if session_panel != null and session_panel.visible:
		return
	if turn_handoff_panel != null and turn_handoff_panel.visible:
		return
	speed_time_left = max(0.0, speed_time_left - delta)
	if speed_time_left <= 0.0:
		_handle_speed_timeout()
	else:
		_update_floating_hud()
		_update_tabletop_passplay_ui()

func _handle_speed_timeout() -> void:
	if not speed_timer_enabled or rules == null or rules.game_over:
		return
	var timed_out_owner: int = rules.turn
	if rules.apply_turn_timeout():
		speed_time_left = float(max(1, rules.turn_timer_seconds))
		selection_label.text = "%s timer hit 0. Turn ends with no action." % rules.owner_name(timed_out_owner)
		_show_event_word("TURN ENDS!", "red")
		_play_sound_cue("cancel")
		if rules.game_over:
			_autosave_current_game("Match complete. Save cleared.")
		else:
			_autosave_current_game("Game saved")
			_show_turn_handoff_if_needed("timeout")
		_update_labels()


func _play_board_audio_scene() -> void:
	# Gameplay music is routed through the global single-stream AudioManager.
	# This replaces menu/tutorial/pause music instead of layering over it.
	AudioManager.play_game_music(true)
	_update_adaptive_board_music()
	call_deferred("_reassert_game_audio_context")

func _reassert_game_audio_context() -> void:
	# A few start flows close menu/setup pages after the first music call. Reassert
	# board-only music at the end of the frame so any late menu-page audio call is
	# killed before the player hears layered menu + game music.
	if not _is_active_game_context_visible():
		return
	AudioManager.enforce_game_music_exclusive()
	_update_adaptive_board_music()

func _is_active_game_context_visible() -> bool:
	if rules == null or tutorial_active:
		return false
	var menu_nodes: Array = [main_menu_panel, new_game_panel, custom_game_panel, draft_panel, tutorial_panel, rules_guide_panel, collections_panel, collections_set_detail_panel, collections_board_detail_panel, collections_showcase_panel, settings_panel]
	if menu_page_backdrop != null and menu_page_backdrop.visible:
		return false
	for node_value in menu_nodes:
		var canvas_item: CanvasItem = node_value as CanvasItem
		if canvas_item != null and canvas_item.visible:
			return false
	return true

func _play_menu_audio_scene(page_context: String = "main") -> void:
	# Menu music is routed through the global single-stream AudioManager.
	AudioManager.play_menu_music(page_context)

func _play_collections_audio_scene() -> void:
	AudioManager.play_menu_music("collections")

func _play_tutorial_audio_scene() -> void:
	AudioManager.play_menu_music("tutorial")

func _update_adaptive_board_music() -> void:
	if rules == null:
		return
	if tutorial_active:
		return
	var peril_active: bool = rules.is_monarch_in_peril(rules.turn)
	var timer_low: bool = speed_timer_enabled and speed_time_left <= 10.0
	AudioManager.update_board_music_progress(_estimated_turn_number(), int(rules.full_rounds), bool(rules.overtime), speed_timer_enabled, peril_active, timer_low)

func _play_resolution_audio(action_type: String) -> void:
	_play_sound_cue(_cue_for_action(action_type))
	var resolution: Dictionary = rules.last_resolution
	if int(resolution.get("enemy_surround_removed", 0)) > 0:
		_play_sound_cue("capture")
	if int(resolution.get("friendly_retreats", 0)) > 0 and _last_action_has_true_retreat():
		_play_sound_cue("retreat")
	if bool(resolution.get("pending_elevation", false)):
		_play_sound_cue("elevate")
	if rules.game_over:
		if rules.ending == SigmaRules.END_SURRENDER:
			_play_sound_cue("surrender")
		else:
			_play_sound_cue("game_result")
	elif rules.is_monarch_in_peril(rules.turn):
		_play_sound_cue("peril")

func _cue_for_action(action_type: String) -> String:
	match action_type:
		SigmaRules.ACTION_MOVE:
			return "move"
		SigmaRules.ACTION_JUMP:
			return "capture"
		SigmaRules.ACTION_DEPLOY:
			return "deploy"
		_:
			return "action"

func _play_sound_cue(cue: String) -> void:
	last_sound_cue = cue
	_trigger_haptic(cue)
	if sound_enabled:
		AudioManager.play_cue(cue)


func _overlay_blocks_board_input() -> bool:
	var blockers: Array = [
		main_menu_panel,
		new_game_panel,
		draft_panel,
		custom_game_panel,
		settings_panel,
		rules_guide_panel,
		collections_panel,
		collections_set_detail_panel,
		collections_board_detail_panel,
		collections_showcase_panel,
		session_panel,
		pause_cover_rect,
		turn_handoff_panel,
		new_game_confirm_panel,
		result_overlay,
		tutorial_backdrop_layer
	]
	for node_value in blockers:
		var item: CanvasItem = node_value as CanvasItem
		if item != null and item.visible:
			return true
	if menu_page_backdrop != null and menu_page_backdrop.visible:
		return true
	return false

func _can_board_accept_input() -> bool:
	if rules == null or board_view == null:
		return false
	if rules.game_over:
		return false
	if ai_thinking or _is_ai_turn_active():
		return false
	# Tutorial uses the live board only after a mission scenario is loaded and the
	# tutorial card has moved out of the way. A paused/saved match must never be
	# editable behind Tutorial, Main Menu, Pause, or other pages.
	if tutorial_active:
		if not tutorial_step_loaded:
			return false
		if tutorial_panel != null and tutorial_panel.visible:
			return false
		if tutorial_backdrop_layer != null and tutorial_backdrop_layer.visible:
			return false
		if _overlay_blocks_board_input():
			return false
		return true
	if _overlay_blocks_board_input():
		return false
	if rules.has_pending_elevation():
		return false
	return true

func _sync_board_input_lock() -> void:
	if board_view != null and board_view.has_method("set_board_input_enabled"):
		board_view.call("set_board_input_enabled", _can_board_accept_input())


func _update_labels() -> void:
	turn_banner.text = _turn_banner_text()
	status_label.text = rules.get_status_text()
	counts_label.text = rules.get_counts_text()
	_update_elevate_panel()
	_update_result_and_overlay()
	action_log_label.text = _action_log_text()
	scenario_label.text = rules.scenario_hint
	_update_mobile_hint()
	_update_save_status_label()
	_update_floating_hud()
	_update_action_buttons_state()
	_update_tabletop_passplay_ui()
	_update_board_flip()
	_update_adaptive_board_music()
	_sync_board_input_lock()
	_maybe_queue_ai_turn()


func _player_name(owner: int) -> String:
	return "Gold" if owner == SigmaRules.OWNER_P1 else "Silver"

func _active_marker(owner: int) -> String:
	if rules == null or rules.game_over:
		return " "
	return "▶" if rules.turn == owner else " "

func _turn_counter_text() -> String:
	if rules == null:
		return "Player Turn 1"
	return "Player Turn %d/%s" % [_estimated_turn_number(), _turn_limit_display()]

func _current_round_number() -> int:
	if rules == null:
		return 1
	return max(1, int(rules.full_rounds) + 1)

func _round_counter_text() -> String:
	if rules == null:
		return "Round 1"
	if bool(rules.overtime):
		return "Overtime %d/%d" % [int(rules.overtime_rounds) + 1, int(rules.overtime_round_limit)]
	return "Round %d/%d" % [_current_round_number(), int(rules.round_limit)]

func _speed_timer_value_text() -> String:
	if speed_time_left < 10.0 and speed_time_left > 0.0:
		return "%.1fs" % speed_time_left
	return "%ds" % int(ceil(speed_time_left))

func _global_timer_text() -> String:
	if rules == null or rules.game_over:
		return "Timer —"
	if speed_timer_enabled:
		return "Timer %s" % _speed_timer_value_text()
	return "Timer OFF"

func _estimated_turn_number() -> int:
	if rules == null:
		return 1
	var total_turns: int = int(rules.full_rounds) * 2
	if rules.turn == SigmaRules.OWNER_P2:
		total_turns += 1
	return max(1, total_turns + 1)

func _turn_limit_display() -> String:
	if speed_total_turn_limit > 0:
		return "%d" % int(speed_total_turn_limit)
	return "%d" % int(rules.turn_limit_total if rules != null else 200)

func _player_clock_text(owner: int) -> String:
	var round_text: String = _round_counter_text()
	if speed_timer_enabled and rules != null and not rules.game_over:
		if rules.turn == owner:
			return "%s · Timer %s" % [round_text, _speed_timer_value_text()]
		return "%s · Timer --" % round_text
	return "%s · Timer OFF" % round_text

func _player_clock_color(owner: int) -> Color:
	if rules == null:
		return Color("#E8EDF2")
	if speed_timer_enabled and rules.turn == owner and speed_time_left <= 5.0 and not rules.game_over:
		return Color("#E84A5F")
	if rules.turn == owner:
		return Color("#F2C14E") if owner == SigmaRules.OWNER_P1 else Color("#D8E2F0")
	return Color("#7A8796")

func _player_panel_text(owner: int) -> String:
	if rules == null:
		return "%s [empty]" % _player_name(owner)
	var removed: int = int(rules.removals[owner])
	var rack: String = _reserve_rack_text(owner)
	var display_name: String = _player_name(owner)
	if single_player_enabled and owner == ai_side:
		display_name = "%s · %s" % [_ai_display_name(), _player_name(owner)]
	elif single_player_enabled and owner != ai_side:
		display_name = "You · %s" % _player_name(owner)
	return "%s %s · %s  %s  Captures %d" % [_active_marker(owner), display_name, _player_clock_text(owner), rack, removed]

func _last_action_short_text() -> String:
	if rules == null or rules.last_resolution.is_empty():
		return "Last action: none"
	var parts: Array = []
	var captures: int = int(rules.last_resolution.get("captures", 0))
	var enemy_surround: int = int(rules.last_resolution.get("enemy_surround_removed", 0))
	var retreats: int = int(rules.last_resolution.get("friendly_retreats", 0))
	if String(rules.last_action.get("type", "")) == SigmaRules.ACTION_DEPLOY:
		parts.append("DEPLOY!")
	if captures > 0:
		parts.append("CAPTURE!")
	if enemy_surround > 0:
		parts.append("SURROUND!")
	if retreats > 0 and _last_action_has_true_retreat():
		parts.append("RETREAT!")
	if bool(rules.last_resolution.get("pending_elevation", false)):
		parts.append("ELEVATE!")
	if parts.is_empty():
		var messages: Variant = rules.last_resolution.get("messages", [])
		if messages is Array and not (messages as Array).is_empty():
			parts.append(String((messages as Array)[0]))
	if parts.is_empty():
		return "Last action: resolved"
	return "Last action: %s" % " ".join(parts)

func _reserve_rack_text(owner: int) -> String:
	if rules == null:
		return "[ ]"
	var count: int = int(rules.reserves[owner])
	var tiles: Array = []
	for i in range(count):
		tiles.append("[G]")
	if tiles.is_empty():
		return "[empty]"
	return "".join(tiles)


func _refresh_all_reserve_trays() -> void:
	if rules == null:
		return
	_refresh_reserve_rack_box(mobile_gold_rack_box, SigmaRules.OWNER_P1, rules.turn == SigmaRules.OWNER_P1 and not rules.game_over, 7, 30)
	_refresh_reserve_rack_box(mobile_silver_rack_box, SigmaRules.OWNER_P2, rules.turn == SigmaRules.OWNER_P2 and not rules.game_over, 6, 26)
	_refresh_tabletop_rack(SigmaRules.OWNER_P1, rules.turn == SigmaRules.OWNER_P1 and not rules.game_over and not rules.has_pending_elevation())
	_refresh_tabletop_rack(SigmaRules.OWNER_P2, rules.turn == SigmaRules.OWNER_P2 and not rules.game_over and not rules.has_pending_elevation())

func _update_floating_hud() -> void:
	if hud_turn_chip != null:
		var turn_text: String = _turn_banner_text()
		hud_turn_chip.text = turn_text
		hud_turn_chip.add_theme_color_override("font_color", Color("#E84A5F") if rules.is_monarch_in_peril(rules.turn) else Color("#F2C14E"))
	if hud_round_chip != null:
		hud_round_chip.text = _round_counter_text()
		hud_round_chip.add_theme_color_override("font_color", Color("#F2C14E") if not bool(rules.overtime) else Color("#E84A5F"))
	if hud_timer_chip != null:
		hud_timer_chip.text = _global_timer_text()
		if speed_timer_enabled and speed_time_left <= 5.0 and not rules.game_over:
			hud_timer_chip.add_theme_color_override("font_color", Color("#E84A5F"))
		else:
			hud_timer_chip.add_theme_color_override("font_color", Color("#E8EDF2"))
	if hud_mode_chip != null:
		if single_player_enabled:
			hud_mode_chip.text = String(current_match_config.get("mode_name", rules.mode_name))
		else:
			hud_mode_chip.text = String(rules.mode_name)
	if hud_gold_panel_label != null:
		if single_player_enabled:
			hud_gold_panel_label.text = "You · Gold"
		else:
			hud_gold_panel_label.text = _player_panel_text(SigmaRules.OWNER_P1)
		hud_gold_panel_label.add_theme_color_override("font_color", Color("#F2C14E") if rules.turn == SigmaRules.OWNER_P1 else Color("#7A8796"))
	if hud_silver_panel_label != null:
		if single_player_enabled:
			hud_silver_panel_label.text = "%s · Silver" % _ai_display_name()
		else:
			hud_silver_panel_label.text = _player_panel_text(SigmaRules.OWNER_P2)
		hud_silver_panel_label.add_theme_color_override("font_color", Color("#D8E2F0") if rules.turn == SigmaRules.OWNER_P2 else Color("#7A8796"))
	_refresh_all_reserve_trays()
	if hud_counts_chip != null:
		var overtime_text: String = ""
		if bool(rules.overtime):
			overtime_text = " · OT"
		hud_counts_chip.text = "Captures %d/%d%s" % [int(rules.removals[SigmaRules.OWNER_P1]), int(rules.removals[SigmaRules.OWNER_P2]), overtime_text]
	if hud_last_action_chip != null:
		hud_last_action_chip.text = _last_action_short_text()
	if hud_hint_chip != null:
		if _is_ai_turn_active() or ai_thinking:
			hud_hint_chip.text = "%s is calculating pathways..." % _ai_display_name()
		elif not pending_preview_action.is_empty():
			hud_hint_chip.text = "Action ready. Tap a legal space to commit your intent."
		elif rules.has_pending_elevation():
			hud_hint_chip.text = "ELEVATE! Choose Sentinel, Infiltrator, or Assassin."
		elif rules.is_monarch_in_peril(rules.turn):
			hud_hint_chip.text = "PERIL! Save your Monarch."
		elif board_view != null and board_view.deploy_mode:
			hud_hint_chip.text = "Deploy ON. Tap your piece, then a green space."
		elif single_player_enabled and rules.turn != ai_side:
			hud_hint_chip.text = "Your move. Build pressure without giving away captures."
		else:
			hud_hint_chip.text = "Your move, %s! Tap a piece." % rules.get_turn_name()

	_update_action_buttons_state()

func _update_action_buttons_state() -> void:
	var locked: bool = rules == null or rules.game_over or ai_thinking or _is_ai_turn_active() or (session_panel != null and session_panel.visible) or (main_menu_panel != null and main_menu_panel.visible)
	if deploy_button != null:
		deploy_button.disabled = locked or rules.has_pending_elevation()
	if undo_button != null:
		undo_button.disabled = locked
	if info_button != null:
		info_button.disabled = false
	if pause_button != null:
		pause_button.disabled = rules == null or rules.game_over


func _set_gameplay_chrome_visible(visible: bool) -> void:
	if not fullscreen_play_chrome:
		return
	var active_tabletop: bool = _is_tabletop_active_for_current_context()
	var chrome_nodes: Array = [title_label, turn_banner, status_label, counts_label, selection_label, result_label, mobile_hint_label, action_log_label, piece_help_label]
	for node_value in chrome_nodes:
		var node: CanvasItem = node_value as CanvasItem
		if node != null:
			node.visible = visible
	if top_controls_bar != null:
		top_controls_bar.visible = visible and not active_tabletop
	if bottom_controls_bar != null:
		bottom_controls_bar.visible = false
	if floating_hud_layer != null:
		floating_hud_layer.visible = (not visible) and not active_tabletop
	_update_tabletop_passplay_ui()

func _turn_banner_text() -> String:
	if ai_thinking and _is_ai_turn_active():
		return "%s Bot Thinking" % ai_difficulty
	if rules.game_over:
		return "Game Over — %s" % rules.ending
	if rules.has_pending_elevation():
		return "Elevate Guardian"
	if board_view != null and board_view.deploy_mode:
		return "%s Deploy Mode" % rules.get_turn_name()
	if rules.is_monarch_in_peril(rules.turn):
		return "%s Monarch in Peril" % rules.get_turn_name()
	return "%s Turn" % rules.get_turn_name()

func _result_headline_text() -> String:
	if rules == null:
		return "Match Complete"
	if rules.ending == SigmaRules.END_SURRENDER and rules.winner >= 0:
		var surrender_owner: int = SigmaRules.OWNER_P2 if rules.winner == SigmaRules.OWNER_P1 else SigmaRules.OWNER_P1
		return "%s Surrenders." % _player_name(surrender_owner)
	match rules.ending:
		SigmaRules.END_OVERTIME_CAPTURE:
			return "Overtime Capture."
		SigmaRules.END_CAPTURE_LEAD:
			return "Capture Lead."
		SigmaRules.END_FIRST_BLOOD:
			return "First Blood."
		SigmaRules.END_SURVIVAL:
			return "Survival Win."
		SigmaRules.END_SURROUND:
			return "Surround Win."
		SigmaRules.END_COLLAPSE:
			return "Collapse Win."
		SigmaRules.END_LOCKED_BOARD:
			return "Locked Board."
		_:
			return "Victory." if rules.winner >= 0 else "Match Complete"

func _result_winner_text() -> String:
	if rules == null:
		return ""
	if rules.winner == SigmaRules.OWNER_P1:
		return "Gold Wins!"
	if rules.winner == SigmaRules.OWNER_P2:
		return "Silver Wins!"
	return "Draw."

func _result_turns_text() -> String:
	if rules == null:
		return "Rounds: 0 · Player turns: 0"
	var turns_estimate: int = int(rules.full_rounds) * 2
	if rules.turn == SigmaRules.OWNER_P2 and not rules.game_over:
		turns_estimate += 1
	if turns_estimate <= 0 and not rules.last_action.is_empty():
		turns_estimate = 1
	return "Rounds: %d · Player turns: %d" % [int(rules.full_rounds), turns_estimate]

func _result_summary_text() -> String:
	# Keep the result screen player-facing and celebratory. Detailed debug-style
	# summaries do not belong in the in-game victory modal.
	return ""

func _result_overlay_text() -> String:
	var headline: String = _result_headline_text()
	var winner_text: String = _result_winner_text()
	if winner_text == "":
		return headline
	return "%s\n%s" % [headline, winner_text]

func _update_result_overlay_text() -> void:
	if result_overlay_label != null:
		result_overlay_label.text = _result_overlay_text()
	if result_summary_label != null:
		var summary_text: String = _result_summary_text()
		result_summary_label.text = summary_text
		result_summary_label.visible = summary_text != ""

func _on_result_rematch() -> void:
	_play_sound_cue("confirm")
	_clear_current_game_save()
	var config: Dictionary = current_match_config.duplicate(true)
	if config.is_empty():
		config = SigmaRules.full_config() if rules != null and rules.mode_name.find("Full SIGMA") >= 0 else SigmaRules.classic_config()
		if speed_timer_enabled:
			config = _apply_blitz_to_config(config)
	_start_custom_now(config)
	selection_label.text = "%s rematch! Gold to move." % String(config.get("mode_name", "SIGMA"))

func _on_result_new_game() -> void:
	_play_sound_cue("page_open")
	if result_overlay != null:
		result_overlay.visible = false
	_show_main_menu()
	_on_main_menu_new_game()

func _on_result_home() -> void:
	_play_sound_cue("page_open")
	if result_overlay != null:
		result_overlay.visible = false
	_show_main_menu()


func _update_result_and_overlay() -> void:
	if rules.game_over:
		result_label.text = _result_overlay_text().replace("\n", " ")
		if result_overlay != null:
			result_overlay.visible = true
			_update_result_overlay_text()
		return
	if result_overlay != null:
		result_overlay.visible = false
	var peril_text: String = ""
	if rules.is_monarch_in_peril(rules.turn):
		peril_text = " Peril: your next action must remove the direct threat."
	var deploy_text: String = ""
	if board_view != null and board_view.deploy_mode:
		deploy_text = " Deploy Mode ON: tap a friendly piece, then tap a green Deploy space."
	result_label.text = "Mode: %s.%s%s" % [rules.mode_name, peril_text, deploy_text]

func _update_mobile_hint() -> void:
	if rules.game_over:
		mobile_hint_label.text = "Open the menu to start a New Game, or review the result."
	elif not pending_preview_action.is_empty():
		mobile_hint_label.text = "Preview Mode: Confirm, Cancel, tap another legal action, or tap away to back out."
	elif rules.has_pending_elevation():
		mobile_hint_label.text = "Choose what your Guardian becomes. Advanced Cap = max 3 of each advanced piece on board."
	elif board_view != null and board_view.deploy_mode:
		mobile_hint_label.text = "Deploy Mode: tap a friendly piece first. Green spaces are legal Deploy spaces."
	elif rules.is_monarch_in_peril(rules.turn):
		mobile_hint_label.text = "Peril: remove the direct threat. Red line shows which enemy piece threatens your Monarch."
	else:
		mobile_hint_label.text = "Your move! Blue = move, red = capture, green = Deploy."

func _action_log_text() -> String:
	if rules.last_resolution.is_empty():
		return "Last action: none yet."
	var messages: Array = []
	var raw_messages: Variant = rules.last_resolution.get("messages", [])
	if raw_messages is Array:
		messages = raw_messages as Array
	var parts: Array = []
	for message_value in messages:
		parts.append(String(message_value))
	var extra: Array = []
	var captures: int = int(rules.last_resolution.get("captures", 0))
	var enemy_surround: int = int(rules.last_resolution.get("enemy_surround_removed", 0))
	var retreats: int = int(rules.last_resolution.get("friendly_retreats", 0))
	if String(rules.last_action.get("type", "")) == SigmaRules.ACTION_DEPLOY:
		parts.append("DEPLOY!")
	if captures > 0:
		extra.append("captures %d" % captures)
	if enemy_surround > 0:
		extra.append("enemy Surround removals %d" % enemy_surround)
	if retreats > 0:
		extra.append("Retreats %d" % retreats)
	if bool(rules.last_resolution.get("pending_elevation", false)):
		extra.append("Elevate choice pending")
	if not extra.is_empty():
		parts.append("(" + ", ".join(extra) + ")")
	if parts.is_empty():
		return "Last action resolved."
	var text: String = "Last action: " + " ".join(parts)
	if last_sound_cue != "":
		text += "  ·  SFX cue: " + last_sound_cue
	return text

func _piece_letter(kind: String) -> String:
	return kind

func _elevate_card_role(kind: String) -> String:
	match kind:
		SigmaRules.KIND_SENTINEL:
			return "blue"
		SigmaRules.KIND_INFILTRATOR:
			return "green"
		SigmaRules.KIND_ASSASSIN:
			return "violet"
		_:
			return "gold"

func _elevate_piece_rule(kind: String) -> String:
	match kind:
		SigmaRules.KIND_SENTINEL:
			return "1 space any direction"
		SigmaRules.KIND_INFILTRATOR:
			return "Up to 2 orthogonal\nOrthogonal capture"
		SigmaRules.KIND_ASSASSIN:
			return "Up to 2 diagonal\nDiagonal capture"
		_:
			return "Advanced piece"

func _elevate_card_text(kind: String, owner: int, available: bool) -> String:
	var count_on_board: int = rules.advanced_count_on_board(owner, kind)
	var cap_text: String = "%d/3 on board" % count_on_board
	if not available:
		return "%s\n%s\nCAP REACHED\n%s" % [_piece_letter(kind), _piece_name(kind), cap_text]
	return "%s\n%s\n%s\n%s" % [_piece_letter(kind), _piece_name(kind), _elevate_piece_rule(kind), cap_text]

func _layout_elevate_panel(owner: int) -> void:
	if elevate_panel == null:
		return
	var holder_w: float = board_holder_ref.size.x if board_holder_ref != null else get_viewport_rect().size.x
	var panel_w: float = min(540.0, max(340.0, holder_w - 36.0))
	var panel_h: float = 228.0
	_layout_player_prompt_panel(elevate_panel, owner, panel_w, panel_h, true)

func _force_show_elevate_prompt_if_pending() -> bool:
	if rules == null or not rules.has_pending_elevation():
		return false
	var owner: int = rules.get_pending_elevation_owner()
	if elevate_panel != null:
		elevate_panel.visible = true
		_layout_elevate_panel(owner)
	if preview_panel != null:
		preview_panel.visible = false
	if board_view != null:
		board_view.clear_action_preview()
	var owner_text: String = rules.owner_name(owner)
	selection_label.text = "ELEVATE! %s chooses an advanced piece." % owner_text
	_play_sound_cue("elevate")
	_show_event_word("ELEVATE!", "gold")
	return true

func _update_elevate_panel() -> void:
	var show_panel: bool = rules.has_pending_elevation()
	if elevate_panel != null:
		elevate_panel.visible = show_panel
	if not show_panel:
		return
	if preview_panel != null:
		preview_panel.visible = false
	var options: Array = rules.get_pending_elevation_options()
	var owner: int = rules.get_pending_elevation_owner()
	_layout_elevate_panel(owner)
	var owner_text: String = rules.owner_name(owner)
	if elevate_subtitle_label != null:
		elevate_subtitle_label.text = "%s Elevates! Choose your new advanced piece." % owner_text
	for kind_value in elevate_buttons.keys():
		var kind: String = String(kind_value)
		var button: Button = elevate_buttons[kind]
		var available: bool = options.has(kind)
		button.visible = true
		button.disabled = not available
		button.text = _elevate_card_text(kind, owner, available)
		button.tooltip_text = "Available: %s. Advanced Cap: max 3 of each advanced piece on board." % ("Yes" if available else "No — cap reached")




func _ai_display_name() -> String:
	return "%s Bot" % ai_difficulty

func _is_ai_turn_active() -> bool:
	if not single_player_enabled:
		return false
	if tutorial_active or ai_thinking:
		return single_player_enabled and rules != null and rules.turn == ai_side and ai_thinking
	if rules == null or rules.game_over or rules.has_pending_elevation():
		return false
	if main_menu_panel != null and main_menu_panel.visible:
		return false
	if new_game_panel != null and new_game_panel.visible:
		return false
	if custom_game_panel != null and custom_game_panel.visible:
		return false
	if draft_panel != null and draft_panel.visible:
		return false
	if settings_panel != null and settings_panel.visible:
		return false
	if rules_guide_panel != null and rules_guide_panel.visible:
		return false
	if collections_panel != null and collections_panel.visible:
		return false
	if session_panel != null and session_panel.visible:
		return false
	if turn_handoff_panel != null and turn_handoff_panel.visible:
		return false
	return rules.turn == ai_side

func _maybe_queue_ai_turn() -> void:
	if ai_turn_queued or ai_thinking:
		return
	if not _is_ai_turn_active():
		return
	ai_turn_queued = true
	call_deferred("_run_ai_turn")

func _ai_think_delay() -> float:
	match ai_difficulty:
		"Beginner":
			return 0.04
		"Rookie":
			return 0.06
		"Intermediate":
			return 0.08
		"Professional":
			return 0.32
		"Expert":
			return 0.52
		"Champion":
			return 0.72
		_:
			return 0.12

func _ai_post_player_animation_delay() -> float:
	# Rules resolve immediately, but the board animation is visual. Wait here so
	# lower-difficulty bots do not cut off the player's move/capture/Deploy animation.
	if rules == null:
		return 0.72
	var action_type: String = String(rules.last_action.get("type", ""))
	if action_type == SigmaRules.ACTION_JUMP:
		return 0.98
	if action_type == SigmaRules.ACTION_DEPLOY:
		return 0.88
	if bool(rules.last_resolution.get("pending_elevation", false)):
		return 1.12
	if int(rules.last_resolution.get("captures", 0)) > 0 or int(rules.last_resolution.get("enemy_surround_removed", 0)) > 0:
		return 0.98
	return 0.76

func _first_legal_ai_action() -> Dictionary:
	if rules == null or rules.game_over or rules.has_pending_elevation():
		return {}
	var actions: Array = rules.get_legal_actions_for_player(ai_side)
	for action_value in actions:
		var action: Dictionary = (action_value as Dictionary).duplicate(true)
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("ok", false)):
			return action
	return {}

func _run_ai_turn() -> void:
	ai_turn_queued = false
	if not _is_ai_turn_active():
		return
	# Animation handoff: let the human player's token motion/callout finish before
	# the AI preview/search starts. This preserves feedback without making low bots
	# feel like they are "thinking" longer.
	await get_tree().create_timer(_ai_post_player_animation_delay()).timeout
	if not _is_ai_turn_active():
		_update_labels()
		return
	ai_thinking = true
	selection_label.text = "%s is calculating pathways..." % _ai_display_name()
	_update_action_buttons_state()
	_update_tabletop_passplay_ui()
	await get_tree().create_timer(_ai_think_delay()).timeout
	if not _is_ai_turn_active():
		ai_thinking = false
		_update_labels()
		return
	# Let the "thinking" UI paint before the synchronous offline search starts.
	await get_tree().process_frame
	var action: Dictionary = {}
	if ai_engine != null:
		action = ai_engine.choose_action(rules, ai_side, ai_difficulty)
	if action.is_empty():
		action = _first_legal_ai_action()
	if action.is_empty():
		ai_thinking = false
		selection_label.text = "%s found no legal action." % _ai_display_name()
		_update_labels()
		return
	var action_type: String = String(action.get("type", ""))
	var preview: Dictionary = rules.preview_action(action)
	if not bool(preview.get("ok", false)):
		ai_thinking = false
		selection_label.text = "%s attempted an illegal pathway and passed control back." % _ai_display_name()
		_play_sound_cue("illegal")
		_update_labels()
		return
	if board_view != null:
		board_view.set_action_preview(action, preview)
	_play_sound_cue("preview")
	await get_tree().create_timer(0.18).timeout
	if not _is_ai_turn_active():
		ai_thinking = false
		_clear_preview_state(true)
		_update_labels()
		return
	if board_view != null:
		board_view.clear_action_preview()
	if rules.apply_action(action):
		_refresh_all_reserve_trays()
		_play_resolution_audio(action_type)
		_show_resolution_event_word(action_type, int(action.get("owner", -1)))
		_play_coin_motion_for_action(action, action_type)
		_set_deploy_mode(false)
		if rules.has_pending_elevation() and rules.get_pending_elevation_owner() == ai_side:
			var elevation_kind: String = ai_engine.choose_elevation(rules, ai_side, ai_difficulty)
			if elevation_kind != "" and rules.choose_pending_elevation(elevation_kind):
				_play_sound_cue("elevate")
				_show_event_word("LEVEL UP", "silver")
		if rules.has_pending_elevation():
			_force_show_elevate_prompt_if_pending()
		else:
			_reset_speed_timer_for_turn()
		if board_view != null:
			board_view.refresh()
		selection_label.text = "%s played. %s to move." % [_ai_display_name(), rules.get_turn_name()]
		_autosave_current_game("Game saved")
	else:
		selection_label.text = "%s could not complete the selected pathway." % _ai_display_name()
		_play_sound_cue("illegal")
	ai_thinking = false
	_update_labels()

func _piece_help_text(kind: String) -> String:
	match kind:
		SigmaRules.KIND_MONARCH:
			return "Monarch: moves 1 space in any direction. May jump-capture enemy non-Monarch pieces. Monarchs are not captured or removed; if directly threatened with no legal escape, they Surrender."
		SigmaRules.KIND_GUARDIAN:
			return "Guardian: moves 1 space orthogonally and jump-captures orthogonally. A Guardian reaching the enemy back row may Elevate. Elevation respects max 3 of each advanced piece on board."
		SigmaRules.KIND_SENTINEL:
			return "Sentinel: moves 1 space in any direction and jump-captures in any direction. Does not Elevate."
		SigmaRules.KIND_INFILTRATOR:
			return "Infiltrator: moves 1 or 2 spaces orthogonally through clear spaces. A clear first orthogonal space can line up an orthogonal jump-capture — no diagonal or L-shaped captures."
		SigmaRules.KIND_ASSASSIN:
			return "Assassin: moves 1 or 2 spaces diagonally through clear spaces. A clear first diagonal space can line up a diagonal jump-capture — no orthogonal or L-shaped captures."
		_:
			return "Piece Guide: Guardian = orthogonal. Sentinel = any direction. Infiltrator = orthogonal ranger. Assassin = diagonal ranger. Monarchs surrender. Advanced Cap counts on-board pieces only."

func _piece_name(kind: String) -> String:
	match kind:
		SigmaRules.KIND_MONARCH:
			return "Monarch"
		SigmaRules.KIND_GUARDIAN:
			return "Guardian"
		SigmaRules.KIND_SENTINEL:
			return "Sentinel"
		SigmaRules.KIND_INFILTRATOR:
			return "Infiltrator"
		SigmaRules.KIND_ASSASSIN:
			return "Assassin"
		_:
			return kind
