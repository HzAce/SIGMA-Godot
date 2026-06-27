extends Node

# SIGMA audio routing cleanup + SIGMA Radio foundation.
# One global music player owns all background music. Scenes and game states call
# AudioManager wrappers; they never create unmanaged background music players.
# SFX stays separate through a small pooled set of AudioStreamPlayers.

const MUSIC_MAIN_MENU := "res://audio/music/sigma_main_menu_theme.ogg"
const MUSIC_STRATEGY := "res://audio/music/sigma_strategy_theme.ogg"
const MUSIC_BATTLE := "res://audio/music/sigma_battle_theme.ogg"
const MUSIC_BLITZ := "res://audio/music/sigma_blitz_theme.ogg"
const MUSIC_PAUSE := "res://audio/music/sigma_pause_theme.ogg"
const MUSIC_TUTORIAL := "res://audio/music/sigma_tutorial_theme.ogg"
const RADIO_MANIFEST_PATH := "res://assets/audio/radio/sigma_radio_manifest.json"

var muted: bool = false
var master_volume: float = 0.95
var sfx_volume: float = 0.85
var music_volume: float = 0.92
var radio_enabled: bool = false
var radio_shuffle: bool = true
var radio_avoid_repeats: bool = true

var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_player: int = 0
var _sfx_streams: Dictionary = {}

var _music_player: AudioStreamPlayer
var _music_fade_tween: Tween
var _current_music_request: String = ""
var _current_music_resolved_path: String = ""
var _current_music_volume_db: float = -8.0
var _last_game_music_request: String = MUSIC_BATTLE
var _active_family: String = ""
var _active_menu_context: String = "main"
var _active_game_player_turn: int = 1
var _active_game_full_round: int = 0
var _active_game_overtime: bool = false
var _active_game_blitz: bool = false
var _active_game_peril: bool = false
var _active_game_timer_low: bool = false
var _music_paused: bool = false
var _radio_tracks: Array = []
var _radio_enabled_tracks: Dictionary = {}
var _radio_last_track_id: String = ""
var _radio_now_playing_title: String = "Default SIGMA Score"
var _radio_now_playing_artist: String = "SIGMA"

var _initialized: bool = false
var _config_path: String = "user://sigma_audio.cfg"

var _music_aliases: Dictionary = {
	MUSIC_MAIN_MENU: "res://assets/audio/music/classic_menu_theme.ogg",
	MUSIC_STRATEGY: "res://assets/audio/sigma_retro/music/sigma_gameplay_focus_loop.ogg",
	MUSIC_BATTLE: "res://assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg",
	MUSIC_BLITZ: "res://assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg",
	MUSIC_PAUSE: "res://assets/audio/sigma_retro/music/sigma_pause_menu_loop.ogg",
	MUSIC_TUTORIAL: "res://assets/audio/music/tutorial_theme.ogg",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_audio_manager()
	set_process(true)

func _process(_delta: float) -> void:
	if not _initialized or muted:
		return
	if _music_player != null and _music_player.stream != null and not _music_paused and not _music_player.playing and not _current_music_resolved_path.is_empty():
		_music_player.play(0.0)

func _initialize_audio_manager() -> void:
	if _initialized:
		return
	_load_settings()
	if music_volume <= 0.02:
		music_volume = 0.92
	_build_sfx_pool()
	_build_music_player()
	_load_sfx_stream_map()
	_load_radio_manifest()
	_initialized = true

func _ensure_initialized() -> void:
	if not _initialized:
		_initialize_audio_manager()

func _build_sfx_pool() -> void:
	if not _sfx_players.is_empty():
		return
	var sfx_bus: String = _safe_bus_name("SFX")
	for i in range(18):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SIGMA_SFX_%02d" % i
		player.bus = sfx_bus
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_sfx_players.append(player)

func _build_music_player() -> void:
	if _music_player != null:
		return
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "SIGMA_BackgroundMusic"
	_music_player.bus = _safe_bus_name("Music")
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_player)

