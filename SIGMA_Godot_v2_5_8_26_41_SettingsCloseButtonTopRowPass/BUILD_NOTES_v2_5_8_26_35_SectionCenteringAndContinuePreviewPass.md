# SIGMA Godot v2.5.8.26.35 — Section Centering + Continue Preview Pass

Base: `SIGMA_Godot_v2_5_8_26_34_TextCenteringPolishPass`

## Summary
This pass fixes the missing Main Menu Continue preview description and recenters app-wide section banner labels that act as section dividers or headings.

## Changes
- Added a dedicated Main Menu preview state for **Continue**.
  - Hover/focus/scroll over Continue now shows: `Continue · resume your saved SIGMA match`.
- Recentered shared section-band headings generated through `_add_custom_section_label()`.
  - This affects labels like `Tournament Name`, `Format`, `Participants`, `Match Setup`, and similar section bands across the Custom / Tournament flow.
- Recentered shared Collections category headings generated through `_add_collection_category_label()`.
  - This affects labels like `Piece Sets` and `Board Sets`.
- Extends the text centering mindset so section-label banners throughout the app behave more consistently.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_35_SectionCenteringAndContinuePreviewPass.md`

## Preserved
- `SigmaRules.gd` unchanged
- Tournament logic unchanged
- Deploy UX unchanged
- SIGMA Radio logic unchanged
- Main Menu background unchanged
