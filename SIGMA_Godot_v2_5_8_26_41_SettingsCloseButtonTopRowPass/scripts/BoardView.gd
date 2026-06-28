extends Control
class_name BoardView

signal action_chosen(action: Dictionary)
signal selection_changed(text: String)
signal piece_focus_changed(kind: String, owner: int, pos: Vector2i)
signal preview_cancel_requested(text: String)
signal info_requested(kind: String, owner: int, pos: Vector2i)
signal deploy_mode_requested(value: bool)

const BOARD_SIZE := 9

var rules: SigmaRules
var selected: Vector2i = Vector2i(-1, -1)
var legal_actions: Array = []
var no_cycle_blocked_actions: Array = []
var deploy_mode: bool = false
var board_input_enabled: bool = true
var board_rect: Rect2 = Rect2()
var cell_size: float = 64.0

var color_bg: Color = Color("#06101F")
var color_bg_panel: Color = Color("#172A4A")
var color_board_edge: Color = Color("#F2C14E")
var color_cell_light: Color = Color("#18283A")
var color_cell_dark: Color = Color("#071827")
var color_cell_center: Color = Color("#F2C14E")
var color_gold: Color = Color("#F2C14E")
var color_gold_shadow: Color = Color("#8A6414")
var color_silver: Color = Color("#E8EDF2")
var color_silver_shadow: Color = Color("#9CA3AF")
var color_p1_text: Color = Color("#111827")
var color_p2_text: Color = Color("#111827")
var color_select: Color = Color("#28E0FF")
var color_move: Color = Color("#28E0FF")
var color_jump: Color = Color("#E84A5F")
var color_deploy: Color = Color("#22C55E")
var color_peril: Color = Color("#E84A5F")
var color_last: Color = Color("#7C3AED")
var color_elevate: Color = Color("#F2C14E")

# Official Classic SIGMA Tokens — presentation layer only.
# Gold Player 1 uses each role's Main accent. Silver Player 2 uses each role's Alternate accent.
# Owner metal (Gold/Silver) communicates side ownership; role accent identifies piece type.
const ROLE_COLOR_MONARCH_GOLD := Color("#E11D48") # Ruby Red
const ROLE_COLOR_MONARCH_SILVER := Color("#7C3AED") # Royal Purple
const ROLE_COLOR_GUARDIAN_GOLD := Color("#F8FAFC") # Pearl Steel
const ROLE_COLOR_GUARDIAN_SILVER := Color("#050A12") # Obsidian
const ROLE_COLOR_SENTINEL_GOLD := Color("#00A3FF") # Electric Blue
const ROLE_COLOR_SENTINEL_SILVER := Color("#14F1E5") # Bright Teal
const ROLE_COLOR_INFILTRATOR_GOLD := Color("#A3FF12") # Neon Lime
const ROLE_COLOR_INFILTRATOR_SILVER := Color("#047857") # Deep Emerald
const ROLE_COLOR_ASSASSIN_GOLD := Color("#FF7A18") # Ember Orange
const ROLE_COLOR_ASSASSIN_SILVER := Color("#FFD84D") # Solar Yellow

const PIECE_SET_CLASSIC_SIGMA := "classic_sigma_tokens"
const PIECE_SET_VECTOR := "vector_obelisks"
const PIECE_SET_DRACONIAN := "draconian"
const PIECE_SET_LIONS_DEN := "lions_den"
const BOARD_THEME_CLASSIC_SIGMA := "classic_sigma_board"
const BOARD_THEME_VECTOR := "vector_board"
const BOARD_THEME_DRACONIAN := "draconian_board"
const BOARD_THEME_LIONS_DEN := "lions_den_board"
const CLASSIC_TEXTURE_BASE := "res://assets/pieces/classic_sigma_tokens/"
const VECTOR_TEXTURE_BASE := "res://assets/pieces/vector_obelisks/"
const DRACONIAN_TEXTURE_BASE := "res://assets/pieces/draconian/"
const LIONS_DEN_TEXTURE_BASE := "res://assets/pieces/lions_den/"
var active_piece_set: String = PIECE_SET_CLASSIC_SIGMA
var active_board_theme: String = BOARD_THEME_CLASSIC_SIGMA
var token_textures: Dictionary = {}
var token_visual_offsets: Dictionary = {}

var tutorial_from: Vector2i = Vector2i(-1, -1)
var tutorial_to: Vector2i = Vector2i(-1, -1)
var tutorial_note: String = ""
var preview_action: Dictionary = {}
var preview_result: Dictionary = {}
var illegal_marker: Vector2i = Vector2i(-1, -1)
var illegal_major: bool = false
var illegal_message: String = ""
var living_preview_mode: bool = false
var tabletop_arena_mode: bool = false
var living_preview_style: String = ""
var token_preview_mode: bool = false
var token_preview_kind: String = SigmaRules.KIND_GUARDIAN
var token_preview_owner: int = SigmaRules.OWNER_P1
var press_cell: Vector2i = Vector2i(-1, -1)
var press_start_msec: int = 0
var press_start_pos: Vector2 = Vector2.ZERO
var last_touch_release_msec: int = -100000
var last_touch_release_cell: Vector2i = Vector2i(-99, -99)
var touch_mouse_debounce_msec: int = 260
var long_press_msec: int = 460
var quick_piece_tap_chain_msec: int = 440
var last_piece_tap_cell: Vector2i = Vector2i(-99, -99)
var last_piece_tap_msec: int = -100000
var same_piece_tap_count: int = 0
var board_flipped: bool = false

# v1.1.23 premium token-motion state. This is visual only; rules resolve immediately,
# then BoardView temporarily hides the final token and draws a casino-chip style
# lift/arc/drop overlay.
var coin_motion_active: bool = false
var coin_motion_kind: String = ""
var coin_motion_owner: int = -1
var coin_motion_from: Vector2i = Vector2i(-1, -1)
var coin_motion_to: Vector2i = Vector2i(-1, -1)
var coin_motion_type: String = "move"
var coin_motion_start_msec: int = 0
var coin_motion_duration_msec: int = 420
var coin_motion_impact_flash: float = 0.0
var cinematic_motion_seed: int = 0

const CINEMATIC_MOVE_MS := 660
const CINEMATIC_CAPTURE_MS := 860
const CINEMATIC_DEPLOY_MS := 760
const CINEMATIC_ELEVATE_MS := 1080

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(360, 360)
	_load_classic_token_textures()
	set_process(true)

func _process(_delta: float) -> void:
	# Classic SIGMA Tokens use a subtle idle underglow pulse, so active boards
	# redraw continuously. The v2.5.8.26.32 main-menu static display opts out
	# so the landing preview stays calm and does not animate its center tile.
	var needs_idle_redraw: bool = token_preview_mode or coin_motion_active or selected.x >= 0 or deploy_mode or _current_turn_in_peril() or not preview_action.is_empty() or illegal_marker.x >= 0
	if rules != null and not (living_preview_mode and living_preview_style == "static_display"):
		needs_idle_redraw = true
	if living_preview_mode and living_preview_style != "static_display":
		needs_idle_redraw = true
	if needs_idle_redraw:
		queue_redraw()

func set_rules(r: SigmaRules) -> void:
	rules = r
	_clear_selection()
	queue_redraw()

func set_active_piece_set(set_id: String) -> void:
	active_piece_set = set_id if not set_id.is_empty() else PIECE_SET_CLASSIC_SIGMA
	if active_piece_set != PIECE_SET_CLASSIC_SIGMA and active_piece_set != PIECE_SET_VECTOR and active_piece_set != PIECE_SET_DRACONIAN and active_piece_set != PIECE_SET_LIONS_DEN:
		active_piece_set = PIECE_SET_CLASSIC_SIGMA
	if active_piece_set == PIECE_SET_CLASSIC_SIGMA:
		_load_token_textures_for_set(PIECE_SET_CLASSIC_SIGMA)
	elif active_piece_set == PIECE_SET_VECTOR:
		_load_token_textures_for_set(PIECE_SET_VECTOR)
	elif active_piece_set == PIECE_SET_DRACONIAN:
		_load_token_textures_for_set(PIECE_SET_DRACONIAN)
	elif active_piece_set == PIECE_SET_LIONS_DEN:
		_load_token_textures_for_set(PIECE_SET_LIONS_DEN)
	queue_redraw()

func set_active_board_theme(theme_id: String) -> void:
	active_board_theme = theme_id if not theme_id.is_empty() else BOARD_THEME_CLASSIC_SIGMA
	if active_board_theme != BOARD_THEME_CLASSIC_SIGMA and active_board_theme != BOARD_THEME_VECTOR and active_board_theme != BOARD_THEME_DRACONIAN and active_board_theme != BOARD_THEME_LIONS_DEN:
		active_board_theme = BOARD_THEME_CLASSIC_SIGMA
	queue_redraw()

func _load_classic_token_textures() -> void:
	_load_token_textures_for_set(PIECE_SET_CLASSIC_SIGMA)

func _load_token_textures_for_set(set_id: String) -> void:
	var base_path: String = _token_texture_base_for_set(set_id)
	if base_path.is_empty():
		return
	var owners: Dictionary = {SigmaRules.OWNER_P1: "gold", SigmaRules.OWNER_P2: "silver"}
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	var names: Dictionary = {
		SigmaRules.KIND_MONARCH: "monarch",
		SigmaRules.KIND_GUARDIAN: "guardian",
		SigmaRules.KIND_SENTINEL: "sentinel",
		SigmaRules.KIND_INFILTRATOR: "infiltrator",
		SigmaRules.KIND_ASSASSIN: "assassin",
	}
	for owner_value in owners.keys():
		for kind_value in kinds:
			var key: String = _token_texture_key_for_set(set_id, String(kind_value), int(owner_value))
			if token_textures.has(key):
				continue
			var path: String = "%s%s_%s.png" % [base_path, owners[owner_value], names[kind_value]]
			if ResourceLoader.exists(path):
				var texture: Texture2D = load(path) as Texture2D
				if texture != null:
					token_textures[key] = texture
					token_visual_offsets[key] = _compute_texture_visual_offset(texture)

func _compute_texture_visual_offset(texture: Texture2D) -> Vector2:
	if texture == null:
		return Vector2.ZERO
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return Vector2.ZERO

	var width: int = image.get_width()
	var height: int = image.get_height()
	var min_x: int = width
	var min_y: int = height
	var max_x: int = -1
	var max_y: int = -1

	for y in range(height):
		for x in range(width):
			var a: float = image.get_pixel(x, y).a
			# Ignore ultra-faint antialiasing and shadow falloff.
			if a > 0.12:
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x < 0 or max_y < 0:
		return Vector2.ZERO

	var image_center: Vector2 = Vector2(width * 0.5, height * 0.5)
	var visible_center: Vector2 = Vector2((float(min_x + max_x + 1) * 0.5), (float(min_y + max_y + 1) * 0.5))
	var offset: Vector2 = image_center - visible_center

	# Prevent overcorrection while still fixing visibly off-center art.
	offset.x = clamp(offset.x, -width * 0.08, width * 0.08)
	offset.y = clamp(offset.y, -height * 0.08, height * 0.08)
	return offset

func _token_texture_base_for_set(set_id: String) -> String:
	match set_id:
		PIECE_SET_CLASSIC_SIGMA:
			return CLASSIC_TEXTURE_BASE
		PIECE_SET_VECTOR:
			return VECTOR_TEXTURE_BASE
		PIECE_SET_DRACONIAN:
			return DRACONIAN_TEXTURE_BASE
		PIECE_SET_LIONS_DEN:
			return LIONS_DEN_TEXTURE_BASE
		_:
			return ""

func _token_texture_key(kind: String, owner: int) -> String:
	return _token_texture_key_for_set(active_piece_set, kind, owner)

func _token_texture_key_for_set(set_id: String, kind: String, owner: int) -> String:
	return "%s|%d:%s" % [set_id, owner, kind]

func _draw_flat_ground_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	# CanvasItem has crisp filled circles, so this helper compresses that shape
	# into a low-profile contact ellipse. It keeps the premium table-shadow
	# feeling without creating the visible gray circular/rectangular slab that
	# appeared behind transparent piece art.
	if radius_x <= 0.0 or radius_y <= 0.0 or color.a <= 0.0:
		return
	draw_set_transform(center, 0.0, Vector2(radius_x, radius_y))
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_texture_piece_ground_fx(glow_center: Vector2, radius: float, alternating_glow: Color, accent: Color, owner_glow: Color, pulse: float, lift: float, moving: bool, selected_piece: bool) -> void:
	# v2.5.8.13: restore the exciting full idle pulse from v2.5.8.7,
	# but keep the v2.5.8.12 strip fix. All full pulses are colored
	# Gold/Silver <-> piece accent and are drawn before the texture. No
	# gray/white post-draw rim or rear halo is used.
	var floor_center: Vector2 = glow_center + Vector2(0, radius * (0.56 + lift * 0.08))
	var lower_center: Vector2 = glow_center + Vector2(0, radius * (0.42 + lift * 0.04))
	var shadow_alpha: float = 0.20 if not moving else 0.14

	# Clean contact shadow only. This gives weight without creating a visible
	# rectangle or top strip.
	_draw_flat_ground_ellipse(
		floor_center,
		radius * (0.70 - lift * 0.04),
		radius * (0.130 - lift * 0.010),
		Color(0, 0, 0, shadow_alpha)
	)
	_draw_flat_ground_ellipse(
		floor_center + Vector2(0, radius * 0.055),
		radius * 0.46,
		radius * 0.052,
		Color(0, 0, 0, shadow_alpha * 0.30)
	)

	# Full alternating owner/accent pulse. This is the old premium feel, but it
	# stays colored and behind the piece. Gold pieces breathe Gold <-> role
	# accent; Silver pieces breathe Silver <-> role accent.
	var pulse_strength: float = 0.55 + pulse * 0.45
	draw_circle(
		glow_center,
		radius * (1.12 + pulse * 0.10),
		_with_alpha(alternating_glow.lightened(0.10), 0.090 + pulse * 0.050)
	)
	draw_circle(
		glow_center,
		radius * (0.88 + pulse * 0.070),
		_with_alpha(alternating_glow.lightened(0.18), 0.115 + pulse * 0.065)
	)
	draw_arc(
		glow_center,
		radius * (1.05 + pulse * 0.070),
		0.0,
		TAU,
		72,
		_with_alpha(alternating_glow.lightened(0.12), 0.28 + pulse * 0.12),
		2.0
	)
	draw_arc(
		glow_center,
		radius * (1.20 + pulse * 0.050),
		0.0,
		TAU,
		72,
		_with_alpha(owner_glow, 0.12 + (1.0 - pulse) * 0.08),
		1.4
	)

	# Keep the lower board-contact rails for the premium tabletop energy feel.
	_draw_flat_ground_ellipse(
		floor_center,
		radius * (0.84 + pulse * 0.05),
		radius * (0.070 + pulse * 0.018),
		_with_alpha(alternating_glow.lightened(0.10), (0.18 + pulse * 0.10) * 0.34)
	)
	_draw_flat_ground_ellipse(
		floor_center + Vector2(0, radius * 0.035),
		radius * (0.54 + pulse * 0.04),
		radius * (0.038 + pulse * 0.010),
		_with_alpha(accent.lightened(0.20), 0.10 + pulse * 0.06)
	)

	draw_arc(lower_center, radius * (0.84 + pulse * 0.045), PI * 0.15, PI * 0.85, 48, _with_alpha(alternating_glow, 0.20 + pulse * 0.10), 2.0)
	draw_arc(lower_center, radius * (0.58 + pulse * 0.030), PI * 0.22, PI * 0.78, 36, _with_alpha(accent.lightened(0.16), 0.12 + pulse * 0.07), 1.2)

	for i in range(4):
		var t: float = float(i) / 3.0
		var angle: float = lerp(PI * 0.20, PI * 0.80, t)
		var tick_r: float = radius * (0.76 + pulse * 0.035)
		var p: Vector2 = lower_center + Vector2(cos(angle), sin(angle)) * tick_r
		var tangent: Vector2 = Vector2(-sin(angle), cos(angle))
		var tick_len: float = radius * (0.045 + 0.012 * sin((pulse + t) * TAU))
		draw_line(p - tangent * tick_len, p + tangent * tick_len, _with_alpha(accent.lightened(0.22), 0.16 + pulse * 0.08), 1.1)

	if selected_piece:
		draw_arc(glow_center, radius * (1.18 + pulse * 0.04), 0.0, TAU, 72, _with_alpha(accent.lightened(0.18), 0.58), 2.6)
		draw_arc(glow_center, radius * (1.31 + pulse * 0.05), 0.0, TAU, 72, _with_alpha(owner_glow, 0.24), 1.8)

	if moving:
		draw_arc(glow_center, radius * (1.22 + lift * 0.08), 0.0, TAU, 72, _with_alpha(alternating_glow, 0.30), 2.4)
		_draw_flat_ground_ellipse(floor_center, radius * 0.74, radius * 0.070, _with_alpha(accent.lightened(0.22), 0.18))