func _safe_bus_name(preferred: String) -> String:
	for i in range(AudioServer.get_bus_count()):
		if AudioServer.get_bus_name(i) == preferred:
			return preferred
	return "Master"

func _load_sfx_stream_map() -> void:
	_sfx_streams = {
		"button_tap": "res://assets/audio/sigma_retro/sfx/sfx_menu_select_blip.wav",
		"button_hover": "res://assets/audio/sigma_retro/sfx/sfx_button_hover_glass.wav",
		"button_back": "res://assets/audio/sigma_retro/sfx/sfx_back_chime.wav",
		"confirm": "res://assets/audio/sigma_retro/sfx/sfx_confirm_chime.wav",
		"cancel": "res://assets/audio/sigma_retro/sfx/sfx_cancel_drop.wav",
		"error": "res://assets/audio/sigma_retro/sfx/sfx_invalid_buzz.wav",
		"page_open": "res://assets/audio/sigma_retro/sfx/sfx_page_open_glass.wav",
		"page_back": "res://assets/audio/sigma_retro/sfx/sfx_page_back_chime.wav",
		"select_piece": "res://assets/audio/sigma_retro/sfx/sfx_select_piece_ping.wav",
		"preview": "res://assets/audio/sigma_retro/sfx/sfx_preview_calc.wav",
		"move": "res://assets/audio/sigma_retro/sfx/sfx_move_confirm.wav",
		"capture": "res://assets/audio/sigma_retro/sfx/sfx_capture_impact.wav",
		"deploy": "res://assets/audio/sigma_retro/sfx/sfx_deploy_materialize.wav",
		"retreat": "res://assets/audio/sigma_retro/sfx/sfx_retreat_pullback.wav",
		"elevate": "res://assets/audio/sigma_retro/sfx/sfx_elevate_chime.wav",
		"peril": "res://assets/audio/sigma_retro/sfx/sfx_peril_warning.wav",
		"surrender": "res://assets/audio/sigma_retro/sfx/sfx_surrender_stinger.wav",
		"overtime": "res://assets/audio/sigma_retro/sfx/sfx_overtime_stinger.wav",
		"game_result": "res://assets/audio/sigma_retro/sfx/sfx_victory_stinger.wav",
		"victory": "res://assets/audio/sigma_retro/sfx/sfx_victory_stinger.wav",
		"logo_intro": "res://assets/audio/sigma_retro/sfx/sfx_logo_intro.wav",
		"impact_soft": "res://assets/audio/sigma_retro/sfx/sfx_move_confirm.wav",
		"impact_heavy": "res://assets/audio/sigma_retro/sfx/sfx_capture_impact.wav",
		"energy_spark": "res://assets/audio/sigma_retro/sfx/sfx_elevate_chime.wav",
		"tutorial_correct": "res://assets/audio/sigma_retro/sfx/sfx_tutorial_correct.wav",
		"tutorial_wrong": "res://assets/audio/sigma_retro/sfx/sfx_tutorial_wrong.wav",
		"tutorial_step_complete": "res://assets/audio/sigma_retro/sfx/sfx_tutorial_step.wav",
		"tutorial_complete": "res://assets/audio/sigma_retro/sfx/sfx_tutorial_complete.wav",
	}

# Required public music API.
func play_music(path: String, volume_db: float = -8.0, fade_time: float = 0.35) -> void:
	_ensure_initialized()
	if muted:
		return
	var resolved_path: String = _resolve_music_path(path)
	if resolved_path.is_empty():
		return
	if _music_player != null and _music_player.playing and not _music_player.stream_paused and resolved_path == _current_music_resolved_path:
		return
	_current_music_request = path
	_current_music_volume_db = volume_db
	_music_paused = false
	if _music_fade_tween != null and _music_fade_tween.is_valid():
		_music_fade_tween.kill()
	if _music_player != null and _music_player.playing and _music_player.stream != null and resolved_path != _current_music_resolved_path and fade_time > 0.0:
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", -80.0, fade_time)
		_music_fade_tween.tween_callback(Callable(self, "_start_resolved_music").bind(resolved_path, volume_db, fade_time))
	else:
		_start_resolved_music(resolved_path, volume_db, fade_time)

