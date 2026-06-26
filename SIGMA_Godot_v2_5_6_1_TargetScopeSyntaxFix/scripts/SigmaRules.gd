extends RefCounted
class_name SigmaRules

const BOARD_SIZE := 9
const OWNER_P1 := 0
const OWNER_P2 := 1

const KIND_MONARCH := "M"
const KIND_GUARDIAN := "G"
const KIND_SENTINEL := "S"
const KIND_INFILTRATOR := "I"
const KIND_ASSASSIN := "A"

const ACTION_MOVE := "move"
const ACTION_JUMP := "jump"
const ACTION_DEPLOY := "deploy"

const END_NONE := ""
const END_SURRENDER := "Surrender"
const END_LOCKED_BOARD := "Locked Board"
const END_OVERTIME_CAPTURE := "Overtime Capture"
const END_CAPTURE_LEAD := "Capture Lead"
const END_FIRST_BLOOD := "First Blood"
const END_SURVIVAL := "Survival"
const END_SURROUND := "Surround"
const END_COLLAPSE := "Collapse"
const END_TIMEOUT := "Timeout"
const END_TURN_TIMEOUT := "Turn Timeout"

var board: Array = []
var turn: int = OWNER_P1
var reserves: Array = [5, 5]
var next_piece_id: int = 1
var mode_name: String = "Classic SIGMA"
var start_row: Array = ["G", "G", "G", "S", "M", "S", "G", "G", "G"]
var elevation_options: Array = [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN]

var surround_toggle: bool = false
var collapse_toggle: bool = false
var hot_start_toggle: bool = false
var speed_sigma: bool = false
var turn_timer_seconds: int = 0
var turn_limit_total: int = 200


var game_over: bool = false
var winner: int = -1
var ending: String = END_NONE
var result_text: String = ""

var full_rounds: int = 0
var round_limit: int = 100
var overtime: bool = false
var overtime_rounds: int = 0
var overtime_round_limit: int = 10
var removals: Array = [0, 0]
var overtime_removals_this_round: Array = [0, 0]
var first_blood_owner: int = -1

var history_keys: Dictionary = {}
# Local No Cycle anti-stall memory. This intentionally tracks only repeated
# no-progress back-and-forth move signatures, not all historical board states.
var anti_stall_moves: Array = [[], []]
var undo_stack: Array = []
var last_action: Dictionary = {}
var last_resolution: Dictionary = {}

var pending_elevation: Dictionary = {}
var pending_finalize: Dictionary = {}
var scenario_hint: String = ""

func new_game(config: Dictionary = {}) -> void:
	mode_name = config.get("mode_name", "Classic SIGMA")
	start_row = config.get("start_row", ["G", "G", "G", "S", "M", "S", "G", "G", "G"])
	elevation_options = config.get("elevation_options", [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN])
	surround_toggle = bool(config.get("surround_toggle", false))
	collapse_toggle = bool(config.get("collapse_toggle", false))
	hot_start_toggle = bool(config.get("hot_start_toggle", false))
	speed_sigma = bool(config.get("speed_sigma", false))
	turn_timer_seconds = int(config.get("turn_timer_seconds", 0))
	round_limit = int(config.get("round_limit", 100))
	turn_limit_total = int(config.get("turn_limit_total", round_limit * 2))

	var p1_start_row: Array = config.get("p1_start_row", start_row) as Array
	var p2_start_row: Array = config.get("p2_start_row", start_row) as Array

	_reset_empty_game_state()

	# Player 2 starts on the top row. Player 1 starts on the bottom row.
	# Draft SIGMA may provide different legal back rows for each player.
	for c in range(BOARD_SIZE):
		_place_piece(OWNER_P2, String(p2_start_row[c]), 0, c)
		_place_piece(OWNER_P1, String(p1_start_row[c]), BOARD_SIZE - 1, c)

	scenario_hint = "%s local pass-and-play." % mode_name
	history_keys[_state_key()] = true

