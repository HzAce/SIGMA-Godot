# SIGMA v2.5.7 Manual Test Plan — Complete App Assets + Audio + Branding

## Asset Import

1. Open the project in Godot.
2. Confirm Godot imports the restored assets without missing-resource errors.
3. Confirm the following folders exist and import cleanly:
   - `assets/pieces/classic_sigma_tokens/`
   - `assets/pieces/vector_obelisks/`
   - `assets/pieces/draconian/`
   - `assets/pieces/lions_den/`
   - `assets/collections/vector/`
   - `assets/collections/draconian/`
   - `assets/collections/lions_den/`
   - `assets/boards/classic_sigma_board_3d/`
   - `assets/boards/draconian_board/`
   - `assets/boards/lions_den_board/`
   - `assets/ui/branding/`
   - `assets/audio/music/`
   - `assets/audio/sigma_retro/music/`
   - `assets/audio/sigma_retro/sfx/`

## Branding

1. Launch the app.
2. Confirm the startup splash displays SIGMA branding.
3. Confirm the Main Menu shows the SIGMA crest above the title.
4. Confirm the Main Menu background art appears behind the landing page without blocking buttons.
5. Confirm text remains readable over the background art.

## Piece Sets

1. Open Collections.
2. Confirm Classic SIGMA Tokens, Obelisk, Dragons, and Lion's Den piece sets show previews.
3. Open each set detail page.
4. Inspect Gold and Silver versions of Monarch, Guardian, Sentinel, Infiltrator, and Assassin.
5. Equip each set and start a match.
6. Confirm board pieces use the selected set.
7. Confirm owner-facing readability remains correct:
   - Gold token faces read from bottom.
   - Silver token faces rotate 180° toward top.

## Boards / Collections

1. Open Collections.
2. Confirm Vector/Obelisk, Dragons, and Lion's Den board promo art appears.
3. Open each board detail page.
4. Equip each board theme.
5. Start a match and confirm the board theme changes visuals only.
6. Confirm no rules or move legality changes when changing boards.

## Audio

1. Launch the app and confirm menu music plays.
2. Open New Game, Collections, Rules, Tutorial, and Settings.
3. Confirm page-open, page-back, button tap, and confirm sounds play.
4. Start Classic SIGMA.
5. Confirm gameplay focus music starts and menu music does not layer over it.
6. Make a normal move and confirm move SFX.
7. Make a capture and confirm capture SFX.
8. Deploy a Reserve Guardian and confirm Deploy SFX.
9. Trigger Elevate and confirm Elevate SFX.
10. Trigger Peril and confirm Peril warning SFX.
11. Confirm Pause uses pause music behavior and returns to gameplay music correctly.
12. Finish a match and confirm result stinger plays.

## Regression

1. Confirm app-wide Back buttons still show as `←`.
2. Confirm Tournament Hub remains centered.
3. Confirm Custom Game opens without parser errors.
4. Confirm New Game uniform layout remains unchanged.
5. Confirm no horizontal clipping appears on New Game or Tournament Hub.
6. Confirm Android touch/select debounce still feels correct.
7. Confirm Tutorial highlight/glow reset remains fixed.
8. Confirm Elevate prompt appears at the correct time only.

## Rules Lock

No rules behavior should change. `SigmaRules.gd` should remain unchanged.