func stop_music(fade_time: float = 0.25) -> void:
	_ensure_initialized()
	_current_music_request = ""
	_current_music_resolved_path = ""
	_active_family = ""
	_music_paused = false
	if _music_fade_tween != null and _music_fade_tween.is_valid():
		_music_fade_tween.kill()
	if _music_player == null or _music_player.stream == null:
		return
	if fade_time <= 0.0 or not _music_player.playing:
		_music_player.stop()
		_music_player.stream = null
		return
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(_music_player, "volume_db", -80.0, fade_time)
	_music_fade_tween.tween_callback(Callable(self, "_finish_stop_music"))

func pause_music() -> void:
	_ensure_initialized()
	_music_paused = true
	if _music_player != null:
		_music_player.stream_paused = true

func resume_music() -> void:
	_ensure_initialized()
	_music_paused = false
	if _music_player != null:
		_music_player.stream_paused = false
		if _music_player.stream != null and not _music_player.playing:
			_music_player.play(0.0)
		_apply_music_volume_db(_current_music_volume_db)

func _finish_stop_music() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null

func _start_resolved_music(resolved_path: String, volume_db: float, fade_time: float) -> void:
	var stream: AudioStream = _load_music_stream(resolved_path)
	if stream == null:
		return
	_prepare_looping_stream(stream)
	_current_music_resolved_path = resolved_path
	_current_music_volume_db = volume_db
	_music_player.stop()
	_music_player.stream = stream
	_music_player.stream_paused = false
	_music_player.volume_db = -60.0 if fade_time > 0.0 else _scaled_music_volume_db(volume_db)
	_music_player.play(0.0)
	if fade_time > 0.0:
		if _music_fade_tween != null and _music_fade_tween.is_valid():
			_music_fade_tween.kill()
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", _scaled_music_volume_db(volume_db), fade_time)
	else:
		_apply_music_volume_db(volume_db)

func _resolve_music_path(path: String) -> String:
	if ResourceLoader.exists(path):
		return path
	if _music_aliases.has(path):
		var alias_path: String = String(_music_aliases[path])
		if ResourceLoader.exists(alias_path):
			return alias_path
	var alt_path: String = ""
	if path.ends_with(".ogg"):
		alt_path = path.replace(".ogg", ".wav")
	elif path.ends_with(".wav"):
		alt_path = path.replace(".wav", ".ogg")
	if not alt_path.is_empty() and ResourceLoader.exists(alt_path):
		return alt_path
	push_warning("SIGMA music file missing: %s" % path)
	return ""

func _load_music_stream(path: String) -> AudioStream:
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		push_warning("SIGMA could not load music stream: %s" % path)
	return stream

func _scaled_music_volume_db(base_volume_db: float) -> float:
	if muted or music_volume <= 0.001 or master_volume <= 0.001:
		return -80.0
	var scale_db: float = linear_to_db(clamp(master_volume * music_volume, 0.001, 1.0))
	return clamp(base_volume_db + scale_db, -80.0, 6.0)

func _apply_music_volume_db(base_volume_db: float) -> void:
	if _music_player != null:
		_music_player.volume_db = _scaled_music_volume_db(base_volume_db)