func _draw_texture_token_for_set(set_id: String, center: Vector2, radius: float, kind: String, owner: int, lift: float = 0.0, tilt: float = 0.0, moving: bool = false, selected_piece: bool = false) -> bool:
	_load_token_textures_for_set(set_id)
	var key: String = _token_texture_key_for_set(set_id, kind, owner)
	if not token_textures.has(key):
		return false
	var texture: Texture2D = token_textures[key] as Texture2D
	if texture == null:
		return false

	var accent: Color = _role_accent_for_kind(kind, owner)
	var owner_glow: Color = _owner_glow_for_owner(owner)
	var pulse: float = _pulse_value()
	var alternating_glow: Color = _alternating_underglow_color(kind, owner, pulse)
	var lift_offset: Vector2 = Vector2(0, -radius * 0.08 * lift)

	var visual_scale: float = 2.42
	if set_id == PIECE_SET_VECTOR:
		visual_scale = 2.58
	elif set_id == PIECE_SET_DRACONIAN:
		visual_scale = 2.68
	elif set_id == PIECE_SET_LIONS_DEN:
		visual_scale = 2.72
	var visual_size: float = radius * visual_scale
	var rect: Rect2 = Rect2(Vector2(-visual_size * 0.5, -visual_size * 0.5), Vector2(visual_size, visual_size))
	var rotation: float = _owner_face_rotation(owner) + (tilt if moving else 0.0)

	var local_offset_px: Vector2 = token_visual_offsets.get(key, Vector2.ZERO)
	var texture_reference_size: float = max(float(texture.get_width()), float(texture.get_height()))
	var scaled_offset: Vector2 = Vector2.ZERO
	if texture_reference_size > 0.0:
		scaled_offset = (local_offset_px * (visual_size / texture_reference_size)).rotated(rotation)

	# Keep the piece texture centering from v2.5.8.14, but tune the ground FX
	# pulse center by piece set. Draconian collection pieces read a little too far
	# right in the showcase/live preview, so give them a small left correction.
	var token_center: Vector2 = center + scaled_offset + lift_offset
	var pulse_shift_x: float = radius * 0.18
	if active_piece_set == PIECE_SET_DRACONIAN:
		pulse_shift_x -= radius * 0.15
	elif active_piece_set == PIECE_SET_VECTOR:
		# Extra micro-nudge left for the Obelisk showcase pulse so it centers better behind the piece.
		pulse_shift_x -= radius * 0.10
	if kind == SigmaRules.KIND_GUARDIAN:
		pulse_shift_x -= radius * 0.03
	var pulse_center: Vector2 = center + scaled_offset + Vector2(pulse_shift_x, 0.0)

	_draw_texture_piece_ground_fx(pulse_center, radius, alternating_glow, accent, owner_glow, pulse, lift, moving, selected_piece)

	draw_set_transform(token_center, rotation, Vector2.ONE)
	draw_texture_rect(texture, rect, false, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func _draw_classic_texture_token(center: Vector2, radius: float, kind: String, owner: int, lift: float = 0.0, tilt: float = 0.0, moving: bool = false, selected_piece: bool = false) -> bool:
	if active_piece_set != PIECE_SET_CLASSIC_SIGMA:
		return false
	return _draw_texture_token_for_set(PIECE_SET_CLASSIC_SIGMA, center, radius, kind, owner, lift, tilt, moving, selected_piece)

func refresh() -> void:
	_reset_piece_tap_chain()
	legal_actions.clear()
	no_cycle_blocked_actions.clear()
	selected = Vector2i(-1, -1)
	preview_action = {}
	preview_result = {}
	illegal_marker = Vector2i(-1, -1)
	piece_focus_changed.emit("", -1, Vector2i(-1, -1))
	queue_redraw()

func set_deploy_mode(value: bool) -> void:
	deploy_mode = value
	_clear_selection()
	queue_redraw()

func set_tutorial_markers(from_pos: Vector2i, to_pos: Vector2i, note: String = "") -> void:
	tutorial_from = from_pos
	tutorial_to = to_pos
	tutorial_note = note
	queue_redraw()

func clear_tutorial_markers() -> void:
	tutorial_from = Vector2i(-1, -1)
	tutorial_to = Vector2i(-1, -1)
	tutorial_note = ""
	queue_redraw()


func set_action_preview(action: Dictionary, preview: Dictionary) -> void:
	preview_action = action.duplicate(true)
	preview_result = preview.duplicate(true)
	illegal_marker = Vector2i(-1, -1)
	illegal_message = ""
	queue_redraw()

func reset_visual_state(clear_tutorial: bool = true) -> void:
	selected = Vector2i(-1, -1)
	legal_actions = []
	no_cycle_blocked_actions = []
	preview_action = {}
	preview_result = {}
	illegal_marker = Vector2i(-1, -1)
	illegal_message = ""
	press_cell = Vector2i(-1, -1)
	_reset_piece_tap_chain()
	if clear_tutorial:
		tutorial_from = Vector2i(-1, -1)
		tutorial_to = Vector2i(-1, -1)
		tutorial_note = ""
	piece_focus_changed.emit("", -1, Vector2i(-1, -1))
	queue_redraw()

func clear_action_preview() -> void:
	preview_action = {}
	preview_result = {}
	queue_redraw()

func clear_selection() -> void:
	_clear_selection()

func show_illegal_marker(cell: Vector2i, message: String = "Illegal action.", major: bool = false) -> void:
	illegal_marker = cell
	illegal_major = major
	illegal_message = message
	preview_action = {}
	preview_result = {}
	queue_redraw()

func clear_illegal_marker() -> void:
	illegal_marker = Vector2i(-1, -1)
	illegal_message = ""
	queue_redraw()

func set_living_preview(enabled: bool, style: String = "") -> void:
	living_preview_mode = enabled
	living_preview_style = style
	if enabled:
		token_preview_mode = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE if enabled else Control.MOUSE_FILTER_STOP
	if enabled:
		board_flipped = false
	queue_redraw()

func set_token_preview(kind: String, owner: int = SigmaRules.OWNER_P1) -> void:
	token_preview_mode = true
	token_preview_kind = kind
	token_preview_owner = owner
	living_preview_mode = false
	_reset_piece_tap_chain()
	selected = Vector2i(-1, -1)
	legal_actions = []
	no_cycle_blocked_actions = []
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_board_flipped(value: bool) -> void:
	if living_preview_mode:
		value = false
	if board_flipped == value:
		return
	board_flipped = value
	_clear_selection()
	queue_redraw()


func set_tabletop_arena_mode(value: bool) -> void:
	if tabletop_arena_mode == value:
		return
	tabletop_arena_mode = value
	_clear_selection()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if token_preview_mode:
		_draw_token_preview()
		return
	_update_board_rect()
	_draw_background()
	_draw_board_shell()
	_draw_board()
	_draw_living_preview_effects()
	_draw_last_action()
	_draw_tutorial_markers()
	_draw_highlights()
	_draw_action_preview()
	_draw_peril()
	_draw_pieces()
	_draw_coin_motion()
	_draw_selected()
	_draw_illegal_marker()
	_draw_mode_frame()

func _draw_token_preview() -> void:
	var center: Vector2 = Vector2(size.x * 0.5, size.y * 0.5)
	# v1.4.0.4: preview controls are clipped inside cards. Keep the
	# token and glow comfortably inside the control bounds so collection pages
	# never bleed or overlap other UI.
	var radius: float = max(14.0, min(size.x, size.y) * 0.24)
	cell_size = radius * 2.15
	var preview_pulse: float = _pulse_value()
	var preview_glow: Color = _alternating_underglow_color(token_preview_kind, token_preview_owner, preview_pulse)
	_draw_flat_ground_ellipse(center + Vector2(0, radius * 0.50), radius * 0.80, radius * 0.18, Color(0, 0, 0, 0.24))
	draw_arc(center, radius * (1.40 + preview_pulse * 0.05), 0.0, TAU, 72, _with_alpha(preview_glow, 0.42), 2.0)
	draw_arc(center, radius * (1.12 + preview_pulse * 0.04), PI * 0.08, PI * 0.92, 52, _with_alpha(preview_glow.lightened(0.12), 0.32), 2.0)
	_draw_premium_token(center, radius, token_preview_kind, token_preview_owner, 0.0, 0.0, false)

func _draw_background() -> void:
	# v2.3.2.15: richer full-screen SIGMA backdrop with stronger upward and
	# horizontal floating motion plus more solid-center shapes.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#010204"), true)
	var center: Vector2 = Vector2(size.x * 0.5, size.y * 0.5)
	var max_radius: float = max(size.x, size.y)
	var time_s: float = float(Time.get_ticks_msec()) / 1000.0
	var pulse: float = _pulse_value()
	var stage_rect: Rect2 = Rect2(Vector2(14.0, 14.0), Vector2(max(40.0, size.x - 28.0), max(40.0, size.y - 28.0)))

	var accent_cols: Array[Color] = [
		ROLE_COLOR_MONARCH_GOLD,
		ROLE_COLOR_MONARCH_SILVER,
		ROLE_COLOR_SENTINEL_GOLD,
		ROLE_COLOR_SENTINEL_SILVER,
		ROLE_COLOR_INFILTRATOR_GOLD,
		ROLE_COLOR_INFILTRATOR_SILVER,
		ROLE_COLOR_ASSASSIN_GOLD,
		ROLE_COLOR_ASSASSIN_SILVER,
	]

	# Deep orbit bed and wide ambient field.
	for i in range(8):
		var radius: float = max_radius * (0.16 + float(i) * 0.10)
		var alpha: float = max(0.0, 0.08 - float(i) * 0.008)
		draw_arc(center, radius, 0.0, TAU, 96, Color("#0B1730", alpha), 1.0)

	# Large ghost sigils behind the field for premium depth.
	for g in range(4):
		var ghost_pos: Vector2 = Vector2(
			size.x * (0.18 + float(g % 2) * 0.56),
			size.y * (0.22 + float(g / 2) * 0.44)
		)
		var ghost_r: float = min(size.x, size.y) * (0.12 + float(g) * 0.02)
		_draw_sigma_bg_ring_rot(ghost_pos, ghost_r, Color("#143562", 0.028), 1.0, -time_s * 0.04 + float(g) * 0.3)
		_draw_sigma_bg_hex_rot(ghost_pos, ghost_r * 0.62, Color("#173F75", 0.024), 1.0, time_s * 0.06 + float(g) * 0.45)
		_draw_sigma_bg_crosshair_rot(ghost_pos, ghost_r * 0.46, Color("#173F75", 0.018), 1.0, -time_s * 0.05)

	# Main floating shape field across the full screen.
	var anchor_points: Array[Vector2] = []
	for i in range(48):
		var accent: Color = accent_cols[i % accent_cols.size()]
		var motion_mode: int = i % 5
		var lane_x_seed: float = float(i * 79)
		var lane_y_seed: float = float(i * 137)
		var flow_x: float = stage_rect.position.x
		var flow_y: float = stage_rect.position.y
		match motion_mode:
			0:
				# Horizontal sweeps.
				flow_x += fmod(lane_x_seed + time_s * (15.0 + float(i % 4) * 3.5), stage_rect.size.x + 160.0) - 80.0
				flow_y += fmod(lane_y_seed, stage_rect.size.y)
				flow_y += sin(time_s * (0.25 + float(i) * 0.011) + float(i) * 0.62) * 18.0
			1:
				# Up-right diagonal rise.
				flow_x += fmod(lane_x_seed + time_s * (10.0 + float(i % 4) * 2.8), stage_rect.size.x + 120.0) - 60.0
				flow_y += fmod(lane_y_seed - time_s * (20.0 + float(i % 5) * 4.0), stage_rect.size.y + 180.0) - 90.0
			2:
				# Up-left diagonal rise.
				flow_x += fmod(lane_x_seed - time_s * (10.5 + float(i % 4) * 2.6), stage_rect.size.x + 120.0) - 60.0
				flow_y += fmod(lane_y_seed - time_s * (19.0 + float(i % 5) * 4.2), stage_rect.size.y + 180.0) - 90.0
			3:
				# Straight upward float.
				flow_x += fmod(lane_x_seed, stage_rect.size.x)
				flow_x += sin(time_s * (0.29 + float(i) * 0.012) + float(i) * 0.58) * 16.0
				flow_y += fmod(lane_y_seed - time_s * (16.0 + float(i % 3) * 4.2), stage_rect.size.y + 200.0) - 100.0
			_:
				# Mixed slow roam.
				flow_x += fmod(lane_x_seed + time_s * (8.0 + float(i % 3) * 2.2), stage_rect.size.x + 140.0) - 70.0
				flow_y += fmod(lane_y_seed - time_s * (10.0 + float(i % 4) * 2.6), stage_rect.size.y + 140.0) - 70.0
		flow_x += sin(time_s * (0.30 + float(i) * 0.012) + float(i) * 0.67) * (10.0 + float(i % 4) * 6.0)
		flow_y += cos(time_s * (0.24 + float(i) * 0.010) + float(i) * 0.81) * (12.0 + float(i % 3) * 6.0)
		var pos: Vector2 = Vector2(flow_x, flow_y)
		anchor_points.append(pos)
		var base_scale: float = 7.0 + float(i % 6) * 3.4
		var scale: float = base_scale * (0.80 + 0.26 * (0.5 + 0.5 * sin(time_s * (0.80 + float(i % 3) * 0.18) + float(i))))
		var rot: float = time_s * (0.16 + float(i % 7) * 0.05) * (1.0 if i % 2 == 0 else -1.0) + float(i) * 0.41
		var glow_alpha: float = 0.05 + 0.032 * (0.5 + 0.5 * sin(time_s * 1.05 + float(i) * 0.55))
		draw_circle(pos, scale * 1.42, Color(accent.r, accent.g, accent.b, glow_alpha * 0.16))
		match i % 11:
			0:
				_draw_sigma_bg_diamond_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha), rot)
			1:
				_draw_sigma_bg_hex_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.9), 1.1, rot)
			2:
				_draw_sigma_bg_triangle_rot(pos, scale * 1.05, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.9), 1.1, rot)
			3:
				_draw_sigma_bg_square_rot(pos, scale * 0.94, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.9), 1.1, rot)
			4:
				_draw_sigma_bg_ring_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.09 + glow_alpha), 1.1, rot)
			5:
				_draw_sigma_bg_chevron_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.09 + glow_alpha), 1.15, rot)
			6:
				_draw_sigma_bg_shard_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.95), 1.1, rot)
			7:
				_draw_sigma_bg_crosshair_rot(pos, scale, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.95), 1.05, rot)
			8:
				_draw_sigma_bg_pentagon_rot(pos, scale * 1.02, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.9), 1.1, rot)
			9:
				_draw_sigma_bg_star_rot(pos, scale * 1.05, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.95), 1.0, rot)
			_:
				_draw_sigma_bg_bars_rot(pos, scale * 1.06, Color(accent.r, accent.g, accent.b, 0.08 + glow_alpha * 0.9), 1.0, rot)
		# Orbiting accent motes.
		if i % 2 == 0:
			var orbit_r: float = scale * (1.7 + 0.35 * sin(time_s * 0.7 + float(i)))
			for o in range(2):
				var ang: float = rot * (1.2 + float(o) * 0.4) + float(o) * PI
				var orb: Vector2 = pos + Vector2(cos(ang), sin(ang)) * orbit_r
				draw_circle(orb, 1.8 + float(o) * 0.5, Color(accent.r, accent.g, accent.b, 0.12 + glow_alpha * 0.35))

	# Micro-shape field with stronger horizontal and upward motion.
	for j in range(92):
		var minor_col: Color = accent_cols[j % accent_cols.size()]
		var mode2: int = j % 4
		var px: float = stage_rect.position.x
		var py: float = stage_rect.position.y
		match mode2:
			0:
				px += fmod(float(j * 57) + time_s * (12.0 + float(j % 4) * 2.2), stage_rect.size.x + 90.0) - 45.0
				py += fmod(float(j * 109), stage_rect.size.y)
			1:
				px += fmod(float(j * 61) + time_s * (8.0 + float(j % 3) * 1.8), stage_rect.size.x + 100.0) - 50.0
				py += fmod(float(j * 97) - time_s * (15.0 + float(j % 4) * 2.8), stage_rect.size.y + 110.0) - 55.0
			2:
				px += fmod(float(j * 71) - time_s * (8.8 + float(j % 3) * 1.6), stage_rect.size.x + 100.0) - 50.0
				py += fmod(float(j * 103) - time_s * (13.0 + float(j % 5) * 2.4), stage_rect.size.y + 110.0) - 55.0
			_:
				px += fmod(float(j * 67), stage_rect.size.x)
				py += fmod(float(j * 89) - time_s * (11.0 + float(j % 5) * 2.1), stage_rect.size.y + 120.0) - 60.0
		px += sin(time_s * 0.42 + float(j) * 0.52) * 8.0
		py += cos(time_s * 0.37 + float(j) * 0.44) * 8.0
		var rr: float = 3.4 + float(j % 5) * 1.5
		var rrot: float = -time_s * (0.20 + float(j % 6) * 0.03) + float(j) * 0.23
		match j % 8:
			0:
				_draw_sigma_bg_triangle_rot(Vector2(px, py), rr, Color(minor_col.r, minor_col.g, minor_col.b, 0.045), 1.0, rrot)
			1:
				_draw_sigma_bg_hex_rot(Vector2(px, py), rr, Color(minor_col.r, minor_col.g, minor_col.b, 0.045), 1.0, rrot)
			2:
				_draw_sigma_bg_square_rot(Vector2(px, py), rr * 0.92, Color(minor_col.r, minor_col.g, minor_col.b, 0.040), 1.0, rrot)
			3:
				_draw_sigma_bg_ring_rot(Vector2(px, py), rr * 0.94, Color(minor_col.r, minor_col.g, minor_col.b, 0.042), 1.0, rrot)
			4:
				_draw_sigma_bg_chevron_rot(Vector2(px, py), rr * 0.98, Color(minor_col.r, minor_col.g, minor_col.b, 0.042), 1.0, rrot)
			5:
				_draw_sigma_bg_crosshair_rot(Vector2(px, py), rr * 0.96, Color(minor_col.r, minor_col.g, minor_col.b, 0.041), 1.0, rrot)
			6:
				_draw_sigma_bg_pentagon_rot(Vector2(px, py), rr * 0.96, Color(minor_col.r, minor_col.g, minor_col.b, 0.040), 1.0, rrot)
			_:
				_draw_sigma_bg_bars_rot(Vector2(px, py), rr * 1.02, Color(minor_col.r, minor_col.g, minor_col.b, 0.039), 1.0, rrot)

	# Faint designed connectors between select anchors.
	for i in range(anchor_points.size() - 1):
		if i % 3 != 0:
			continue
		var a: Vector2 = anchor_points[i]
		var b: Vector2 = anchor_points[(i + 7) % anchor_points.size()]
		if a.distance_to(b) < min(size.x, size.y) * 0.32:
			draw_line(a, b, Color("#79D8FF", 0.018), 1.0)
			var mid: Vector2 = a.lerp(b, 0.5)
			draw_circle(mid, 1.1, Color("#F2C14E", 0.05))

	# Premium particles and tiny twinkles across the full field.
	for k in range(34):
		var t: float = time_s * (0.12 + float(k % 6) * 0.012) + float(k) * 0.61
		var x2: float = stage_rect.position.x + fmod(float(k * 91) + sin(t * 0.8) * 14.0, max(1.0, stage_rect.size.x))
		var y2: float = stage_rect.position.y + fmod(float(k * 143) + cos(t * 0.9) * 20.0, max(1.0, stage_rect.size.y))
		var twinkle: float = 0.030 + 0.050 * (0.5 + 0.5 * sin(t * 1.7))
		draw_circle(Vector2(x2, y2), 0.9 + 0.55 * sin(t * 1.3), Color("#F2C14E", twinkle))

	# Very subtle ambient glows.
	for n in range(4):
		var glow_r: float = size.x * (0.16 + float(n) * 0.10)
		var glow_center: Vector2 = Vector2(size.x * (0.18 + float(n % 2) * 0.46), size.y * (0.22 + float(n / 2) * 0.46))
		draw_arc(glow_center, glow_r, 0.0, TAU, 64, Color("#102040", 0.025 - float(n) * 0.004 + pulse * 0.003), 1.0)


