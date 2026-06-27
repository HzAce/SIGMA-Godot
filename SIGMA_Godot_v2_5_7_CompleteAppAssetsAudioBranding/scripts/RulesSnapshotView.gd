extends Control
class_name RulesSnapshotView

# Static Rules Guide diagram renderer.
# Uses the official Classic SIGMA piece assets for non-interactive handbook snapshots.
# This is a visual/reference layer only; it does not decide legality.

var snapshot_id: String = "goal"
var token_textures: Dictionary = {}
var role_colors: Dictionary = {
	"gold": Color("#F2C14E"),
	"silver": Color("#CBD5E1"),
	"red": Color("#E53946"),
	"purple": Color("#8B5CF6"),
	"green": Color("#22C55E"),
	"blue": Color("#28A8FF"),
	"teal": Color("#20E6D2"),
	"orange": Color("#FF8A24"),
	"yellow": Color("#FDE047"),
	"pearl": Color("#E8EDF2"),
	"obsidian": Color("#111827")
}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 132)
	_load_token_textures()
	queue_redraw()

func set_snapshot(id: String) -> void:
	snapshot_id = id
	queue_redraw()

func _load_token_textures() -> void:
	token_textures = {
		"gold": {
			"M": load("res://assets/pieces/classic_sigma_tokens/gold_monarch.png"),
			"G": load("res://assets/pieces/classic_sigma_tokens/gold_guardian.png"),
			"S": load("res://assets/pieces/classic_sigma_tokens/gold_sentinel.png"),
			"I": load("res://assets/pieces/classic_sigma_tokens/gold_infiltrator.png"),
			"A": load("res://assets/pieces/classic_sigma_tokens/gold_assassin.png")
		},
		"silver": {
			"M": load("res://assets/pieces/classic_sigma_tokens/silver_monarch.png"),
			"G": load("res://assets/pieces/classic_sigma_tokens/silver_guardian.png"),
			"S": load("res://assets/pieces/classic_sigma_tokens/silver_sentinel.png"),
			"I": load("res://assets/pieces/classic_sigma_tokens/silver_infiltrator.png"),
			"A": load("res://assets/pieces/classic_sigma_tokens/silver_assassin.png")
		}
	}

func _draw() -> void:
	var r: Rect2 = Rect2(Vector2.ZERO, size)
	_draw_card_background(r)
	match snapshot_id:
		"setup":
			_draw_setup_snapshot(r)
		"actions":
			_draw_action_snapshot(r)
		"rounds":
			_draw_rounds_snapshot(r)
		"monarch":
			_draw_piece_movement_snapshot(r, "M", "gold", [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,0), Vector2i(1,0), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1)], "Monarch", role_colors["red"])
		"guardian":
			_draw_piece_movement_snapshot(r, "G", "gold", [Vector2i(0,-1), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,1)], "Guardian", role_colors["pearl"])
		"sentinel":
			_draw_piece_movement_snapshot(r, "S", "gold", [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,0), Vector2i(1,0), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1)], "Sentinel", role_colors["blue"])
		"infiltrator":
			_draw_piece_movement_snapshot(r, "I", "gold", [Vector2i(0,-1), Vector2i(0,-2), Vector2i(-1,0), Vector2i(-2,0), Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(0,2)], "Infiltrator", role_colors["green"])
		"assassin":
			_draw_piece_movement_snapshot(r, "A", "gold", [Vector2i(-1,-1), Vector2i(-2,-2), Vector2i(1,-1), Vector2i(2,-2), Vector2i(-1,1), Vector2i(-2,2), Vector2i(1,1), Vector2i(2,2)], "Assassin", role_colors["orange"])
		"deploy":
			_draw_deploy_snapshot(r)
		"peril":
			_draw_peril_snapshot(r, false)
		"surrender":
			_draw_peril_snapshot(r, true)
		"retreat":
			_draw_retreat_snapshot(r)
		"elevate":
			_draw_elevate_snapshot(r)
		"advanced_cap":
			_draw_advanced_cap_snapshot(r)
		"overtime":
			_draw_overtime_snapshot(r)
		_:
			_draw_goal_snapshot(r)

func _draw_card_background(r: Rect2) -> void:
	draw_rect(r.grow(-1), Color("#09111F"), true)
	draw_rect(r.grow(-1), Color("#F2C14E"), false, 2.0)
	for i in range(4):
		var alpha: float = 0.11 - float(i) * 0.02
		draw_rect(r.grow(-4.0 - float(i) * 3.0), Color(0.15, 0.85, 1.0, alpha), false, 1.0)

func _board_rect(r: Rect2) -> Rect2:
	var margin: float = 12.0
	var available_h: float = max(86.0, r.size.y - margin * 2.0)
	var available_w: float = min(r.size.x * 0.50, available_h)
	var side: float = floor(min(available_w, available_h))
	return Rect2(Vector2(margin, r.position.y + (r.size.y - side) * 0.5), Vector2(side, side))

