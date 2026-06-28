extends RefCounted
class_name SigmaAI

# SIGMA v2.2.1 offline strategy bot with safety sense.
# The bot never decides legality. All candidate actions, previews, and simulated
# results come from SigmaRules.gd. This file only evaluates legal pathways.
# Goal: play to win through pressure, Peril, Surrender pathways, captures,
# creative Deploy/Retreat use, and long-term activity — not passive Overtime.

const INF := 1000000000.0
const WIN_SCORE := 1000000.0
const BOARD_CENTER := Vector2i(4, 4)
const MAX_RECENT_ACTIONS := 10

var rng := RandomNumberGenerator.new()
var recent_action_keys: Array = []

func _init() -> void:
	rng.randomize()

func difficulty_config(difficulty: String) -> Dictionary:
	match difficulty:
		"Beginner":
			return {
				"depth": 1, "branch": 4, "variety": 0.58, "noise": 150.0,
				"tactical": 0.58, "eval_quality": 0.58, "top_pool": 7,
				"safety": 0.35, "sacrifice": 0.18,
				"selective": 0, "repeat_penalty": 12.0, "time_ms": 35, "fast_pick": true
			}
		"Rookie":
			return {
				"depth": 1, "branch": 4, "variety": 0.42, "noise": 90.0,
				"tactical": 0.76, "eval_quality": 0.72, "top_pool": 6,
				"safety": 0.50, "sacrifice": 0.22,
				"selective": 0, "repeat_penalty": 22.0, "time_ms": 45, "fast_pick": true
			}
		"Intermediate":
			return {
				"depth": 1, "branch": 5, "variety": 0.28, "noise": 48.0,
				"tactical": 0.92, "eval_quality": 0.86, "top_pool": 5,
				"safety": 0.70, "sacrifice": 0.30,
				"selective": 0, "repeat_penalty": 32.0, "time_ms": 70, "fast_pick": true
			}
		"Professional":
			return {
				"depth": 2, "branch": 9, "variety": 0.18, "noise": 24.0,
				"tactical": 1.04, "eval_quality": 1.00, "top_pool": 4,
				"safety": 1.00, "sacrifice": 0.42,
				"selective": 0, "repeat_penalty": 42.0, "time_ms": 260
			}
		"Expert":
			return {
				"depth": 2, "branch": 11, "variety": 0.11, "noise": 12.0,
				"tactical": 1.12, "eval_quality": 1.10, "top_pool": 3,
				"safety": 1.16, "sacrifice": 0.55,
				"selective": 1, "repeat_penalty": 55.0, "time_ms": 420
			}
		"Champion":
			return {
				"depth": 2, "branch": 12, "variety": 0.06, "noise": 5.0,
				"tactical": 1.22, "eval_quality": 1.20, "top_pool": 2,
				"safety": 1.28, "sacrifice": 0.70,
				"selective": 1, "repeat_penalty": 70.0, "time_ms": 650
			}
		_:
			return difficulty_config("Rookie")

