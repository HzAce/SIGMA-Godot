# SIGMA Godot v2.5.8.26.34 — Text Centering Polish Pass

Base: `SIGMA_Godot_v2_5_8_26_33_UITextBandCohesionSweep`

## Summary
This patch fixes a few layout/alignment issues introduced or revealed by the v33 text-band system and performs a quick centering polish pass where centered presentation is the better fit.

## Changes
- Fixed the Main Menu preview helper caption so it no longer collapses into a narrow vertical text strip.
- Centered Tournament Hub schedule and standings line items.
- Converted the long Tournament Hub helper note into a caption band.
- Centered Settings hero-band text and subtitle text.
- Centered SIGMA Radio station hero/banner text and subtitle text.
- Upgraded the Settings radio sub-banner (`SIGMA FM · Player Radio Override`) into a centered caption band.
- Performed a quick text-centering check in the touched UI areas to keep label placement more intentional.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_34_TextCenteringPolishPass.md`

## Preserved
- `SigmaRules.gd` unchanged
- Deploy UX unchanged
- SIGMA Radio logic unchanged
- Tournament logic unchanged
- Main Menu background unchanged
