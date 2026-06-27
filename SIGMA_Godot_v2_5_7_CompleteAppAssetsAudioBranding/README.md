# SIGMA Godot v2.5.7 — Complete App Assets + Audio + Branding

Full completion pass on top of v2.5.6.2 Classic SIGMA Set Assets.

## Added / Restored

### Piece Sets

The complete visible piece-set library is now included under `assets/pieces/`:

- `classic_sigma_tokens/`
- `vector_obelisks/`
- `draconian/`
- `lions_den/`

Each set includes Gold and Silver versions of:

- Monarch
- Guardian
- Sentinel
- Infiltrator
- Assassin

### Collection / Board Assets

Restored collection and board promo assets:

- `assets/collections/vector/vector_board_promo.png`
- `assets/collections/draconian/draconian_board_promo.png`
- `assets/collections/lions_den/lions_den_board_promo.png`
- `assets/boards/draconian_board/draconian_board_promo.png`
- `assets/boards/lions_den_board/lions_den_board_promo.png`
- `assets/boards/classic_sigma_board_3d/` blockout OBJ/MTL reference

### Branding

Restored SIGMA branding assets:

- `assets/ui/branding/sigma_crest.png`
- `assets/ui/branding/sigma_main_menu_art.png`
- `assets/ui/branding/sigma_startup_splash.png`

Main Menu now uses the restored branding art:

- Full-screen SIGMA menu art behind the landing page.
- SIGMA crest displayed above the title.
- Existing startup splash remains wired to `sigma_startup_splash.png`.

### Audio

Added/rebuilt the complete SIGMA audio pack at the paths used by `AudioManager.gd`:

Music:

- `assets/audio/music/classic_menu_theme.ogg`
- `assets/audio/music/tutorial_theme.ogg`
- `assets/audio/music/menu_theme.ogg`
- `assets/audio/music/classic_board_theme.ogg`
- `assets/audio/music/board_theme.ogg`
- `assets/audio/sigma_retro/music/sigma_gameplay_focus_loop.ogg`
- `assets/audio/sigma_retro/music/sigma_battle_blitz_loop.ogg`
- `assets/audio/sigma_retro/music/sigma_pause_menu_loop.ogg`

SFX:

- UI/menu SFX
- gameplay move/capture/deploy/elevate/peril/result SFX
- Tutorial correct/wrong/step/complete SFX
- logo intro SFX

Audio direction remains: premium 16-bit tactical arcade strategy, no vocals, no crowd noise, no guitar, no orchestra.

## Preserved

- v2.5.6 app-wide left-arrow Back buttons.
- v2.5.6 centered Tournament Hub layout.
- v2.5.6.1 target-scope parser fix.
- v2.5.6.2 Classic SIGMA token asset restore.
- Single-stream `AudioManager.gd` behavior.
- Official terminology and SIGMA identity locks.

## Rules Lock

No rules behavior changed. `SigmaRules.gd` is unchanged from v2.5.6.2.

## Android export path

```text
exports/android/SIGMA_Mobile_v2_5_7_debug.apk
```

## First open note

Godot may generate or refresh `.import` files on first open. After verifying the project imports cleanly, commit generated `.import` files to GitHub if needed.