func _rotate_vec(v: Vector2, angle: float) -> Vector2:
	var c: float = cos(angle)
	var s: float = sin(angle)
	return Vector2(v.x * c - v.y * s, v.x * s + v.y * c)

func _transform_points(points: PackedVector2Array, center: Vector2, rotation: float) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for p in points:
		out.append(center + _rotate_vec(p, rotation))
	return out

func _draw_sigma_bg_diamond_rot(center: Vector2, radius: float, col: Color, rotation: float) -> void:
	var pts: PackedVector2Array = _transform_points(PackedVector2Array([
		Vector2(0, -radius),
		Vector2(radius, 0),
		Vector2(0, radius),
		Vector2(-radius, 0),
	]), center, rotation)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.18))
	_draw_closed_polyline(pts, col, 1.35)

func _draw_sigma_bg_hex_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var ang: float = TAU * float(i) / 6.0 - PI * 0.5 + rotation
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.10))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_triangle_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(3):
		var ang: float = TAU * float(i) / 3.0 - PI * 0.5 + rotation
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.12))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_square_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = _transform_points(PackedVector2Array([
		Vector2(-radius, -radius),
		Vector2(radius, -radius),
		Vector2(radius, radius),
		Vector2(-radius, radius),
	]), center, rotation)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.10))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_ring_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	draw_circle(center, radius * 0.42, Color(col.r, col.g, col.b, col.a * 0.10))
	draw_arc(center, radius, rotation, rotation + TAU, 36, col, width)
	draw_arc(center, radius * 0.58, rotation, rotation + TAU, 36, Color(col.r, col.g, col.b, col.a * 0.55), max(1.0, width - 0.15))

func _draw_sigma_bg_chevron_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = _transform_points(PackedVector2Array([
		Vector2(-radius * 0.70, -radius * 0.28),
		Vector2(0, radius * 0.52),
		Vector2(radius * 0.70, -radius * 0.28),
	]), center, rotation)
	_draw_closed_polyline(pts, col, width)
	var pts2: PackedVector2Array = _transform_points(PackedVector2Array([
		Vector2(-radius * 0.46, -radius * 0.54),
		Vector2(0, radius * 0.24),
		Vector2(radius * 0.46, -radius * 0.54),
	]), center, rotation)
	_draw_closed_polyline(pts2, Color(col.r, col.g, col.b, col.a * 0.72), max(1.0, width - 0.1))

func _draw_sigma_bg_shard_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = _transform_points(PackedVector2Array([
		Vector2(0, -radius),
		Vector2(radius * 0.52, -radius * 0.16),
		Vector2(radius * 0.22, radius),
		Vector2(-radius * 0.42, radius * 0.34),
	]), center, rotation)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.10))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_crosshair_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	draw_arc(center, radius * 0.48, rotation, rotation + TAU, 24, Color(col.r, col.g, col.b, col.a * 0.72), width)
	var lines: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(-radius, 0), Vector2(-radius * 0.42, 0)]),
		PackedVector2Array([Vector2(radius * 0.42, 0), Vector2(radius, 0)]),
		PackedVector2Array([Vector2(0, -radius), Vector2(0, -radius * 0.42)]),
		PackedVector2Array([Vector2(0, radius * 0.42), Vector2(0, radius)]),
	]
	for line_pts in lines:
		var pts: PackedVector2Array = _transform_points(line_pts, center, rotation)
		draw_line(pts[0], pts[1], col, width)
	draw_circle(center, max(1.2, radius * 0.08), Color(col.r, col.g, col.b, col.a * 0.72))

func _draw_sigma_bg_pentagon_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(5):
		var ang: float = TAU * float(i) / 5.0 - PI * 0.5 + rotation
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.12))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_star_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var ang: float = TAU * float(i) / 10.0 - PI * 0.5 + rotation
		var rr: float = radius if i % 2 == 0 else radius * 0.46
		pts.append(center + Vector2(cos(ang), sin(ang)) * rr)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, col.a * 0.08))
	_draw_closed_polyline(pts, col, width)

func _draw_sigma_bg_bars_rot(center: Vector2, radius: float, col: Color, width: float, rotation: float) -> void:
	for i in range(3):
		var yy: float = (float(i) - 1.0) * radius * 0.42
		var pts: PackedVector2Array = _transform_points(PackedVector2Array([
			Vector2(-radius * 0.85, yy),
			Vector2(radius * 0.85, yy),
		]), center, rotation)
		draw_line(pts[0], pts[1], col, width)

func _update_board_rect() -> void:
	# v1.9.0: fit the grid inside a board-as-console layout. Tabletop keeps
	# room for player-facing command decks; non-tabletop keeps the playfield
	# larger and lets the mobile command zone live below it.
	var viewport_size: Vector2 = get_viewport_rect().size
	var smallest_viewport_side: float = min(viewport_size.x, viewport_size.y)
	var is_phone_like: bool = smallest_viewport_side <= 820.0
	var margin: float = 44.0 if is_phone_like else 54.0
	var top_safe: float = 0.0
	var bottom_safe: float = 0.0

	if not living_preview_mode:
		if tabletop_arena_mode:
			top_safe = 106.0 if is_phone_like else 118.0
			bottom_safe = 112.0 if is_phone_like else 124.0
		else:
			# v2.2.1: non-tabletop is a mobile command view with an opponent
			# console at the top and thumb-friendly player console at the bottom.
			top_safe = 132.0 if is_phone_like else 126.0
			bottom_safe = 154.0 if is_phone_like else 142.0

	var available_w: float = max(120.0, size.x - margin * 2.0)
	var available_h: float = max(120.0, size.y - margin * 2.0 - top_safe - bottom_safe)
	var available_side: float = min(available_w, available_h)

	var min_touch_cell: float = 50.0 if is_phone_like else 58.0
	var max_cell: float = 86.0 if is_phone_like else 104.0
	var desired_side: float = min(available_side, 9.0 * max_cell)
	if available_side >= min_touch_cell * float(BOARD_SIZE):
		cell_size = clamp(desired_side / float(BOARD_SIZE), min_touch_cell, max_cell)
	else:
		cell_size = max(30.0, available_side / float(BOARD_SIZE))

	var side: float = cell_size * float(BOARD_SIZE)
	var origin_x: float = (size.x - side) * 0.5
	var origin_y: float = (size.y - side) * 0.5
	if not living_preview_mode:
		var free_h: float = max(0.0, available_h - side)
		if tabletop_arena_mode:
			origin_y = margin + top_safe + free_h * 0.5
		else:
			origin_y = margin + top_safe + min(free_h * 0.12, 20.0)

	board_rect = Rect2(Vector2(origin_x, origin_y), Vector2(side, side))

func _draw_board_shell() -> void:
	if active_board_theme == BOARD_THEME_LIONS_DEN:
		_draw_lions_den_board_shell()
		return
	if active_board_theme == BOARD_THEME_DRACONIAN:
		_draw_draconian_board_shell()
		return
	if active_board_theme == BOARD_THEME_VECTOR:
		_draw_vector_board_shell()
		return
	var pulse: float = _pulse_value()
	var shell: Rect2 = board_rect.grow(8)
	var console: Rect2 = shell.grow(cell_size * 0.30)

	# Deep product-render shadow and graphite body.
	draw_rect(Rect2(console.position + Vector2(0, cell_size * 0.13), console.size), Color("#000000", 0.46), true)
	draw_rect(console.grow(16), Color("#000000", 0.72), true)
	draw_rect(console.grow(12), Color("#02050B", 0.99), true)
	draw_rect(console.grow(8), Color("#09111C", 0.98), true)
	draw_rect(console.grow(4), Color("#111B29", 0.94), true)

	# Layered outer armor: gold on Gold-side geometry, cyan/silver on Silver-side geometry.
	draw_rect(console.grow(6), Color("#D4AF37", 0.38), false, 5.0)
	draw_rect(console.grow(4), Color("#28E0FF", 0.18 + pulse * 0.04), false, 2.2)
	draw_rect(console.grow(-2), Color("#F2C14E", 0.40), false, 2.0)
	for i in range(5):
		var inset: float = float(i) * 6.0
		var band: Rect2 = console.grow(8.0 - inset)
		var alpha: float = 0.28 - float(i) * 0.035
		draw_rect(band, Color("#FFFFFF", max(0.04, alpha)), false, 1.2)

	# Four concept-art corner assemblies.
	var corner_size: float = clamp(cell_size * 0.60, 30.0, 52.0)
	_draw_command_corner(console.position + Vector2(6, 6), corner_size, color_gold, true)
	_draw_command_corner(console.position + Vector2(console.size.x - corner_size - 6, 6), corner_size, color_select, false)
	_draw_command_corner(console.position + Vector2(6, console.size.y - corner_size - 6), corner_size, color_gold, false)
	_draw_command_corner(console.position + Vector2(console.size.x - corner_size - 6, console.size.y - corner_size - 6), corner_size, color_select, true)

	# Integrated player-facing command docks. The real Buttons sit over these
	# zones, so the controls read as part of the board instead of app chrome.
	var dock_h: float = clamp(cell_size * 0.64, 34.0, 62.0)
	var top_dock: Rect2 = Rect2(Vector2(shell.position.x + cell_size * 0.42, console.position.y + 10.0), Vector2(shell.size.x - cell_size * 0.84, dock_h))
	var bottom_dock: Rect2 = Rect2(Vector2(shell.position.x + cell_size * 0.42, console.position.y + console.size.y - dock_h - 10.0), Vector2(shell.size.x - cell_size * 0.84, dock_h))
	_draw_control_center_dock(top_dock, Color("#D8E2F0"), "SILVER")
	_draw_control_center_dock(bottom_dock, Color("#F2C14E"), "GOLD")

	# Side command pylons and static laser rails.
	var wing_l: PackedVector2Array = PackedVector2Array([
		Vector2(console.position.x + 8, shell.position.y + cell_size * 0.34),
		Vector2(shell.position.x - cell_size * 0.18, shell.position.y + cell_size * 0.82),
		Vector2(shell.position.x - cell_size * 0.18, shell.position.y + shell.size.y - cell_size * 0.82),
		Vector2(console.position.x + 8, shell.position.y + shell.size.y - cell_size * 0.34),
	])
	var wing_r: PackedVector2Array = PackedVector2Array([
		Vector2(console.position.x + console.size.x - 8, shell.position.y + cell_size * 0.34),
		Vector2(shell.position.x + shell.size.x + cell_size * 0.18, shell.position.y + cell_size * 0.82),
		Vector2(shell.position.x + shell.size.x + cell_size * 0.18, shell.position.y + shell.size.y - cell_size * 0.82),
		Vector2(console.position.x + console.size.x - 8, shell.position.y + shell.size.y - cell_size * 0.34),
	])
	_draw_board_wing(wing_l, color_gold, false)
	_draw_board_wing(wing_r, color_select, true)
	_draw_energy_rail(Rect2(Vector2(console.position.x + 14, shell.position.y + cell_size * 0.70), Vector2(max(10.0, cell_size * 0.28), shell.size.y - cell_size * 1.40)), color_gold)
	_draw_energy_rail(Rect2(Vector2(console.position.x + console.size.x - max(10.0, cell_size * 0.28) - 14, shell.position.y + cell_size * 0.70), Vector2(max(10.0, cell_size * 0.28), shell.size.y - cell_size * 1.40)), color_select)

	# 9×9 play slab. This is the sacred gameplay plane: clear, readable, and
	# quieter than the surrounding command hardware.
	draw_rect(shell.grow(10), Color("#000000", 0.74), true)
	draw_rect(shell.grow(6), Color("#D4AF37", 0.62), true)
	draw_rect(shell.grow(2), Color("#0A1321", 1.0), true)
	draw_rect(shell, Color("#F2C14E", 0.76), false, 3.0)
	draw_rect(board_rect.grow(5), Color("#020712", 0.98), true)
	draw_rect(board_rect.grow(4), Color("#28E0FF", 0.10 + pulse * 0.03), false, 2.4)
	draw_rect(board_rect.grow(1), Color("#D4AF37", 0.30), false, 1.5)

func _draw_vector_board_shell() -> void:
	var pulse: float = _pulse_value()
	var shell: Rect2 = board_rect.grow(10)
	var console: Rect2 = shell.grow(cell_size * 0.34)
	# Onyx slab and faceted Vector frame.
	draw_rect(Rect2(console.position + Vector2(0, cell_size * 0.16), console.size), Color("#000000", 0.54), true)
	draw_rect(console.grow(18), Color("#000000", 0.80), true)
	draw_rect(console.grow(12), Color("#030407", 0.98), true)
	draw_rect(console.grow(6), Color("#0A0D12", 0.98), true)
	draw_rect(console.grow(2), Color("#11151D", 0.92), true)
	# Angular frame facets.
	var facet: float = clamp(cell_size * 0.42, 24.0, 46.0)
	var top_left: PackedVector2Array = PackedVector2Array([console.position, console.position + Vector2(facet, 0), console.position + Vector2(0, facet)])
	var top_right: PackedVector2Array = PackedVector2Array([console.position + Vector2(console.size.x, 0), console.position + Vector2(console.size.x - facet, 0), console.position + Vector2(console.size.x, facet)])
	var bottom_left: PackedVector2Array = PackedVector2Array([console.position + Vector2(0, console.size.y), console.position + Vector2(facet, console.size.y), console.position + Vector2(0, console.size.y - facet)])
	var bottom_right: PackedVector2Array = PackedVector2Array([console.position + console.size, console.position + Vector2(console.size.x - facet, console.size.y), console.position + Vector2(console.size.x, console.size.y - facet)])
	for tri in [top_left, top_right, bottom_left, bottom_right]:
		draw_colored_polygon(tri, Color("#1B2028", 0.96))
		_draw_closed_polyline(tri, Color("#D4AF37", 0.44), 2.0)
	draw_rect(console.grow(4), Color("#D4AF37", 0.38), false, 3.0)
	draw_rect(console.grow(1), Color("#E8EDF2", 0.18), false, 1.6)
	draw_rect(console.grow(-6), Color("#00E5FF", 0.16 + pulse * 0.04), false, 1.8)
	# Laser rails and vector channels.
	var rail_col_gold: Color = Color("#F2C14E", 0.40 + pulse * 0.08)
	var rail_col_silver: Color = Color("#E8EDF2", 0.30 + pulse * 0.06)
	for i in range(5):
		var x: float = console.position.x + console.size.x * (0.16 + float(i) * 0.17)
		draw_line(Vector2(x, console.position.y + 12), Vector2(x + cell_size * 0.38, shell.position.y - 8), Color("#F2C14E", 0.10 + pulse * 0.04), 1.2)
		draw_line(Vector2(x + cell_size * 0.22, shell.position.y + shell.size.y + 8), Vector2(x - cell_size * 0.18, console.position.y + console.size.y - 12), Color("#E8EDF2", 0.09 + pulse * 0.04), 1.2)
	# Central Vector sigil behind board.
	var sig_center: Vector2 = board_rect.get_center()
	var sig_r: float = cell_size * 1.06
	draw_arc(sig_center, sig_r, 0.0, TAU, 80, Color("#D4AF37", 0.08), 1.4)
	draw_arc(sig_center, sig_r * 0.64, 0.0, TAU, 80, Color("#00E5FF", 0.06), 1.2)
	var sigma_pts: PackedVector2Array = PackedVector2Array([
		sig_center + Vector2(-sig_r * 0.30, -sig_r * 0.34),
		sig_center + Vector2(sig_r * 0.30, -sig_r * 0.34),
		sig_center + Vector2(-sig_r * 0.10, 0),
		sig_center + Vector2(sig_r * 0.30, sig_r * 0.34),
		sig_center + Vector2(-sig_r * 0.30, sig_r * 0.34),
	])
	_draw_closed_polyline(sigma_pts, Color("#D4AF37", 0.12), 3.0)
	# Play slab.
	draw_rect(shell.grow(8), Color("#000000", 0.78), true)
	draw_rect(shell.grow(5), Color("#11151D", 1.0), true)
	draw_rect(shell.grow(2), Color("#D4AF37", 0.50), true)
	draw_rect(shell, Color("#05070B", 1.0), true)
	draw_rect(shell, Color("#E8EDF2", 0.30), false, 1.6)
	draw_rect(board_rect.grow(4), Color("#000000", 0.92), true)
	draw_rect(board_rect.grow(3), Color("#D4AF37", 0.32), false, 1.6)
	draw_rect(board_rect.grow(1), Color("#00E5FF", 0.16 + pulse * 0.03), false, 1.2)


