# SIGMA v2.5.6.1 Manual Test Plan — Target Scope Syntax Fix

## Compile Check

1. Open the project in Godot.
2. Confirm the project opens without the parser error:
   - `Line 4422: Identifier "target" not declared in the current scope.`
3. Confirm `scripts/Main.gd` loads successfully.

## Custom Game Hub Regression

1. Launch the app.
2. Open **New Game**.
3. Tap **Custom Game**.
4. Confirm the Custom Game hub opens.
5. Confirm the hub buttons appear:
   - Single Custom Match
   - Create Tournament
   - Continue Tournament
   - Draft SIGMA
6. Confirm the left-arrow Back button returns to the previous page/menu correctly.

## Tournament Hub Regression

1. Open or create a Tournament.
2. Confirm Tournament Hub content remains centered inside the framed panel.
3. Confirm the left-arrow Back button appears and works.
4. Confirm the top-right X closes to Main Menu.
5. Confirm no right-side clipping or scrollbar overlap appears.

## Rules

No rules behavior should change. `SigmaRules.gd` should be unchanged.

---

## Previous v2.5.6 Test Coverage

# SIGMA v2.5.6 Manual Test Plan — Global Back Arrow + Centered Tournament Hub

## Back Arrow Regression

1. Launch the app.
2. Open Tutorial, Rules Guide, Collections detail pages, Custom Game, Tournament, Tournament Builder, Tournament Hub, and Draft setup.
3. Confirm every former text **Back** button now displays a left-pointing arrow: `←`.
4. Confirm each arrow still performs the same navigation as the previous Back button.
5. Confirm the X close button remains top-right on overlay/menu pages where it existed before.
6. Confirm arrow buttons are compact and do not stretch full-width across the panel.

## Tournament Hub Centering

1. Launch the app.
2. Open Tournament.
3. Create or continue a tournament so the Tournament Hub appears.
4. Confirm the hub content is centered inside the gold framed panel.
5. Confirm Tournament Hub title, tournament name, summary line, Next Match/Edit Setup buttons, section headers, detail cards, Next Match, Upcoming Schedule, Standings/Ladder, Records + Stats, and footer note align as one centered column.
6. Confirm the detail cards are centered and still appear as a 2-column grid on the current portrait layout.
7. Confirm the schedule and standings text are readable inside the centered column.
8. Confirm the vertical scrollbar does not visually push the content off-center.
9. Confirm no horizontal scroll appears.

## v2.5.5 New Game Regression

1. Open New Game from the Main Menu.
2. Confirm Classic SIGMA, Full SIGMA, Draft SIGMA, and Custom Game buttons are the same width and height.
3. Confirm BLITZ!: OFF and Opponent: Human are the same size and aligned.
4. Confirm the description card is fully visible and centered in the lower half of the screen.
5. Confirm Start Game appears inside the description card.
6. Confirm Custom Game still opens the Custom Game builder.

## Gameplay Regression

1. Start a Classic SIGMA match.
2. Confirm the board is 9x9.
3. Confirm Classic row is `G G G S M S G G G`.
4. Confirm each side has 5 Reserve Guardians.
5. Confirm Deploy, Retreat, Peril, Surrender, Elevate, No Cycle, and Overtime flows still behave as before.

## Rules Lock

No rules behavior should change. `SigmaRules.gd` should be unchanged from the v2.5.5 uploaded source.