func _info_rect(r: Rect2, board: Rect2) -> Rect2:
	var x: float = board.position.x + board.size.x + 12.0
	return Rect2(Vector2(x, r.position.y + 12.0), Vector2(max(0.0, r.size.x - x - 12.0), r.size.y - 24.0))

func _draw_mini_board(board: Rect2) -> void:
	draw_rect(board.grow(5.0), Color("#04070D"), true)
	draw_rect(board.grow(5.0), Color("#D4AF37"), false, 2.0)
	var cell: float = board.size.x / 9.0
	for row in range(9):
		for col in range(9):
			var tile: Rect2 = Rect2(board.position + Vector2(float(col) * cell, float(row) * cell), Vector2(cell, cell))
			var base: Color = Color("#111B2D") if (row + col) % 2 == 0 else Color("#16243A")
			draw_rect(tile, base, true)
			draw_rect(tile, Color(0.98, 0.76, 0.28, 0.22), false, 1.0)

func _cell_center(board: Rect2, pos: Vector2i) -> Vector2:
	var cell: float = board.size.x / 9.0
	return board.position + Vector2((float(pos.x) + 0.5) * cell, (float(pos.y) + 0.5) * cell)

func _draw_highlight(board: Rect2, pos: Vector2i, color: Color, radius_scale: float = 0.34) -> void:
	if pos.x < 0 or pos.x > 8 or pos.y < 0 or pos.y > 8:
		return
	var cell: float = board.size.x / 9.0
	var c: Vector2 = _cell_center(board, pos)
	draw_circle(c, cell * radius_scale, Color(color.r, color.g, color.b, 0.26))
	draw_circle(c, cell * radius_scale * 0.68, Color(color.r, color.g, color.b, 0.18))

func _draw_arrow(from: Vector2, to: Vector2, color: Color, width: float = 2.0) -> void:
	draw_line(from, to, color, width, true)
	var dir: Vector2 = (to - from).normalized()
	if dir.length() <= 0.001:
		return
	var left: Vector2 = dir.rotated(2.55) * 8.0
	var right: Vector2 = dir.rotated(-2.55) * 8.0
	draw_line(to, to + left, color, width, true)
	draw_line(to, to + right, color, width, true)

func _draw_token(board: Rect2, pos: Vector2i, kind: String, owner_key: String, scale: float = 0.88) -> void:
	var cell: float = board.size.x / 9.0
	var center: Vector2 = _cell_center(board, pos)
	var size_px: float = cell * scale
	var tex: Texture2D = null
	if token_textures.has(owner_key) and (token_textures[owner_key] as Dictionary).has(kind):
		tex = (token_textures[owner_key] as Dictionary)[kind]
	if tex != null:
		draw_texture_rect(tex, Rect2(center - Vector2(size_px, size_px) * 0.5, Vector2(size_px, size_px)), false)
	else:
		var metal: Color = role_colors["gold"] if owner_key == "gold" else role_colors["silver"]
		draw_circle(center, size_px * 0.46, metal)
		draw_string(get_theme_default_font(), center + Vector2(-5, 5), kind, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.BLACK)

func _draw_caption(rect: Rect2, headline: String, lines: Array) -> void:
	var font: Font = get_theme_default_font()
	draw_string(font, rect.position + Vector2(0, 18), headline, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 16, Color("#F2C14E"))
	var y: float = rect.position.y + 40.0
	for line_value in lines:
		draw_string(font, Vector2(rect.position.x, y), String(line_value), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, 12, Color("#E8EDF2"))
		y += 17.0

func _draw_setup_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	var row: Array = ["G", "I", "A", "S", "M", "S", "A", "I", "G"]
	for i in range(row.size()):
		_draw_token(board, Vector2i(i, 8), String(row[i]), "gold", 0.78)
		_draw_token(board, Vector2i(i, 0), String(row[i]), "silver", 0.78)
	_draw_caption(_info_rect(r, board), "Classic SIGMA Set", ["Official pieces + board.", "Gold starts from bottom.", "Silver faces top.", "5 Reserve Guardians each."])

func _draw_goal_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4, 6), "M", "silver", 0.9)
	_draw_token(board, Vector2i(4, 8), "I", "gold", 0.9)
	_draw_highlight(board, Vector2i(4, 6), role_colors["red"], 0.48)
	_draw_arrow(_cell_center(board, Vector2i(4, 8)), _cell_center(board, Vector2i(4, 6)), role_colors["red"], 2.5)
	_draw_caption(_info_rect(r, board), "Goal", ["Create direct Peril.", "No legal escape means", "the Monarch Surrenders."])

