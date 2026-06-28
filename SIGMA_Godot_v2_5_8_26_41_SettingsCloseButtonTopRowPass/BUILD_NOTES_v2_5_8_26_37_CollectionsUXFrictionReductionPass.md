# SIGMA Godot v2.5.8.26.37 — Collections UX Friction Reduction Pass

Base: `SIGMA_Godot_v2_5_8_26_36_CollectionsGridViewAndEquipButtonPass`

## Summary
This patch tightens Collections and removes friction from hover popups, bottom status text, and collection detail actions.

## Changes
- Disabled Godot hover tooltip popups by clearing tooltip text across the UI.
- Replaced the Collections bottom status text with a small SIGMA crest footer.
- Removed the extra descriptive Collections footer note.
- Renamed `Board Sets` / `Board Set` player-facing text to `Boards` / `Board`.
- Updated Collections taxonomy direction:
  - Full Sets = matching themed Pieces + Board.
  - Pieces can later exist as their own collectible Piece Sets.
  - Boards are their own collectible category.
- Renamed the current combined set grid section to `Full Sets`.
- Removed Back buttons from collection set/board detail frames because each frame already has an X close button.
- Made collection detail Equip buttons larger and more button-like.
- Selecting Equip in a collection detail frame now equips the choice and closes the detail frame automatically.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_37_CollectionsUXFrictionReductionPass.md`

## Preserved
- `SigmaRules.gd` unchanged
- Rules logic unchanged
- Deploy UX unchanged
- SIGMA Radio logic unchanged
- Main Menu background unchanged
