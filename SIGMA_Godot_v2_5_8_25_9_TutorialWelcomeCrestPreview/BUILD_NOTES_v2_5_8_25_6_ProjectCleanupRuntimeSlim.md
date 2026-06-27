# SIGMA Godot v2.5.8.25.6 — Project Cleanup / Runtime Asset Slim

Purpose:
- Reduce Godot startup/import overhead by keeping only runtime-needed assets inside the project.
- Move build notes, docs, masters, generated sources, preview sheets, and duplicate promos out of the playable project.

Kept in the runtime project:
- project.godot
- scripts/
- scenes/
- runtime UI icons:
  - assets/ui/icons/sigma_arrows/runtime_256/
  - assets/ui/icons/sigma_rules/core/runtime_256/
- current tutorial piece intro tokens:
  - assets/ui/tutorial/piece_intro/classic_tokens/runtime_512/gold/
- current gameplay piece sets and board/theme assets
- current audio assets

Moved out to the separate RemovedDevArchive zip:
- old ANDROID_EXPORT_PATH / BUILD_NOTES / README markdown files
- docs/ reference materials
- source_generated icon art
- master-size icon art
- preview sheets
- unused silver/hero/master tutorial intro variants
- duplicate board promo images under assets/boards

Code update:
- Tutorial piece intro texture path now loads optimized runtime_512/gold assets instead of 768px hero assets.

No gameplay rules changed.
SigmaRules.gd is unchanged in this cleanup pass.

Additional cleanup fix:
- Added runtime placeholder radio manifest at assets/audio/radio/sigma_radio_manifest.json so the hardcoded path resolves.
