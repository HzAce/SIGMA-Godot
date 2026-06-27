# SIGMA v1.6.0.8 — Clean Music Context Pass

## Purpose

This update refines the adaptive music system after v1.6.0.7 testing.

## Menu music

- 4-instrument shared core.
- 1 page-specific instrument layer.
- Maximum 5 active menu instruments.
- Approximate 30-second structured/elegant loop.
- No bass/sub/low rumble.
- Menu music persists across menu pages and does not restart between menus.
- Page layers fade in/out gently.

## Game music

- Active game is separate from menu music.
- New Game, Continue, and Restart start/restart board-based music.
- Pause/resume preserves board music position.
- Exiting to menu starts fresh menu music.

## Technical notes

- New menu audio files:
  - `menu_base_4inst.ogg`
  - `menu_main_layer_1inst.ogg`
  - `menu_collections_layer_1inst.ogg`
  - `menu_settings_layer_1inst.ogg`
  - `menu_rules_layer_1inst.ogg`
  - `menu_tutorial_layer_1inst.ogg`
  - `menu_setup_layer_1inst.ogg`
- `AudioManager.gd` now has `pause_game_music()` and `resume_game_music()` for pause/unpause without restart.
- `SigmaRules.gd` unchanged.
