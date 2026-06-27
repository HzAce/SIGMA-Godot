# SIGMA v1.7.0.1 — Menu/Game Separation + Close UX

Focused patch on top of v1.7.0.

## Audio behavior

- Menu music is for non-game pages only.
- Active gameplay is its own board-music context.
- Starting, continuing, or restarting a game hard-stops menu stems before starting Classic SIGMA Board music.
- Pause/unpause during a game pauses/resumes the current board music and ambience without restarting.
- Returning from game to Main Menu may start menu music fresh.

## Page behavior

- Pause is an in-game match control.
- Non-game pages use X/close behavior to return to Main Menu.
- Settings, Rules Guide, Tutorial, Collections, New Game, Custom Game, and Draft setup should not require Pause to exit.

## Rules

`SigmaRules.gd` unchanged.
