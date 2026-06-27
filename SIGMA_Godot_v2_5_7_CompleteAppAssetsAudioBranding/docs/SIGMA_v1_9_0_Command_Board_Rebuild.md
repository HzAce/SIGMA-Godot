# SIGMA Godot v1.9.0 — Classic SIGMA Command Board Rebuild

This build is a major presentation-layer rebuild toward the official Classic SIGMA visual/audio identity.

## Focus

- The active game should feel like a premium SIGMA command board, not a chessboard with app buttons.
- The official default/unlocked **Classic SIGMA Set** includes both:
  - Classic SIGMA Pieces
  - Classic SIGMA Board
- The playable board remains 2.5D for Android readability and performance.
- The grid stays clear and gameplay-safe; spectacle lives in the frame, command decks, rails, and audio.

## Major changes

- Reworked `BoardView.gd` into a more integrated Classic SIGMA command-board look.
- Dark laser-etched 9×9 grid with subtle nodes instead of a chess-like board identity.
- Heavier graphite/gold/cyan frame with corner command assemblies, side pylons, and embedded player command docks.
- Tabletop command bars restyled as board-console extensions.
- Recreated music as separate, more distinct menu and board worlds.
- Replaced SFX with higher-energy arcade/laser/level-up inspired cues.
- Preserved official Classic SIGMA Pieces for gameplay, tutorial, rules snapshots, and collection previews.

## Rules lock

`SigmaRules.gd` is unchanged. Rules logic remains the source of truth; UI does not decide legality.

## Android export path

```text
exports/android/SIGMA_Mobile_v1_9_0_debug.apk
```

## Install after export

```bash
~/Library/Android/sdk/platform-tools/adb install -r "/Users/Daniel/Downloads/sigma_godot_scratch_v1_9_0_classic_sigma_command_board/exports/android/SIGMA_Mobile_v1_9_0_debug.apk"
```
