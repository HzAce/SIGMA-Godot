# SIGMA Godot v2.5.8.26.32 — Main Menu Clarity + Preview Pass

Base project: `SIGMA_Godot_v2_5_8_26_31_RuntimeCleanupPass.zip`

## Summary
- Added a premium smoked-glass readability stage behind the colorful SIGMA wordmark and tagline.
- Preserved the bright gold-and-blue celestial main menu background at `res://assets/ui/branding/sigma_main_menu_background_clean.png`.
- Gave the crest and wordmark more breathing room so the logo reads more clearly on mobile.
- Reframed the main menu live preview as a darker premium showcase chamber with gold trim and subtle static HUD side details.
- Removed the need for any preview title text; the menu does **not** display “SIGMA Tactical Display Chamber.”
- Changed the main menu BoardView preview to a `static_display` living-preview style so it does not use animated center-tile effects.
- Kept the existing main menu button order and primary/secondary styling hierarchy.
- Left `SigmaRules.gd` untouched.

## Files Changed
- `scripts/Main.gd`
  - Rebuilt the Main Menu hero zone into a glass readability stack.
  - Added the new wordmark halo texture layer.
  - Redesigned the preview area into a contained darker chamber frame.
  - Added static side HUD decoration helper for the preview chamber.
  - Kept the live BoardView preview, but now requests `static_display` style.
- `scripts/BoardView.gd`
  - Added `static_display` support for living previews.
  - Added a static preview frame with no pulsing center tile.
  - Prevented idle redraw loops for static landing previews.
  - Removed the quick-preview center tile sparkle/pulse block as a safety measure.

## New Assets
- `assets/ui/main_menu/sigma_logo_glass_halo.png`
- `assets/ui/main_menu/sigma_logo_local_vignette.png`
- `assets/ui/main_menu/main_menu_preview_chamber_frame_reference.png`

## Preserved / Not Changed
- `scripts/SigmaRules.gd` was not modified.
- Deploy tap UX from v2.5.8.26.30 was not modified.
- SIGMA Radio behavior and audio files were not modified.
- Collections functionality was not modified.
- Main menu background path and cover scaling were preserved.
- No gameplay legality logic was moved into UI.

## Test Notes
- Godot was not available in the patching environment, so this package should be opened and tested in Godot.
- Recommended first test: launch the main menu on phone portrait, confirm the wordmark is clearer, confirm the preview chamber appears, and confirm there is no animated center-tile effect in the main menu preview.