func _draw_action_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4, 4), "G", "gold", 0.9)
	_draw_highlight(board, Vector2i(4, 3), role_colors["blue"])
	_draw_highlight(board, Vector2i(5, 4), role_colors["red"])
	_draw_highlight(board, Vector2i(3, 4), role_colors["green"])
	_draw_caption(_info_rect(r, board), "One player turn", ["Move, Capture, or Deploy.", "Preview/Confirm in Classic.", "BLITZ! applies fast actions."])

func _draw_rounds_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(3, 7), "G", "gold", 0.76)
	_draw_token(board, Vector2i(5, 1), "G", "silver", 0.76)
	_draw_caption(_info_rect(r, board), "Full round", ["Gold player turn", "+ Silver player turn", "= 1 full round.", "Gold always starts."])

func _draw_piece_movement_snapshot(r: Rect2, kind: String, owner_key: String, offsets: Array, headline: String, col: Color) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	var origin: Vector2i = Vector2i(4, 4)
	_draw_token(board, origin, kind, owner_key, 0.95)
	for off_value in offsets:
		var p: Vector2i = origin + (off_value as Vector2i)
		_draw_highlight(board, p, col)
		_draw_arrow(_cell_center(board, origin), _cell_center(board, p), Color(col.r, col.g, col.b, 0.72), 1.6)
	_draw_caption(_info_rect(r, board), headline, ["Official Classic token.", "Highlighted spaces show", "basic movement geometry."])

func _draw_deploy_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4, 5), "S", "gold", 0.9)
	for p in [Vector2i(4,4), Vector2i(5,5), Vector2i(4,6), Vector2i(3,5)]:
		_draw_highlight(board, p, role_colors["green"])
	_draw_token(board, Vector2i(3, 8), "G", "gold", 0.58)
	_draw_caption(_info_rect(r, board), "Deploy", ["Reserve Guardian enters", "adjacent to a friendly", "piece by legal direction."])

func _draw_peril_snapshot(r: Rect2, surrender: bool) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4, 2), "M", "silver", 0.9)
	_draw_token(board, Vector2i(4, 4), "S", "gold", 0.9)
	_draw_arrow(_cell_center(board, Vector2i(4,4)), _cell_center(board, Vector2i(4,2)), role_colors["red"], 2.7)
	_draw_highlight(board, Vector2i(4,2), role_colors["red"], 0.52)
	if surrender:
		for p in [Vector2i(3,1), Vector2i(4,1), Vector2i(5,1), Vector2i(3,2), Vector2i(5,2), Vector2i(3,3), Vector2i(4,3), Vector2i(5,3)]:
			_draw_highlight(board, p, role_colors["purple"], 0.25)
	_draw_caption(_info_rect(r, board), "Surrender" if surrender else "Peril", ["Direct threat to Monarch.", "Next action must escape." if not surrender else "No legal escape.", "Monarchs Surrender."])

func _draw_retreat_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4,4), "G", "gold", 0.9)
	for p in [Vector2i(4,3), Vector2i(5,4), Vector2i(4,5), Vector2i(3,4)]:
		_draw_token(board, p, "G", "gold", 0.62)
	_draw_highlight(board, Vector2i(4,4), role_colors["green"], 0.50)
	_draw_caption(_info_rect(r, board), "Retreat", ["Friendly boxed-in", "non-Monarch pieces", "Retreat instead of", "being removed."])

func _draw_elevate_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4,1), "G", "gold", 0.86)
	_draw_highlight(board, Vector2i(4,0), role_colors["purple"], 0.50)
	_draw_arrow(_cell_center(board, Vector2i(4,1)), _cell_center(board, Vector2i(4,0)), role_colors["purple"], 2.4)
	_draw_token(board, Vector2i(6,0), "S", "gold", 0.58)
	_draw_token(board, Vector2i(7,0), "I", "gold", 0.58)
	_draw_token(board, Vector2i(8,0), "A", "gold", 0.58)
	_draw_caption(_info_rect(r, board), "Elevate", ["Guardian reaches", "enemy back row.", "Choose S, I, or A", "if cap allows."])

func _draw_advanced_cap_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	for i in range(3):
		_draw_token(board, Vector2i(1 + i, 4), "S", "gold", 0.62)
		_draw_token(board, Vector2i(1 + i, 5), "I", "gold", 0.62)
		_draw_token(board, Vector2i(1 + i, 6), "A", "gold", 0.62)
	_draw_caption(_info_rect(r, board), "Advanced Cap", ["Max 3 of each", "advanced type", "on board at once."])

func _draw_overtime_snapshot(r: Rect2) -> void:
	var board: Rect2 = _board_rect(r)
	_draw_mini_board(board)
	_draw_token(board, Vector2i(4,7), "M", "gold", 0.75)
	_draw_token(board, Vector2i(4,1), "M", "silver", 0.75)
	_draw_caption(_info_rect(r, board), "Overtime", ["After 100 full rounds", "Overtime begins.", "Enemy removals can", "win by Overtime Capture."])