func choose_action(rules: SigmaRules, ai_owner: int, difficulty: String = "Rookie") -> Dictionary:
	if rules == null or rules.game_over or rules.has_pending_elevation():
		return {}
	var actions: Array = rules.get_legal_actions_for_player(ai_owner)
	if actions.is_empty():
		return {}
	var cfg: Dictionary = difficulty_config(difficulty)
	var depth: int = int(cfg.get("depth", 1))
	var branch_limit: int = int(cfg.get("branch", 7))
	var tactical_scale: float = float(cfg.get("tactical", 1.0))
	var eval_quality: float = float(cfg.get("eval_quality", 1.0))
	var safety_scale: float = float(cfg.get("safety", 0.8))
	var sacrifice_tolerance: float = float(cfg.get("sacrifice", 0.3))
	var deadline_ms: int = Time.get_ticks_msec() + int(cfg.get("time_ms", 180))
	var fast_pick: bool = bool(cfg.get("fast_pick", false))
	var rows: Array = []
	var urgent: Array = []

	# First pass: score every legal action quickly so the AI always has a move.
	for action_value in actions:
		var action: Dictionary = (action_value as Dictionary).duplicate(true)
		var preview: Dictionary = rules.preview_action(action)
		if not bool(preview.get("ok", false)):
			continue
		var quick: float = _quick_action_score(rules, action, ai_owner, eval_quality) * tactical_scale
		if not fast_pick:
			quick += _post_action_safety_score(rules, action, ai_owner, eval_quality, safety_scale, sacrifice_tolerance)
		else:
			# Beginner through Intermediate use a lightweight chooser so offline mobile play
			# feels responsive. They still use preview legality and tactical scoring, but
			# skip the expensive simulated safety pass.
			quick += _fast_opening_development_bonus(rules, action, ai_owner, eval_quality)
		quick -= _recent_repeat_penalty(action, float(cfg.get("repeat_penalty", 0.0)))
		var urgency: int = _preview_urgency(rules, action, preview, ai_owner)
		if urgency > 0:
			urgent.append({"action": action, "score": quick, "urgency": urgency})
		rows.append({"action": action, "score": quick, "urgency": urgency})
	if rows.is_empty():
		return {}

	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var au: int = int(a.get("urgency", 0))
		var bu: int = int(b.get("urgency", 0))
		if au != bu:
			return au > bu
		return float(a.get("score", 0.0)) > float(b.get("score", 0.0))
	)

	# Forced tactical moves must happen immediately: win, create Surrender, or escape own Peril.
	if not urgent.is_empty():
		urgent.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var au: int = int(a.get("urgency", 0))
			var bu: int = int(b.get("urgency", 0))
			if au != bu:
				return au > bu
			return float(a.get("score", 0.0)) > float(b.get("score", 0.0))
		)
		var top_urgent: Dictionary = urgent[0] as Dictionary
		if int(top_urgent.get("urgency", 0)) >= 80:
			var forced_action: Dictionary = (top_urgent.get("action", {}) as Dictionary).duplicate(true)
			_record_action_choice(forced_action)
			return forced_action

	if fast_pick:
		var fast_chosen: Dictionary = _choose_from_ranked_rows(rows, cfg)
		var fast_action: Dictionary = (fast_chosen.get("action", {}) as Dictionary).duplicate(true)
		_record_action_choice(fast_action)
		return fast_action

	# Second pass: only the top branch gets deeper search. This keeps Android real-time.
	var search_rows: Array = rows.duplicate(true)
	while search_rows.size() > branch_limit:
		search_rows.pop_back()
	var searched: Array = []
	for row_value in search_rows:
		if Time.get_ticks_msec() > deadline_ms:
			break
		var row: Dictionary = row_value as Dictionary
		var action: Dictionary = (row.get("action", {}) as Dictionary).duplicate(true)
		var sim: SigmaRules = _clone_rules(rules)
		if not _apply_action_for_search(sim, action, ai_owner, difficulty):
			continue
		var score: float = float(row.get("score", 0.0))
		if depth > 1:
			score += _minimax(sim, ai_owner, depth - 1, -INF, INF, branch_limit, int(cfg.get("selective", 0)), eval_quality)
		else:
			score += _evaluate(sim, ai_owner, eval_quality) * 0.18
		if float(cfg.get("noise", 0.0)) > 0.0 and int(row.get("urgency", 0)) < 90:
			score += rng.randf_range(-float(cfg.get("noise", 0.0)), float(cfg.get("noise", 0.0)))
		searched.append({"action": action, "score": score, "urgency": int(row.get("urgency", 0))})
	if not searched.is_empty():
		rows = searched
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var au: int = int(a.get("urgency", 0))
		var bu: int = int(b.get("urgency", 0))
		if au != bu:
			return au > bu
		return float(a.get("score", 0.0)) > float(b.get("score", 0.0))
	)

	var variety: float = float(cfg.get("variety", 0.16))
	var window: float = max(10.0, 90.0 * variety + float(cfg.get("noise", 0.0)) * 0.20)
	var best_score: float = float(rows[0].get("score", 0.0))
	var candidates: Array = []
	for row_value in rows:
		var row: Dictionary = row_value as Dictionary
		if int(row.get("urgency", 0)) == int(rows[0].get("urgency", 0)) and float(row.get("score", -INF)) >= best_score - window:
			candidates.append(row)
	var max_pool: int = clampi(int(cfg.get("top_pool", 4)), 1, 8)
	while candidates.size() > max_pool:
		candidates.pop_back()
	if candidates.is_empty():
		var fallback_action: Dictionary = (rows[0].get("action", {}) as Dictionary).duplicate(true)
		_record_action_choice(fallback_action)
		return fallback_action
	var chosen: Dictionary = _weighted_candidate_choice(candidates, best_score, float(cfg.get("noise", 0.0)))
	var chosen_action: Dictionary = (chosen.get("action", {}) as Dictionary).duplicate(true)
	_record_action_choice(chosen_action)
	return chosen_action

func _preview_urgency(before_rules: SigmaRules, action: Dictionary, preview: Dictionary, ai_owner: int) -> int:
	if bool(preview.get("surrender", false)):
		return 98
	if before_rules.is_monarch_in_peril(ai_owner) and not bool(preview.get("own_monarch_in_peril", false)):
		return 92
	if bool(preview.get("enemy_monarch_in_peril", false)):
		return 42
	if String(action.get("type", "")) == SigmaRules.ACTION_JUMP:
		return 40
	if bool(preview.get("pending_elevation", false)):
		return 34
	return 0

