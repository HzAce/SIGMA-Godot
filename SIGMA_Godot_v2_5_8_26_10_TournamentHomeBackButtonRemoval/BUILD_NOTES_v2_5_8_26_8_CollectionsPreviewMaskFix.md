# SIGMA Godot v2.5.8.26.8 — Collections Preview Mask Fix

Base:
- SIGMA Godot v2.5.8.26.7 — Intro Splash Screen Fit

Change:
- Fixed the Collections live preview showcase sweep so it is clipped to the playable board preview rectangle.
- The animated sweep/light polygon no longer spills beyond the board into the outer frame/card area.
- Added a small reusable polygon-to-rect clipping helper for custom-drawn board preview FX.

Files changed:
- scripts/BoardView.gd

No gameplay rules changed.
SigmaRules.gd unchanged.
