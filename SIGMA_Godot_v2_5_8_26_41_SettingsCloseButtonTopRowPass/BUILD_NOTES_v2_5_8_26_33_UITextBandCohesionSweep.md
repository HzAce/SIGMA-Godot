# SIGMA Godot v2.5.8.26.33 — UI Text Band Cohesion Sweep

Base: `SIGMA_Godot_v2_5_8_26_32_MainMenuClarityPreviewPass`

## Summary
This patch extends the v2.5.8.26.32 main-menu clarity direction into a broader app-wide UI text cohesion pass. The goal is to make headers, helper captions, and page-intro text feel more intentional, more premium, and easier to read against complex backgrounds.

## Implementation highlights
- Added a reusable `_make_text_band()` helper in `scripts/Main.gd`.
- Refined the main-menu tagline color so it better matches the main wordmark band.
- Replaced the floating main-menu preview helper text with a contained caption band.
- Applied new title / caption band treatment to these pages:
  - Tutorial
  - Settings
  - SIGMA Radio station screen
  - New Game
  - Collections Vault
  - Rules Guide
  - Tournament home
  - Custom Game hub
  - Single Custom Match
  - Create Tournament
  - Tournament Hub
- Converted shared section-label helpers to the band system:
  - `_add_custom_section_label()`
  - `_add_collection_category_label()`
- Added banded card headings in Settings for Audio and SIGMA Radio.

## Design rules respected
- No return of the removed `SIGMA Tactical Display Chamber` label.
- No center-tile gameplay distraction added to the board preview.
- No rules logic changes.
- No legality / engine changes.
- Patch remains presentation-focused.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_33_UITextBandCohesionSweep.md`

## Notes
- This patch intentionally keeps the existing mobile-first layout model and button hierarchy.
- The band system is code-driven; no required new art assets were needed for this pass.