func choose_elevation(rules: SigmaRules, ai_owner: int, difficulty: String = "Rookie") -> String:
	if rules == null or not rules.has_pending_elevation():
		return ""
	var options: Array = rules.get_pending_elevation_options()
	if options.is_empty():
		return ""
	var best_kind: String = String(options[0])
	var best_score: float = -INF
	var cfg: Dictionary = difficulty_config(difficulty)
	for kind_value in options:
		var kind: String = String(kind_value)
		var sim: SigmaRules = _clone_rules(rules)
		if not sim.choose_pending_elevation(kind):
			continue
		var score: float = _evaluate(sim, ai_owner, float(cfg.get("eval_quality", 1.0)))
		# Choose advanced pieces based on board need, not fixed preference.
		score += _elevation_role_fit(sim, ai_owner, kind)
		if difficulty in ["Beginner", "Rookie", "Intermediate"]:
			score += rng.randf_range(-28.0, 28.0)
		if score > best_score:
			best_score = score
			best_kind = kind
	return best_kind

func _minimax(rules: SigmaRules, perspective: int, depth: int, alpha: float, beta: float, branch_limit: int, selective: int, eval_quality: float) -> float:
	if rules.game_over or rules.has_pending_elevation():
		return _evaluate(rules, perspective, eval_quality)
	if depth <= 0:
		if selective > 0 and _position_is_tactical(rules, perspective):
			return _tactical_extension(rules, perspective, alpha, beta, max(6, int(branch_limit / 2)), eval_quality)
		return _evaluate(rules, perspective, eval_quality)
	var owner: int = int(rules.turn)
	var ordered: Array = _ordered_actions(rules, owner, branch_limit, eval_quality)
	if ordered.is_empty():
		return _evaluate(rules, perspective, eval_quality)
	if owner == perspective:
		var best: float = -INF
		for row_value in ordered:
			var action: Dictionary = (row_value as Dictionary).get("action", {}) as Dictionary
			var sim: SigmaRules = _clone_rules(rules)
			if not _apply_action_for_search(sim, action, owner, "search"):
				continue
			var score: float = _minimax(sim, perspective, depth - 1, alpha, beta, branch_limit, selective, eval_quality)
			best = max(best, score)
			alpha = max(alpha, best)
			if beta <= alpha:
				break
		return best
	else:
		var worst: float = INF
		for row_value in ordered:
			var action: Dictionary = (row_value as Dictionary).get("action", {}) as Dictionary
			var sim: SigmaRules = _clone_rules(rules)
			if not _apply_action_for_search(sim, action, owner, "search"):
				continue
			var score: float = _minimax(sim, perspective, depth - 1, alpha, beta, branch_limit, selective, eval_quality)
			worst = min(worst, score)
			beta = min(beta, worst)
			if beta <= alpha:
				break
		return worst

func _tactical_extension(rules: SigmaRules, perspective: int, alpha: float, beta: float, branch_limit: int, eval_quality: float) -> float:
	var owner: int = int(rules.turn)
	var ordered: Array = _ordered_actions(rules, owner, branch_limit, eval_quality)
	var tactical_rows: Array = []
	for row_value in ordered:
		var row: Dictionary = row_value as Dictionary
		var action: Dictionary = row.get("action", {}) as Dictionary
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("surrender", false)) or bool(preview.get("enemy_monarch_in_peril", false)) or String(action.get("type", "")) == SigmaRules.ACTION_JUMP or bool(preview.get("pending_elevation", false)):
			tactical_rows.append(row)
	while tactical_rows.size() > branch_limit:
		tactical_rows.pop_back()
	if tactical_rows.is_empty():
		return _evaluate(rules, perspective, eval_quality)
	if owner == perspective:
		var best: float = _evaluate(rules, perspective, eval_quality)
		for row_value in tactical_rows:
			var action: Dictionary = (row_value as Dictionary).get("action", {}) as Dictionary
			var sim: SigmaRules = _clone_rules(rules)
			if not _apply_action_for_search(sim, action, owner, "search"):
				continue
			var score: float = _evaluate(sim, perspective, eval_quality)
			best = max(best, score)
			alpha = max(alpha, best)
			if beta <= alpha:
				break
		return best
	else:
		var worst: float = _evaluate(rules, perspective, eval_quality)
		for row_value in tactical_rows:
			var action: Dictionary = (row_value as Dictionary).get("action", {}) as Dictionary
			var sim: SigmaRules = _clone_rules(rules)
			if not _apply_action_for_search(sim, action, owner, "search"):
				continue
			var score: float = _evaluate(sim, perspective, eval_quality)
			worst = min(worst, score)
			beta = min(beta, worst)
			if beta <= alpha:
				break
		return worst

func _ordered_actions(rules: SigmaRules, owner: int, branch_limit: int, eval_quality: float) -> Array:
	var rows: Array = []
	for action_value in rules.get_legal_actions_for_player(owner):
		var action: Dictionary = (action_value as Dictionary).duplicate(true)
		var safety_scale: float = clampf(eval_quality, 0.55, 1.25)
		var sacrifice_tolerance: float = 0.35 if eval_quality < 1.0 else 0.58
		var score: float = _quick_action_score(rules, action, owner, eval_quality)
		score += _post_action_safety_score(rules, action, owner, eval_quality, safety_scale, sacrifice_tolerance)
		rows.append({"action": action, "score": score})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("score", 0.0)) > float(b.get("score", 0.0))
	)
	while rows.size() > branch_limit:
		rows.pop_back()
	return rows