func _draw_draconian_board_shell() -> void:
	var pulse: float = _pulse_value()
	var shell: Rect2 = board_rect.grow(10)
	var console: Rect2 = shell.grow(cell_size * 0.36)
	draw_rect(Rect2(console.position + Vector2(0, cell_size * 0.18), console.size), Color("#000000", 0.62), true)
	draw_rect(console.grow(18), Color("#000000", 0.84), true)
	draw_rect(console.grow(12), Color("#100408", 0.98), true)
	draw_rect(console.grow(6), Color("#1A0A0D", 0.96), true)
	draw_rect(console.grow(2), Color("#080507", 0.98), true)
	draw_rect(console.grow(4), Color("#D4AF37", 0.44), false, 3.4)
	draw_rect(console.grow(-2), Color("#FF3B30", 0.14 + pulse * 0.04), false, 2.0)
	draw_rect(console.grow(-8), Color("#28E0FF", 0.08 + pulse * 0.03), false, 1.6)
	var claw: float = clamp(cell_size * 0.52, 28.0, 54.0)
	var corners: Array = [
		PackedVector2Array([console.position, console.position + Vector2(claw, 0), console.position + Vector2(0, claw)]),
		PackedVector2Array([console.position + Vector2(console.size.x, 0), console.position + Vector2(console.size.x - claw, 0), console.position + Vector2(console.size.x, claw)]),
		PackedVector2Array([console.position + Vector2(0, console.size.y), console.position + Vector2(claw, console.size.y), console.position + Vector2(0, console.size.y - claw)]),
		PackedVector2Array([console.position + console.size, console.position + Vector2(console.size.x - claw, console.size.y), console.position + Vector2(console.size.x, console.size.y - claw)])
	]
	for tri in corners:
		draw_colored_polygon(tri, Color("#1F1110", 0.92))
		_draw_closed_polyline(tri, Color("#F2C14E", 0.44), 2.0)
	# Dragon-flame channels around the arena.
	for i in range(6):
		var t: float = float(i) / 5.0
		var y: float = console.position.y + console.size.y * (0.10 + t * 0.80)
		draw_line(Vector2(console.position.x + 10, y), Vector2(shell.position.x - 6, y - cell_size * 0.16), Color("#FF3B30", 0.12 + pulse * 0.04), 1.6)
		draw_line(Vector2(shell.position.x + shell.size.x + 6, y - cell_size * 0.10), Vector2(console.position.x + console.size.x - 10, y), Color("#28E0FF", 0.10 + pulse * 0.04), 1.6)
	var sig_center: Vector2 = board_rect.get_center()
	var sig_r: float = cell_size * 1.00
	var gem: PackedVector2Array = PackedVector2Array([sig_center + Vector2(0, -sig_r * 0.48), sig_center + Vector2(sig_r * 0.30, 0), sig_center + Vector2(0, sig_r * 0.48), sig_center + Vector2(-sig_r * 0.30, 0)])
	_draw_closed_polyline(gem, Color("#D4AF37", 0.12), 3.0)
	draw_rect(shell.grow(8), Color("#000000", 0.80), true)
	draw_rect(shell.grow(5), Color("#2A1208", 0.96), true)
	draw_rect(shell.grow(2), Color("#D4AF37", 0.56), true)
	draw_rect(shell, Color("#050506", 1.0), true)
	draw_rect(shell, Color("#FFB000", 0.26 + pulse * 0.04), false, 1.8)
	draw_rect(board_rect.grow(4), Color("#000000", 0.94), true)
	draw_rect(board_rect.grow(3), Color("#D4AF37", 0.34), false, 1.6)
	draw_rect(board_rect.grow(1), Color("#FF3B30", 0.10 + pulse * 0.03), false, 1.2)

func _draw_draconian_board() -> void:
	var pulse: float = _pulse_value()
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var rect: Rect2 = _cell_rect(Vector2i(r, c))
			var parity: bool = ((r + c) % 2 == 0)
			var base: Color = Color("#17120F") if parity else Color("#0B090A")
			var shift: float = float(((r * 19 + c * 7) % 9) - 4) * 0.005
			var col: Color = base.lightened(max(0.0, shift)).darkened(max(0.0, -shift))
			draw_rect(rect, col, true)
			draw_rect(rect.grow(-2), Color("#FFFFFF", 0.018 if parity else 0.010), true)
			draw_rect(rect.grow(-5), Color("#000000", 0.22), false, 1.0)
			draw_rect(rect, Color("#000000", 0.34), false, 1.0)
			var line_col: Color = Color("#D4AF37", 0.12 + pulse * 0.02)
			draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, line_col, 1.0)
			draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, Color("#F2C14E", 0.08 + pulse * 0.02), 1.0)
			if ((r * 3 + c * 5) % 11) == 0:
				var chip: Vector2 = rect.position + rect.size * 0.5
				var flame: PackedVector2Array = PackedVector2Array([chip + Vector2(0, -cell_size * 0.060), chip + Vector2(cell_size * 0.044, 0), chip + Vector2(0, cell_size * 0.060), chip + Vector2(-cell_size * 0.044, 0)])
				draw_colored_polygon(flame, Color("#FF3B30", 0.055))
	var rail_h: float = max(5.0, cell_size * 0.060)
	draw_rect(Rect2(board_rect.position, Vector2(board_rect.size.x, rail_h)), Color("#E8EDF2", 0.42), true)
	draw_rect(Rect2(board_rect.position + Vector2(0, board_rect.size.y - rail_h), Vector2(board_rect.size.x, rail_h)), Color("#D4AF37", 0.56), true)

func _draw_vector_board() -> void:
	var pulse: float = _pulse_value()
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var rect: Rect2 = _cell_rect(Vector2i(r, c))
			var parity: bool = ((r + c) % 2 == 0)
			var base: Color = Color("#11151B") if parity else Color("#090D12")
			var shift: float = float(((r * 13 + c * 17) % 9) - 4) * 0.006
			var col: Color = base.lightened(max(0.0, shift)).darkened(max(0.0, -shift))
			draw_rect(rect, col, true)
			draw_rect(rect.grow(-2), Color("#FFFFFF", 0.020 if parity else 0.012), true)
			draw_rect(rect.grow(-5), Color("#000000", 0.22), false, 1.0)
			draw_rect(rect, Color("#000000", 0.35), false, 1.0)
			# Laser-cut Vector lines.
			var h_col: Color = Color("#F2C14E", 0.11 + pulse * 0.02) if c <= 4 else Color("#E8EDF2", 0.10 + pulse * 0.02)
			var v_col: Color = Color("#00E5FF", 0.06 + pulse * 0.02)
			draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, h_col, 1.0)
			draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, v_col, 1.0)
			var node: Vector2 = rect.position + Vector2(rect.size.x, rect.size.y)
			var node_col: Color = Color("#D4AF37", 0.42) if c <= 4 else Color("#E8EDF2", 0.34)
			draw_circle(node, max(1.5, cell_size * 0.025), node_col)
			if ((r * 5 + c * 3) % 13) == 0:
				var chip: Vector2 = rect.position + rect.size * 0.5
				var diamond: PackedVector2Array = PackedVector2Array([chip + Vector2(0, -cell_size * 0.055), chip + Vector2(cell_size * 0.055, 0), chip + Vector2(0, cell_size * 0.055), chip + Vector2(-cell_size * 0.055, 0)])
				draw_colored_polygon(diamond, Color("#D4AF37", 0.08))
	# Diagonal vector inlays across the board surface.
	for i in range(5):
		var t: float = float(i) / 4.0
		var a: Vector2 = board_rect.position.lerp(board_rect.position + Vector2(0, board_rect.size.y), t)
		var b: Vector2 = (board_rect.position + Vector2(board_rect.size.x, 0)).lerp(board_rect.position + board_rect.size, t)
		draw_line(a, b, Color("#D4AF37", 0.055), 1.0)
		var c1: Vector2 = (board_rect.position + Vector2(board_rect.size.x, 0)).lerp(board_rect.position, t)
		var d1: Vector2 = (board_rect.position + board_rect.size).lerp(board_rect.position + Vector2(0, board_rect.size.y), t)
		draw_line(c1, d1, Color("#E8EDF2", 0.045), 1.0)
	# Owner rails.
	var rail_h: float = max(5.0, cell_size * 0.060)
	draw_rect(Rect2(board_rect.position, Vector2(board_rect.size.x, rail_h)), Color("#E8EDF2", 0.46), true)
	draw_rect(Rect2(board_rect.position + Vector2(0, board_rect.size.y - rail_h), Vector2(board_rect.size.x, rail_h)), Color("#D4AF37", 0.54), true)

func _draw_lions_den_board_shell() -> void:
	var pulse: float = _pulse_value()
	var shell: Rect2 = board_rect.grow(10)
	var console: Rect2 = shell.grow(cell_size * 0.34)
	draw_rect(Rect2(console.position + Vector2(0, cell_size * 0.18), console.size), Color("#000000", 0.60), true)
	draw_rect(console.grow(18), Color("#000000", 0.84), true)
	draw_rect(console.grow(12), Color("#120907", 0.98), true)
	draw_rect(console.grow(6), Color("#1D120C", 0.96), true)
	draw_rect(console.grow(2), Color("#080506", 0.98), true)
	draw_rect(console.grow(4), Color("#D4AF37", 0.46), false, 3.2)
	draw_rect(console.grow(-2), Color("#FFD84D", 0.14 + pulse * 0.04), false, 2.0)
	draw_rect(console.grow(-8), Color("#28E0FF", 0.07 + pulse * 0.03), false, 1.4)
	var crest_center: Vector2 = Vector2(console.position.x + console.size.x * 0.5, console.position.y + cell_size * 0.28)
	draw_circle(crest_center, cell_size * 0.34, Color("#120907", 0.96))
	draw_circle(crest_center, cell_size * 0.25, Color("#D4AF37", 0.78))
	draw_circle(crest_center, cell_size * 0.16, Color("#2A180D", 0.98))
	draw_circle(crest_center + Vector2(0, -cell_size * 0.04), cell_size * 0.05, Color("#FFF4B8", 0.85))
	var corner_size: float = clamp(cell_size * 0.56, 30.0, 54.0)
	_draw_command_corner(console.position + Vector2(6, 6), corner_size, Color("#FF5A36"), true)
	_draw_command_corner(console.position + Vector2(console.size.x - corner_size - 6, 6), corner_size, Color("#28E0FF"), false)
	_draw_command_corner(console.position + Vector2(6, console.size.y - corner_size - 6), corner_size, Color("#8B5CF6"), false)
	_draw_command_corner(console.position + Vector2(console.size.x - corner_size - 6, console.size.y - corner_size - 6), corner_size, Color("#2FE66C"), true)
	var left_panel: Rect2 = Rect2(Vector2(console.position.x - cell_size * 0.14, shell.position.y + cell_size * 0.82), Vector2(cell_size * 0.34, shell.size.y - cell_size * 1.64))
	var right_panel: Rect2 = Rect2(Vector2(console.position.x + console.size.x - cell_size * 0.20, shell.position.y + cell_size * 0.82), Vector2(cell_size * 0.34, shell.size.y - cell_size * 1.64))
	_draw_energy_rail(left_panel, Color("#FF7A18"))
	_draw_energy_rail(right_panel, Color("#28E0FF"))
	for i in range(4):
		var t: float = float(i) / 3.0
		var lx: float = console.position.x + console.size.x * (0.08 + t * 0.16)
		var rx: float = console.position.x + console.size.x * (0.76 + t * 0.16)
		draw_line(Vector2(lx, console.position.y + cell_size * 0.62), Vector2(lx - cell_size * 0.16, console.position.y + cell_size * 0.16), Color("#FF7A18", 0.14 + pulse * 0.04), 1.4)
		draw_line(Vector2(rx, console.position.y + cell_size * 0.62), Vector2(rx + cell_size * 0.16, console.position.y + cell_size * 0.16), Color("#28E0FF", 0.14 + pulse * 0.04), 1.4)
		draw_line(Vector2(lx, console.position.y + console.size.y - cell_size * 0.62), Vector2(lx - cell_size * 0.16, console.position.y + console.size.y - cell_size * 0.16), Color("#8B5CF6", 0.12 + pulse * 0.04), 1.4)
		draw_line(Vector2(rx, console.position.y + console.size.y - cell_size * 0.62), Vector2(rx + cell_size * 0.16, console.position.y + console.size.y - cell_size * 0.16), Color("#2FE66C", 0.12 + pulse * 0.04), 1.4)
	draw_rect(shell.grow(8), Color("#000000", 0.80), true)
	draw_rect(shell.grow(5), Color("#24140D", 0.96), true)
	draw_rect(shell.grow(2), Color("#D4AF37", 0.54), true)
	draw_rect(shell, Color("#050506", 1.0), true)
	draw_rect(shell, Color("#FFF4B8", 0.20 + pulse * 0.03), false, 1.8)
	draw_rect(board_rect.grow(4), Color("#000000", 0.94), true)
	draw_rect(board_rect.grow(3), Color("#D4AF37", 0.34), false, 1.6)
	draw_rect(board_rect.grow(1), Color("#FFD84D", 0.10 + pulse * 0.03), false, 1.2)

func _draw_lions_den_board() -> void:
	var pulse: float = _pulse_value()
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var rect: Rect2 = _cell_rect(Vector2i(r, c))
			var parity: bool = ((r + c) % 2 == 0)
			var base: Color = Color("#18120F") if parity else Color("#0D0B0C")
			draw_rect(rect, base, true)
			draw_rect(rect.grow(-2), Color("#FFFFFF", 0.018 if parity else 0.010), true)
			draw_rect(rect.grow(-5), Color("#000000", 0.22), false, 1.0)
			draw_rect(rect, Color("#000000", 0.34), false, 1.0)
			draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, Color("#D4AF37", 0.12 + pulse * 0.02), 1.0)
			draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, Color("#F2C14E", 0.08 + pulse * 0.02), 1.0)
			if ((r * 5 + c * 7) % 13) == 0:
				var chip: Vector2 = rect.position + rect.size * 0.5
				var jewel: PackedVector2Array = PackedVector2Array([chip + Vector2(0, -cell_size * 0.055), chip + Vector2(cell_size * 0.055, 0), chip + Vector2(0, cell_size * 0.055), chip + Vector2(-cell_size * 0.055, 0)])
				draw_colored_polygon(jewel, Color("#D4AF37", 0.08))
				_draw_closed_polyline(jewel, Color("#D4AF37", 0.12), 1.0)
	var rail_h: float = max(5.0, cell_size * 0.060)
	draw_rect(Rect2(board_rect.position, Vector2(board_rect.size.x, rail_h)), Color("#E8EDF2", 0.42), true)
	draw_rect(Rect2(board_rect.position + Vector2(0, board_rect.size.y - rail_h), Vector2(board_rect.size.x, rail_h)), Color("#D4AF37", 0.56), true)

func _draw_command_corner(pos: Vector2, side: float, accent: Color, flip: bool) -> void:
	var rect: Rect2 = Rect2(pos, Vector2(side, side))
	draw_rect(rect, Color("#050A12", 0.96), true)
	draw_rect(rect, _with_alpha(accent, 0.34), false, 2.0)
	var tri: PackedVector2Array
	if flip:
		tri = PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(0, rect.size.y)])
	else:
		tri = PackedVector2Array([rect.position + Vector2(rect.size.x, rect.size.y), rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(0, rect.size.y)])
	draw_colored_polygon(tri, _with_alpha(accent, 0.22))
	_draw_closed_polyline(tri, _with_alpha(accent.lightened(0.15), 0.56), 1.8)
	var c: Vector2 = rect.get_center()
	var jewel: PackedVector2Array = PackedVector2Array([c + Vector2(0, -side * 0.22), c + Vector2(side * 0.22, 0), c + Vector2(0, side * 0.22), c + Vector2(-side * 0.22, 0)])
	draw_colored_polygon(jewel, Color("#080C12", 0.96))
	_draw_closed_polyline(jewel, _with_alpha(accent, 0.80), 2.0)
	draw_circle(c, side * 0.060, _with_alpha(accent.lightened(0.30), 0.78))

func _draw_board_wing(points: PackedVector2Array, accent: Color, _flipped_side: bool) -> void:
	draw_colored_polygon(points, Color("#050A12", 0.94))
	_draw_closed_polyline(points, _with_alpha(accent, 0.38), 2.0)
	if points.size() < 4:
		return
	# Geometric laser-etched struts, static and understated.
	var a: Vector2 = points[0]
	var b: Vector2 = points[1]
	var c: Vector2 = points[2]
	var d: Vector2 = points[3]
	for i in range(3):
		var t: float = 0.22 + float(i) * 0.24
		var p1: Vector2 = a.lerp(d, t)
		var p2: Vector2 = b.lerp(c, t + 0.08)
		draw_line(p1, p2, _with_alpha(accent, 0.18), 1.4)
	var mid: Vector2 = (a + b + c + d) * 0.25
	draw_circle(mid, 4.5, _with_alpha(accent, 0.34))
	draw_circle(mid, 1.8, Color("#FFFFFF", 0.38))

func _draw_corner_jewel(c: Vector2, accent: Color) -> void:
	var outer: PackedVector2Array = PackedVector2Array([c + Vector2(0, -17), c + Vector2(17, 0), c + Vector2(0, 17), c + Vector2(-17, 0)])
	var inner: PackedVector2Array = PackedVector2Array([c + Vector2(0, -9), c + Vector2(9, 0), c + Vector2(0, 9), c + Vector2(-9, 0)])
	draw_colored_polygon(outer, Color("#120B02", 0.98))
	_draw_closed_polyline(outer, Color("#F2C14E", 0.86), 2.0)
	draw_colored_polygon(inner, _with_alpha(accent.lightened(0.10), 0.70))
	_draw_closed_polyline(inner, Color("#FFFFFF", 0.24), 1.4)
	draw_circle(c + Vector2(-1.6, -1.6), 2.0, Color("#FFFFFF", 0.62))

func _draw_control_center_dock(rect: Rect2, accent: Color, _label_text: String) -> void:
	if rect.size.x <= 10 or rect.size.y <= 10:
		return
	# A dock is not a floating UI card; it is a built-in player-facing console.
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y * 0.16), rect.size), Color("#000000", 0.46), true)
	draw_rect(rect, Color("#010611", 0.98), true)
	draw_rect(rect.grow(-2), Color("#071321", 0.94), true)
	draw_rect(rect, _with_alpha(accent, 0.62), false, 2.4)
	draw_rect(rect.grow(-6), Color("#28E0FF", 0.10), false, 1.2)
	var cy: float = rect.position.y + rect.size.y * 0.5
	var name_plate: Rect2 = Rect2(Vector2(rect.position.x + rect.size.x * 0.04, rect.position.y + rect.size.y * 0.22), Vector2(rect.size.x * 0.20, rect.size.y * 0.56))
	draw_rect(name_plate, Color("#000000", 0.28), true)
	draw_rect(name_plate, _with_alpha(accent, 0.32), false, 1.2)
	# Reserve socket motifs visually align with the actual Reserve Guardian tray above.
	for i in range(5):
		var px: float = rect.position.x + rect.size.x * (0.34 + float(i) * 0.095)
		var socket_r: float = rect.size.y * 0.20
		draw_circle(Vector2(px, cy), socket_r, Color("#000000", 0.46))
		draw_circle(Vector2(px, cy), socket_r * 0.72, _with_alpha(accent, 0.20 + 0.04 * float(i % 2)))
		draw_arc(Vector2(px, cy), socket_r, 0.0, TAU, 32, _with_alpha(accent, 0.54), 1.5)
	# Laser inlay line.
	var line_y: float = rect.position.y + rect.size.y * 0.78
	draw_line(Vector2(rect.position.x + rect.size.x * 0.26, line_y), Vector2(rect.position.x + rect.size.x * 0.92, line_y), _with_alpha(Color("#28E0FF"), 0.24), 1.6)

