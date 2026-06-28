# SIGMA Godot v2.5.8.26.31 — Runtime Cleanup Pass

Base:
- SIGMA Godot v2.5.8.26.30 — Deploy Outside Tap Cancel

Cleanup:
- Removed duplicate static-background backup art.
- Removed older unused main-menu artwork.
- Removed unused 3D board blockout source files.
- Removed old accumulated build-note markdown files from the project root.

Removed files:
- `BUILD_NOTES_v2_5_8_25_6_ProjectCleanupRuntimeSlim.md`
- `BUILD_NOTES_v2_5_8_25_7_TutorialWelcomeIntro.md`
- `BUILD_NOTES_v2_5_8_25_8_TutorialIntroAndCardFlowFix.md`
- `BUILD_NOTES_v2_5_8_25_9_TutorialWelcomeCrestPreview.md`
- `BUILD_NOTES_v2_5_8_26_SigmaRadioFoundation.md`
- `BUILD_NOTES_v2_5_8_26_1_SigmaRadioPolish.md`
- `BUILD_NOTES_v2_5_8_26_2_SigmaRadioSettingsLayout.md`
- `BUILD_NOTES_v2_5_8_26_3_SigmaRadioPolishCleanup.md`
- `BUILD_NOTES_v2_5_8_26_4_SettingsScrollFix.md`
- `BUILD_NOTES_v2_5_8_26_5_RadioStatusDotPass.md`
- `BUILD_NOTES_v2_5_8_26_6_ResponsiveStaticImageScaling.md`
- `BUILD_NOTES_v2_5_8_26_7_IntroSplashScreenFit.md`
- `BUILD_NOTES_v2_5_8_26_8_CollectionsPreviewMaskFix.md`
- `BUILD_NOTES_v2_5_8_26_9_TournamentBackButtonFix.md`
- `BUILD_NOTES_v2_5_8_26_10_TournamentHomeBackButtonRemoval.md`
- `BUILD_NOTES_v2_5_8_26_11_AudioRuntimeOptimization.md`
- `BUILD_NOTES_v2_5_8_26_12_MainMenuBackgroundFX.md`
- `BUILD_NOTES_v2_5_8_26_13_MainMenuBackgroundSwap.md`
- `BUILD_NOTES_v2_5_8_26_14_RadioMenuMusicOverride.md`
- `BUILD_NOTES_v2_5_8_26_15_SigmaRadioSongPack.md`
- `BUILD_NOTES_v2_5_8_26_16_RadioContinuityLock.md`
- `BUILD_NOTES_v2_5_8_26_17_DoubleTapDeployShortcut.md`
- `BUILD_NOTES_v2_5_8_26_18_TripleTapDeployOff.md`
- `BUILD_NOTES_v2_5_8_26_19_DragonPulseCenterAdjust.md`
- `BUILD_NOTES_v2_5_8_26_20_DragonPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_21_ObeliskPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_22_ObeliskPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_23_ObeliskPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_24_ObeliskPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_25_ObeliskPulseMicroLeft.md`
- `BUILD_NOTES_v2_5_8_26_26_CollectionsBookletRedesign.md`
- `BUILD_NOTES_v2_5_8_26_29_StaticMainMenuBackgroundSwap.md`
- `BUILD_NOTES_v2_5_8_26_30_DeployOutsideTapCancel.md`
- `assets/ui/branding/sigma_main_menu_background_static_v29.png` (3.29 MB)
- `assets/ui/branding/sigma_main_menu_art.png` (2.27 MB)
- `assets/boards/classic_sigma_board_3d/classic_sigma_board_blockout.obj`
- `assets/boards/classic_sigma_board_3d/classic_sigma_board_blockout.obj.import`
- `assets/boards/classic_sigma_board_3d/classic_sigma_board_blockout.mtl`
- `assets/boards/classic_sigma_board_3d/README.md`

Estimated removed size:
- 5.61 MB uncompressed

Kept:
- Current static main menu background.
- Current responsive main menu scaling.
- SIGMA Radio song pack.
- Active default music, fallback music, and SFX.
- All collection piece sets and board promo assets.
- All scripts and gameplay rules.

No gameplay rules changed.
SigmaRules.gd unchanged.