func _clone_rules(rules: SigmaRules) -> SigmaRules:
	var sim: SigmaRules = SigmaRules.new()
	sim.import_save_state(rules.export_save_state())
	return sim

func _apply_action_for_search(sim: SigmaRules, action: Dictionary, actor: int, difficulty: String) -> bool:
	if not sim.apply_action(action):
		return false
	if sim.has_pending_elevation() and sim.get_pending_elevation_owner() == actor:
		var kind: String = choose_elevation(sim, actor, difficulty)
		if kind != "":
			sim.choose_pending_elevation(kind)
	return true

func _urgency_level(before_rules: SigmaRules, after_rules: SigmaRules, action: Dictionary, preview: Dictionary, ai_owner: int) -> int:
	if after_rules.game_over and after_rules.winner == ai_owner:
		return 100
	if bool(preview.get("surrender", false)):
		return 98
	# If the AI Monarch is already in Peril, legal escape is an obligation.
	if before_rules.is_monarch_in_peril(ai_owner) and not bool(preview.get("own_monarch_in_peril", false)):
		return 92
	if after_rules.game_over and after_rules.winner == before_rules.enemy(ai_owner):
		return 91
	if String(action.get("type", "")) == SigmaRules.ACTION_JUMP:
		return 45
	if bool(preview.get("enemy_monarch_in_peril", false)):
		return 42
	if bool(preview.get("pending_elevation", false)):
		return 36
	return 0

func _quick_action_score(rules: SigmaRules, action: Dictionary, owner: int, eval_quality: float = 1.0) -> float:
	var score: float = 0.0
	var preview: Dictionary = rules.preview_action(action)
	if not bool(preview.get("ok", false)):
		return -INF
	if bool(preview.get("surrender", false)):
		score += 18000.0
	if bool(preview.get("enemy_monarch_in_peril", false)):
		score += 780.0 * eval_quality
	if bool(preview.get("own_monarch_in_peril", false)):
		score -= 1600.0 * eval_quality
	# Captures and surrounds use piece values when we can identify the affected piece.
	for pos_value in (preview.get("captured_positions", []) as Array):
		var pos: Vector2i = pos_value as Vector2i
		score += 290.0 + _piece_value_at(rules, pos) * 1.25
	for pos_value in (preview.get("enemy_surround_positions", []) as Array):
		var pos: Vector2i = pos_value as Vector2i
		score += 170.0 + _piece_value_at(rules, pos) * 0.85
	# Friendly Retreat is a SIGMA resource, not a failure. Give creative credit
	# when it returns an advanced piece or creates future Deploy flexibility.
	for pos_value in (preview.get("friendly_retreat_positions", []) as Array):
		var pos: Vector2i = pos_value as Vector2i
		var p = _piece_at(rules, pos)
		if p != null:
			var kind: String = String(p.kind)
			if kind in [SigmaRules.KIND_SENTINEL, SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN]:
				score += 90.0 * eval_quality
			else:
				score += 32.0 * eval_quality
	if bool(preview.get("pending_elevation", false)):
		score += 430.0 * eval_quality
	if String(action.get("type", "")) == SigmaRules.ACTION_DEPLOY:
		score += _deploy_action_bonus(rules, action, owner, eval_quality)
		score -= _early_deploy_penalty(rules, action, preview, owner, eval_quality)
	var from_pos: Vector2i = action.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	if to_pos.x >= 0:
		score += _center_score(to_pos) * 5.0 * eval_quality
		score += _forward_progress_bonus(to_pos, owner) * 7.0 * eval_quality
		score += _monarch_pressure_bonus(rules, to_pos, owner) * 5.0 * eval_quality
	if from_pos.x >= 0 and to_pos.x >= 0:
		if String(action.get("type", "")) == SigmaRules.ACTION_MOVE:
			score += _opening_back_row_development_bonus(rules, action, owner, eval_quality)
		# Do not overvalue pure side-to-side shuffles. This helps prevent bots from
		# playing for Overtime by drifting around safely.
		if _forward_progress_bonus(to_pos, owner) <= _forward_progress_bonus(from_pos, owner) and _center_score(to_pos) <= _center_score(from_pos):
			score -= 12.0 * eval_quality
	return score