static func classic_config() -> Dictionary:
	return {
		"mode_name": "Classic SIGMA",
		"start_row": ["G", "G", "G", "S", "M", "S", "G", "G", "G"],
		"elevation_options": [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func sentinel_config() -> Dictionary:
	return {
		"mode_name": "Sentinel SIGMA",
		"start_row": ["G", "G", "G", "S", "M", "S", "G", "G", "G"],
		"elevation_options": [KIND_SENTINEL],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}


static func infiltrator_config() -> Dictionary:
	return {
		"mode_name": "Infiltrator SIGMA",
		"start_row": ["G", "I", "G", "G", "M", "G", "G", "I", "G"],
		"elevation_options": [KIND_INFILTRATOR],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func assassin_config() -> Dictionary:
	return {
		"mode_name": "Assassin SIGMA",
		"start_row": ["G", "G", "A", "G", "M", "G", "A", "G", "G"],
		"elevation_options": [KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func sentinel_infiltrator_config() -> Dictionary:
	return {
		"mode_name": "Sentinel-Infiltrator SIGMA",
		"start_row": ["G", "I", "G", "S", "M", "S", "G", "I", "G"],
		"elevation_options": [KIND_SENTINEL, KIND_INFILTRATOR],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func sentinel_assassin_config() -> Dictionary:
	return {
		"mode_name": "Sentinel-Assassin SIGMA",
		"start_row": ["G", "G", "A", "S", "M", "S", "A", "G", "G"],
		"elevation_options": [KIND_SENTINEL, KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func infiltrator_assassin_config() -> Dictionary:
	return {
		"mode_name": "Infiltrator-Assassin SIGMA",
		"start_row": ["G", "I", "A", "G", "M", "G", "A", "I", "G"],
		"elevation_options": [KIND_INFILTRATOR, KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func config_for_mode_id(mode_id: String) -> Dictionary:
	match mode_id:
		"classic":
			return classic_config()
		"sentinel":
			return sentinel_config()
		"infiltrator":
			return infiltrator_config()
		"assassin":
			return assassin_config()
		"sentinel_infiltrator":
			return sentinel_infiltrator_config()
		"sentinel_assassin":
			return sentinel_assassin_config()
		"infiltrator_assassin":
			return infiltrator_assassin_config()
		"full":
			return full_config()
		_:
			return classic_config()

static func full_config() -> Dictionary:
	return {
		"mode_name": "Full SIGMA",
		"start_row": ["G", "I", "A", "S", "M", "S", "A", "I", "G"],
		"elevation_options": [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

static func draft_config(p1_row: Array, p2_row: Array) -> Dictionary:
	return {
		"mode_name": "Draft SIGMA",
		"start_row": ["G", "G", "G", "S", "M", "S", "G", "G", "G"],
		"p1_start_row": p1_row,
		"p2_start_row": p2_row,
		"elevation_options": [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN],
		"surround_toggle": false,
		"collapse_toggle": false,
		"hot_start_toggle": false,
	}

func _reset_empty_game_state() -> void:
	board.clear()
	for r in range(BOARD_SIZE):
		var row: Array = []
		for c in range(BOARD_SIZE):
			row.append(null)
		board.append(row)

	next_piece_id = 1
	turn = OWNER_P1
	reserves = [5, 5]
	game_over = false
	winner = -1
	ending = END_NONE
	result_text = ""
	full_rounds = 0
	overtime = false
	overtime_rounds = 0
	removals = [0, 0]
	overtime_removals_this_round = [0, 0]
	first_blood_owner = -1
	undo_stack = []
	last_action = {}
	last_resolution = {}
	history_keys = {}
	pending_elevation = {}
	pending_finalize = {}

func _place_piece(owner: int, kind: String, r: int, c: int) -> void:
	board[r][c] = {
		"id": next_piece_id,
		"owner": owner,
		"kind": kind,
		"hot_unused": kind == KIND_GUARDIAN and hot_start_toggle,
	}
	next_piece_id += 1

func get_piece(pos: Vector2i):
	if not _in_bounds(pos):
		return null
	return board[pos.x][pos.y]

func get_turn_name() -> String:
	return "Gold" if turn == OWNER_P1 else "Silver"

func owner_name(owner: int) -> String:
	return "Gold" if owner == OWNER_P1 else "Silver"

func enemy(owner: int) -> int:
	return OWNER_P2 if owner == OWNER_P1 else OWNER_P1

func forward_dir(owner: int) -> int:
	return -1 if owner == OWNER_P1 else 1

func enemy_back_row(owner: int) -> int:
	return 0 if owner == OWNER_P1 else BOARD_SIZE - 1

func own_back_row(owner: int) -> int:
	return BOARD_SIZE - 1 if owner == OWNER_P1 else 0

func get_legal_actions_for_piece(pos: Vector2i) -> Array:
	if game_over or has_pending_elevation():
		return []
	var piece = get_piece(pos)
	if piece == null or int(piece.owner) != turn:
		return []
	var out: Array = []
	var pseudo_actions: Array = _get_pseudo_actions_for_piece(pos, piece)
	for action_value in pseudo_actions:
		var action: Dictionary = action_value
		if _is_action_legal(action):
			out.append(action)
	return out

func get_no_cycle_blocked_actions_for_piece(pos: Vector2i) -> Array:
	if game_over or has_pending_elevation():
		return []
	var piece = get_piece(pos)
	if piece == null or int(piece.owner) != turn:
		return []
	var out: Array = []
	var pseudo_actions: Array = _get_pseudo_actions_for_piece(pos, piece)
	for action_value in pseudo_actions:
		var action: Dictionary = action_value
		if _would_action_be_blocked_by_local_stall(action):
			out.append(action)
	return out

func get_legal_actions_for_player(owner: int) -> Array:
	if game_over or has_pending_elevation():
		return []
	var saved_turn: int = turn
	turn = owner
	var out: Array = []
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p != null and int(p.owner) == owner:
				var pos: Vector2i = Vector2i(r, c)
				var pseudo_actions: Array = _get_pseudo_actions_for_piece(pos, p)
				for action_value in pseudo_actions:
					var action: Dictionary = action_value
					if _is_action_legal(action):
						out.append(action)
	turn = saved_turn
	return out

func apply_action(action: Dictionary) -> bool:
	if game_over or has_pending_elevation():
		return false
	if not _is_action_legal(action):
		last_resolution = {"ok": false, "message": "Illegal action"}
		return false

	undo_stack.append(_snapshot())
	var actor: int = int(action.owner)
	var was_overtime: bool = overtime
	var own_peril_before: bool = is_monarch_in_peril(actor)
	var enemy_peril_before: bool = is_monarch_in_peril(enemy(actor))
	last_action = action.duplicate(true)
	last_resolution = _apply_action_core(action)
	_record_anti_stall_after_action(actor, action, last_resolution, own_peril_before, enemy_peril_before)

	if has_pending_elevation():
		pending_finalize = {"actor": actor, "was_overtime": was_overtime}
		return true

	_finalize_after_action(actor, was_overtime)
	return true


func preview_action(action: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"ok": false,
		"reason": "Illegal action.",
		"action": action.duplicate(true),
		"action_type": String(action.get("type", "")),
		"from": action.get("from", Vector2i(-1, -1)),
		"to": action.get("to", Vector2i(-1, -1)),
		"capture": action.get("capture", Vector2i(-1, -1)),
		"captured_positions": [],
		"enemy_surround_positions": [],
		"friendly_retreat_positions": [],
		"messages": [],
		"tags": [],
		"confirm_text": "Confirm",
		"description": "Preview action.",
		"enemy_monarch_in_peril": false,
		"own_monarch_in_peril": false,
		"surrender": false,
		"pending_elevation": false,
	}
	if game_over:
		result.reason = "Illegal: the game is already over."
		return result
	if has_pending_elevation():
		result.reason = "Illegal: choose an Elevate option first."
		return result
	if not _is_action_legal(action):
		result.reason = get_illegal_reason(action)
		return result

	var snap: Dictionary = _snapshot()
	var actor: int = int(action.owner)
	var action_type: String = String(action.type)
	var resolution: Dictionary = _apply_action_core(action)
	var foe: int = enemy(actor)
	var enemy_threats: Array = get_peril_threats(foe)
	var own_threats: Array = get_peril_threats(actor)
	var surrender_now: bool = false
	if not bool(resolution.get("pending_elevation", false)):
		var saved_turn: int = turn
		turn = foe
		if is_monarch_in_peril(foe) and not _player_has_any_legal_escape(foe):
			surrender_now = true
		turn = saved_turn

	result.ok = true
	result.reason = ""
	result.messages = (resolution.get("messages", []) as Array).duplicate(true)
	result.captured_positions = (resolution.get("captured_positions", []) as Array).duplicate(true)
	result.enemy_surround_positions = (resolution.get("enemy_surround_positions", []) as Array).duplicate(true)
	result.friendly_retreat_positions = (resolution.get("friendly_retreat_positions", []) as Array).duplicate(true)
	result.enemy_monarch_in_peril = not enemy_threats.is_empty()
	result.own_monarch_in_peril = not own_threats.is_empty()
	result.surrender = surrender_now
	result.pending_elevation = bool(resolution.get("pending_elevation", false))

	var tags: Array = []
	if action_type == ACTION_MOVE:
		tags.append("Move")
	elif action_type == ACTION_JUMP:
		tags.append("Capture")
	elif action_type == ACTION_DEPLOY:
		tags.append("Deploy")
	if int(resolution.get("enemy_surround_removed", 0)) > 0:
		tags.append("Surround")
	if int(resolution.get("friendly_retreats", 0)) > 0:
		tags.append("Retreat")
	if not enemy_threats.is_empty():
		tags.append("Peril")
	if surrender_now:
		tags.append("Surrender")
	if bool(resolution.get("pending_elevation", false)):
		tags.append("Elevate")
	result.tags = tags
	result.confirm_text = _preview_confirm_text(action_type, surrender_now, bool(resolution.get("pending_elevation", false)))
	result.description = _preview_description(result, actor)

	_restore(snap)
	return result

func get_illegal_reason(action: Dictionary) -> String:
	if game_over:
		return "Illegal: the game is already over."
	if has_pending_elevation():
		return "Illegal: choose an Elevate option first."
	if not action.has("owner") or int(action.owner) != turn:
		return "Illegal: it is not that player's turn."
	var actor: int = int(action.owner)
	var action_type: String = String(action.get("type", ""))
	if action_type != ACTION_DEPLOY:
		var from: Vector2i = action.get("from", Vector2i(-1, -1))
		var moving_piece: Variant = get_piece(from)
		if moving_piece == null or int(moving_piece.owner) != actor:
			return "Illegal: select one of your own pieces."
	else:
		if int(reserves[actor]) <= 0:
			return "Illegal: no Reserve Guardians are available to Deploy."

	var own_peril_before: bool = is_monarch_in_peril(actor)
	var enemy_peril_before: bool = is_monarch_in_peril(enemy(actor))
	var snap: Dictionary = _snapshot()
	_apply_action_core(action)
	var reason: String = "Illegal action."
	if _find_monarch(actor).x < 0:
		reason = "Illegal: your Monarch would be removed."
	elif is_monarch_in_peril(actor):
		reason = "Illegal: your Monarch would be in Peril."
	elif not _monarch_has_empty_adjacent(actor):
		reason = "Illegal: your Monarch would have no empty adjacent space."
	elif collapse_toggle and _collapsed_owner() == actor:
		reason = "Illegal: that action would immediately cause your own Collapse."
	else:
		var resolution: Dictionary = last_resolution.duplicate(true)
		if _would_repeat_local_stall(action, resolution, own_peril_before, enemy_peril_before):
			reason = "Illegal: No Cycle blocks the fourth repeated no-progress back-and-forth move."
		else:
			reason = "Illegal: choose a highlighted legal action."
	_restore(snap)
	return reason

func _preview_confirm_text(action_type: String, surrender_now: bool, pending_elevation_now: bool) -> String:
	if surrender_now:
		return "Force Surrender"
	if pending_elevation_now:
		return "Confirm + Elevate"
	match action_type:
		ACTION_MOVE:
			return "Confirm Move"
		ACTION_JUMP:
			return "Confirm Capture"
		ACTION_DEPLOY:
			return "Confirm Deploy"
		_:
			return "Confirm"

func _preview_description(preview: Dictionary, _actor: int) -> String:
	var parts: Array = []
	var tags: Array = preview.get("tags", []) as Array
	if not tags.is_empty():
		parts.append("Tags: " + " · ".join(tags))
	var messages: Array = preview.get("messages", []) as Array
	for message_value in messages:
		parts.append(String(message_value))
	var captured_count: int = (preview.get("captured_positions", []) as Array).size()
	var surround_count: int = (preview.get("enemy_surround_positions", []) as Array).size()
	var retreat_count: int = (preview.get("friendly_retreat_positions", []) as Array).size()
	if captured_count > 0:
		parts.append("Captures %d enemy non-Monarch piece(s)." % captured_count)
	if surround_count > 0:
		parts.append("Enemy surrounded piece(s) will be removed: %d." % surround_count)
	if retreat_count > 0:
		parts.append("Friendly piece(s) will Retreat: %d." % retreat_count)
	if bool(preview.get("enemy_monarch_in_peril", false)):
		parts.append("Enemy Monarch will be in Peril.")
	if bool(preview.get("surrender", false)):
		parts.append("This action forces Surrender.")
	elif bool(preview.get("pending_elevation", false)):
		parts.append("Guardian will reach the enemy back row and may Elevate.")
	if parts.is_empty():
		parts.append("Preview ready.")
	return " ".join(parts)

func choose_pending_elevation(kind: String) -> bool:
	if not has_pending_elevation():
		return false
	var options: Array = get_pending_elevation_options()
	if not options.has(kind):
		return false
	var pos: Vector2i = pending_elevation.get("pos", Vector2i(-1, -1))
	var piece_id: int = int(pending_elevation.get("piece_id", -1))
	if not _in_bounds(pos):
		return false
	var p = board[pos.x][pos.y]
	if p == null or int(p.id) != piece_id or String(p.kind) != KIND_GUARDIAN:
		return false
	p.kind = kind
	p.hot_unused = false
	last_resolution["elevated"] = true
	last_resolution["messages"].append("Guardian elevated to %s." % _piece_full_name(kind))
	pending_elevation = {}
	var actor: int = int(pending_finalize.get("actor", turn))
	var was_overtime: bool = bool(pending_finalize.get("was_overtime", overtime))
	pending_finalize = {}
	_finalize_after_action(actor, was_overtime)
	return true

func has_pending_elevation() -> bool:
	return not pending_elevation.is_empty()

func get_pending_elevation_options() -> Array:
	if pending_elevation.is_empty():
		return []
	return pending_elevation.get("options", []).duplicate(true)

func get_pending_elevation_owner() -> int:
	if pending_elevation.is_empty():
		return turn
	return int(pending_elevation.get("owner", turn))

func advanced_count_on_board(owner: int, kind: String) -> int:
	return _advanced_count(owner, kind)

func skip_pending_elevation_if_no_options() -> void:
	if not has_pending_elevation():
		return
	if get_pending_elevation_options().is_empty():
		pending_elevation = {}
		var actor: int = int(pending_finalize.get("actor", turn))
		var was_overtime: bool = bool(pending_finalize.get("was_overtime", overtime))
		pending_finalize = {}
		_finalize_after_action(actor, was_overtime)

func _finalize_after_action(actor: int, was_overtime: bool) -> void:
	# Turn passes before checking the opponent's legal escape choices.
	turn = enemy(actor)
	var key: String = _state_key()
	history_keys[key] = true

	# Surrender: opponent Monarch is directly threatened and has no legal escape.
	var defender: int = turn
	if is_monarch_in_peril(defender) and not _player_has_any_legal_escape(defender):
		game_over = true
		winner = actor
		ending = END_SURRENDER
		result_text = "%s wins by Surrender." % owner_name(actor)
		return

	# Optional immediate win toggles.
	if surround_toggle and int(last_resolution.get("enemy_surround_removed", 0)) > 0:
		game_over = true
		winner = actor
		ending = END_SURROUND
		result_text = "%s wins by Surround." % owner_name(actor)
		return

	if collapse_toggle:
		var collapsed_owner: int = _collapsed_owner()
		if collapsed_owner != -1:
			game_over = true
			winner = enemy(collapsed_owner)
			ending = END_COLLAPSE
			result_text = "%s wins by Collapse." % owner_name(winner)
			return

	# Round / Overtime tracking. A full round completes after Player 2 acts.
	if actor == OWNER_P2:
		if was_overtime:
			overtime_rounds += 1
			if int(overtime_removals_this_round[OWNER_P1]) > 0 and int(overtime_removals_this_round[OWNER_P2]) == 0:
				_set_overtime_capture_winner(OWNER_P1)
				return
			elif int(overtime_removals_this_round[OWNER_P2]) > 0 and int(overtime_removals_this_round[OWNER_P1]) == 0:
				_set_overtime_capture_winner(OWNER_P2)
				return
			elif overtime_rounds >= overtime_round_limit:
				_apply_overtime_fallback()
				return
			overtime_removals_this_round = [0, 0]
		else:
			full_rounds += 1
			if full_rounds >= round_limit:
				overtime = true
				overtime_rounds = 0
				overtime_removals_this_round = [0, 0]

	# Locked Board draw: current player has no action and is not in Peril.
	if not is_monarch_in_peril(turn) and not _player_has_any_legal_escape(turn):
		game_over = true
		winner = -1
		ending = END_LOCKED_BOARD
		result_text = "Locked Board draw."
		return

func export_save_state() -> Dictionary:
	var data: Dictionary = _snapshot()
	data["undo_stack"] = undo_stack.duplicate(true)
	data["save_schema"] = 1
	return data

func import_save_state(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	_restore(data)
	undo_stack = (data.get("undo_stack", []) as Array).duplicate(true)
	return true

func undo() -> bool:
	if undo_stack.is_empty():
		return false
	var snap: Dictionary = undo_stack.pop_back()
	_restore(snap)
	return true

func is_monarch_in_peril(owner: int) -> bool:
	return get_peril_threats(owner).size() > 0

func get_peril_threats(owner: int) -> Array:
	# Direct Monarch Peril: a Monarch is in Peril when an enemy piece
	# directly threatens the Monarch's square by that piece's movement geometry.
	# The Monarch is still never physically captured in legal play; no escape = Surrender.
	var threats: Array = []
	var mpos: Vector2i = _find_monarch(owner)
	if mpos.x < 0:
		return threats
	var foe: int = enemy(owner)
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p == null or int(p.owner) != foe:
				continue
			var epos: Vector2i = Vector2i(r, c)
			if _piece_directly_threatens_square(epos, p, mpos):
				# Keep both target and landing keys for UI compatibility.
				threats.append({"from": epos, "monarch": mpos, "target": mpos, "landing": mpos, "piece": p})
	return threats

func _piece_directly_threatens_square(from_pos: Vector2i, piece: Dictionary, target_pos: Vector2i) -> bool:
	var delta: Vector2i = target_pos - from_pos
	var kind: String = String(piece.kind)
	if delta == Vector2i.ZERO:
		return false

	if kind == KIND_GUARDIAN:
		return _direction_in_list(delta, _orthogonal_dirs())

	if kind == KIND_SENTINEL or kind == KIND_MONARCH:
		return _direction_in_list(delta, _all_adjacent_dirs())

	if kind == KIND_INFILTRATOR:
		if delta.x != 0 and delta.y != 0:
			return false
		var distance: int = abs(delta.x) + abs(delta.y)
		if distance == 1:
			return true
		if distance == 2:
			var step: Vector2i = Vector2i(_sign_i(delta.x), _sign_i(delta.y))
			var mid: Vector2i = from_pos + step
			return _in_bounds(mid) and board[mid.x][mid.y] == null
		return false

	if kind == KIND_ASSASSIN:
		if abs(delta.x) != abs(delta.y):
			return false
		var distance_diag: int = abs(delta.x)
		if distance_diag == 1:
			return true
		if distance_diag == 2:
			var step_diag: Vector2i = Vector2i(_sign_i(delta.x), _sign_i(delta.y))
			var mid_diag: Vector2i = from_pos + step_diag
			return _in_bounds(mid_diag) and board[mid_diag.x][mid_diag.y] == null
		return false

	return false

func get_status_text() -> String:
	if game_over:
		return result_text
	if has_pending_elevation():
		return "%s Guardian may Elevate. Choose an advanced piece." % owner_name(int(pending_elevation.get("owner", turn)))
	var text: String = "%s to act" % get_turn_name()
	if is_monarch_in_peril(turn):
		text += " — Monarch in Peril: remove the direct threat."
	if overtime:
		text += " — Overtime round %d/%d." % [overtime_rounds + 1, overtime_round_limit]
	elif speed_sigma:
		var current_turn_number: int = int(min(turn_limit_total, full_rounds * 2 + (0 if turn == OWNER_P1 else 1) + 1))
		text += " — Turn %d/%d." % [current_turn_number, turn_limit_total]
	else:
		text += " — Round %d/%d." % [full_rounds + 1, round_limit]
	return text

func get_counts_text() -> String:
	return "Reserve Guardians: Gold %d / Silver %d    Removals: Gold %d / Silver %d" % [int(reserves[0]), int(reserves[1]), int(removals[0]), int(removals[1])]

func _get_pseudo_actions_for_piece(pos: Vector2i, piece: Dictionary) -> Array:
	var actions: Array = []
	var owner: int = int(piece.owner)

	# Normal movement.
	for step_value in _move_steps_for_piece(piece):
		var step: Vector2i = step_value
		var to: Vector2i = pos + step
		if _in_bounds(to) and board[to.x][to.y] == null:
			actions.append({"type": ACTION_MOVE, "owner": owner, "from": pos, "to": to, "piece_id": int(piece.id)})

	# Two-space normal movement for Infiltrator / Assassin and optional Hot Start Guardian.
	for step_value in _long_move_steps_for_piece(piece):
		var step: Vector2i = step_value
		var mid: Vector2i = pos + step
		var to2: Vector2i = pos + (step * 2)
		if _in_bounds(mid) and _in_bounds(to2) and board[mid.x][mid.y] == null and board[to2.x][to2.y] == null:
			actions.append({"type": ACTION_MOVE, "owner": owner, "from": pos, "to": to2, "piece_id": int(piece.id)})

	# Jump-captures against enemy non-Monarch pieces only. Monarchs surrender; they are not removed.
	for d_value in _capture_dirs_for_piece(piece):
		var d: Vector2i = d_value
		var mid: Vector2i = pos + d
		var land: Vector2i = pos + (d * 2)
		if not _in_bounds(mid) or not _in_bounds(land):
			continue
		var jumped = board[mid.x][mid.y]
		if jumped == null or int(jumped.owner) == owner or String(jumped.kind) == KIND_MONARCH:
			continue
		if board[land.x][land.y] != null:
			continue
		actions.append({"type": ACTION_JUMP, "owner": owner, "from": pos, "to": land, "capture": mid, "piece_id": int(piece.id)})

	# Advanced reach-captures: Infiltrators and Assassins may use one clear
	# first movement space to line up a jump-capture in the same straight geometry.
	# This keeps Infiltrators purely orthogonal and Assassins purely diagonal.
	# It does not allow L-shaped, bent, or mixed-geometry captures.
	var kind_for_reach: String = String(piece.kind)
	if kind_for_reach == KIND_INFILTRATOR or kind_for_reach == KIND_ASSASSIN:
		for reach_d_value in _capture_dirs_for_piece(piece):
			var reach_d: Vector2i = reach_d_value
			var approach: Vector2i = pos + reach_d
			var reach_mid: Vector2i = pos + (reach_d * 2)
			var reach_land: Vector2i = pos + (reach_d * 3)
			if not _in_bounds(approach) or not _in_bounds(reach_mid) or not _in_bounds(reach_land):
				continue
			if board[approach.x][approach.y] != null:
				continue
			var reach_jumped = board[reach_mid.x][reach_mid.y]
			if reach_jumped == null or int(reach_jumped.owner) == owner or String(reach_jumped.kind) == KIND_MONARCH:
				continue
			if board[reach_land.x][reach_land.y] != null:
				continue
			actions.append({"type": ACTION_JUMP, "owner": owner, "from": pos, "to": reach_land, "capture": reach_mid, "approach": approach, "piece_id": int(piece.id)})

	# Deploy a Reserve Guardian adjacent to this friendly piece in a legal movement direction.
	if int(reserves[owner]) > 0:
		for d_value in _deploy_dirs_for_piece(piece):
			var d: Vector2i = d_value
			var dep: Vector2i = pos + d
			if not _in_bounds(dep):
				continue
			if board[dep.x][dep.y] != null:
				continue
			if dep.x == enemy_back_row(owner):
				continue
			actions.append({"type": ACTION_DEPLOY, "owner": owner, "from": pos, "to": dep})

	return actions


func _is_action_pseudo_legal(action: Dictionary) -> bool:
	var owner: int = int(action.get("owner", -1))
	var action_type: String = String(action.get("type", ""))
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	if owner != turn:
		return false
	if not _in_bounds(from):
		return false
	var source_piece = get_piece(from)
	if source_piece == null or int(source_piece.owner) != owner:
		return false
	var pseudo_actions: Array = _get_pseudo_actions_for_piece(from, source_piece)
	for candidate_value in pseudo_actions:
		var candidate: Dictionary = candidate_value
		if String(candidate.get("type", "")) != action_type:
			continue
		if Vector2i(candidate.get("from", Vector2i(-9, -9))) != from:
			continue
		if Vector2i(candidate.get("to", Vector2i(-9, -9))) != Vector2i(action.get("to", Vector2i(-8, -8))):
			continue
		if action_type == ACTION_JUMP:
			if Vector2i(candidate.get("capture", Vector2i(-9, -9))) != Vector2i(action.get("capture", Vector2i(-8, -8))):
				continue
		return true
	return false

func _is_action_legal(action: Dictionary) -> bool:
	if game_over:
		return false
	if not action.has("owner") or int(action.owner) != turn:
		return false
	if not _is_action_pseudo_legal(action):
		return false
	var actor: int = int(action.owner)
	var action_type: String = String(action.type)
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	var moving_piece: Variant = null
	if action_type != ACTION_DEPLOY:
		moving_piece = get_piece(from)
		if moving_piece == null or int(moving_piece.owner) != actor:
			return false

	var own_peril_before: bool = is_monarch_in_peril(actor)
	var enemy_peril_before: bool = is_monarch_in_peril(enemy(actor))
	var snap: Dictionary = _snapshot()
	_apply_action_core(action)

	var legal: bool = true
	if _find_monarch(actor).x < 0:
		legal = false
	if legal and is_monarch_in_peril(actor):
		legal = false
	if legal and not _monarch_has_empty_adjacent(actor):
		legal = false

	# A legal action may not immediately cause your own Collapse loss if Collapse is enabled.
	if legal and collapse_toggle and _collapsed_owner() == actor:
		legal = false

	# No Cycle is now a narrow anti-stall rule: it only blocks repeated
	# no-progress back-and-forth movement by the same player. It does not ban
	# normal strategic returns to previously seen board states.
	if legal and _would_repeat_local_stall(action, last_resolution, own_peril_before, enemy_peril_before):
		legal = false

	_restore(snap)
	return legal

func _apply_action_core(action: Dictionary) -> Dictionary:
	var actor: int = int(action.owner)
	var action_type: String = String(action.type)
	var resolution: Dictionary = {
		"captures": 0,
		"enemy_surround_removed": 0,
		"friendly_retreats": 0,
		"captured_positions": [],
		"enemy_surround_positions": [],
		"friendly_retreat_positions": [],
		"elevated": false,
		"pending_elevation": false,
		"moved_piece_retreated": false,
		"moved_piece_id": -1,
		"messages": [],
	}

	var moved_piece_id: int = -1
	var was_deploy: bool = action_type == ACTION_DEPLOY

	if action_type == ACTION_DEPLOY:
		var to: Vector2i = action.to
		reserves[actor] = int(reserves[actor]) - 1
		_place_piece(actor, KIND_GUARDIAN, to.x, to.y)
		board[to.x][to.y].hot_unused = false
		moved_piece_id = int(board[to.x][to.y].id)
		resolution.messages.append("%s deployed a Reserve Guardian." % owner_name(actor))
	elif action_type == ACTION_MOVE:
		var from: Vector2i = action.from
		var to: Vector2i = action.to
		var p = board[from.x][from.y]
		moved_piece_id = int(p.id)
		if String(p.kind) == KIND_GUARDIAN:
			p.hot_unused = false
		board[to.x][to.y] = p
		board[from.x][from.y] = null
		resolution.messages.append("%s moved." % owner_name(actor))
	elif action_type == ACTION_JUMP:
		var from: Vector2i = action.from
		var to: Vector2i = action.to
		var cap: Vector2i = action.capture
		var p = board[from.x][from.y]
		moved_piece_id = int(p.id)
		if String(p.kind) == KIND_GUARDIAN:
			p.hot_unused = false
		board[to.x][to.y] = p
		board[from.x][from.y] = null
		board[cap.x][cap.y] = null
		_record_enemy_removal(actor)
		resolution.captures = int(resolution.captures) + 1
		var captured_positions_list: Array = resolution.get("captured_positions", []) as Array
		captured_positions_list.append(cap)
		resolution["captured_positions"] = captured_positions_list
		resolution.messages.append("%s captured a non-Monarch piece." % owner_name(actor))

	resolution.moved_piece_id = moved_piece_id

	# Surround + Retreat are simultaneous from the resolved board.
	var surrounded: Array = _find_surrounded_non_monarchs()
	for item_value in surrounded:
		var item: Dictionary = item_value
		var pos: Vector2i = item.pos
		var p = item.piece
		if board[pos.x][pos.y] == null:
			continue
		if int(p.owner) == actor:
			if int(p.id) == moved_piece_id:
				resolution.moved_piece_retreated = true
			var friendly_retreat_positions_list: Array = resolution.get("friendly_retreat_positions", []) as Array
			friendly_retreat_positions_list.append(pos)
			resolution["friendly_retreat_positions"] = friendly_retreat_positions_list
			_retreat_piece(pos, p)
			resolution.friendly_retreats = int(resolution.friendly_retreats) + 1
		else:
			board[pos.x][pos.y] = null
			_record_enemy_removal(actor)
			var enemy_surround_positions_list: Array = resolution.get("enemy_surround_positions", []) as Array
			enemy_surround_positions_list.append(pos)
			resolution["enemy_surround_positions"] = enemy_surround_positions_list
			resolution.enemy_surround_removed = int(resolution.enemy_surround_removed) + 1

	# Elevate after Surround / Retreat. Deployed Guardians cannot elevate on the turn deployed.
	# v1.1.9 keeps a real pending choice instead of auto-elevating.
	if not was_deploy and moved_piece_id != -1:
		var current_pos: Vector2i = _find_piece_by_id(moved_piece_id)
		if current_pos.x >= 0:
			var mp = board[current_pos.x][current_pos.y]
			if String(mp.kind) == KIND_GUARDIAN and current_pos.x == enemy_back_row(actor):
				var options: Array = _legal_elevation_options(actor)
				if not options.is_empty():
					pending_elevation = {"owner": actor, "pos": current_pos, "piece_id": moved_piece_id, "options": options}
					resolution.pending_elevation = true
					resolution.messages.append("Guardian may Elevate.")

	last_resolution = resolution
	return resolution

func _record_enemy_removal(actor: int) -> void:
	removals[actor] = int(removals[actor]) + 1
	if first_blood_owner == -1:
		first_blood_owner = actor
	if overtime:
		overtime_removals_this_round[actor] = int(overtime_removals_this_round[actor]) + 1

func _retreat_piece(pos: Vector2i, piece: Dictionary) -> void:
	var owner: int = int(piece.owner)
	var kind: String = String(piece.kind)
	board[pos.x][pos.y] = null
	if kind == KIND_GUARDIAN:
		reserves[owner] = int(reserves[owner]) + 1
	# Retreated advanced pieces return to advanced supply. They do not count against the Advanced Cap while off-board; the cap is board-based only.

func _move_signature(owner: int, piece_id: int, from: Vector2i, to: Vector2i) -> String:
	return "%d:%d:%d,%d>%d,%d" % [owner, piece_id, from.x, from.y, to.x, to.y]

func _inverse_move_signature(owner: int, piece_id: int, from: Vector2i, to: Vector2i) -> String:
	return _move_signature(owner, piece_id, to, from)

func _action_moved_piece_id(action: Dictionary) -> int:
	if String(action.get("type", "")) == ACTION_DEPLOY:
		return -1
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	if not _in_bounds(from):
		return -1
	var p = board[from.x][from.y]
	if p == null:
		return -1
	return int(p.id)

func _action_has_progress(action: Dictionary, resolution: Dictionary, own_peril_before: bool, enemy_peril_before: bool) -> bool:
	var action_type: String = String(action.get("type", ""))
	if action_type == ACTION_DEPLOY or action_type == ACTION_JUMP:
		return true
	if int(resolution.get("captures", 0)) > 0:
		return true
	if int(resolution.get("enemy_surround_removed", 0)) > 0:
		return true
	if int(resolution.get("friendly_retreats", 0)) > 0:
		return true
	if bool(resolution.get("pending_elevation", false)):
		return true
	var actor: int = int(action.get("owner", turn))
	if is_monarch_in_peril(actor) != own_peril_before:
		return true
	if is_monarch_in_peril(enemy(actor)) != enemy_peril_before:
		return true
	return false

func _would_repeat_local_stall(action: Dictionary, resolution: Dictionary, own_peril_before: bool = false, enemy_peril_before: bool = false) -> bool:
	if String(action.get("type", "")) != ACTION_MOVE:
		return false
	if _action_has_progress(action, resolution, own_peril_before, enemy_peril_before):
		return false
	var actor: int = int(action.get("owner", turn))
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	var to: Vector2i = action.get("to", Vector2i(-1, -1))
	var piece_id: int = int(resolution.get("moved_piece_id", -1))
	if piece_id < 0:
		piece_id = _action_moved_piece_id(action)
	if piece_id < 0:
		return false
	var recent: Array = anti_stall_moves[actor] if actor >= 0 and actor < anti_stall_moves.size() else []
	if recent.size() < 3:
		return false
	var sig: String = _move_signature(actor, piece_id, from, to)
	var inverse_sig: String = _inverse_move_signature(actor, piece_id, from, to)
	# Allow three no-progress back-and-forth steps, then block the fourth
	# continuation of that exact local stall loop. Example: A→B, B→A, A→B
	# may happen; the next B→A is marked illegal unless progress occurred.
	return String(recent[recent.size() - 3]) == inverse_sig and String(recent[recent.size() - 2]) == sig and String(recent[recent.size() - 1]) == inverse_sig

func _would_action_be_blocked_by_local_stall(action: Dictionary) -> bool:
	if game_over:
		return false
	if not action.has("owner") or int(action.owner) != turn:
		return false
	if String(action.get("type", "")) != ACTION_MOVE:
		return false
	var actor: int = int(action.owner)
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	var moving_piece: Variant = get_piece(from)
	if moving_piece == null or int(moving_piece.owner) != actor:
		return false
	var own_peril_before: bool = is_monarch_in_peril(actor)
	var enemy_peril_before: bool = is_monarch_in_peril(enemy(actor))
	var snap: Dictionary = _snapshot()
	_apply_action_core(action)
	var base_legal: bool = true
	if _find_monarch(actor).x < 0:
		base_legal = false
	if base_legal and is_monarch_in_peril(actor):
		base_legal = false
	if base_legal and not _monarch_has_empty_adjacent(actor):
		base_legal = false
	if base_legal and collapse_toggle and _collapsed_owner() == actor:
		base_legal = false
	var blocked: bool = base_legal and _would_repeat_local_stall(action, last_resolution, own_peril_before, enemy_peril_before)
	_restore(snap)
	return blocked

func _record_anti_stall_after_action(actor: int, action: Dictionary, resolution: Dictionary, own_peril_before: bool, enemy_peril_before: bool) -> void:
	if _action_has_progress(action, resolution, own_peril_before, enemy_peril_before):
		anti_stall_moves = [[], []]
		return
	if String(action.get("type", "")) != ACTION_MOVE:
		return
	var from: Vector2i = action.get("from", Vector2i(-1, -1))
	var to: Vector2i = action.get("to", Vector2i(-1, -1))
	var piece_id: int = int(resolution.get("moved_piece_id", -1))
	if piece_id < 0:
		return
	var sig: String = _move_signature(actor, piece_id, from, to)
	var recent: Array = anti_stall_moves[actor]
	recent.append(sig)
	while recent.size() > 4:
		recent.pop_front()
	anti_stall_moves[actor] = recent

func _find_surrounded_non_monarchs() -> Array:
	var out: Array = []
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p == null or String(p.kind) == KIND_MONARCH:
				continue
			if not _has_empty_normal_movement_space(Vector2i(r, c), p):
				out.append({"pos": Vector2i(r, c), "piece": p.duplicate(true)})
	return out

func _has_empty_normal_movement_space(pos: Vector2i, piece: Dictionary) -> bool:
	for step_value in _move_steps_for_piece(piece):
		var step: Vector2i = step_value
		var to: Vector2i = pos + step
		if _in_bounds(to) and board[to.x][to.y] == null:
			return true
	for step_value in _long_move_steps_for_piece(piece):
		var step: Vector2i = step_value
		var mid: Vector2i = pos + step
		var to2: Vector2i = pos + (step * 2)
		if _in_bounds(mid) and _in_bounds(to2) and board[mid.x][mid.y] == null and board[to2.x][to2.y] == null:
			return true
	return false

func _move_steps_for_piece(piece: Dictionary) -> Array:
	var kind: String = String(piece.kind)
	if kind == KIND_GUARDIAN:
		return _orthogonal_dirs()
	if kind == KIND_SENTINEL or kind == KIND_MONARCH:
		return _all_adjacent_dirs()
	if kind == KIND_INFILTRATOR:
		return _orthogonal_dirs()
	if kind == KIND_ASSASSIN:
		return _diagonal_dirs()
	return []

func _long_move_steps_for_piece(piece: Dictionary) -> Array:
	var kind: String = String(piece.kind)
	if kind == KIND_INFILTRATOR:
		return _orthogonal_dirs()
	if kind == KIND_ASSASSIN:
		return _diagonal_dirs()
	if kind == KIND_GUARDIAN and hot_start_toggle and bool(piece.get("hot_unused", false)):
		return _orthogonal_dirs()
	return []

func _capture_dirs_for_piece(piece: Dictionary) -> Array:
	var kind: String = String(piece.kind)
	if kind == KIND_GUARDIAN:
		return _orthogonal_dirs()
	if kind == KIND_SENTINEL or kind == KIND_MONARCH:
		return _all_adjacent_dirs()
	if kind == KIND_INFILTRATOR:
		return _orthogonal_dirs()
	if kind == KIND_ASSASSIN:
		return _diagonal_dirs()
	return []

func _deploy_dirs_for_piece(piece: Dictionary) -> Array:
	# Deploy uses movement direction, not movement range, and is always adjacent.
	return _move_steps_for_piece({"owner": piece.owner, "kind": piece.kind, "hot_unused": false})

func _all_adjacent_dirs() -> Array:
	return [
		Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
		Vector2i(0, -1),                    Vector2i(0, 1),
		Vector2i(1, -1),  Vector2i(1, 0),  Vector2i(1, 1),
	]

func _orthogonal_dirs() -> Array:
	return [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

func _diagonal_dirs() -> Array:
	return [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]


func _sign_i(value: int) -> int:
	if value < 0:
		return -1
	if value > 0:
		return 1
	return 0

func _direction_in_list(dir: Vector2i, dirs: Array) -> bool:
	for d_value in dirs:
		var d: Vector2i = d_value
		if d == dir:
			return true
	return false

func _player_has_any_legal_escape(owner: int) -> bool:
	var saved_turn: int = turn
	turn = owner
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p == null or int(p.owner) != owner:
				continue
			var pseudo_actions: Array = _get_pseudo_actions_for_piece(Vector2i(r, c), p)
			for action_value in pseudo_actions:
				var action: Dictionary = action_value
				if _is_action_legal(action):
					turn = saved_turn
					return true
	turn = saved_turn
	return false

func _monarch_has_empty_adjacent(owner: int) -> bool:
	var mpos: Vector2i = _find_monarch(owner)
	if mpos.x < 0:
		return false
	for d_value in _all_adjacent_dirs():
		var d: Vector2i = d_value
		var adjacent_pos: Vector2i = mpos + d
		if _in_bounds(adjacent_pos) and board[adjacent_pos.x][adjacent_pos.y] == null:
			return true
	return false

func _monarch_adjacent_to_enemy(owner: int) -> bool:
	var mpos: Vector2i = _find_monarch(owner)
	if mpos.x < 0:
		return false
	var foe: int = enemy(owner)
	for d_value in _all_adjacent_dirs():
		var d: Vector2i = d_value
		var ppos: Vector2i = mpos + d
		if _in_bounds(ppos):
			var p = board[ppos.x][ppos.y]
			if p != null and int(p.owner) == foe:
				return true
	return false

func _find_monarch(owner: int) -> Vector2i:
	if board.size() < BOARD_SIZE:
		return Vector2i(-1, -1)
	for r in range(BOARD_SIZE):
		if not (board[r] is Array) or (board[r] as Array).size() < BOARD_SIZE:
			continue
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p != null and int(p.owner) == owner and String(p.kind) == KIND_MONARCH:
				return Vector2i(r, c)
	return Vector2i(-1, -1)

func _find_piece_by_id(piece_id: int) -> Vector2i:
	if board.size() < BOARD_SIZE:
		return Vector2i(-1, -1)
	for r in range(BOARD_SIZE):
		if not (board[r] is Array) or (board[r] as Array).size() < BOARD_SIZE:
			continue
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p != null and int(p.id) == piece_id:
				return Vector2i(r, c)
	return Vector2i(-1, -1)

func _in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE

func _legal_elevation_options(owner: int) -> Array:
	var out: Array = []
	for kind_value in elevation_options:
		var kind: String = String(kind_value)
		if _advanced_count(owner, kind) < 3:
			out.append(kind)
	return out

func _advanced_count(owner: int, kind: String) -> int:
	var count: int = 0
	for r in range(BOARD_SIZE):
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p != null and int(p.owner) == owner and String(p.kind) == kind:
				count += 1
	return count

func _collapsed_owner() -> int:
	for owner_value in [OWNER_P1, OWNER_P2]:
		var owner: int = int(owner_value)
		var has_advanced: bool = false
		for kind_value in [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN]:
			var kind: String = String(kind_value)
			if _advanced_count(owner, kind) > 0:
				has_advanced = true
		if not has_advanced:
			return owner
	return -1

func apply_turn_timeout() -> bool:
	if game_over or has_pending_elevation() or not speed_sigma:
		return false
	undo_stack.append(_snapshot())
	var actor: int = turn
	var was_overtime: bool = overtime
	last_action = {"type": END_TURN_TIMEOUT, "owner": actor}
	last_resolution = {
		"ok": true,
		"turn_timeout": true,
		"captures": 0,
		"enemy_surround_removed": 0,
		"friendly_retreats": 0,
		"messages": ["%s turn ended by BLITZ! timer." % owner_name(actor)],
	}
	turn = enemy(actor)
	history_keys[_state_key()] = true

	# A BLITZ! timeout is a skipped action, not a loss and not progress.
	# It still advances the total turn/round clock and can trigger Overtime.
	if actor == OWNER_P2:
		if was_overtime:
			overtime_rounds += 1
			if overtime_rounds >= overtime_round_limit:
				_apply_overtime_fallback()
				return true
			overtime_removals_this_round = [0, 0]
		else:
			full_rounds += 1
			if full_rounds >= round_limit:
				overtime = true
				overtime_rounds = 0
				overtime_removals_this_round = [0, 0]

	# Locked Board is still checked after the clock passes the turn.
	if not is_monarch_in_peril(turn) and not _player_has_any_legal_escape(turn):
		game_over = true
		winner = -1
		ending = END_LOCKED_BOARD
		result_text = "Locked Board draw."
	return true

func _set_overtime_capture_winner(owner: int) -> void:
	game_over = true
	winner = owner
	ending = END_OVERTIME_CAPTURE
	result_text = "%s wins by Overtime Capture." % owner_name(owner)

func _apply_overtime_fallback() -> void:
	game_over = true
	if int(removals[OWNER_P1]) > int(removals[OWNER_P2]):
		winner = OWNER_P1
		ending = END_CAPTURE_LEAD
		result_text = "Gold wins by Capture Lead."
	elif int(removals[OWNER_P2]) > int(removals[OWNER_P1]):
		winner = OWNER_P2
		ending = END_CAPTURE_LEAD
		result_text = "Silver wins by Capture Lead."
	elif first_blood_owner != -1:
		winner = first_blood_owner
		ending = END_FIRST_BLOOD
		result_text = "%s wins by First Blood." % owner_name(winner)
	else:
		winner = OWNER_P2
		ending = END_SURVIVAL
		result_text = "Silver wins by Survival."

func _state_key() -> String:
	var parts: Array = []
	parts.append("turn:%d" % turn)
	parts.append("res:%d,%d" % [int(reserves[0]), int(reserves[1])])
	parts.append("hot:%s" % str(hot_start_toggle))
	for r in range(BOARD_SIZE):
		var row_parts: Array = []
		for c in range(BOARD_SIZE):
			var p = board[r][c]
			if p == null:
				row_parts.append("__")
			else:
				var h: String = "1" if bool(p.get("hot_unused", false)) else "0"
				row_parts.append("%d%s%s" % [int(p.owner), String(p.kind), h])
		parts.append("".join(row_parts))
	return "|".join(parts)

func _snapshot() -> Dictionary:
	return {
		"board": board.duplicate(true),
		"turn": turn,
		"reserves": reserves.duplicate(true),
		"next_piece_id": next_piece_id,
		"mode_name": mode_name,
		"start_row": start_row.duplicate(true),
		"elevation_options": elevation_options.duplicate(true),
		"surround_toggle": surround_toggle,
		"collapse_toggle": collapse_toggle,
		"hot_start_toggle": hot_start_toggle,
		"speed_sigma": speed_sigma,
		"turn_timer_seconds": turn_timer_seconds,
		"turn_limit_total": turn_limit_total,
		"round_limit": round_limit,
		"game_over": game_over,
		"winner": winner,
		"ending": ending,
		"result_text": result_text,
		"full_rounds": full_rounds,
		"overtime": overtime,
		"overtime_rounds": overtime_rounds,
		"removals": removals.duplicate(true),
		"overtime_removals_this_round": overtime_removals_this_round.duplicate(true),
		"first_blood_owner": first_blood_owner,
		"history_keys": history_keys.duplicate(true),
		"anti_stall_moves": anti_stall_moves.duplicate(true),
		"last_action": last_action.duplicate(true),
		"last_resolution": last_resolution.duplicate(true),
		"pending_elevation": pending_elevation.duplicate(true),
		"pending_finalize": pending_finalize.duplicate(true),
		"scenario_hint": scenario_hint,
	}

func _restore(s: Dictionary) -> void:
	board = s.board.duplicate(true)
	turn = int(s.turn)
	reserves = s.reserves.duplicate(true)
	next_piece_id = int(s.next_piece_id)
	mode_name = String(s.mode_name)
	start_row = s.start_row.duplicate(true)
	elevation_options = s.elevation_options.duplicate(true)
	surround_toggle = bool(s.surround_toggle)
	collapse_toggle = bool(s.collapse_toggle)
	hot_start_toggle = bool(s.hot_start_toggle)
	speed_sigma = bool(s.get("speed_sigma", false))
	turn_timer_seconds = int(s.get("turn_timer_seconds", 0))
	turn_limit_total = int(s.get("turn_limit_total", int(s.get("round_limit", 100)) * 2))
	round_limit = int(s.get("round_limit", int(floor(float(turn_limit_total) / 2.0))))
	game_over = bool(s.game_over)
	winner = int(s.winner)
	ending = String(s.ending)
	result_text = String(s.result_text)
	full_rounds = int(s.full_rounds)
	overtime = bool(s.overtime)
	overtime_rounds = int(s.overtime_rounds)
	removals = s.removals.duplicate(true)
	overtime_removals_this_round = s.overtime_removals_this_round.duplicate(true)
	first_blood_owner = int(s.first_blood_owner)
	history_keys = s.history_keys.duplicate(true)
	anti_stall_moves = s.get("anti_stall_moves", [[], []]).duplicate(true)
	last_action = s.last_action.duplicate(true)
	last_resolution = s.last_resolution.duplicate(true)
	pending_elevation = s.get("pending_elevation", {}).duplicate(true)
	pending_finalize = s.get("pending_finalize", {}).duplicate(true)
	scenario_hint = String(s.get("scenario_hint", ""))

func _piece_full_name(kind: String) -> String:
	match kind:
		KIND_MONARCH:
			return "Monarch"
		KIND_GUARDIAN:
			return "Guardian"
		KIND_SENTINEL:
			return "Sentinel"
		KIND_INFILTRATOR:
			return "Infiltrator"
		KIND_ASSASSIN:
			return "Assassin"
		_:
			return kind

# --------------------------
# Scenario Test Lab helpers
# --------------------------

func load_scenario(scenario_id: String) -> void:
	var saved_surround: bool = surround_toggle
	var saved_collapse: bool = collapse_toggle
	var saved_hot: bool = hot_start_toggle
	mode_name = "Scenario Lab"
	start_row = ["G", "G", "G", "S", "M", "S", "G", "G", "G"]
	elevation_options = [KIND_SENTINEL, KIND_INFILTRATOR, KIND_ASSASSIN]
	surround_toggle = saved_surround
	collapse_toggle = saved_collapse
	hot_start_toggle = saved_hot
	_reset_empty_game_state()
	surround_toggle = saved_surround
	collapse_toggle = saved_collapse
	hot_start_toggle = saved_hot
	mode_name = "Scenario Lab - %s" % scenario_id

	var actual_id: String = scenario_id
	match scenario_id:
		"tutorial_move_guardian":
			actual_id = "guardian_move"
		"tutorial_jump_capture":
			actual_id = "guardian_capture"
		"tutorial_deploy":
			actual_id = "deploy"
		"tutorial_direct_peril":
			actual_id = "tutorial_create_peril"
		"tutorial_escape_peril":
			actual_id = "escape_peril"
		"tutorial_surrender":
			actual_id = "tutorial_force_surrender"
		"tutorial_retreat":
			actual_id = "retreat"
		"tutorial_elevate":
			actual_id = "elevate"
		"clean_escape":
			actual_id = "escape_peril"
		_:
			pass

	match actual_id:
		"classic_setup":
			new_game(classic_config())
			scenario_hint = "Classic setup: row GGGSMSGGG for both players, 5 Reserve Guardians each."
			return

		"guardian_move":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Select Gold Guardian at r5 c5. Legal moves: all four orthogonal adjacent spaces. No diagonal movement."

		"guardian_capture":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 4)
			_place_piece(OWNER_P2, KIND_SENTINEL, 3, 4)
			_place_piece(OWNER_P2, KIND_SENTINEL, 4, 3)
			_place_piece(OWNER_P2, KIND_SENTINEL, 4, 5)
			_place_piece(OWNER_P2, KIND_SENTINEL, 5, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Select Gold Guardian at r5 c5. All four orthogonal jump-captures should highlight. Diagonal jumps are not legal."

		"guardian_deploy":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 4)
			reserves = [5, 0]
			turn = OWNER_P1
			scenario_hint = "Press Deploy, then select Gold Guardian at r5 c5. Green Deploy spaces should be orthogonal only."

		"sentinel_movement":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_SENTINEL, 4, 4)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 4, 5)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 3, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Select Gold Sentinel at r5 c5. It moves 1 in any direction and jump-captures in any direction with empty landing."


		"tutorial_create_peril":
			_place_piece(OWNER_P1, KIND_MONARCH, 8, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P1, KIND_SENTINEL, 6, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Tutorial: move Gold Sentinel from r7 c5 to r6 c5. That directly threatens the Silver Monarch and creates Peril."

		"tutorial_force_surrender":
			# Corner Surrender lesson. Silver Monarch is boxed in.
			# The Gold Sentinel moves to r2 c2. Silver's adjacent Guardians
			# cannot jump-capture it because their landing squares are occupied.
			_place_piece(OWNER_P1, KIND_MONARCH, 8, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 0, 1)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 1, 0)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 2, 1)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 1, 2)
			_place_piece(OWNER_P1, KIND_SENTINEL, 2, 2)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Tutorial: move Gold Sentinel from r3 c3 to r2 c2. Silver Monarch is directly threatened with no legal escape and Surrenders."

		"peril_guardian":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 4, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Direct Peril: Silver Guardian at r5 c4 threatens Gold Monarch at r5 c5 orthogonally."

		"peril_sentinel":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_SENTINEL, 3, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Direct Peril: Silver Sentinel at r4 c5 directly threatens Gold Monarch at r5 c5."

		"peril_infiltrator_2":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_INFILTRATOR, 4, 2)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Direct Peril: Silver Infiltrator at r5 c3 threatens two spaces orthogonally to Gold Monarch at r5 c5 because path is clear."

		"peril_assassin_2":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_ASSASSIN, 2, 2)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Direct Peril: Silver Assassin at r3 c3 threatens two spaces diagonally to Gold Monarch at r5 c5 because path is clear."

		"peril_blocked_path":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 3)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_INFILTRATOR, 4, 2)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Blocked Path: Silver Infiltrator at r5 c3 is blocked by Gold Guardian at r5 c4, so Gold Monarch should NOT be in Peril."

		"peril_monarch_adjacent":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 3, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Direct Peril: enemy Monarch threatens one adjacent space. Gold Monarch is in Peril from adjacent Silver Monarch."

		"surrender":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			# Adjacent enemies directly threaten and occupy every normal escape square.
			for pos_value in [Vector2i(3,3), Vector2i(3,4), Vector2i(3,5), Vector2i(4,3), Vector2i(4,5), Vector2i(5,3), Vector2i(5,4), Vector2i(5,5)]:
				var pos: Vector2i = pos_value
				_place_piece(OWNER_P2, KIND_SENTINEL, pos.x, pos.y)
			# Occupy every possible Monarch escape square so the Monarch has no legal escape.
			for land_value in [Vector2i(2,2), Vector2i(2,4), Vector2i(2,6), Vector2i(4,2), Vector2i(4,6), Vector2i(6,2), Vector2i(6,4), Vector2i(6,6)]:
				var land_pos: Vector2i = land_value
				_place_piece(OWNER_P2, KIND_GUARDIAN, land_pos.x, land_pos.y)
			reserves = [0, 0]
			turn = OWNER_P1
			if is_monarch_in_peril(OWNER_P1) and not _player_has_any_legal_escape(OWNER_P1):
				game_over = true
				winner = OWNER_P2
				ending = END_SURRENDER
				result_text = "Silver wins by Surrender."
			scenario_hint = "Gold Monarch is boxed in and directly threatened with no legal escape. Result should show Silver wins by Surrender; Monarch remains on board."

		"escape_peril":
			_place_piece(OWNER_P1, KIND_MONARCH, 4, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 0, 0)
			_place_piece(OWNER_P2, KIND_SENTINEL, 3, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Gold starts in direct Peril from r4 c5. Select the Monarch; only moves that end outside direct threat should be legal."

		"deploy":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_SENTINEL, 4, 4)
			reserves = [5, 0]
			turn = OWNER_P1
			scenario_hint = "Press Deploy, select Gold Sentinel at r5 c5, then tap a green space. Reserve Guardian count should decrease."

		"illegal_deploy":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 1, 4)
			reserves = [5, 0]
			turn = OWNER_P1
			scenario_hint = "Press Deploy, select Guardian at r2 c5. Deploy to enemy back row r1 c5 is illegal; other orthogonal non-back-row Deploy spaces may be legal."

		"retreat":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 3, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 5)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 5, 4)
			_place_piece(OWNER_P1, KIND_SENTINEL, 5, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Move Gold Sentinel from r6 c4 to r5 c4. The friendly Guardian at r5 c5 should Retreat, not count as enemy removal."

		"enemy_surround":
			_put_basic_monarchs()
			_place_piece(OWNER_P2, KIND_GUARDIAN, 4, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 3, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 5, 4)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 5)
			_place_piece(OWNER_P1, KIND_SENTINEL, 5, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Move Gold Sentinel from r6 c4 to r5 c4. Silver Guardian at r5 c5 should be removed by Surround."

		"elevate":
			_place_piece(OWNER_P1, KIND_MONARCH, 8, 4)
			_place_piece(OWNER_P2, KIND_MONARCH, 4, 8)
			_place_piece(OWNER_P1, KIND_GUARDIAN, 1, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "Move Gold Guardian from r2 c5 to r1 c5. Elevate panel should offer Sentinel, Infiltrator, Assassin unless capped."

		"no_cycle":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_SENTINEL, 4, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			var sid: int = int(board[4][4].id)
			anti_stall_moves[OWNER_P1] = [
				_move_signature(OWNER_P1, sid, Vector2i(4, 4), Vector2i(4, 5)),
				_move_signature(OWNER_P1, sid, Vector2i(4, 5), Vector2i(4, 4)),
			]
			scenario_hint = "Select Gold Sentinel at r5 c5. Moving to r5 c6 is marked illegal only after three consecutive no-progress back-and-forth steps."

		"overtime":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_SENTINEL, 4, 3)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 4, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			overtime = true
			full_rounds = round_limit
			overtime_rounds = 0
			overtime_removals_this_round = [0, 0]
			scenario_hint = "Overtime forced. Track removals during each full overtime round; one-sided removal wins by Overtime Capture at round end."

		"illegal_lshape_infiltrator":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_INFILTRATOR, 4, 2)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 3, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "QA: Infiltrator may not step then turn into an L-shaped capture."

		"illegal_lshape_assassin":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_ASSASSIN, 5, 1)
			_place_piece(OWNER_P2, KIND_GUARDIAN, 4, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "QA: Assassin may not step then turn into a bent capture."

		"infiltrator_reach_capture":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_INFILTRATOR, 4, 2)
			_place_piece(OWNER_P2, KIND_INFILTRATOR, 4, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "QA: Gold Infiltrator can move through one clear orthogonal space, jump the enemy Infiltrator, and land beyond it."

		"assassin_reach_capture":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_ASSASSIN, 5, 1)
			_place_piece(OWNER_P2, KIND_ASSASSIN, 3, 3)
			reserves = [0, 0]
			turn = OWNER_P1
			scenario_hint = "QA: Gold Assassin can move through one clear diagonal space, jump the enemy Assassin, and land beyond it."

		"blitz_timeout":
			_put_basic_monarchs()
			_place_piece(OWNER_P1, KIND_GUARDIAN, 4, 4)
			reserves = [0, 0]
			turn = OWNER_P1
			speed_sigma = true
			turn_timer_seconds = 10
			turn_limit_total = 140
			round_limit = 70
			scenario_hint = "QA BLITZ: press QA Smoke or wait in BLITZ. Timeout should end the turn, not the game."

		"result_surrender":
			_put_basic_monarchs()
			reserves = [0, 0]
			turn = OWNER_P2
			game_over = true
			winner = OWNER_P1
			ending = END_SURRENDER
			result_text = "Gold wins by Surrender."
			removals = [2, 1]
			scenario_hint = "QA Result Screen: Gold wins by Surrender."

		"fallback_capture_lead":
			_put_basic_monarchs()
			reserves = [0, 0]
			overtime = true
			full_rounds = round_limit
			overtime_rounds = overtime_round_limit
			removals = [3, 2]
			first_blood_owner = OWNER_P2
			turn = OWNER_P1
			scenario_hint = "Debug fallback case: Gold removals 3, Silver 2. Press Resolve Fallback; Gold should win Capture Lead."

		"fallback_first_blood":
			_put_basic_monarchs()
			reserves = [0, 0]
			overtime = true
			full_rounds = round_limit
			overtime_rounds = overtime_round_limit
			removals = [2, 2]
			first_blood_owner = OWNER_P1
			turn = OWNER_P1
			scenario_hint = "Debug fallback case: removals tied 2-2 and Gold has First Blood. Press Resolve Fallback; Gold should win First Blood."

		"fallback_survival":
			_put_basic_monarchs()
			reserves = [0, 0]
			overtime = true
			full_rounds = round_limit
			overtime_rounds = overtime_round_limit
			removals = [0, 0]
			first_blood_owner = -1
			turn = OWNER_P1
			scenario_hint = "Debug fallback case: no removals. Press Resolve Fallback; Silver should win Survival."

		_:
			new_game(classic_config())
			return

	history_keys = {}
	history_keys[_state_key()] = true

func _put_basic_monarchs() -> void:
	_place_piece(OWNER_P1, KIND_MONARCH, 8, 4)
	_place_piece(OWNER_P2, KIND_MONARCH, 0, 4)

func _mark_resulting_state_seen(action: Dictionary) -> void:
	var snap: Dictionary = _snapshot()
	var actor: int = int(action.owner)
	_apply_action_core(action)
	turn = enemy(actor)
	var key: String = _state_key()
	_restore(snap)
	history_keys[key] = true

func force_overtime_debug() -> void:
	overtime = true
	full_rounds = round_limit
	overtime_rounds = 0
	overtime_removals_this_round = [0, 0]
	scenario_hint = "Overtime forced by debug button."

func resolve_overtime_fallback_debug() -> void:
	_apply_overtime_fallback()

func set_fallback_case_debug(case_name: String) -> void:
	game_over = false
	winner = -1
	ending = END_NONE
	result_text = ""
	overtime = true
	full_rounds = round_limit
	overtime_rounds = overtime_round_limit
	match case_name:
		"capture_lead":
			removals = [3, 2]
			first_blood_owner = OWNER_P2
			scenario_hint = "Debug fallback set: Gold 3 removals, Silver 2. Resolve = Gold Capture Lead."
		"first_blood":
			removals = [2, 2]
			first_blood_owner = OWNER_P1
			scenario_hint = "Debug fallback set: tied removals, Gold First Blood. Resolve = Gold First Blood."
		"survival":
			removals = [0, 0]
			first_blood_owner = -1
			scenario_hint = "Debug fallback set: no removals. Resolve = Silver Survival."
