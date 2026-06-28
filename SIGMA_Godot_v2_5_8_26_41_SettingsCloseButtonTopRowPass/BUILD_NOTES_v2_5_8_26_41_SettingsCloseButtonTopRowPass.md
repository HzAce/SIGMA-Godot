# SIGMA Godot v2.5.8.26.41 — Settings Close Button Top Row Pass

Base: `SIGMA_Godot_v2_5_8_26_40_ContextAwareSettingsReturnPass`

## Summary
This pass moves the Settings close button above the Settings title/caption bands so the header bands can stretch across the page and remain visually centered with the rest of the layout.

## Changes
- Moved the Settings `X` close button into its own top row aligned right.
- Allowed the `Settings` hero band to span the full available width.
- Allowed the `Sound. Radio. Utilities.` caption band to span the full available width.
- Improved visual centering and consistency with the rest of the page.

## Files changed
- `scripts/Main.gd`
- `BUILD_NOTES_v2_5_8_26_41_SettingsCloseButtonTopRowPass.md`

## Preserved
- Context-aware Settings return behavior remains intact.
- `SigmaRules.gd` unchanged.
- Settings content and audio/radio logic unchanged.