func _draw_energy_rail(rect: Rect2, accent: Color) -> void:
	if rect.size.x <= 2 or rect.size.y <= 2:
		return
	draw_rect(rect, Color("#020917", 0.88), true)
	draw_rect(rect, _with_alpha(accent, 0.28), false, 1.5)
	var dash_count: int = 5
	for i in range(dash_count):
		var y: float = rect.position.y + rect.size.y * (0.12 + float(i) * 0.19)
		var dash: Rect2 = Rect2(Vector2(rect.position.x + rect.size.x * 0.22, y), Vector2(rect.size.x * 0.56, max(2.0, rect.size.y * 0.035)))
		draw_rect(dash, _with_alpha(accent, 0.25 + 0.04 * float(i % 2)), true)

func _draw_board() -> void:
	if active_board_theme == BOARD_THEME_LIONS_DEN:
		_draw_lions_den_board()
		return
	if active_board_theme == BOARD_THEME_DRACONIAN:
		_draw_draconian_board()
		return
	if active_board_theme == BOARD_THEME_VECTOR:
		_draw_vector_board()
		return
	# Official Classic SIGMA Board surface: not a chessboard, but a dark laser-
	# etched 9×9 command grid. Subtle tile contrast keeps the board readable;
	# gold/cyan nodes carry the SIGMA control-center identity.
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var rect: Rect2 = _cell_rect(Vector2i(r, c))
			var parity: bool = ((r + c) % 2 == 0)
			var base: Color = Color("#142435") if parity else Color("#0B1B28")
			var material_shift: float = float(((r * 17 + c * 11) % 7) - 3) * 0.005
			var col: Color = base.lightened(max(0.0, material_shift)).darkened(max(0.0, -material_shift))
			draw_rect(rect, col, true)
			# Beveled tile depth.
			draw_rect(rect.grow(-2), Color("#FFFFFF", 0.018 if parity else 0.012), true)
			draw_rect(rect.grow(-5), Color("#000000", 0.18), false, 1.0)
			draw_rect(rect, Color("#000000", 0.28), false, 1.0)
			# Micro linework and intersection nodes, inspired by the board concept image.
			draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, Color("#28E0FF", 0.08), 1.0)
			draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, Color("#D4AF37", 0.055), 1.0)
			var node: Vector2 = rect.position + Vector2(rect.size.x, rect.size.y)
			var node_col: Color = Color("#F2C14E", 0.34) if parity else Color("#28E0FF", 0.22)
			draw_circle(node, max(1.5, cell_size * 0.026), node_col)
			if ((r * 3 + c * 5) % 10) == 0:
				draw_circle(rect.position + Vector2(rect.size.x * 0.70, rect.size.y * 0.26), cell_size * 0.012, Color("#F2C14E", 0.11))

	# Owner orientation rails: Silver top, Gold bottom, subtle and static.
	var rail_h: float = max(5.0, cell_size * 0.060)
	draw_rect(Rect2(board_rect.position, Vector2(board_rect.size.x, rail_h)), _with_alpha(color_silver, 0.42), true)
	draw_rect(Rect2(board_rect.position + Vector2(0, board_rect.size.y - rail_h), Vector2(board_rect.size.x, rail_h)), _with_alpha(color_gold, 0.64), true)

	# Corner-chip motifs only. No idle center tile marker.
	for chip_cell_value in [Vector2i(0, 0), Vector2i(0, 8), Vector2i(8, 0), Vector2i(8, 8)]:
		var chip_cell: Vector2i = chip_cell_value
		var chip_center: Vector2 = _cell_center(chip_cell)
		draw_arc(chip_center, cell_size * 0.20, 0.0, TAU, 32, Color("#D4AF37", 0.30), 1.8)
		draw_circle(chip_center, cell_size * 0.040, Color("#F2C14E", 0.36))

func _draw_living_preview_effects() -> void:
	if not living_preview_mode:
		return
	if living_preview_style == "static_display":
		_draw_static_living_preview_frame()
		return
	var pulse: float = _pulse_value()
	var tick: float = float(Time.get_ticks_msec() % 2400) / 2400.0
	draw_rect(board_rect.grow(6.0 + pulse * 2.0), _with_alpha(color_gold, 0.20 + pulse * 0.18), false, 3.0)
	if living_preview_style == "quick":
		_draw_quick_play_menu_animation(pulse, tick)
	elif living_preview_style == "full":
		for col_value in [1, 2, 3, 5, 6, 7]:
			var c: int = int(col_value)
			_draw_living_cell_pulse(Vector2i(BOARD_SIZE - 1, c), color_select, pulse)
			_draw_living_cell_pulse(Vector2i(0, c), color_select, pulse)
	elif living_preview_style == "draft":
		var draft_cols: Array = [3, 4, 5]
		for i in range(draft_cols.size()):
			var c2: int = int(draft_cols[i])
			var local_pulse: float = fmod(pulse + float(i) * 0.30, 1.0)
			var pulse_col: Color = color_select
			if i == 1:
				pulse_col = color_deploy
			elif i == 2:
				pulse_col = color_last
			_draw_living_cell_pulse(Vector2i(4, c2), pulse_col, local_pulse)
	elif living_preview_style == "tutorial":
		_draw_tutorial_menu_animation(pulse)
	elif living_preview_style == "rules":
		_draw_living_cell_pulse(Vector2i(4, 4), color_peril, pulse)
		_draw_living_cell_pulse(Vector2i(5, 4), color_peril, pulse)
		_draw_living_cell_pulse(Vector2i(3, 4), color_deploy, 1.0 - pulse)
		_draw_living_cell_pulse(Vector2i(1, 4), color_elevate, pulse)
	elif living_preview_style == "settings":
		_draw_settings_menu_animation(pulse)
	elif living_preview_style == "collections":
		_draw_collections_menu_animation(pulse, tick)

func _draw_static_living_preview_frame() -> void:
	# Static-only landing-page showcase frame. No pulsing center tile, no moving
	# targeting marker, and no gameplay legality involvement.
	draw_rect(board_rect.grow(5.0), _with_alpha(color_gold, 0.18), false, 2.2)
	draw_rect(board_rect.grow(2.0), Color("#28E0FF", 0.08), false, 1.2)
	var rail_alpha: float = 0.14
	draw_line(board_rect.position + Vector2(0, -7), board_rect.position + Vector2(board_rect.size.x, -7), Color("#F2C14E", rail_alpha), 1.1)
	draw_line(board_rect.position + Vector2(0, board_rect.size.y + 7), board_rect.position + Vector2(board_rect.size.x, board_rect.size.y + 7), Color("#E8EDF2", rail_alpha), 1.1)


func _draw_living_row_glow(row: int, col: Color, alpha: float) -> void:
	for c in range(BOARD_SIZE):
		draw_rect(_cell_rect(Vector2i(row, c)).grow(-7), _with_alpha(col, alpha), true)

func _draw_living_cell_pulse(cell: Vector2i, col: Color, pulse: float) -> void:
	if cell.x < 0:
		return
	var rect: Rect2 = _cell_rect(cell)
	var center: Vector2 = rect.get_center()
	draw_rect(rect.grow(-7), _with_alpha(col, 0.12 + pulse * 0.18), true)
	draw_arc(center, cell_size * (0.33 + pulse * 0.08), 0.0, TAU, 40, _with_alpha(col, 0.72), 3.0)


func _draw_quick_play_menu_animation(pulse: float, tick: float) -> void:
	# Quick Play should feel like the Classic board waking up: Monarchs breathe,
	# Sentinels scan, and a short opening move previews how play begins.
	_draw_living_row_glow(BOARD_SIZE - 1, color_gold, 0.16 + pulse * 0.18)
	_draw_living_row_glow(0, color_silver, 0.12 + pulse * 0.14)
	var gold_monarch: Vector2i = Vector2i(BOARD_SIZE - 1, 4)
	var silver_monarch: Vector2i = Vector2i(0, 4)
	_draw_living_cell_pulse(gold_monarch, color_gold, pulse)
	_draw_living_cell_pulse(silver_monarch, color_silver, pulse)
	var sweep: float = float(Time.get_ticks_msec() % 1800) / 1800.0
	var left_sentinel: Vector2 = _cell_center(Vector2i(BOARD_SIZE - 1, 3)).lerp(_cell_center(Vector2i(BOARD_SIZE - 1, 5)), sweep)
	var right_sentinel: Vector2 = _cell_center(Vector2i(0, 5)).lerp(_cell_center(Vector2i(0, 3)), sweep)
	draw_circle(left_sentinel, cell_size * 0.08, _with_alpha(color_select, 0.78))
	draw_circle(right_sentinel, cell_size * 0.08, _with_alpha(color_select, 0.58))
	_draw_arrow(_cell_center(Vector2i(BOARD_SIZE - 1, 2)), _cell_center(Vector2i(BOARD_SIZE - 2, 2)), _with_alpha(color_move, 0.28 + pulse * 0.34), 3.0)
	_draw_arrow(_cell_center(Vector2i(0, 6)), _cell_center(Vector2i(1, 6)), _with_alpha(color_move, 0.22 + pulse * 0.28), 3.0)
	# v2.5.8.26.32: no animated center-tile marker on the landing preview.

func _draw_tutorial_menu_animation(pulse: float) -> void:
	# Tutorial preview teaches the family of pieces before any page opens.
	var tutorial_cells: Array = [Vector2i(8, 4), Vector2i(8, 0), Vector2i(8, 3), Vector2i(8, 1), Vector2i(8, 2)]
	var tutorial_colors: Array = [color_gold, color_silver, color_select, color_deploy, color_last]
	var active_index: int = int((Time.get_ticks_msec() / 620) % tutorial_cells.size())
	for i in range(tutorial_cells.size()):
		var cell: Vector2i = tutorial_cells[i]
		var col: Color = tutorial_colors[i]
		var active: bool = i == active_index
		var alpha: float = 0.95 if active else 0.22
		var rect: Rect2 = _cell_rect(cell)
		draw_rect(rect.grow(-5), _with_alpha(col, alpha * 0.25), true)
		draw_rect(rect.grow(-5), _with_alpha(col, alpha), false, 3.0 if active else 1.8)
		if active:
			var top: Vector2 = rect.get_center() + Vector2(0, -cell_size * 0.95)
			_draw_arrow(top, rect.get_center(), _with_alpha(col, 0.62), 2.8)
			draw_arc(rect.get_center(), cell_size * (0.45 + pulse * 0.08), 0.0, TAU, 44, _with_alpha(col, 0.90), 3.0)
	# A subtle learning path across the piece row.
	for j in range(tutorial_cells.size() - 1):
		_draw_arrow(_cell_center(tutorial_cells[j]), _cell_center(tutorial_cells[j + 1]), _with_alpha(color_select, 0.16), 2.0)

func _draw_settings_menu_animation(pulse: float) -> void:
	# Settings should feel calm and controlled, not like a rules toggle screen.
	draw_rect(board_rect, Color(0, 0, 0, 0.36), true)
	draw_rect(board_rect.grow(-12), _with_alpha(color_silver, 0.18 + pulse * 0.15), false, 3.0)
	var panel_w: float = board_rect.size.x * 0.56
	var panel_h: float = cell_size * 0.55
	for i in range(3):
		var y: float = board_rect.position.y + board_rect.size.y * (0.34 + float(i) * 0.13)
		var x: float = board_rect.position.x + (board_rect.size.x - panel_w) * 0.5
		var card: Rect2 = Rect2(Vector2(x, y), Vector2(panel_w, panel_h))
		draw_rect(card, _with_alpha(color_bg_panel, 0.72), true)
		draw_rect(card, _with_alpha(color_silver, 0.40), false, 1.8)
		var knob_x: float = x + panel_w * (0.25 + 0.25 * float(i))
		draw_circle(Vector2(knob_x + pulse * panel_w * 0.08, y + panel_h * 0.5), panel_h * 0.22, _with_alpha(color_select, 0.72))
	var center: Vector2 = board_rect.get_center()
	for k in range(6):
		var angle: float = float(k) / 6.0 * TAU + float(Time.get_ticks_msec() % 2400) / 2400.0 * TAU
		var p: Vector2 = center + Vector2(cos(angle), sin(angle)) * cell_size * 1.85
		draw_circle(p, cell_size * 0.045, _with_alpha(color_gold, 0.55 + pulse * 0.25))


func _clip_polygon_edge(points: Array, edge: String, value: float) -> Array:
	var output: Array = []
	if points.is_empty():
		return output
	var previous: Vector2 = points[points.size() - 1]
	var previous_inside: bool = _point_inside_clip_edge(previous, edge, value)
	for current_value in points:
		var current: Vector2 = current_value
		var current_inside: bool = _point_inside_clip_edge(current, edge, value)
		if current_inside:
			if not previous_inside:
				output.append(_clip_edge_intersection(previous, current, edge, value))
			output.append(current)
		elif previous_inside:
			output.append(_clip_edge_intersection(previous, current, edge, value))
		previous = current
		previous_inside = current_inside
	return output

func _point_inside_clip_edge(point: Vector2, edge: String, value: float) -> bool:
	match edge:
		"left":
			return point.x >= value
		"right":
			return point.x <= value
		"top":
			return point.y >= value
		"bottom":
			return point.y <= value
	return true

func _clip_edge_intersection(a: Vector2, b: Vector2, edge: String, value: float) -> Vector2:
	var delta: Vector2 = b - a
	if edge == "left" or edge == "right":
		if abs(delta.x) <= 0.0001:
			return Vector2(value, a.y)
		var t_x: float = clamp((value - a.x) / delta.x, 0.0, 1.0)
		return a + delta * t_x
	if abs(delta.y) <= 0.0001:
		return Vector2(a.x, value)
	var t_y: float = clamp((value - a.y) / delta.y, 0.0, 1.0)
	return a + delta * t_y

func _clip_polygon_to_rect(points: PackedVector2Array, clip_rect: Rect2) -> PackedVector2Array:
	var clipped: Array = []
	for p in points:
		clipped.append(p)
	var left: float = clip_rect.position.x
	var right: float = clip_rect.position.x + clip_rect.size.x
	var top: float = clip_rect.position.y
	var bottom: float = clip_rect.position.y + clip_rect.size.y
	clipped = _clip_polygon_edge(clipped, "left", left)
	clipped = _clip_polygon_edge(clipped, "right", right)
	clipped = _clip_polygon_edge(clipped, "top", top)
	clipped = _clip_polygon_edge(clipped, "bottom", bottom)
	var result: PackedVector2Array = PackedVector2Array()
	for p2 in clipped:
		result.append(p2)
	return result

func _draw_colored_polygon_clipped(points: PackedVector2Array, clip_rect: Rect2, color: Color) -> void:
	var clipped: PackedVector2Array = _clip_polygon_to_rect(points, clip_rect)
	if clipped.size() >= 3:
		draw_colored_polygon(clipped, color)


func _draw_collections_menu_animation(pulse: float, tick: float) -> void:
	# Collections is a premium vault/showcase, not a control table.
	# Keep it visually distinct from Settings: no slider bars, no calibration cards.
	# The preview reads as a complete-set tracker with collectible token pedestals,
	# carousel arcs, and showcase-light sweeps.
	draw_rect(board_rect, Color("#050715", 0.32), true)
	var center: Vector2 = board_rect.get_center()
	var vault_rect: Rect2 = board_rect.grow(-cell_size * 0.42)
	draw_rect(vault_rect, Color("#020617", 0.34), true)
	draw_rect(vault_rect, _with_alpha(color_gold, 0.34 + pulse * 0.12), false, 3.0)
	draw_rect(vault_rect.grow(-cell_size * 0.10), _with_alpha(color_select, 0.16 + pulse * 0.10), false, 1.8)

	# Showcase carousel rings: slow, collectible-display energy.
	var orbit_radii: Array = [cell_size * 1.18, cell_size * 1.78, cell_size * 2.28]
	for i in range(orbit_radii.size()):
		var radius: float = float(orbit_radii[i])
		var start_angle: float = tick * TAU * (0.6 + float(i) * 0.12) + float(i) * 0.72
		var col: Color = color_gold if i == 0 else (color_select if i == 1 else color_last)
		draw_arc(center, radius, start_angle, start_angle + PI * 1.18, 72, _with_alpha(col, 0.22 + pulse * 0.12), 2.4)
		draw_arc(center, radius, start_angle + PI, start_angle + PI * 1.72, 72, _with_alpha(col, 0.12 + pulse * 0.08), 1.5)

	# Five collectible role pedestals, matching the official set order.
	var kinds: Array = [SigmaRules.KIND_MONARCH, SigmaRules.KIND_GUARDIAN, SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]
	var owner_rows: Array = [0, BOARD_SIZE - 1]
	for owner_index in range(owner_rows.size()):
		var row: int = int(owner_rows[owner_index])
		var owner: int = SigmaRules.OWNER_P2 if row == 0 else SigmaRules.OWNER_P1
		for i in range(kinds.size()):
			var col_index: int = i * 2
			if i == 2:
				col_index = 4
			var cell: Vector2i = Vector2i(row, clamp(col_index, 0, BOARD_SIZE - 1))
			var kind: String = String(kinds[i])
			var accent: Color = _role_accent_for_kind(kind, owner)
			var local_pulse: float = 0.35 + 0.65 * fmod(pulse + float(i) * 0.17 + float(owner_index) * 0.08, 1.0)
			var rect: Rect2 = _cell_rect(cell)
			var pedestal: Rect2 = rect.grow(-cell_size * 0.22)
			draw_rect(pedestal, _with_alpha(accent, 0.12 + local_pulse * 0.10), true)
			draw_rect(pedestal, _with_alpha(accent, 0.54 + local_pulse * 0.22), false, 2.4)
			draw_arc(rect.get_center(), cell_size * (0.31 + local_pulse * 0.04), 0.0, TAU, 36, _with_alpha(accent, 0.50), 2.0)

	# Center set-logo pulse: complete set equipped, not individual interchangeable parts.
	draw_circle(center, cell_size * (0.58 + pulse * 0.06), _with_alpha(color_gold, 0.08 + pulse * 0.06))
	draw_arc(center, cell_size * (0.62 + pulse * 0.04), 0.0, TAU, 60, _with_alpha(color_gold, 0.62), 3.0)
	draw_arc(center, cell_size * (0.42 + pulse * 0.04), 0.0, TAU, 60, _with_alpha(color_select, 0.50), 2.0)
	for spoke in range(5):
		var angle: float = float(spoke) / 5.0 * TAU - PI * 0.5 + tick * TAU * 0.14
		var a: Vector2 = center + Vector2(cos(angle), sin(angle)) * cell_size * 0.34
		var b: Vector2 = center + Vector2(cos(angle), sin(angle)) * cell_size * 0.82
		draw_line(a, b, _with_alpha(color_gold, 0.34 + pulse * 0.18), 2.0)

	# Premium gallery light sweep, angled differently from the normal board shine.
	var sweep_x: float = board_rect.position.x - board_rect.size.x * 0.35 + tick * board_rect.size.x * 1.70
	var sweep_poly: PackedVector2Array = PackedVector2Array([
		Vector2(sweep_x - cell_size * 0.25, board_rect.position.y),
		Vector2(sweep_x + cell_size * 0.16, board_rect.position.y),
		Vector2(sweep_x + cell_size * 1.12, board_rect.position.y + board_rect.size.y),
		Vector2(sweep_x + cell_size * 0.70, board_rect.position.y + board_rect.size.y),
	])
	# Clip the showcase sweep to the playable board rect so it never spills over the preview frame.
	_draw_colored_polygon_clipped(sweep_poly, board_rect, Color("#F2C14E", 0.060))

	# Small unlock/storefront sparkles.
	for j in range(10):
		var t: float = fmod(tick + float(j) * 0.137, 1.0)
		var angle2: float = float(j) * 1.91 + tick * TAU * 0.30
		var sparkle_pos: Vector2 = center + Vector2(cos(angle2), sin(angle2)) * (cell_size * (1.0 + t * 1.55))
		var sparkle_col: Color = color_gold if j % 2 == 0 else color_select
		draw_circle(sparkle_pos, cell_size * (0.018 + 0.016 * sin(t * TAU)), _with_alpha(sparkle_col, 0.32 + pulse * 0.22))

