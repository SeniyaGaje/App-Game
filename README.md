PlayHub

A SwiftUI iOS game app with three arcade-style modes, built progressively over four weeks.

Game Modes

Tap Frenzy — Tap a button as fast as you can before a 10-second timer runs out. Features a combo multiplier, trap colours, and a shrinking button to keep things tense.

Light It Up — A whack-a-mole grid where one card lights up briefly. Tap it before it goes dark. The grid grows and the window shrinks as the round progresses through four difficulty levels.

Quiz Rush — 10 live trivia questions fetched from the Open Trivia DB API. Answer correctly to build a streak and earn bonus points. Handles loading and error states gracefully.

Features


Home screen with NavigationStack routing to each mode.
High scores persisted per mode via @AppStorage.
Stats tab showing totals, personal bests, and a bar chart per mode (SwiftUI Charts).
Map tab recording the location of each completed session via Core Location.
Daily challenge notification schedulable from the Settings tab.
ShareLink on the result screen to share your score.
All game logic separated into ObservableObject ViewModels.
