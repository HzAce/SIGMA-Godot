# SIGMA v1.4.0.2 — Collections Layout + Alternating Underglow

## Summary

This update keeps the focus on **Set 1: Classic SIGMA Tokens** and fixes presentation issues found during testing.

## Fixed

- Collections is now a full-screen page, not an overlay inside the active game board.
- Collections uses scrollable content so large token previews can fit on small screens.
- Active game UI remains fixed and non-scrollable.
- Token preview rows are organized by owner: Gold Pieces and Silver Pieces.
- Token underglow is centered beneath each piece.
- Underglow alternates between owner color and piece role color.

## Underglow rule

Gold side pieces pulse:

```text
Gold → Gold-side role accent → Gold → Gold-side role accent
```

Silver side pieces pulse:

```text
Silver → Silver-side role accent → Silver → Silver-side role accent
```

This communicates both owner and piece identity without changing legal rules.

## Rules lock

`SigmaRules.gd` is unchanged. All updates are UI/presentation only.