func _evaluate(rules: SigmaRules, perspective: int, eval_quality: float = 1.0) -> float:
	if rules.game_over:
		if rules.winner == perspective:
			return WIN_SCORE
		if rules.winner == rules.enemy(perspective):
			return -WIN_SCORE
		return 0.0
	var opponent: int = rules.enemy(perspective)
	var score: float = 0.0
	for r in range(SigmaRules.BOARD_SIZE):
		for c in range(SigmaRules.BOARD_SIZE):
			var p = rules.board[r][c]
			if p == null:
				continue
			var owner: int = int(p.owner)
			var sign: float = 1.0 if owner == perspective else -1.0
			var kind: String = String(p.kind)
			var pos: Vector2i = Vector2i(r, c)
			score += sign * _piece_value(kind)
			score += sign * _center_score(pos) * 7.0 * eval_quality
			score += sign * _forward_progress_bonus(pos, owner) * _progress_weight(kind) * eval_quality
			score += sign * _piece_activity_bonus(rules, pos, p) * eval_quality
			if kind != SigmaRules.KIND_MONARCH:
				score += sign * _monarch_pressure_bonus(rules, pos, owner) * 4.0 * eval_quality
	# Reserves and Deploy flexibility.
	score += float(rules.reserves[perspective] - rules.reserves[opponent]) * 42.0 * eval_quality
	score += float(_deploy_count(rules, perspective) - _deploy_count(rules, opponent)) * 7.0 * eval_quality
	# Removed/captured material matters, but should not overpower winning pressure.
	score += float(rules.removals[perspective] - rules.removals[opponent]) * 190.0
	# Monarch pressure and safety.
	if rules.is_monarch_in_peril(opponent):
		score += 930.0 * eval_quality
		score -= float(_escape_action_count(rules, opponent)) * 22.0 * eval_quality
	if rules.is_monarch_in_peril(perspective):
		score -= 1120.0 * eval_quality
		score += float(_escape_action_count(rules, perspective)) * 16.0 * eval_quality
	score += float(_monarch_space_count(rules, perspective) - _monarch_space_count(rules, opponent)) * 20.0 * eval_quality
	# Whole-position activity. Better bots value active pressure over turtling.
	var own_actions: int = rules.get_legal_actions_for_player(perspective).size()
	var opp_actions: int = rules.get_legal_actions_for_player(opponent).size()
	score += float(own_actions - opp_actions) * 4.5 * eval_quality
	score += float(_pressure_action_count(rules, perspective) - _pressure_action_count(rules, opponent)) * 13.0 * eval_quality
	# Danger sense: pieces that can be captured next turn are real liabilities.
	score += _available_capture_value(rules, perspective) * 1.15 * eval_quality
	score -= _available_capture_value(rules, opponent) * 1.35 * eval_quality
	# Avoid defensive Overtime-only play. As the round limit approaches, raise the
	# value of pressure, material conversion, and active threats.
	var round_ratio: float = 0.0
	if int(rules.round_limit) > 0:
		round_ratio = clampf(float(rules.full_rounds) / float(rules.round_limit), 0.0, 1.0)
	score += round_ratio * float(_pressure_action_count(rules, perspective) - _pressure_action_count(rules, opponent)) * 18.0 * eval_quality
	if rules.overtime:
		score += float(rules.overtime_removals_this_round[perspective] - rules.overtime_removals_this_round[opponent]) * 340.0
		score += float(rules.removals[perspective] - rules.removals[opponent]) * 80.0
	return score

func _post_action_safety_score(rules: SigmaRules, action: Dictionary, owner: int, eval_quality: float, safety_scale: float, sacrifice_tolerance: float) -> float:
	var preview: Dictionary = rules.preview_action(action)
	if not bool(preview.get("ok", false)):
		return -50000.0
	if bool(preview.get("surrender", false)):
		return 0.0
	var sim: SigmaRules = _clone_rules(rules)
	if not _apply_action_for_search(sim, action, owner, "safety"):
		return -50000.0
	var opponent: int = rules.enemy(owner)
	var score: float = 0.0
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	var moved_piece = _piece_at(sim, to_pos)
	if to_pos.x >= 0 and moved_piece != null and int(moved_piece.owner) == owner:
		var kind: String = String(moved_piece.kind)
		if kind != SigmaRules.KIND_MONARCH:
			var value: float = max(80.0, _piece_value(kind))
			var danger: float = _capture_threat_value_on_square(sim, opponent, to_pos)
			if danger > 0.0:
				var support: int = _friendly_support_count(sim, to_pos, owner)
				var payoff: float = _action_payoff_score(preview, action)
				var penalty: float = (value * 1.45 + danger * 0.45 + 130.0) * safety_scale
				if support > 0:
					penalty *= max(0.54, 1.0 - float(support) * 0.14)
				if payoff >= 1200.0:
					penalty *= max(0.20, 1.0 - sacrifice_tolerance)
				elif payoff >= 500.0:
					penalty *= max(0.45, 1.0 - sacrifice_tolerance * 0.62)
				score -= penalty
			elif bool(preview.get("enemy_monarch_in_peril", false)) and _friendly_support_count(sim, to_pos, owner) > 0:
				# Reward supported pressure, not naked Monarch-chasing.
				score += 90.0 * eval_quality
	# If the opponent gets an immediate Surrender or major capture after our move,
	# the move is strategically suspect unless it was already a forced win line.
	if _opponent_has_immediate_surrender(sim, opponent):
		score -= 2400.0 * safety_scale
	var opp_capture_value: float = _available_capture_value(sim, opponent)
	if opp_capture_value > 0.0:
		score -= opp_capture_value * 0.35 * safety_scale
	return score

