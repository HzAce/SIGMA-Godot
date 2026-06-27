# SIGMA v2.0.0 — AI and Harmonic Audio Notes

## Single Player vs AI

Single Player is an offline mode. The player controls Gold and the AI controls Silver in the first foundation build.

Difficulty bots:

- Beginner
- Rookie
- Intermediate
- Professional
- Expert
- Champion

Difficulty primarily changes how far ahead the bot searches, how wide its candidate pathway set is, and how much controlled variety it allows.

The AI uses `SigmaRules.gd` for all legal actions and all simulation. The UI and AI do not decide legality.

## AI personality target

The AI should play to win. It should seek Monarch pressure, Peril, Surrender, captures, strong Deploys, useful Retreat outcomes, and long-term pathways. It should not passively defend until Overtime.

The AI uses controlled variety so close moves are not always identical, while forced progression such as immediate wins, Peril saves, captures, and Surrender threats remains reliable.

## Music update

Menu and board music were rebuilt as longer harmonic loops with more variation.

- Menu music: longer harmonic browsing/lobby identity.
- Board music: separate tactical match identity.
- Board layers: base + turn thresholds + Overtime urgency.
- SFX: high-quality arcade / laser / level-up direction.

