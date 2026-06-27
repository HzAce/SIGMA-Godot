# SIGMA Godot v2.5.8.26 — SIGMA Radio Foundation

Base:
- SIGMA Godot v2.5.8.25.9 — Tutorial Welcome Crest Preview

Purpose:
- Build the first real SIGMA Radio foundation while preserving the current default game score.

Audio rules now supported:
1. Current music remains the Default SIGMA Score:
   - Main Menu
   - Settings / Rules / Pause
   - Tutorial
   - Gameplay
   - Battle / BLITZ / Peril / Overtime
2. Music ON/OFF is now its own control.
   - Music OFF stops both default music and SIGMA Radio.
   - SFX remains separate.
3. SIGMA Radio ON overrides the default score.
   - Radio uses one central AudioManager music player, so default score and Radio do not layer on top of each other.
   - When Radio is OFF, default music resumes based on the current game/menu context.
4. SIGMA Radio supports:
   - ON/OFF
   - Play Mode: Random
   - Play Mode: Playlist
   - Select/unselect songs from the player's SIGMA Radio song pool
   - Next Track
   - Reset Radio
5. Song pool safety:
   - At least one song must remain selected.
6. Settings are saved to user://sigma_audio.cfg:
   - master volume
   - SFX enabled
   - SFX volume
   - Music enabled
   - Music volume
   - Radio enabled
   - Radio play mode
   - selected/unselected radio tracks

Files changed:
- scripts/AudioManager.gd
- scripts/Main.gd
- assets/audio/radio/sigma_radio_manifest.json

No gameplay rules changed.
SigmaRules.gd is unchanged.