func _draw_tutorial_markers() -> void:
	if tutorial_from.x >= 0:
		var r_from: Rect2 = _cell_rect(tutorial_from)
		draw_rect(r_from.grow(-2), _with_alpha(Color("#F2C14E"), 0.18), true)
		draw_rect(r_from.grow(-2), Color("#F2C14E"), false, 5.0)
		draw_arc(_cell_center(tutorial_from), cell_size * 0.45, 0.0, TAU, 40, _with_alpha(Color("#F2C14E"), 0.85), 3.0)
	if tutorial_to.x >= 0:
		var r_to: Rect2 = _cell_rect(tutorial_to)
		draw_rect(r_to.grow(-6), _with_alpha(Color("#00D1FF"), 0.20), true)
		draw_rect(r_to.grow(-6), Color("#00D1FF"), false, 4.0)
		if tutorial_from.x >= 0:
			_draw_arrow(_cell_center(tutorial_from), _cell_center(tutorial_to), _with_alpha(Color("#F2C14E"), 0.70), 3.0)

func _draw_highlights() -> void:
	for action_value in legal_actions:
		var action: Dictionary = action_value
		var to: Vector2i = action.to
		var center: Vector2 = _cell_center(to)
		var action_type: String = String(action.type)
		if action_type == SigmaRules.ACTION_MOVE:
			draw_circle(center, cell_size * 0.15, _with_alpha(color_move, 0.80))
			draw_arc(center, cell_size * 0.24, 0.0, TAU, 28, _with_alpha(color_move, 0.65), 2.0)
		elif action_type == SigmaRules.ACTION_JUMP:
			if selected.x >= 0:
				_draw_arrow(_cell_center(selected), center, _with_alpha(color_jump, 0.75), 4.0)
			draw_circle(center, cell_size * 0.22, _with_alpha(color_jump, 0.80))
			draw_arc(center, cell_size * 0.31, 0.0, TAU, 32, color_jump, 3.0)
		elif action_type == SigmaRules.ACTION_DEPLOY:
			draw_rect(_cell_rect(to).grow(-8), _with_alpha(color_deploy, 0.22), true)
			draw_circle(center, cell_size * 0.17, _with_alpha(color_deploy, 0.85))
			draw_arc(center, cell_size * 0.27, 0.0, TAU, 32, color_deploy, 3.0)



	for blocked_value in no_cycle_blocked_actions:
		var blocked_action: Dictionary = blocked_value
		var blocked_to: Vector2i = blocked_action.get("to", Vector2i(-1, -1))
		if blocked_to.x >= 0:
			_draw_x_on_cell(blocked_to, color_peril, true)
			draw_rect(_cell_rect(blocked_to).grow(-6), _with_alpha(color_peril, 0.10), true)

func _draw_action_preview() -> void:
	if preview_action.is_empty() or preview_result.is_empty():
		return
	var from_pos: Vector2i = preview_action.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = preview_action.get("to", Vector2i(-1, -1))
	var action_type: String = String(preview_action.get("type", ""))
	var col: Color = color_move
	if action_type == SigmaRules.ACTION_JUMP:
		col = color_jump
	elif action_type == SigmaRules.ACTION_DEPLOY:
		col = color_deploy
	if from_pos.x >= 0 and to_pos.x >= 0:
		_draw_arrow(_cell_center(from_pos), _cell_center(to_pos), _with_alpha(col, 0.96), 6.0)
		draw_rect(_cell_rect(from_pos).grow(-3), _with_alpha(col, 0.18), true)
	if to_pos.x >= 0:
		var to_rect: Rect2 = _cell_rect(to_pos)
		draw_rect(to_rect.grow(-5), _with_alpha(col, 0.28), true)
		draw_rect(to_rect.grow(-5), col, false, 5.0)
		# Ghost destination token.
		var piece: Variant = null
		if action_type == SigmaRules.ACTION_DEPLOY:
			piece = {"owner": rules.turn, "kind": SigmaRules.KIND_GUARDIAN}
		elif from_pos.x >= 0:
			piece = rules.get_piece(from_pos)
		if piece != null:
			_draw_piece_ghost(to_pos, piece, col)
	var captured_positions: Array = preview_result.get("captured_positions", []) as Array
	for pos_value in captured_positions:
		var pos: Vector2i = pos_value
		_draw_x_on_cell(pos, color_jump, false)
	var enemy_surround_positions: Array = preview_result.get("enemy_surround_positions", []) as Array
	for pos_value in enemy_surround_positions:
		var pos: Vector2i = pos_value
		draw_rect(_cell_rect(pos).grow(-7), _with_alpha(color_jump, 0.30), true)
		_draw_x_on_cell(pos, color_jump, false)
	var friendly_retreat_positions: Array = preview_result.get("friendly_retreat_positions", []) as Array
	for pos_value in friendly_retreat_positions:
		var pos: Vector2i = pos_value
		var rect: Rect2 = _cell_rect(pos)
		draw_rect(rect.grow(-7), _with_alpha(color_deploy, 0.25), true)
		draw_rect(rect.grow(-7), color_deploy, false, 4.0)
		_draw_arrow(_cell_center(pos), _cell_center(pos) + Vector2(0, -cell_size * 0.30), _with_alpha(color_deploy, 0.85), 3.0)
	if bool(preview_result.get("surrender", false)):
		var foe: int = rules.enemy(rules.turn)
		var mpos: Vector2i = rules._find_monarch(foe)
		if mpos.x >= 0:
			draw_rect(_cell_rect(mpos).grow(-2), _with_alpha(color_gold, 0.28), true)
			draw_rect(_cell_rect(mpos).grow(-2), color_peril, false, 6.0)

func _draw_piece_ghost(pos: Vector2i, piece: Dictionary, accent: Color) -> void:
	var center: Vector2 = _cell_center(pos)
	var radius: float = cell_size * 0.31
	var owner: int = int(piece.owner)
	var kind: String = String(piece.kind)
	var fill: Color = color_gold if owner == SigmaRules.OWNER_P1 else color_silver
	var role_col: Color = _role_accent_for_kind(kind, owner)
	draw_circle(center, radius, _with_alpha(fill, 0.45))
	draw_arc(center, radius, 0.0, TAU, 48, _with_alpha(accent, 0.95), 3.0)
	draw_arc(center, radius * 0.72, 0.0, TAU, 44, _with_alpha(role_col, 0.88), 2.2)
	_begin_owner_facing_face(center, owner)
	_draw_piece_label(Vector2.ZERO, radius, kind, owner)
	_end_owner_facing_face()

func _draw_illegal_marker() -> void:
	if illegal_marker.x < 0:
		return
	var col: Color = color_peril
	_draw_x_on_cell(illegal_marker, col, illegal_major)
	if illegal_major:
		draw_rect(_cell_rect(illegal_marker).grow(-3), _with_alpha(col, 0.16), true)

func _draw_x_on_cell(pos: Vector2i, col: Color, major: bool) -> void:
	if pos.x < 0:
		return
	var rect: Rect2 = _cell_rect(pos)
	var inset: float = cell_size * (0.24 if major else 0.34)
	var width: float = 7.0 if major else 4.0
	var a: Vector2 = rect.position + Vector2(inset, inset)
	var b: Vector2 = rect.position + rect.size - Vector2(inset, inset)
	var c: Vector2 = rect.position + Vector2(rect.size.x - inset, inset)
	var d: Vector2 = rect.position + Vector2(inset, rect.size.y - inset)
	draw_line(a, b, col, width)
	draw_line(c, d, col, width)

func _with_alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)

func _draw_closed_polyline(points: PackedVector2Array, col: Color, width: float) -> void:
	if points.size() < 2:
		return
	for i in range(points.size()):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		draw_line(a, b, col, width)

func _draw_arrow(a: Vector2, b: Vector2, col: Color, width: float) -> void:
	draw_line(a, b, col, width)
	var dir: Vector2 = (b - a).normalized()
	if dir.length() == 0.0:
		return
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var tip: Vector2 = b - dir * (cell_size * 0.18)
	var left: Vector2 = tip - dir * (cell_size * 0.14) + perp * (cell_size * 0.08)
	var right: Vector2 = tip - dir * (cell_size * 0.14) - perp * (cell_size * 0.08)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), col)

func _draw_last_action() -> void:
	if rules == null or rules.last_action.is_empty():
		return
	var action: Dictionary = rules.last_action
	if action.has("from"):
		var from_pos: Vector2i = action.from
		draw_rect(_cell_rect(from_pos).grow(-4), _with_alpha(color_last, 0.15), true)
		draw_rect(_cell_rect(from_pos).grow(-4), _with_alpha(color_last, 0.45), false, 2.0)
	if action.has("to"):
		var to_pos: Vector2i = action.to
		draw_rect(_cell_rect(to_pos).grow(-4), _with_alpha(color_last, 0.22), true)
		draw_rect(_cell_rect(to_pos).grow(-4), _with_alpha(color_last, 0.65), false, 2.0)

func _draw_selected() -> void:
	if selected.x < 0:
		return
	var pulse: float = _pulse_value()
	var rect: Rect2 = _cell_rect(selected)
	draw_rect(rect.grow(-3 - pulse * 2.0), _with_alpha(color_select, 0.95), false, 4.0)
	draw_circle(_cell_center(selected), cell_size * (0.43 + pulse * 0.035), _with_alpha(color_select, 0.16))

func _draw_mode_frame() -> void:
	if rules == null:
		return
	if deploy_mode:
		draw_rect(board_rect.grow(7), _with_alpha(color_deploy, 0.92), false, 6.0)
	elif _current_turn_in_peril():
		var pulse: float = _pulse_value()
		draw_rect(board_rect.grow(7 + pulse * 2.0), _with_alpha(color_peril, 0.92), false, 6.0)

func _draw_peril() -> void:
	if rules == null:
		return
	for owner_value in [SigmaRules.OWNER_P1, SigmaRules.OWNER_P2]:
		var owner: int = int(owner_value)
		var threats: Array = rules.get_peril_threats(owner)
		if threats.is_empty():
			continue
		for threat_value in threats:
			var t: Dictionary = threat_value
			var mpos: Vector2i = t.monarch
			var from_pos: Vector2i = t.from
			var target: Vector2i = t.get("target", mpos)
			var pulse: float = _pulse_value()
			draw_rect(_cell_rect(mpos).grow(-5 - pulse * 2.0), _with_alpha(color_peril, 0.24), true)
			draw_rect(_cell_rect(mpos).grow(-5 - pulse * 2.0), color_peril, false, 4.0)
			_draw_arrow(_cell_center(from_pos), _cell_center(target), _with_alpha(color_peril, 0.78), 4.0)


func play_coin_motion(action: Dictionary, piece: Dictionary = {}, motion_type: String = "move") -> void:
	if action.is_empty():
		return
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	var from_pos: Vector2i = action.get("from", to_pos)
	if to_pos.x < 0:
		return
	var final_piece = piece
	if final_piece.is_empty() and rules != null:
		var p = rules.get_piece(to_pos)
		if p != null:
			final_piece = p
	if final_piece.is_empty():
		final_piece = {
			"kind": action.get("kind", SigmaRules.KIND_GUARDIAN),
			"owner": action.get("owner", SigmaRules.OWNER_P1),
		}
	coin_motion_kind = String(final_piece.get("kind", SigmaRules.KIND_GUARDIAN))
	coin_motion_owner = int(final_piece.get("owner", SigmaRules.OWNER_P1))
	coin_motion_from = from_pos
	coin_motion_to = to_pos
	coin_motion_type = motion_type
	coin_motion_start_msec = Time.get_ticks_msec()
	match motion_type:
		"capture":
			coin_motion_duration_msec = CINEMATIC_CAPTURE_MS
		"deploy":
			coin_motion_duration_msec = CINEMATIC_DEPLOY_MS
		"elevate":
			coin_motion_duration_msec = CINEMATIC_ELEVATE_MS
		_:
			coin_motion_duration_msec = CINEMATIC_MOVE_MS
	coin_motion_impact_flash = 1.0
	# Deterministic sparkle layout per action. Purely visual; never affects rules.
	cinematic_motion_seed = abs((to_pos.x + 3) * 92821 + (to_pos.y + 7) * 68917 + (from_pos.x + 11) * 31337 + coin_motion_duration_msec)
	coin_motion_active = true
	queue_redraw()

func _draw_coin_motion() -> void:
	if not coin_motion_active:
		return
	var elapsed: float = float(Time.get_ticks_msec() - coin_motion_start_msec)
	var t: float = clamp(elapsed / float(max(1, coin_motion_duration_msec)), 0.0, 1.0)
	var travel_ease: float = _ease_in_out_cubic(t)
	if coin_motion_type == "deploy":
		travel_ease = _ease_out_back(clamp(t, 0.0, 1.0), 0.72)
	elif coin_motion_type == "elevate":
		travel_ease = _ease_out_cubic(t)

	var from_center: Vector2 = _cell_center(coin_motion_from)
	var to_center: Vector2 = _cell_center(coin_motion_to)
	if coin_motion_type == "deploy":
		from_center = to_center + Vector2(0, -cell_size * 1.22)
	elif coin_motion_type == "elevate":
		from_center = to_center

	var base_center: Vector2 = from_center.lerp(to_center, travel_ease)
	var lift_strength: float = 0.08
	if coin_motion_type == "capture":
		lift_strength = 0.44
	elif coin_motion_type == "deploy":
		lift_strength = 0.62
	elif coin_motion_type == "elevate":
		lift_strength = 0.82

	# Heavy movement reads as friction + mass: slow start, deliberate travel,
	# compressed landing, and a small final settle instead of a floaty glide.
	var lift: float = sin(t * PI) * cell_size * lift_strength
	var drag_y: float = sin(t * PI) * cell_size * (0.026 if coin_motion_type == "move" else 0.044)
	var settle: float = 0.0
	if t > 0.78:
		var settle_t: float = (t - 0.78) / 0.22
		settle = sin(settle_t * PI * 2.0) * cell_size * 0.022 * (1.0 - settle_t)
	var center: Vector2 = base_center + Vector2(0, -lift + drag_y + settle)
	var radius: float = cell_size * 0.36
	var impact_t: float = clamp((t - 0.70) / 0.30, 0.0, 1.0)
	var scale_boost: float = 1.0 + sin(t * PI) * (0.035 if coin_motion_type == "move" else 0.10)
	var landing_compress: float = 0.0
	if t > 0.84:
		landing_compress = sin((t - 0.84) / 0.16 * PI) * (0.055 if coin_motion_type == "move" else 0.095)
	var visual_radius: float = radius * (scale_boost + landing_compress)
	var tilt: float = sin(t * PI * 2.0) * (0.045 if coin_motion_type == "move" else 0.14)
	if coin_motion_type == "capture":
		tilt += sin(t * PI) * 0.18
	elif coin_motion_type == "elevate":
		tilt = t * TAU * 1.18

	var motion_col: Color = _motion_color(coin_motion_type, coin_motion_kind, coin_motion_owner)
	_draw_cinematic_motion_trail(from_center, to_center, center, t, motion_col)

	# Contact shadow remains on the table while the token lifts above it.
	var shadow_center: Vector2 = to_center.lerp(base_center, 0.36) + Vector2(0, cell_size * 0.10)
	var shadow_scale: float = clamp(1.20 - sin(t * PI) * 0.56, 0.42, 1.20)
	draw_circle(shadow_center, radius * 0.98 * shadow_scale, Color(0, 0, 0, 0.30))
	draw_circle(shadow_center + Vector2(0, radius * 0.08 * shadow_scale), radius * 0.66 * shadow_scale, Color(0, 0, 0, 0.20))

	if t > 0.48:
		_draw_cinematic_impact_field(to_center, impact_t, motion_col, coin_motion_type)
	if coin_motion_type == "capture" and t > 0.18 and t < 0.82:
		_draw_cinematic_cut_line(from_center, to_center, t, motion_col)
	if coin_motion_type == "elevate":
		_draw_elevate_energy_column(to_center, t, motion_col)

	_draw_motion_token(center, visual_radius, coin_motion_kind, coin_motion_owner, tilt)
	if t >= 1.0:
		coin_motion_active = false
		queue_redraw()

func _draw_motion_token(center: Vector2, radius: float, kind: String, owner: int, tilt: float) -> void:
	_draw_premium_token(center, radius, kind, owner, 1.0, tilt, true)

func _motion_color(motion_type: String, kind: String, owner: int) -> Color:
	if motion_type == "capture":
		return color_jump
	if motion_type == "deploy":
		return color_deploy
	if motion_type == "elevate":
		return color_elevate
	return _alternating_underglow_color(kind, owner, _pulse_value())

