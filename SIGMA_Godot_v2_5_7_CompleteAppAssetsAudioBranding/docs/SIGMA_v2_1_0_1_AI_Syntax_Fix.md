# SIGMA v2.1.0.1 — AI Strategy Syntax Fix

Fixed a compile-stopping syntax error in `scripts/SigmaAI.gd` where a wrapped comment line was missing `#`, causing Godot to parse `playing for Overtime...` as invalid code. No rules changes; `SigmaRules.gd` remains unchanged.
