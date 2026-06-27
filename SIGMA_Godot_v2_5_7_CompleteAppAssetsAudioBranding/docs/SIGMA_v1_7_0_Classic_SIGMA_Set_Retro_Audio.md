# SIGMA v1.7.0 — Classic SIGMA Set + Retro-Premium Audio

## Summary

v1.7.0 makes the **Classic SIGMA Set** the official default unlocked full set and refreshes menu/game music toward a softer, catchier retro-premium handheld direction.

## Classic SIGMA Set

A full set includes both a Pieces Set and a Board Set:

```text
Classic SIGMA Set
├─ Classic SIGMA Pieces Set
└─ Classic SIGMA Board Set
```

The Classic SIGMA Set is unlocked and equipped by default.

## Music direction

The previous music direction was too harsh and repeated too obviously. v1.7.0 replaces the stems with original, softer retro-inspired melodies based on classic handheld game music design principles:

- memorable motifs
- phrase-based loops
- simple emotional harmony
- clear instrument voices
- gentle chiptune color
- no heavy bass/sub
- smooth adaptive layering

No melodies from existing games are copied.

## Menu music architecture

- 4 core instruments.
- +1 page layer.
- Maximum 5 active instruments.
- About 32-second structured loop.
- Menu-to-menu navigation should not restart the base theme.
- Page layers enter/exit gracefully.

## Board music architecture

- Classic SIGMA Board has its own board music.
- Game music starts fresh on New Game, Continue, and Restart.
- Pause/unpause preserves board music position.
- Adaptive layers fade in at player turn 40, 100, 160, and Overtime.

## SFX

Core board/event SFX were refreshed toward premium-retro clarity:

- select
- preview
- move
- capture
- Deploy
- Retreat
- Elevate
- Peril
- Surrender
- Victory

## Rules

`SigmaRules.gd` is unchanged.
