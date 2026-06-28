# SIGMA Godot v2.5.8.26.40 — Context-Aware Settings Return Pass

Base: `SIGMA_Godot_v2_5_8_26_39_CollectionsPreviewGoldLabelPass`

## Summary
This patch fixes Settings closing behavior so opening Settings from a paused tutorial practice or paused match no longer dumps the player back to the Main Menu.

## Changes
- Added `settings_return_context` to remember where Settings was opened from.
- If Settings is opened from the Pause menu, pressing X returns to the Pause menu instead of Main Menu.
- Tutorial practice sessions stay active while Settings is open.
- If Settings is opened during Tutorial flow, closing Settings returns to Tutorial context instead of ending the tutorial.
- Added safe return paths for Rules, Collections, Custom Game, and New Game if Settings is opened from those contexts later.

## Preserved
- `SigmaRules.gd` unchanged.
- Tutorial rules and practice logic unchanged.
- Pause menu behavior unchanged except for the Settings return path.
- SIGMA Radio logic unchanged.
- Collections behavior unchanged.