func _action_payoff_score(preview: Dictionary, action: Dictionary) -> float:
	var payoff: float = 0.0
	if bool(preview.get("enemy_monarch_in_peril", false)):
		payoff += 520.0
	if bool(preview.get("pending_elevation", false)):
		payoff += 420.0
	if String(action.get("type", "")) == SigmaRules.ACTION_JUMP:
		payoff += 360.0
	payoff += float((preview.get("captured_positions", []) as Array).size()) * 300.0
	payoff += float((preview.get("enemy_surround_positions", []) as Array).size()) * 260.0
	return payoff

func _capture_threat_value_on_square(rules: SigmaRules, attacker: int, target: Vector2i) -> float:
	if target.x < 0:
		return 0.0
	var value: float = 0.0
	for action_value in rules.get_legal_actions_for_player(attacker):
		var action: Dictionary = action_value as Dictionary
		if String(action.get("type", "")) == SigmaRules.ACTION_JUMP and action.get("capture", Vector2i(-1, -1)) == target:
			value = max(value, _piece_value_at(rules, target))
	return value

func _available_capture_value(rules: SigmaRules, attacker: int) -> float:
	var value: float = 0.0
	var seen: Dictionary = {}
	for action_value in rules.get_legal_actions_for_player(attacker):
		var action: Dictionary = action_value as Dictionary
		if String(action.get("type", "")) != SigmaRules.ACTION_JUMP:
			continue
		var cap: Vector2i = action.get("capture", Vector2i(-1, -1))
		if cap.x < 0:
			continue
		var key: String = "%d,%d" % [cap.x, cap.y]
		if seen.has(key):
			continue
		seen[key] = true
		value += _piece_value_at(rules, cap) + 60.0
	return value

func _opponent_has_immediate_surrender(rules: SigmaRules, opponent: int) -> bool:
	for action_value in rules.get_legal_actions_for_player(opponent):
		var action: Dictionary = action_value as Dictionary
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("ok", false)) and bool(preview.get("surrender", false)):
			return true
	return false

func _friendly_support_count(rules: SigmaRules, pos: Vector2i, owner: int) -> int:
	if pos.x < 0:
		return 0
	var count: int = 0
	for r in range(max(0, pos.x - 2), min(SigmaRules.BOARD_SIZE, pos.x + 3)):
		for c in range(max(0, pos.y - 2), min(SigmaRules.BOARD_SIZE, pos.y + 3)):
			if r == pos.x and c == pos.y:
				continue
			var p = rules.board[r][c]
			if p == null or int(p.owner) != owner:
				continue
			var dist: int = abs(r - pos.x) + abs(c - pos.y)
			if dist <= 2:
				count += 1
	return count

func _choose_from_ranked_rows(rows: Array, cfg: Dictionary) -> Dictionary:
	if rows.is_empty():
		return {}
	var variety: float = float(cfg.get("variety", 0.20))
	var noise: float = float(cfg.get("noise", 0.0))
	var window: float = max(12.0, 80.0 * variety + noise * 0.18)
	var best_score: float = float((rows[0] as Dictionary).get("score", 0.0))
	var candidates: Array = []
	for row_value in rows:
		var row: Dictionary = row_value as Dictionary
		if int(row.get("urgency", 0)) == int((rows[0] as Dictionary).get("urgency", 0)) and float(row.get("score", -INF)) >= best_score - window:
			candidates.append(row)
	var max_pool: int = clampi(int(cfg.get("top_pool", 4)), 1, 8)
	while candidates.size() > max_pool:
		candidates.pop_back()
	if candidates.is_empty():
		return rows[0] as Dictionary
	return _weighted_candidate_choice(candidates, best_score, noise)


func _weighted_candidate_choice(candidates: Array, best_score: float, noise: float) -> Dictionary:
	var total: float = 0.0
	var weights: Array = []
	for row_value in candidates:
		var row: Dictionary = row_value as Dictionary
		var delta: float = max(0.0, best_score - float(row.get("score", best_score)))
		var weight: float = 1.0 / (1.0 + delta / max(1.0, 18.0 + noise))
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * max(total, 0.0001)
	for i in range(candidates.size()):
		roll -= float(weights[i])
		if roll <= 0.0:
			return candidates[i] as Dictionary
	return candidates[0] as Dictionary

func _record_action_choice(action: Dictionary) -> void:
	var key: String = _action_key(action)
	if key == "":
		return
	recent_action_keys.append(key)
	while recent_action_keys.size() > MAX_RECENT_ACTIONS:
		recent_action_keys.pop_front()

func _recent_repeat_penalty(action: Dictionary, base_penalty: float) -> float:
	var key: String = _action_key(action)
	if key == "" or base_penalty <= 0.0:
		return 0.0
	var penalty: float = 0.0
	for i in range(recent_action_keys.size()):
		if String(recent_action_keys[i]) == key:
			penalty += base_penalty * (1.0 + float(i) / max(1.0, float(recent_action_keys.size())))
	return penalty