func _draw_cinematic_motion_trail(from_center: Vector2, to_center: Vector2, center: Vector2, t: float, col: Color) -> void:
	var path_alpha: float = clamp(sin(t * PI) * 0.42, 0.0, 0.42)
	if path_alpha <= 0.01:
		return
	var dir: Vector2 = to_center - from_center
	if dir.length() < 1.0:
		dir = Vector2(0, -1)
	var n: Vector2 = dir.normalized()
	var p: Vector2 = Vector2(-n.y, n.x)
	draw_line(from_center, center, _with_alpha(col, path_alpha * 0.42), 8.0)
	draw_line(from_center + p * 4.0, center + p * 2.0, _with_alpha(col.lightened(0.22), path_alpha * 0.30), 2.6)
	draw_line(from_center - p * 4.0, center - p * 2.0, _with_alpha(col.darkened(0.08), path_alpha * 0.24), 2.2)

func _draw_cinematic_impact_field(to_center: Vector2, impact_t: float, col: Color, motion_type: String) -> void:
	if impact_t <= 0.0:
		return
	var fade: float = 1.0 - impact_t
	var base: float = cell_size * (0.20 + impact_t * (0.48 if motion_type == "move" else 0.70))
	draw_arc(to_center, base, 0.0, TAU, 72, _with_alpha(col.lightened(0.20), 0.68 * fade), 4.4)
	draw_arc(to_center, base * 0.72, 0.0, TAU, 72, _with_alpha(color_gold, 0.28 * fade), 2.4)
	if motion_type == "capture" or motion_type == "elevate":
		for i in range(10):
			var a: float = TAU * float(i) / 10.0 + float(cinematic_motion_seed % 37) * 0.017
			var start: Vector2 = to_center + Vector2(cos(a), sin(a)) * base * 0.46
			var finish: Vector2 = to_center + Vector2(cos(a), sin(a)) * base * (0.86 + impact_t * 0.40)
			draw_line(start, finish, _with_alpha(col.lightened(0.35), 0.42 * fade), 2.0)

func _draw_cinematic_cut_line(from_center: Vector2, to_center: Vector2, t: float, col: Color) -> void:
	var local_t: float = clamp((t - 0.18) / 0.64, 0.0, 1.0)
	var fade: float = sin(local_t * PI)
	var pos: Vector2 = from_center.lerp(to_center, local_t)
	var dir: Vector2 = (to_center - from_center).normalized()
	if dir.length() < 0.5:
		dir = Vector2(1, 0)
	var p: Vector2 = Vector2(-dir.y, dir.x)
	draw_line(pos - dir * cell_size * 0.38 - p * 3.0, pos + dir * cell_size * 0.38 + p * 3.0, _with_alpha(col.lightened(0.28), 0.72 * fade), 5.0)
	draw_line(pos - dir * cell_size * 0.30 + p * 5.0, pos + dir * cell_size * 0.30 - p * 5.0, _with_alpha(Color.WHITE, 0.38 * fade), 2.2)

func _draw_elevate_energy_column(center: Vector2, t: float, col: Color) -> void:
	var rise: float = sin(t * PI)
	var height: float = cell_size * (0.20 + rise * 0.72)
	var width: float = cell_size * (0.16 + rise * 0.12)
	var top: Vector2 = center + Vector2(0, -height)
	var poly: PackedVector2Array = PackedVector2Array([
		center + Vector2(-width, 0),
		top + Vector2(-width * 0.38, 0),
		top + Vector2(width * 0.38, 0),
		center + Vector2(width, 0),
	])
	draw_colored_polygon(poly, _with_alpha(col, 0.12 + rise * 0.14))
	draw_line(center + Vector2(-width * 0.55, 0), top, _with_alpha(col.lightened(0.25), 0.46 * rise), 2.4)
	draw_line(center + Vector2(width * 0.55, 0), top, _with_alpha(Color.WHITE, 0.22 * rise), 1.6)

func _ease_out_back(t: float, overshoot: float = 1.70158) -> float:
	var u: float = t - 1.0
	return 1.0 + (overshoot + 1.0) * u * u * u + overshoot * u * u

func _owner_face_rotation(owner: int) -> float:
	# Gold starts on the bottom and reads normally from the bottom player.
	# Silver starts on the top, so its readable face turns toward the top player.
	return PI if owner == SigmaRules.OWNER_P2 else 0.0

func _begin_owner_facing_face(center: Vector2, owner: int, extra_rotation: float = 0.0) -> void:
	draw_set_transform(center, _owner_face_rotation(owner) + extra_rotation, Vector2.ONE)

func _end_owner_facing_face() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ease_out_cubic(t: float) -> float:
	var inv: float = 1.0 - t
	return 1.0 - inv * inv * inv

func _ease_in_out_cubic(t: float) -> float:
	if t < 0.5:
		return 4.0 * t * t * t
	var f: float = -2.0 * t + 2.0
	return 1.0 - (f * f * f) / 2.0

func _should_skip_piece_for_motion(pos: Vector2i) -> bool:
	return coin_motion_active and pos == coin_motion_to

func _draw_pieces() -> void:
	if rules == null:
		return
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = rules.board[r][c]
			if p == null:
				continue
			var pos: Vector2i = Vector2i(r, c)
			if _should_skip_piece_for_motion(pos):
				continue
			_draw_piece(pos, p)

func _draw_piece(pos: Vector2i, piece: Dictionary) -> void:
	var center: Vector2 = _cell_center(pos)
	var owner: int = int(piece.owner)
	var kind: String = String(piece.kind)
	var radius: float = cell_size * 0.36 * _piece_height_scale(kind)
	_draw_premium_token(center, radius, kind, owner, 0.0, 0.0, false, selected == pos)

func _draw_premium_token(center: Vector2, radius: float, kind: String, owner: int, lift: float = 0.0, tilt: float = 0.0, moving: bool = false, selected_piece: bool = false) -> void:
	if active_piece_set == PIECE_SET_LIONS_DEN:
		if _draw_texture_token_for_set(PIECE_SET_LIONS_DEN, center, radius, kind, owner, lift, tilt, moving, selected_piece):
			return
	if active_piece_set == PIECE_SET_DRACONIAN:
		if _draw_texture_token_for_set(PIECE_SET_DRACONIAN, center, radius, kind, owner, lift, tilt, moving, selected_piece):
			return
	if active_piece_set == PIECE_SET_VECTOR:
		if _draw_texture_token_for_set(PIECE_SET_VECTOR, center, radius, kind, owner, lift, tilt, moving, selected_piece):
			return
		_draw_vector_token(center, radius, kind, owner, lift, tilt, moving, selected_piece)
		return
	if _draw_classic_texture_token(center, radius, kind, owner, lift, tilt, moving, selected_piece):
		return
	# Classic SIGMA Tokens: premium casino-chip ownership + abstract role identity.
	# This is visual only. Legal identity still comes from SigmaRules.gd.
	var fill: Color = color_gold if owner == SigmaRules.OWNER_P1 else color_silver
	var shadow: Color = color_gold_shadow if owner == SigmaRules.OWNER_P1 else color_silver_shadow
	var accent: Color = _role_accent_for_kind(kind, owner)
	var height: float = _piece_height_scale(kind)
	var slab_offset: float = radius * (0.14 + height * 0.055)
	var shadow_alpha: float = 0.34 if not moving else 0.24

	# Weighted table shadow: tokens should feel like physical premium chips, not flat icons.
	draw_circle(center + Vector2(0, radius * 0.27 + lift * 2.2), radius * (1.13 - lift * 0.08), Color(0, 0, 0, shadow_alpha))
	draw_circle(center + Vector2(0, radius * 0.36), radius * 0.76, Color(0, 0, 0, shadow_alpha * 0.62))

	# Centered alternating owner/role aura. Monarch is intentionally the most ceremonial.
	var fallback_pulse: float = _pulse_value()
	var aura_alpha: float = 0.13
	if kind == SigmaRules.KIND_MONARCH:
		aura_alpha = 0.29
	elif kind != SigmaRules.KIND_GUARDIAN:
		aura_alpha = 0.20
	draw_circle(center, radius * (1.20 + fallback_pulse * 0.055), _with_alpha(_alternating_underglow_color(kind, owner, fallback_pulse), aura_alpha))

	# Heavy side slab and beveled owner-metal body.
	draw_circle(center + Vector2(0, slab_offset), radius * 1.04, shadow.darkened(0.24))
	draw_circle(center + Vector2(0, slab_offset * 0.55), radius * 1.015, shadow)
	draw_circle(center, radius * 1.01, fill.lightened(0.04))
	draw_circle(center, radius * 0.91, fill.darkened(0.05))
	draw_circle(center, radius * 0.78, fill.lightened(0.10))

	# Casino-chip rim and radial ticks. Body stays unrotated for consistent tabletop lighting.
	draw_arc(center, radius * 1.01, 0.0, TAU, 80, shadow.darkened(0.14), 5.5)
	draw_arc(center, radius * 0.90, 0.0, TAU, 72, _with_alpha(Color("#FFFFFF"), 0.52), 2.4)
	draw_arc(center, radius * 0.76, 0.0, TAU, 64, _with_alpha(accent, 0.92), 3.4)
	_draw_classic_sigma_chip_marks(center, radius, accent, owner)
	draw_circle(center + Vector2(-radius * 0.20, -radius * 0.24), radius * 0.34, Color(1, 1, 1, 0.25))
	draw_arc(center, radius * 0.86, -PI * 0.88 + tilt * 0.12, PI * 0.10 + tilt * 0.12, 36, Color(1, 1, 1, 0.62), 3.6)

	# Readable face content rotates toward the owner; chip body/rim/shadow do not.
	_begin_owner_facing_face(center, owner, tilt if moving else 0.0)
	_draw_classic_sigma_inner_core(Vector2.ZERO, radius, kind, owner, accent)
	_draw_token_identity_badge(Vector2.ZERO, radius, kind, accent)
	_draw_piece_icon(Vector2.ZERO, radius, kind, accent, owner)
	_draw_piece_label(Vector2.ZERO, radius, kind, owner)
	_end_owner_facing_face()

func _draw_vector_token(center: Vector2, radius: float, kind: String, owner: int, lift: float = 0.0, tilt: float = 0.0, moving: bool = false, selected_piece: bool = false) -> void:
	var accent: Color = _role_accent_for_kind(kind, owner)
	var owner_trim: Color = Color("#D4AF37") if owner == SigmaRules.OWNER_P1 else Color("#E8EDF2")
	var pulse: float = _pulse_value()
	var token_center: Vector2 = center + Vector2(0, -radius * 0.10 * lift)
	var rotation: float = _owner_face_rotation(owner) + (tilt if moving else 0.0)
	# Contact shadow and neon ground pulse.
	draw_circle(center + Vector2(0, radius * 0.40), radius * 0.86, Color("#000000", 0.46 if not moving else 0.30))
	draw_circle(center, radius * (1.18 + pulse * 0.05), _with_alpha(accent, 0.15 + pulse * 0.04))
	if selected_piece:
		draw_arc(center, radius * 1.26, 0.0, TAU, 64, _with_alpha(accent.lightened(0.24), 0.82), 3.8)
		draw_arc(center, radius * 1.38, 0.0, TAU, 64, _with_alpha(owner_trim, 0.34), 2.6)
	# Draw owner-facing obelisk silhouette.
	draw_set_transform(token_center, rotation, Vector2.ONE)
	var base_y: float = radius * 0.56
	var base_w: float = radius * 0.96
	var base_h: float = radius * 0.34
	var base: PackedVector2Array = PackedVector2Array([
		Vector2(-base_w * 0.62, base_y - base_h * 0.25),
		Vector2(base_w * 0.62, base_y - base_h * 0.25),
		Vector2(base_w * 0.82, base_y + base_h * 0.35),
		Vector2(base_w * 0.44, base_y + base_h * 0.66),
		Vector2(-base_w * 0.44, base_y + base_h * 0.66),
		Vector2(-base_w * 0.82, base_y + base_h * 0.35),
	])
	draw_colored_polygon(base, Color("#05070B", 1.0))
	_draw_closed_polyline(base, _with_alpha(owner_trim, 0.86), 2.0)
	var body_h: float = radius * (1.50 + (_piece_height_scale(kind) - 1.0) * 0.22)
	var body_w: float = radius * 0.62
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(0, -body_h),
		Vector2(body_w * 0.62, -body_h * 0.70),
		Vector2(body_w * 0.72, base_y - base_h * 0.16),
		Vector2(body_w * 0.34, base_y + base_h * 0.06),
		Vector2(-body_w * 0.34, base_y + base_h * 0.06),
		Vector2(-body_w * 0.72, base_y - base_h * 0.16),
		Vector2(-body_w * 0.62, -body_h * 0.70),
	])
	draw_colored_polygon(body, Color("#070A0F", 1.0))
	_draw_closed_polyline(body, _with_alpha(owner_trim, 0.78), 1.8)
	# Facets.
	draw_line(Vector2(0, -body_h), Vector2(0, base_y - base_h * 0.02), _with_alpha(Color.WHITE, 0.28), 1.2)
	draw_line(Vector2(-body_w * 0.56, -body_h * 0.68), Vector2(-body_w * 0.22, base_y - base_h * 0.04), _with_alpha(owner_trim, 0.36), 1.2)
	draw_line(Vector2(body_w * 0.56, -body_h * 0.68), Vector2(body_w * 0.22, base_y - base_h * 0.04), _with_alpha(owner_trim, 0.36), 1.2)
	# Neon laser channels.
	var laser_a: Color = _with_alpha(accent.lightened(0.20), 0.92)
	var laser_b: Color = _with_alpha(accent, 0.54 + pulse * 0.18)
	draw_line(Vector2(0, -body_h * 0.82), Vector2(0, base_y - base_h * 0.22), laser_a, 3.0)
	draw_line(Vector2(-body_w * 0.30, -body_h * 0.55), Vector2(-body_w * 0.18, base_y - base_h * 0.12), laser_b, 2.0)
	draw_line(Vector2(body_w * 0.30, -body_h * 0.55), Vector2(body_w * 0.18, base_y - base_h * 0.12), laser_b, 2.0)
	# Role badge plate and icon.
	var badge_center: Vector2 = Vector2(0, -body_h * 0.42)
	var badge: PackedVector2Array = PackedVector2Array([badge_center + Vector2(0, -radius * 0.32), badge_center + Vector2(radius * 0.34, 0), badge_center + Vector2(0, radius * 0.32), badge_center + Vector2(-radius * 0.34, 0)])
	draw_colored_polygon(badge, Color("#000000", 0.62))
	_draw_closed_polyline(badge, laser_a, 2.0)
	_draw_piece_icon(badge_center, radius * 0.44, kind, laser_a, owner)
	# Base letter/identity.
	var font: Font = ThemeDB.fallback_font
	var font_size: int = int(max(11.0, radius * 0.34))
	var letter_size: Vector2 = font.get_string_size(kind, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-letter_size.x * 0.5, base_y + base_h * 0.31), kind, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, _with_alpha(owner_trim, 0.95))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_classic_sigma_chip_marks(center: Vector2, radius: float, accent: Color, owner: int) -> void:
	var tick_col: Color = _with_alpha(accent, 0.82)
	var metal_col: Color = _with_alpha(color_gold if owner == SigmaRules.OWNER_P1 else color_silver, 0.96)
	for i in range(16):
		var angle: float = TAU * float(i) / 16.0
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var inner: Vector2 = center + dir * radius * 0.92
		var outer: Vector2 = center + dir * radius * 1.03
		var mark_col: Color = tick_col if i % 2 == 0 else metal_col.darkened(0.08)
		draw_line(inner, outer, mark_col, 2.0)

func _draw_classic_sigma_inner_core(center: Vector2, radius: float, kind: String, owner: int, accent: Color) -> void:
	var inner_fill: Color = Color("#111827") if owner == SigmaRules.OWNER_P1 else Color("#F8FAFC")
	var inner_alpha: float = 0.18 if owner == SigmaRules.OWNER_P1 else 0.32
	draw_circle(center, radius * 0.58, _with_alpha(inner_fill, inner_alpha))
	draw_arc(center, radius * 0.58, 0.0, TAU, 56, _with_alpha(accent, 0.86), 2.5)
	if kind == SigmaRules.KIND_MONARCH:
		draw_arc(center, radius * 0.66, -PI * 0.25, PI * 1.25, 56, _with_alpha(accent, 0.45), 2.0)
	elif kind == SigmaRules.KIND_GUARDIAN:
		draw_rect(Rect2(center - Vector2(radius * 0.42, radius * 0.42), Vector2(radius * 0.84, radius * 0.84)), _with_alpha(accent, 0.10), false, 1.6)
	elif kind == SigmaRules.KIND_SENTINEL:
		draw_arc(center, radius * 0.68, 0.0, TAU, 64, _with_alpha(accent, 0.24), 1.8)
	elif kind == SigmaRules.KIND_INFILTRATOR:
		draw_line(center + Vector2(-radius * 0.48, radius * 0.36), center + Vector2(radius * 0.48, -radius * 0.36), _with_alpha(accent, 0.28), 2.0)
	elif kind == SigmaRules.KIND_ASSASSIN:
		draw_line(center + Vector2(-radius * 0.52, radius * 0.52), center + Vector2(radius * 0.52, -radius * 0.52), _with_alpha(accent, 0.30), 2.8)

func _draw_token_identity_badge(center: Vector2, radius: float, kind: String, col: Color) -> void:
	if kind == SigmaRules.KIND_MONARCH:
		var crown: PackedVector2Array = PackedVector2Array([
			center + Vector2(-radius * 0.48, radius * 0.10),
			center + Vector2(-radius * 0.25, -radius * 0.34),
			center + Vector2(0, -radius * 0.08),
			center + Vector2(radius * 0.25, -radius * 0.34),
			center + Vector2(radius * 0.48, radius * 0.10),
		])
		draw_colored_polygon(crown, Color(col.r, col.g, col.b, 0.20))
		_draw_closed_polyline(crown, Color(col.r, col.g, col.b, 0.82), 2.2)
	elif kind == SigmaRules.KIND_GUARDIAN:
		draw_rect(Rect2(center - Vector2(radius * 0.32, radius * 0.32), Vector2(radius * 0.64, radius * 0.64)), Color(col.r, col.g, col.b, 0.08), true)
	elif kind == SigmaRules.KIND_SENTINEL:
		draw_arc(center, radius * 0.52, 0.0, TAU, 40, Color(col.r, col.g, col.b, 0.42), 2.4)
		draw_arc(center, radius * 0.36, 0.0, TAU, 40, Color(col.r, col.g, col.b, 0.22), 2.0)
	elif kind == SigmaRules.KIND_INFILTRATOR:
		draw_line(center + Vector2(-radius * 0.46, 0), center + Vector2(radius * 0.46, 0), Color(col.r, col.g, col.b, 0.34), 3.0)
		draw_line(center + Vector2(0, -radius * 0.46), center + Vector2(0, radius * 0.46), Color(col.r, col.g, col.b, 0.34), 3.0)
	elif kind == SigmaRules.KIND_ASSASSIN:
		draw_line(center + Vector2(-radius * 0.52, radius * 0.52), center + Vector2(radius * 0.52, -radius * 0.52), Color(col.r, col.g, col.b, 0.38), 4.0)
		draw_line(center + Vector2(-radius * 0.44, radius * 0.22), center + Vector2(radius * 0.22, -radius * 0.44), Color(col.r, col.g, col.b, 0.20), 2.0)

