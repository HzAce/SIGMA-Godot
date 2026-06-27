# SIGMA Godot v2.5.8.26.6 — Responsive Static Image Scaling

Base:
- SIGMA Godot v2.5.8.26.5 — Radio Status Dot Pass

Changes:
- Added reusable responsive image helpers for static art.
- Background/static decorative art now uses cover scaling where appropriate.
- Crest/logo/tutorial/rules visuals use contain scaling so they do not stretch or crop.
- Startup splash image now scales responsively without stretching.
- Main menu background art now fills the screen without stretching and crops safely if needed.
- Main menu crest, Radio crest, Tutorial welcome crest, Rules Guide visuals, tutorial piece visuals, movement arrows, collection previews, and reserve token tiles are configured to keep aspect ratio.
- Added a viewport resize refresh hook so static layouts reflow when screen size changes.

Files changed:
- scripts/Main.gd

No gameplay rules changed.
SigmaRules.gd is unchanged.
