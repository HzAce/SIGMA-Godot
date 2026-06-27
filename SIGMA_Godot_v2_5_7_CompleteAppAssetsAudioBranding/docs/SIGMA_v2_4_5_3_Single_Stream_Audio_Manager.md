# SIGMA v2.4.5.3 — Single-Stream Audio Manager Notes

This build replaces the prior adaptive multi-layer music approach with a simpler and safer global music manager.

## Core rule

Only one background music `AudioStreamPlayer` exists:

```text
AudioManager / SIGMA_BackgroundMusic
```

Scenes do not own direct background music players.

## Public API

```gdscript
AudioManager.play_music(path: String, volume_db: float = -8.0, fade_time: float = 0.35)
AudioManager.stop_music(fade_time: float = 0.25)
AudioManager.pause_music()
AudioManager.resume_music()
```

## SIGMA scene wrappers

Existing scene code calls compatibility wrappers:

```gdscript
AudioManager.play_menu_music(page_context)
AudioManager.play_game_music(true)
AudioManager.play_pause_music(true)
AudioManager.resume_game_music()
```

Each wrapper calls `play_music()` with the correct scene track. That means scene transitions now replace music rather than layering music stems.

## Path aliases

The requested paths are supported as logical requests and are mapped to existing project files when the preferred `res://audio/music/...` file is not present:

```text
res://audio/music/sigma_main_menu_theme.ogg -> res://assets/audio/music/classic_menu_theme.ogg
res://audio/music/sigma_strategy_theme.ogg -> res://assets/audio/sigma_retro/music/sigma_gameplay_focus_loop.ogg
res://audio/music/sigma_battle_theme.ogg -> res://assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg
res://audio/music/sigma_blitz_theme.ogg -> res://assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg
res://audio/music/sigma_pause_theme.ogg -> res://assets/audio/sigma_retro/music/sigma_pause_menu_loop.ogg
res://audio/music/sigma_tutorial_theme.ogg -> res://assets/audio/music/tutorial_theme.ogg
```
