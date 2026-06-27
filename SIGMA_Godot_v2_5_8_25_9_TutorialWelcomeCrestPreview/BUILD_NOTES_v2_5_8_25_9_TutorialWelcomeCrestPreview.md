SIGMA Godot v2.5.8.25.9 — Tutorial Welcome Crest Preview

Base:
- SIGMA_Godot_v2_5_8_25_8_TutorialIntroAndCardFlowFix

Changes:
- Updated the Welcome to SIGMA Tutorial preview panel to use the existing SIGMA crest artwork at res://assets/ui/branding/sigma_crest.png.
- Removed the welcome-page arrow row so the crest is the single focused preview visual.
- Preserved the existing welcome-page structure, Begin Tutorial flow, and Mission 1 tutorial card behavior.
- Added a safe fallback so if the crest texture fails to load, the welcome page still shows the gold SIGMA wordmark.

Files changed:
- scripts/Main.gd
- BUILD_NOTES_v2_5_8_25_9_TutorialWelcomeCrestPreview.md