func _prepare_looping_stream(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true

# Compatibility wrappers used by existing SIGMA scenes and UI.
func play_menu_music(page_context: String = "main") -> void:
	_active_family = "menu"
	_active_menu_context = _normalize_menu_context(page_context)
	match _active_menu_context:
		"tutorial":
			if ResourceLoader.exists(MUSIC_TUTORIAL) or _music_aliases.has(MUSIC_TUTORIAL):
				_play_context_music("tutorial", MUSIC_TUTORIAL, -9.0, 0.35)
			else:
				_play_context_music("tutorial", MUSIC_STRATEGY, -9.0, 0.35)
		"settings", "rules", "setup", "collections":
			_play_context_music(_active_menu_context, MUSIC_PAUSE, -10.0, 0.35)
		_:
			_play_context_music("menu", MUSIC_MAIN_MENU, -8.0, 0.35)

func play_game_music(_restart: bool = true) -> void:
	_active_family = "board"
	_music_paused = false
	_last_game_music_request = _gameplay_music_request_for_state()
	_play_context_music(_radio_context_for_game_state(), _last_game_music_request, -8.0, 0.35)

func enforce_game_music_exclusive() -> void:
	play_game_music(false)

func update_board_music_progress(player_turn_number: int, full_rounds: int, overtime_active: bool, blitz_active: bool = false, peril_active: bool = false, timer_low: bool = false) -> void:
	_active_game_player_turn = max(1, player_turn_number)
	_active_game_full_round = max(0, full_rounds)
	_active_game_overtime = overtime_active
	_active_game_blitz = blitz_active
	_active_game_peril = peril_active
	_active_game_timer_low = timer_low
	if _active_family == "board" and not _music_paused:
		var next_request: String = _gameplay_music_request_for_state()
		if next_request != _last_game_music_request or _current_music_resolved_path.is_empty():
			_last_game_music_request = next_request
			_play_context_music(_radio_context_for_game_state(), next_request, -8.0 if next_request != MUSIC_BLITZ else -7.0, 0.35)

func _gameplay_music_request_for_state() -> String:
	if _active_game_blitz or _active_game_overtime or _active_game_peril or _active_game_timer_low:
		return MUSIC_BLITZ
	return MUSIC_BATTLE

func pause_game_music() -> void:
	# Pause screen uses its own calm loop. Store current game track and let
	# play_pause_music() replace it cleanly through the single music player.
	_last_game_music_request = _gameplay_music_request_for_state()

func resume_game_music() -> void:
	_active_family = "board"
	_music_paused = false
	_play_context_music(_radio_context_for_game_state(), _last_game_music_request if not _last_game_music_request.is_empty() else MUSIC_BATTLE, -8.0, 0.35)

func play_pause_music(_restart: bool = true) -> void:
	_active_family = "pause"
	_play_context_music("pause", MUSIC_PAUSE, -12.0, 0.25)

func stop_pause_music() -> void:
	if _active_family == "pause":
		_active_family = ""

func stop_all_music_layers() -> void:
	stop_music(0.25)

func play_ambience(_name: String, _restart: bool = false) -> void:
	# Ambience is no longer a separate unmanaged layer. One background stream only.
	return

func stop_ambience() -> void:
	return

func force_replay_music_layers() -> void:
	if _active_family == "board":
		play_game_music(true)
	elif _active_family == "pause":
		play_pause_music(true)
	else:
		play_menu_music(_active_menu_context)

func _normalize_menu_context(page_context: String) -> String:
	match page_context:
		"collections", "settings", "rules", "tutorial", "setup", "main":
			return page_context
		_:
			return "main"

func _play_context_music(context: String, fallback_path: String, volume_db: float = -8.0, fade_time: float = 0.35, force_next: bool = false) -> void:
	_ensure_initialized()
	var radio_track: Dictionary = _choose_radio_track(context, force_next)
	if radio_enabled and not radio_track.is_empty():
		_radio_last_track_id = String(radio_track.get("id", ""))
		_radio_now_playing_title = String(radio_track.get("title", "SIGMA Radio"))
		_radio_now_playing_artist = String(radio_track.get("artist", "SIGMA"))
		play_music(String(radio_track.get("path", fallback_path)), volume_db, fade_time)
		return
	_radio_now_playing_title = "Default SIGMA Score"
	_radio_now_playing_artist = "SIGMA"
	play_music(fallback_path, volume_db, fade_time)

func _radio_context_for_game_state() -> String:
	if _active_game_blitz:
		return "blitz"
	if _active_game_overtime:
		return "overtime"
	if _active_game_peril:
		return "peril"
	if _active_game_timer_low:
		return "battle"
	return "gameplay"

func _radio_context_for_active_state() -> String:
	match _active_family:
		"board":
			return _radio_context_for_game_state()
		"pause":
			return "pause"
		"menu":
			return _active_menu_context if not _active_menu_context.is_empty() else "menu"
		_:
			return "menu"

func _choose_radio_track(context: String, force_next: bool = false) -> Dictionary:
	if not radio_enabled:
		return {}
	_load_radio_manifest()
	var available: Array = []
	for track in _radio_tracks:
		if typeof(track) != TYPE_DICTIONARY:
			continue
		var id: String = String(track.get("id", ""))
		var path: String = String(track.get("path", ""))
		if id.is_empty() or path.is_empty():
			continue
		if _radio_enabled_tracks.has(id) and not bool(_radio_enabled_tracks[id]):
			continue
		if not _track_allows_context(track, context):
			continue
		if _resolve_music_path(path).is_empty():
			continue
		available.append(track)
	if available.is_empty():
		return {}
	if radio_avoid_repeats and available.size() > 1:
		var filtered: Array = []
		for track in available:
			if String(track.get("id", "")) != _radio_last_track_id:
				filtered.append(track)
		if not filtered.is_empty():
			available = filtered
	if radio_shuffle or force_next:
		return available[randi() % available.size()]
	return available[0]

func _track_allows_context(track: Dictionary, context: String) -> bool:
	var contexts: Array = track.get("allowed_contexts", [])
	if contexts.is_empty():
		return true
	for value in contexts:
		if String(value) == context:
			return true
	# Treat intensity contexts as battle-compatible.
	if context == "peril" or context == "overtime" or context == "blitz":
		for value in contexts:
			if String(value) == "battle" or String(value) == "gameplay":
				return true
	return false

func _load_radio_manifest() -> void:
	if not _radio_tracks.is_empty():
		return
	var loaded: Array = []
	if ResourceLoader.exists(RADIO_MANIFEST_PATH):
		var file: FileAccess = FileAccess.open(RADIO_MANIFEST_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_ARRAY:
				loaded = parsed
	if loaded.is_empty():
		loaded = _default_radio_tracks()
	_radio_tracks = loaded
	for track in _radio_tracks:
		if typeof(track) == TYPE_DICTIONARY:
			var id: String = String(track.get("id", ""))
			if not id.is_empty() and not _radio_enabled_tracks.has(id):
				_radio_enabled_tracks[id] = true

func _default_radio_tracks() -> Array:
	return [
		{"id":"sigma_main_menu", "title":"SIGMA Main Theme", "artist":"SIGMA Score", "path":"res://assets/audio/music/classic_menu_theme.ogg", "allowed_contexts":["menu", "settings", "collections", "rules"]},
		{"id":"sigma_focus", "title":"SIGMA Focus Loop", "artist":"SIGMA Score", "path":"res://assets/audio/sigma_retro/music/sigma_gameplay_focus_loop.ogg", "allowed_contexts":["gameplay", "tutorial"]},
		{"id":"sigma_battle", "title":"SIGMA Battle Loop", "artist":"SIGMA Score", "path":"res://assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg", "allowed_contexts":["gameplay", "battle", "blitz", "peril", "overtime"]},
		{"id":"sigma_pause", "title":"SIGMA Pause Loop", "artist":"SIGMA Score", "path":"res://assets/audio/sigma_retro/music/sigma_pause_menu_loop.ogg", "allowed_contexts":["pause", "settings", "collections", "rules"]},
	]

func get_radio_tracks() -> Array:
	_ensure_initialized()
	_load_radio_manifest()
	return _radio_tracks.duplicate(true)

func is_radio_track_enabled(id: String) -> bool:
	_ensure_initialized()
	return bool(_radio_enabled_tracks.get(id, true))

func set_radio_track_enabled(id: String, enabled: bool) -> void:
	_ensure_initialized()
	if id.is_empty():
		return
	_radio_enabled_tracks[id] = enabled
	_save_settings()

func toggle_radio_track(id: String) -> bool:
	var next_value: bool = not is_radio_track_enabled(id)
	set_radio_track_enabled(id, next_value)
	return next_value

func set_radio_enabled(enabled: bool) -> void:
	_ensure_initialized()
	radio_enabled = enabled
	_save_settings()
	force_replay_music_layers()

func toggle_radio_enabled() -> bool:
	set_radio_enabled(not radio_enabled)
	return radio_enabled

func toggle_radio_shuffle() -> bool:
	_ensure_initialized()
	radio_shuffle = not radio_shuffle
	_save_settings()
	return radio_shuffle

func next_radio_track() -> void:
	_ensure_initialized()
	if not radio_enabled:
		radio_enabled = true
		_save_settings()
	_play_context_music(_radio_context_for_active_state(), _last_game_music_request if _active_family == "board" else MUSIC_MAIN_MENU, -8.0, 0.20, true)

func reset_radio_settings() -> void:
	_ensure_initialized()
	radio_enabled = false
	radio_shuffle = true
	radio_avoid_repeats = true
	_radio_enabled_tracks.clear()
	for track in _radio_tracks:
		if typeof(track) == TYPE_DICTIONARY:
			var id: String = String(track.get("id", ""))
			if not id.is_empty():
				_radio_enabled_tracks[id] = true
	_save_settings()
	force_replay_music_layers()

func get_radio_status_text() -> String:
	_ensure_initialized()
	var mode: String = "ON" if radio_enabled else "OFF"
	var shuffle_text: String = "Shuffle" if radio_shuffle else "In order"
	return "SIGMA Radio: %s · %s · Now Playing: %s" % [mode, shuffle_text, _radio_now_playing_title]

# SFX API.
func play_ui(name: String) -> void:
	_play_sfx(name, 0.88)

func play_board(name: String) -> void:
	_play_sfx(name, 1.0)

func play_event(name: String) -> void:
	_play_sfx(name, 1.0)

func play_tutorial(name: String) -> void:
	_play_sfx(name, 0.95)

func play_cue(name: String) -> void:
	match name:
		"button_tap", "button_hover", "button_back", "cancel", "confirm", "page_open", "page_back":
			play_ui(name)
		"illegal":
			play_ui("error")
		"select_piece", "preview", "move", "capture", "deploy", "retreat", "elevate", "impact_soft", "impact_heavy", "energy_spark":
			play_board(name)
		"peril", "surrender", "overtime", "game_result", "victory", "logo_intro":
			play_event(name)
		"tutorial_correct", "tutorial_wrong", "tutorial_step_complete", "tutorial_complete":
			play_tutorial(name)
		_:
			play_ui("button_tap")

func play_action_finish(action_name: String) -> void:
	match action_name:
		"move":
			play_board("move")
		"capture":
			play_board("capture")
		"deploy":
			play_board("deploy")
		"elevate":
			play_board("elevate")
		_:
			return

func _play_sfx(name: String, scale: float = 1.0) -> void:
	_ensure_initialized()
	if muted:
		return
	if not _sfx_streams.has(name):
		push_warning("SIGMA SFX cue missing from map: %s" % name)
		return
	if _sfx_players.is_empty():
		_build_sfx_pool()
	var stream: AudioStream = _load_sfx_stream(String(_sfx_streams[name]))
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx_player]
	_next_sfx_player = (_next_sfx_player + 1) % _sfx_players.size()
	player.stop()
	player.stream = stream
	var linear_volume: float = clamp(master_volume * sfx_volume * scale, 0.0, 1.0)
	player.volume_db = linear_to_db(max(linear_volume, 0.0001))
	player.pitch_scale = randf_range(0.988, 1.012)
	player.play()

func _load_sfx_stream(path: String) -> AudioStream:
	var resolved_path: String = path
	if not ResourceLoader.exists(resolved_path):
		var alt_path: String = ""
		if resolved_path.ends_with(".wav"):
			alt_path = resolved_path.replace(".wav", ".ogg")
		elif resolved_path.ends_with(".ogg"):
			alt_path = resolved_path.replace(".ogg", ".wav")
		if not alt_path.is_empty() and ResourceLoader.exists(alt_path):
			resolved_path = alt_path
		else:
			push_warning("SIGMA SFX file missing: %s" % path)
			return null
	var stream: AudioStream = load(resolved_path) as AudioStream
	if stream == null:
		push_warning("SIGMA could not load SFX stream: %s" % resolved_path)
	return stream

# Settings / status.
func set_muted(value: bool) -> void:
	_ensure_initialized()
	muted = value
	if muted:
		if _music_player != null:
			_music_player.volume_db = -80.0
	else:
		_apply_music_volume_db(_current_music_volume_db)
		if _current_music_request.is_empty():
			play_menu_music(_active_menu_context)
	_save_settings()

func toggle_muted() -> bool:
	set_muted(not muted)
	return muted

func set_master_volume(value: float) -> void:
	_ensure_initialized()
	master_volume = clamp(value, 0.0, 1.0)
	_apply_music_volume_db(_current_music_volume_db)
	_save_settings()

func set_sfx_volume(value: float) -> void:
	_ensure_initialized()
	sfx_volume = clamp(value, 0.0, 1.0)
	_save_settings()

func set_music_volume(value: float) -> void:
	_ensure_initialized()
	music_volume = clamp(value, 0.0, 1.0)
	_apply_music_volume_db(_current_music_volume_db)
	_save_settings()

func reset_audio_settings() -> void:
	_ensure_initialized()
	muted = false
	master_volume = 0.95
	sfx_volume = 0.85
	music_volume = 0.92
	_apply_music_volume_db(_current_music_volume_db)
	if _current_music_request.is_empty():
		play_menu_music(_active_menu_context)
	_save_settings()

func play_music_test_burst() -> void:
	_ensure_initialized()
	if muted:
		return
	play_menu_music(_active_menu_context)
	play_cue("confirm")

func get_status_text() -> String:
	var mute_text: String = "Muted" if muted else "Sound On"
	var family_text: String = _active_family if not _active_family.is_empty() else "—"
	var music_name: String = _current_music_request.get_file() if not _current_music_request.is_empty() else "—"
	if _music_paused:
		family_text += " paused"
	return "%s · Master %d%% · SFX %d%% · Music %d%% · %s · %s" % [mute_text, int(round(master_volume * 100.0)), int(round(sfx_volume * 100.0)), int(round(music_volume * 100.0)), family_text, _radio_now_playing_title if radio_enabled else music_name]

func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(_config_path)
	if error != OK:
		return
	muted = bool(config.get_value("audio", "muted", muted))
	master_volume = float(config.get_value("audio", "master_volume", master_volume))
	sfx_volume = float(config.get_value("audio", "sfx_volume", sfx_volume))
	music_volume = float(config.get_value("audio", "music_volume", music_volume))
	radio_enabled = bool(config.get_value("radio", "enabled", radio_enabled))
	radio_shuffle = bool(config.get_value("radio", "shuffle", radio_shuffle))
	radio_avoid_repeats = bool(config.get_value("radio", "avoid_repeats", radio_avoid_repeats))
	var track_state = config.get_value("radio", "tracks", {})
	if typeof(track_state) == TYPE_DICTIONARY:
		_radio_enabled_tracks = track_state

func _save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "muted", muted)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("radio", "enabled", radio_enabled)
	config.set_value("radio", "shuffle", radio_shuffle)
	config.set_value("radio", "avoid_repeats", radio_avoid_repeats)
	config.set_value("radio", "tracks", _radio_enabled_tracks)
	config.save(_config_path)