func _action_key(action: Dictionary) -> String:
	var t: String = String(action.get("type", ""))
	var f: Vector2i = action.get("from", Vector2i(-1, -1))
	var to: Vector2i = action.get("to", Vector2i(-1, -1))
	return "%s:%d,%d>%d,%d" % [t, f.x, f.y, to.x, to.y]

func _position_is_tactical(rules: SigmaRules, perspective: int) -> bool:
	if rules.is_monarch_in_peril(perspective) or rules.is_monarch_in_peril(rules.enemy(perspective)):
		return true
	var owner: int = int(rules.turn)
	for action_value in rules.get_legal_actions_for_player(owner):
		var action: Dictionary = action_value as Dictionary
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("surrender", false)) or bool(preview.get("enemy_monarch_in_peril", false)) or bool(preview.get("pending_elevation", false)) or String(action.get("type", "")) == SigmaRules.ACTION_JUMP:
			return true
	return false

func _piece_at(rules: SigmaRules, pos: Vector2i):
	if pos.x < 0 or pos.y < 0 or pos.x >= SigmaRules.BOARD_SIZE or pos.y >= SigmaRules.BOARD_SIZE:
		return null
	return rules.board[pos.x][pos.y]

func _piece_value_at(rules: SigmaRules, pos: Vector2i) -> float:
	var p = _piece_at(rules, pos)
	if p == null:
		return 0.0
	return _piece_value(String(p.kind))

func _piece_value(kind: String) -> float:
	match kind:
		SigmaRules.KIND_GUARDIAN:
			return 100.0
		SigmaRules.KIND_SENTINEL:
			return 225.0
		SigmaRules.KIND_INFILTRATOR:
			return 240.0
		SigmaRules.KIND_ASSASSIN:
			return 252.0
		SigmaRules.KIND_MONARCH:
			return 0.0
		_:
			return 0.0

func _progress_weight(kind: String) -> float:
	match kind:
		SigmaRules.KIND_GUARDIAN:
			return 8.0
		SigmaRules.KIND_INFILTRATOR, SigmaRules.KIND_ASSASSIN:
			return 4.3
		SigmaRules.KIND_SENTINEL:
			return 3.0
		_:
			return 2.0

func _center_score(pos: Vector2i) -> float:
	var dist: float = abs(float(pos.x) - 4.0) + abs(float(pos.y) - 4.0)
	return max(0.0, 8.0 - dist)

func _forward_progress_bonus(pos: Vector2i, owner: int) -> float:
	if owner == SigmaRules.OWNER_P1:
		return float(8 - pos.x)
	return float(pos.x)

func _find_monarch(rules: SigmaRules, owner: int) -> Vector2i:
	for r in range(SigmaRules.BOARD_SIZE):
		for c in range(SigmaRules.BOARD_SIZE):
			var p = rules.board[r][c]
			if p != null and int(p.owner) == owner and String(p.kind) == SigmaRules.KIND_MONARCH:
				return Vector2i(r, c)
	return Vector2i(-1, -1)

func _monarch_pressure_bonus(rules: SigmaRules, pos: Vector2i, owner: int) -> float:
	var enemy_monarch: Vector2i = _find_monarch(rules, rules.enemy(owner))
	if enemy_monarch.x < 0:
		return 0.0
	var dist: float = abs(float(pos.x - enemy_monarch.x)) + abs(float(pos.y - enemy_monarch.y))
	return max(0.0, 7.0 - dist)

func _piece_activity_bonus(rules: SigmaRules, pos: Vector2i, piece: Dictionary) -> float:
	var kind: String = String(piece.kind)
	var activity: float = 0.0
	var dirs: Array = []
	if kind == SigmaRules.KIND_GUARDIAN:
		dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	elif kind == SigmaRules.KIND_ASSASSIN:
		dirs = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	elif kind == SigmaRules.KIND_INFILTRATOR:
		dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	else:
		dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	for d in dirs:
		var n: Vector2i = pos + d
		if n.x >= 0 and n.y >= 0 and n.x < SigmaRules.BOARD_SIZE and n.y < SigmaRules.BOARD_SIZE and rules.board[n.x][n.y] == null:
			activity += 1.0
	return activity * 4.0

func _early_deploy_penalty(rules: SigmaRules, action: Dictionary, preview: Dictionary, owner: int, eval_quality: float) -> float:
	if String(action.get("type", "")) != SigmaRules.ACTION_DEPLOY:
		return 0.0
	# In the opening, the bot should usually develop pieces from the back row.
	# Deploy is still allowed and can win scoring when it has a real tactical reason.
	var early_rounds: int = 7
	if int(rules.full_rounds) > early_rounds:
		return 0.0
	var reason_score: float = 0.0
	if bool(preview.get("surrender", false)):
		reason_score += 1000.0
	if bool(preview.get("enemy_monarch_in_peril", false)):
		reason_score += 500.0
	if bool(preview.get("pending_elevation", false)):
		reason_score += 250.0
	reason_score += float((preview.get("captured_positions", []) as Array).size()) * 400.0
	reason_score += float((preview.get("enemy_surround_positions", []) as Array).size()) * 320.0
	reason_score += float((preview.get("friendly_retreat_positions", []) as Array).size()) * 180.0
	if reason_score >= 360.0:
		return 0.0
	var penalty: float = 520.0 * eval_quality
	# Let a little variety through; do not make opening Deploy impossible.
	penalty += float(max(0, early_rounds - int(rules.full_rounds))) * 28.0 * eval_quality
	return penalty


