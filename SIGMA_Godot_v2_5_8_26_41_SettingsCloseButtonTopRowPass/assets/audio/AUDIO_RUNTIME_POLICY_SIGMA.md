# SIGMA Audio Runtime Policy

## Format rules

- Radio songs: `.ogg`
- Default music: `.ogg`
- Long loops / ambience: `.ogg`
- Short UI and gameplay SFX: `.wav`
- Original WAV masters: keep outside the runtime project

## Why

Long music tracks are the easiest place to waste storage. Runtime music should be OGG Vorbis so the game package stays small. Short SFX can remain WAV because they are small, immediate, and may overlap during play.

## Runtime folder rule

Runtime project should contain only game-ready audio.

Recommended structure:

```text
assets/audio/music/
  classic_menu_theme.ogg
  tutorial_theme.ogg

assets/audio/sigma_retro/music/
  sigma_gameplay_focus_loop.ogg
  sigma_battle_blitz_loop.ogg
  sigma_pause_menu_loop.ogg

assets/audio/radio/
  sigma_radio_manifest.json
  songs/
    future_radio_track_01.ogg
    future_radio_track_02.ogg

assets/audio/sigma_retro/sfx/
  short_sfx.wav
```

## SIGMA Radio rule

SIGMA Radio should not preload the whole song pool. The manifest should hold metadata and paths. `AudioManager` should load the current song into the one global music player, then replace it when the song changes.

## Cleanup rule

Do not keep duplicate exports such as `menu_theme.ogg` if the active track is already `classic_menu_theme.ogg`. Do not keep WAV music masters in the runtime project.
