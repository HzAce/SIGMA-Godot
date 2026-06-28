# SIGMA Godot v2.5.8.26.38 — Collections Front-Facing Language Cleanup Pass

Base: `SIGMA_Godot_v2_5_8_26_37_CollectionsUXFrictionReductionPass`

## Summary
This patch cleans up player-facing Collections language so the current Collections page is framed around **Pieces** and **Boards**, while reserving **Full Sets** terminology for the future Store/monetization flow.

## Changes
- Removed the redundant top equipped gold banner from Collections.
- Changed the main Collections grid section from **Full Sets** to **Piece Sets**.
- Removed front-facing **Full Set** language from the equipped preview card and collection detail headers.
- Updated Collections wording to describe equipped **Pieces** and **Board** instead of “Full Set.”
- Kept matching theme information as “Matching Board” where helpful, without using Store-style Full Set terminology.
- Continued the earlier `Board Sets` → `Boards` language cleanup.
- Added a global tooltip cleanup in the readability pass so desktop hover description popups do not return.

## Preserved
- `SigmaRules.gd` unchanged
- Collection equip behavior unchanged
- Equip buttons still close detail frames
- Grid / Stack view toggle unchanged
- SIGMA Radio logic unchanged
- Main Menu background unchanged
