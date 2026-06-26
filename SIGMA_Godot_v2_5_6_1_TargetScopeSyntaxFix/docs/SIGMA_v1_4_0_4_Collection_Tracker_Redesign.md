# SIGMA v1.4.0.4 — Collection Tracker Redesign

## Design decision

Collections is now treated as a **Piece Collection Tracker** and monetization-ready storefront foundation.

The main Collections page should show complete set cards/logos only. Players equip full premade sets. Pieces are not mixed across sets.

## Page hierarchy

```text
Collections
└── Set Card: Classic SIGMA Tokens
    └── Set Detail
        ├── Gold Pieces · Player 1
        ├── Silver Pieces · Player 2
        └── Piece Viewer
            ├── Gold version
            └── Silver version
```

## Current set

**Set 1 — Classic SIGMA Tokens**

- Active/equipped by default.
- Premium casino-chip / abstract strategy identity.
- Gold/Silver owner metal.
- Role accents.
- Centered alternating underglow.
- Owner-facing readability.

## Future monetization direction

Future sets can use this same structure:

- Locked
- Unlocked
- Equipped
- Coming Soon
- Featured

Locked sets can still be previewed enough to create desire, while Equip remains disabled until unlocked.

## Technical notes

- `SigmaRules.gd` unchanged.
- Collections remains UI/presentation only.
- Gameplay uses the active complete set.
- Main Collections page no longer renders individual piece grids.
- Set Detail / Piece Viewer use clipped preview cards to prevent token/glow bleed.
- Future true 3D model rotation can plug into the Piece Viewer flow.