func _draw_piece_icon(center: Vector2, radius: float, kind: String, outline: Color, owner: int) -> void:
	var icon_col: Color = _with_alpha(outline, 0.92)
	if kind == SigmaRules.KIND_MONARCH:
		_draw_monarch_icon(center, radius, icon_col)
	elif kind == SigmaRules.KIND_GUARDIAN:
		_draw_guardian_icon(center, radius, icon_col)
	elif kind == SigmaRules.KIND_SENTINEL:
		_draw_sentinel_icon(center, radius, icon_col)
	elif kind == SigmaRules.KIND_INFILTRATOR:
		_draw_infiltrator_icon(center, radius, icon_col, owner)
	elif kind == SigmaRules.KIND_ASSASSIN:
		_draw_assassin_icon(center, radius, icon_col)

func _draw_piece_label(center: Vector2, radius: float, kind: String, owner: int) -> void:
	# This may be drawn inside an owner-facing transform, so `center` can be local Vector2.ZERO.
	var font: Font = ThemeDB.fallback_font
	var font_size: int = int(max(16.0, cell_size * 0.30))
	var text_size: Vector2 = font.get_string_size(kind, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos: Vector2 = center - Vector2(text_size.x * 0.5, -radius * 0.42)
	var text_color: Color = color_p1_text if owner == SigmaRules.OWNER_P1 else color_p2_text
	draw_string(font, text_pos, kind, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

func _draw_monarch_icon(center: Vector2, radius: float, col: Color) -> void:
	var diamond: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -radius * 0.55),
		center + Vector2(radius * 0.48, 0),
		center + Vector2(0, radius * 0.55),
		center + Vector2(-radius * 0.48, 0),
	])
	draw_colored_polygon(diamond, _with_alpha(col, 0.20))
	_draw_closed_polyline(diamond, col, 3.0)
	draw_circle(center, radius * 0.16, col)

func _draw_guardian_icon(center: Vector2, radius: float, col: Color) -> void:
	var shield: PackedVector2Array = PackedVector2Array([
		center + Vector2(-radius * 0.34, -radius * 0.35),
		center + Vector2(radius * 0.34, -radius * 0.35),
		center + Vector2(radius * 0.28, radius * 0.08),
		center + Vector2(0, radius * 0.48),
		center + Vector2(-radius * 0.28, radius * 0.08),
	])
	draw_colored_polygon(shield, _with_alpha(col, 0.14))
	_draw_closed_polyline(shield, col, 2.5)
	draw_line(center + Vector2(0, -radius * 0.28), center + Vector2(0, radius * 0.30), _with_alpha(col, 0.75), 2.0)

func _draw_sentinel_icon(center: Vector2, radius: float, col: Color) -> void:
	draw_arc(center, radius * 0.42, 0.0, TAU, 36, col, 3.0)
	draw_circle(center, radius * 0.13, col)
	draw_line(center + Vector2(-radius * 0.50, 0), center + Vector2(radius * 0.50, 0), _with_alpha(col, 0.65), 2.0)
	draw_line(center + Vector2(0, -radius * 0.50), center + Vector2(0, radius * 0.50), _with_alpha(col, 0.65), 2.0)

func _draw_infiltrator_icon(center: Vector2, radius: float, col: Color, owner: int) -> void:
	var dir: Vector2 = Vector2(0, -1)
	var start: Vector2 = center - dir * radius * 0.42
	var tip: Vector2 = center + dir * radius * 0.42
	draw_line(start, tip, col, 3.0)
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var left: Vector2 = tip - dir * radius * 0.22 + perp * radius * 0.14
	var right: Vector2 = tip - dir * radius * 0.22 - perp * radius * 0.14
	draw_colored_polygon(PackedVector2Array([tip, left, right]), col)
	draw_line(center + Vector2(-radius * 0.34, 0), center + Vector2(radius * 0.34, 0), _with_alpha(col, 0.55), 2.0)

func _draw_assassin_icon(center: Vector2, radius: float, col: Color) -> void:
	draw_line(center + Vector2(-radius * 0.42, radius * 0.42), center + Vector2(radius * 0.42, -radius * 0.42), col, 4.0)
	draw_line(center + Vector2(-radius * 0.18, radius * 0.45), center + Vector2(radius * 0.45, -radius * 0.18), _with_alpha(col, 0.50), 2.0)
	draw_circle(center + Vector2(radius * 0.44, -radius * 0.44), radius * 0.09, col)

func _piece_height_scale(kind: String) -> float:
	if kind == SigmaRules.KIND_MONARCH:
		return 1.16
	if kind == SigmaRules.KIND_SENTINEL or kind == SigmaRules.KIND_INFILTRATOR or kind == SigmaRules.KIND_ASSASSIN:
		return 1.06
	return 1.0

func _role_accent_for_kind(kind: String, owner: int) -> Color:
	if kind == SigmaRules.KIND_MONARCH:
		return ROLE_COLOR_MONARCH_GOLD if owner == SigmaRules.OWNER_P1 else ROLE_COLOR_MONARCH_SILVER
	if kind == SigmaRules.KIND_GUARDIAN:
		return ROLE_COLOR_GUARDIAN_GOLD if owner == SigmaRules.OWNER_P1 else ROLE_COLOR_GUARDIAN_SILVER
	if kind == SigmaRules.KIND_SENTINEL:
		return ROLE_COLOR_SENTINEL_GOLD if owner == SigmaRules.OWNER_P1 else ROLE_COLOR_SENTINEL_SILVER
	if kind == SigmaRules.KIND_INFILTRATOR:
		return ROLE_COLOR_INFILTRATOR_GOLD if owner == SigmaRules.OWNER_P1 else ROLE_COLOR_INFILTRATOR_SILVER
	if kind == SigmaRules.KIND_ASSASSIN:
		return ROLE_COLOR_ASSASSIN_GOLD if owner == SigmaRules.OWNER_P1 else ROLE_COLOR_ASSASSIN_SILVER
	return color_gold if owner == SigmaRules.OWNER_P1 else color_silver

func _piece_glow_color(kind: String, owner: int) -> Color:
	return _alternating_underglow_color(kind, owner, _pulse_value())

func _owner_glow_for_owner(owner: int) -> Color:
	return color_gold if owner == SigmaRules.OWNER_P1 else color_silver

func _alternating_underglow_color(kind: String, owner: int, pulse: float) -> Color:
	# v1.4.0.2: Under-glow breathes between owner color and role color:
	# Gold Monarch = Gold <-> Ruby Red, Silver Monarch = Silver <-> Royal Purple, etc.
	var owner_color: Color = _owner_glow_for_owner(owner)
	var role_color: Color = _role_accent_for_kind(kind, owner)
	if kind == SigmaRules.KIND_GUARDIAN and owner == SigmaRules.OWNER_P2:
		# Obsidian identity still needs visible energy on dark boards.
		role_color = Color("#111827")
	var blend: float = clamp(pulse, 0.0, 1.0)
	return owner_color.lerp(role_color, blend)

func _outline_for_kind(kind: String, owner: int) -> Color:
	return _role_accent_for_kind(kind, owner)


func set_board_input_enabled(value: bool) -> void:
	board_input_enabled = value
	# Keep the board visible, but prevent taps from reaching gameplay when menus,
	# pause, modals, or tutorial cards are covering the active match.
	mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	if not value:
		press_cell = Vector2i(-1, -1)
		_reset_piece_tap_chain()


func _gui_input(event: InputEvent) -> void:
	if not board_input_enabled:
		return
	if rules == null or rules.game_over or rules.has_pending_elevation():
		return
	var pointer_pos: Vector2 = Vector2.ZERO
	var is_press: bool = false
	var is_release: bool = false
	var is_touch_event: bool = false

	if event is InputEventMouseButton:
		# Android can emit a real touch event and then an emulated mouse event
		# for the same tap. After v1.2.9.2 added "tap selected piece again to
		# unselect", that duplicate mouse event could immediately undo the
		# selection. Ignore/debounce those synthetic mouse duplicates.
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		pointer_pos = mouse_event.position
		var mouse_cell: Vector2i = _pos_to_cell(pointer_pos)
		if OS.has_feature("android"):
			return
		if Time.get_ticks_msec() - last_touch_release_msec < touch_mouse_debounce_msec and mouse_cell == last_touch_release_cell:
			return
		is_press = mouse_event.pressed
		is_release = not mouse_event.pressed
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		pointer_pos = touch_event.position
		is_press = touch_event.pressed
		is_release = not touch_event.pressed
		is_touch_event = true
	else:
		return

	if is_press:
		press_cell = _pos_to_cell(pointer_pos)
		press_start_msec = Time.get_ticks_msec()
		press_start_pos = pointer_pos
		return

	if not is_release:
		return

	var cell: Vector2i = _pos_to_cell(pointer_pos)
	if is_touch_event:
		last_touch_release_msec = Time.get_ticks_msec()
		last_touch_release_cell = cell

	var elapsed: int = Time.get_ticks_msec() - press_start_msec
	var moved: bool = pointer_pos.distance_to(press_start_pos) > 18.0
	if cell.x >= 0 and cell == press_cell and elapsed >= long_press_msec and not moved:
		_emit_info_for_cell(cell)
		press_cell = Vector2i(-1, -1)
		return

	press_cell = Vector2i(-1, -1)
	if cell.x < 0:
		_reset_piece_tap_chain()
		if deploy_mode and selected.x >= 0:
			clear_action_preview()
			clear_illegal_marker()
			deploy_mode_requested.emit(false)
			return
		if not preview_action.is_empty():
			clear_action_preview()
			_clear_selection()
			preview_cancel_requested.emit("Preview canceled. Selection cleared.")
		else:
			_clear_selection()
		return
	_handle_cell_tap(cell)


func _emit_info_for_cell(cell: Vector2i) -> void:
	for blocked_value in no_cycle_blocked_actions:
		var blocked_action: Dictionary = blocked_value
		var blocked_to: Vector2i = blocked_action.get("to", Vector2i(-1, -1))
		if blocked_to == cell:
			show_illegal_marker(cell, "NO CYCLE — fourth repeated no-progress back-and-forth move.", true)
			selection_changed.emit("NO CYCLE — fourth repeated no-progress back-and-forth move.")
			return

	var p = rules.get_piece(cell)
	if p == null:
		return
	info_requested.emit(String(p.kind), int(p.owner), cell)

func _handle_cell_tap(cell: Vector2i) -> void:
	for action_value in legal_actions:
		var action: Dictionary = action_value
		var to: Vector2i = action.to
		if to == cell:
			_reset_piece_tap_chain()
			clear_illegal_marker()
			action_chosen.emit(action)
			return

	for blocked_value in no_cycle_blocked_actions:
		var blocked_action: Dictionary = blocked_value
		var blocked_to: Vector2i = blocked_action.get("to", Vector2i(-1, -1))
		if blocked_to == cell:
			_reset_piece_tap_chain()
			show_illegal_marker(cell, "NO CYCLE — fourth repeated no-progress back-and-forth move.", true)
			selection_changed.emit("NO CYCLE — fourth repeated no-progress back-and-forth move.")
			return

	if deploy_mode and selected.x >= 0:
		_reset_piece_tap_chain()
		clear_action_preview()
		clear_illegal_marker()
		deploy_mode_requested.emit(false)
		return

	var p = rules.get_piece(cell)
	if p != null and int(p.owner) == rules.turn:
		var tap_count: int = _register_piece_tap(cell)
		if tap_count >= 3 and selected == cell:
			clear_illegal_marker()
			clear_action_preview()
			if deploy_mode:
				deploy_mode_requested.emit(false)
			else:
				_clear_selection()
			_reset_piece_tap_chain()
			return
		if tap_count == 2:
			if not preview_action.is_empty():
				clear_action_preview()
				preview_cancel_requested.emit("Preview canceled. Deploy shortcut opened.")
			clear_illegal_marker()
			if not deploy_mode:
				deploy_mode_requested.emit(true)
			_select_friendly_piece(cell, p)
			return
		if selected == cell and preview_action.is_empty():
			# Single re-tap keeps the piece selected. Fast second tap opens Deploy;
			# fast third tap clears selection. This prevents double tap from being
			# eaten by the old "tap again to unselect" behavior.
			clear_illegal_marker()
			_select_friendly_piece(cell, p)
			return
		if not preview_action.is_empty():
			clear_action_preview()
			preview_cancel_requested.emit("Preview canceled. Selected another friendly piece.")
		clear_illegal_marker()
		_select_friendly_piece(cell, p)
		return

	_reset_piece_tap_chain()
	if not preview_action.is_empty():
		clear_action_preview()
		clear_illegal_marker()
		_clear_selection()
		preview_cancel_requested.emit("Preview canceled. Selection cleared.")
		return

	clear_illegal_marker()
	_clear_selection()


func _register_piece_tap(cell: Vector2i) -> int:
	var now_msec: int = Time.get_ticks_msec()
	if cell == last_piece_tap_cell and now_msec - last_piece_tap_msec <= quick_piece_tap_chain_msec:
		same_piece_tap_count += 1
	else:
		same_piece_tap_count = 1
	last_piece_tap_cell = cell
	last_piece_tap_msec = now_msec
	return same_piece_tap_count

func _reset_piece_tap_chain() -> void:
	last_piece_tap_cell = Vector2i(-99, -99)
	last_piece_tap_msec = -100000
	same_piece_tap_count = 0

func _select_friendly_piece(cell: Vector2i, piece: Dictionary) -> void:
	selected = cell
	legal_actions = _filter_actions_for_current_mode(rules.get_legal_actions_for_piece(cell))
	no_cycle_blocked_actions = _filter_actions_for_current_mode(rules.get_no_cycle_blocked_actions_for_piece(cell))
	selection_changed.emit(_selection_text(cell, piece, legal_actions))
	piece_focus_changed.emit(String(piece.kind), int(piece.owner), cell)
	queue_redraw()



func _cancel_preview_keep_selection(message: String) -> void:
	clear_action_preview()
	preview_cancel_requested.emit(message)
	selection_changed.emit(message)
	queue_redraw()

func _clear_selection() -> void:
	selected = Vector2i(-1, -1)
	legal_actions = []
	no_cycle_blocked_actions = []
	preview_action = {}
	preview_result = {}
	piece_focus_changed.emit("", -1, Vector2i(-1, -1))
	if deploy_mode:
		selection_changed.emit("Deploy Mode: tap a friendly piece to choose where a Reserve Guardian can Deploy.")
	else:
		selection_changed.emit("Tap one of your pieces to see legal moves and jumps.")
	queue_redraw()

func _filter_actions_for_current_mode(actions: Array) -> Array:
	var filtered: Array = []
	for action_value in actions:
		var action: Dictionary = action_value
		var action_type: String = String(action.type)
		if deploy_mode and action_type == SigmaRules.ACTION_DEPLOY:
			filtered.append(action)
		elif not deploy_mode and action_type != SigmaRules.ACTION_DEPLOY:
			filtered.append(action)
	return filtered

func _selection_text(cell: Vector2i, piece: Dictionary, actions: Array) -> String:
	var move_count: int = 0
	var jump_count: int = 0
	var deploy_count: int = 0
	for action_value in actions:
		var action: Dictionary = action_value
		var action_type: String = String(action.type)
		if action_type == SigmaRules.ACTION_MOVE:
			move_count += 1
		elif action_type == SigmaRules.ACTION_JUMP:
			jump_count += 1
		elif action_type == SigmaRules.ACTION_DEPLOY:
			deploy_count += 1
	var name: String = _piece_name(String(piece.kind))
	if deploy_mode:
		return "Deploy from %s at r%d c%d — %d legal Deploy spaces." % [name, cell.x + 1, cell.y + 1, deploy_count]
	var extra: String = ""
	if no_cycle_blocked_actions.size() > 0:
		extra = " Red X = No Cycle stall."
	return "%s selected at r%d c%d — %d moves, %d jumps.%s" % [name, cell.x + 1, cell.y + 1, move_count, jump_count, extra]

func _piece_name(kind: String) -> String:
	match kind:
		"M":
			return "Monarch"
		"G":
			return "Guardian"
		"S":
			return "Sentinel"
		"I":
			return "Infiltrator"
		"A":
			return "Assassin"
		_:
			return kind

func _current_turn_in_peril() -> bool:
	if rules == null or rules.game_over:
		return false
	return rules.is_monarch_in_peril(rules.turn)

func _pulse_value() -> float:
	var t: float = float(Time.get_ticks_msec() % 1000) / 1000.0
	return (sin(t * TAU) + 1.0) * 0.5

func _display_cell(cell: Vector2i) -> Vector2i:
	if board_flipped:
		return Vector2i(BOARD_SIZE - 1 - cell.x, BOARD_SIZE - 1 - cell.y)
	return cell

func _cell_rect(cell: Vector2i) -> Rect2:
	var display: Vector2i = _display_cell(cell)
	return Rect2(board_rect.position + Vector2(display.y * cell_size, display.x * cell_size), Vector2(cell_size, cell_size))

func _cell_center(cell: Vector2i) -> Vector2:
	return _cell_rect(cell).get_center()

func _pos_to_cell(p: Vector2) -> Vector2i:
	if not board_rect.has_point(p):
		return Vector2i(-1, -1)
	var local: Vector2 = p - board_rect.position
	var c: int = int(floor(local.x / cell_size))
	var r: int = int(floor(local.y / cell_size))
	if r < 0 or r >= BOARD_SIZE or c < 0 or c >= BOARD_SIZE:
		return Vector2i(-1, -1)
	var cell: Vector2i = Vector2i(r, c)
	if board_flipped:
		return Vector2i(BOARD_SIZE - 1 - cell.x, BOARD_SIZE - 1 - cell.y)
	return cell
