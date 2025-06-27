# Memorize - SwiftUI Memory Card Game

A simple memory card game built with SwiftUI that challenges players to match pairs of cards by remembering their positions.

## Features

- Start screen with game instructions
- 6 cards (3 pairs) with emoji symbols
- Two-card flipping mechanics
- Smooth animations and visual feedback
- Fade-out effect for matched cards
- Game over screen with restart option

## Project Structure

```
Memorize/
├── ContentView.swift         // Main game controller and logic
├── StartView.swift           // Start screen
├── GameView.swift            // Game screen with grid
├── CardView.swift            // Individual card view
├── GameOverView.swift        // End screen after winning
├── Models.swift              // Card model and GameState enum
```

## Core Concepts in SwiftUI Used

- `@State` variables for managing UI state
- View composition with custom child views
- Conditional view rendering based on game state
- Animations using `withAnimation` and `.animation`
- Timers and delays using `DispatchQueue`

## Game Flow

```
StartView
  ↓ onBegin()
startGame() → shuffles and sets up cards
  ↓
GameView (play mode)
  ↓ onCardTap(index)
Check match → update state
  ↓
If all matched → GameOverView
  ↓ onPlayAgain()
Back to startGame()
```

## File: ContentView.swift

### State Variables

```swift
@State private var gameState: GameState = .start
@State private var cards: [Card] = []
@State private var flippedCards: [Int] = []
@State private var matchedCards: Set<Int> = []
@State private var canFlip = true
```

These variables manage the game logic and rendering:

- `gameState`: Current screen state
- `cards`: The 6 shuffled cards
- `flippedCards`: Tracks flipped indexes (max 2)
- `matchedCards`: Stores matched card indexes
- `canFlip`: Prevents double-tapping during delay

### Body Layout

```swift
ZStack {
    LinearGradient(...) // Background
    switch gameState {
        case .start: StartView(onBegin: startGame)
        case .playing: GameView(...)
        case .gameOver: GameOverView(onPlayAgain: startGame)
    }
}
```

This controls which screen to show based on the game state.

### Function: startGame()

```swift
cards = (0..<6).map {
    Card(id: $0, emoji: emojis[$0 % 3], isMatched: false)
}.shuffled()
```

- Creates 6 cards using 3 emoji pairs
- Randomizes their order
- Resets the state for a new game

### Function: handleCardTap(\_:)

Handles the core game logic:

- Prevents re-tapping the same or matched card
- Appends index to flippedCards
- When 2 cards are flipped:
  - If matching → mark as matched
  - If not → flip back after 1 second delay
- If all cards matched → change game state to .gameOver

## File: Models.swift

### Card Struct

```swift
struct Card: Identifiable {
    let id: Int
    let emoji: String
    var isMatched: Bool
}
```

Each card has an ID, an emoji symbol, and a matched state.

### GameState Enum

```swift
enum GameState {
    case start, playing, gameOver
}
```

Manages current screen display logic.

## StartView.swift

The welcome screen with game instructions and a "Begin" button:

```swift
StartView(onBegin: startGame)
```

Tapping the button runs startGame().

## GameView.swift

Displays:

- Game title
- 3x2 grid using LazyVGrid
- Each card is rendered via CardView

```swift
CardView(...)
  .onTapGesture {
    onCardTap(index)
  }
```

## CardView.swift

Renders a single card:

```swift
ZStack {
    RoundedRectangle() // Card background
    if isFlipped { Text(card.emoji) }
    else if isMatched { faded emoji }
    else { "?" }
}
```

Includes smooth animations when flipping or matching.

## GameOverView.swift

Simple win screen:

- Celebration symbol
- "Game Over" message
- "Play Again" button → calls startGame() again

## Preview

```swift
#Preview {
    ContentView()
}
```

Used for Xcode SwiftUI canvas previews.

## Learning Goals

- Understand SwiftUI state-driven rendering
- Practice working with view composition
- Learn how to manage game state with logic and animations
- Use structs and enums to organize models

## To Run This App

1. Open project in Xcode
2. Run in Simulator or real device
3. Tap "Begin" to start playing

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
