# SIGMA Godot v2.5.8.26.36 — Collections Grid View + Equip Button Pass

Base: `SIGMA_Godot_v2_5_8_26_35_SectionCenteringAndContinuePreviewPass`

## Summary
This patch upgrades the Collections Vault layout so the monetization/collector page feels more like a premium showcase and less like a long list.

## Changes
- Added a small Collections view toggle button:
  - `View: Grid`
  - `View: Stack`
- Defaulted Piece Sets and Board Sets to a 3-column Grid view.
- Kept Stack view available through the toggle.
- Added compact grid card presentation for collection cards.
- Removed the bottom `Equip Classic` / `Classic Equipped` footer button from the main Collections page.
- Enlarged modal detail action buttons into bigger rounded button-style controls.
- Removed disabled `Equipped` action buttons from Classic detail modals; Classic detail pages now use Back only.
- Expanded relevant collection detail modal frames slightly to better fit the larger action buttons.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_36_CollectionsGridViewAndEquipButtonPass.md`

## Preserved
- `SigmaRules.gd` unchanged
- Collection equip logic unchanged
- Board/piece preview logic unchanged
- SIGMA Radio unchanged
- Main Menu background unchanged