func _opening_back_row_development_bonus(rules: SigmaRules, action: Dictionary, owner: int, eval_quality: float) -> float:
	if int(rules.full_rounds) > 7:
		return 0.0
	if String(action.get("type", "")) != SigmaRules.ACTION_MOVE:
		return 0.0
	var from_pos: Vector2i = action.get("from", Vector2i(-1, -1))
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	if from_pos.x < 0 or to_pos.x < 0:
		return 0.0
	var home_row: int = 8 if owner == SigmaRules.OWNER_P1 else 0
	if from_pos.x != home_row:
		return 0.0
	if _forward_progress_bonus(to_pos, owner) <= _forward_progress_bonus(from_pos, owner):
		return 0.0
	return 210.0 * eval_quality


func _fast_opening_development_bonus(rules: SigmaRules, action: Dictionary, owner: int, eval_quality: float) -> float:
	var bonus: float = 0.0
	bonus += _opening_back_row_development_bonus(rules, action, owner, eval_quality)
	if String(action.get("type", "")) == SigmaRules.ACTION_DEPLOY and int(rules.full_rounds) <= 7:
		var preview: Dictionary = rules.preview_action(action)
		bonus -= _early_deploy_penalty(rules, action, preview, owner, eval_quality) * 0.55
	return bonus


func _deploy_action_bonus(rules: SigmaRules, action: Dictionary, owner: int, eval_quality: float) -> float:
	var to_pos: Vector2i = action.get("to", Vector2i(-1, -1))
	var score: float = 95.0 * eval_quality
	if to_pos.x >= 0:
		score += _center_score(to_pos) * 4.0
		score += _monarch_pressure_bonus(rules, to_pos, owner) * 12.0
		# Deploying into future promotion lanes is useful but should not be blind.
		score += _forward_progress_bonus(to_pos, owner) * 4.0
	return score

func _deploy_count(rules: SigmaRules, owner: int) -> int:
	var count: int = 0
	for action_value in rules.get_legal_actions_for_player(owner):
		var action: Dictionary = action_value as Dictionary
		if String(action.get("type", "")) == SigmaRules.ACTION_DEPLOY:
			count += 1
	return count

func _pressure_action_count(rules: SigmaRules, owner: int) -> int:
	var count: int = 0
	for action_value in rules.get_legal_actions_for_player(owner):
		var action: Dictionary = action_value as Dictionary
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("surrender", false)) or bool(preview.get("enemy_monarch_in_peril", false)) or String(action.get("type", "")) == SigmaRules.ACTION_JUMP or bool(preview.get("pending_elevation", false)):
			count += 1
	return count

func _escape_action_count(rules: SigmaRules, owner: int) -> int:
	var count: int = 0
	if not rules.is_monarch_in_peril(owner):
		return 0
	for action_value in rules.get_legal_actions_for_player(owner):
		var action: Dictionary = action_value as Dictionary
		var preview: Dictionary = rules.preview_action(action)
		if bool(preview.get("ok", false)) and not bool(preview.get("own_monarch_in_peril", false)):
			count += 1
	return count

func _monarch_space_count(rules: SigmaRules, owner: int) -> int:
	var mpos: Vector2i = _find_monarch(rules, owner)
	if mpos.x < 0:
		return 0
	var count: int = 0
	for dr in range(-1, 2):
		for dc in range(-1, 2):
			if dr == 0 and dc == 0:
				continue
			var p: Vector2i = mpos + Vector2i(dr, dc)
			if p.x >= 0 and p.y >= 0 and p.x < SigmaRules.BOARD_SIZE and p.y < SigmaRules.BOARD_SIZE and rules.board[p.x][p.y] == null:
				count += 1
	return count

func _elevation_role_fit(rules: SigmaRules, owner: int, kind: String) -> float:
	var enemy_monarch: Vector2i = _find_monarch(rules, rules.enemy(owner))
	var own_monarch: Vector2i = _find_monarch(rules, owner)
	var pressure_need: float = 0.0
	if enemy_monarch.x >= 0:
		pressure_need = _center_score(enemy_monarch)
	var defensive_need: float = 0.0
	if own_monarch.x >= 0:
		defensive_need = 8.0 - _monarch_space_count(rules, owner)
	match kind:
		SigmaRules.KIND_SENTINEL:
			return 80.0 + defensive_need * 16.0
		SigmaRules.KIND_INFILTRATOR:
			return 85.0 + pressure_need * 10.0 + float(rules.reserves[owner]) * 8.0
		SigmaRules.KIND_ASSASSIN:
			return 92.0 + pressure_need * 13.0
		_:
			return 0.0
