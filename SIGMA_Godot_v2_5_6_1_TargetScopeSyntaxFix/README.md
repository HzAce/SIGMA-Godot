# SIGMA Godot v2.5.6.1 — Target Scope Syntax Fix

This is a focused hotfix on top of **v2.5.6 — Global Back Arrow + Centered Tournament Hub**.

## Fixed

- Fixed the Godot parser error:

```text
Line 4422: Identifier "target" not declared in the current scope.
```

- The issue was in `_rebuild_custom_games_hub_panel()` where the Custom Game hub grid was being added to `target`, but that local variable does not exist in that function.
- The grid now correctly adds to `custom_content_box`.

## Preserved from v2.5.6

- App-wide Back buttons display as a left-pointing arrow.
- Tournament Hub content remains centered in a clean max-width column.
- X close button remains top-right where present.
- Tournament Hub scrollbar padding/centering pass remains active.

## Rules Lock

No rules behavior changed. `SigmaRules.gd` is unchanged from v2.5.6.

## Android export path

```text
exports/android/SIGMA_Mobile_v2_5_6_1_debug.apk
```
