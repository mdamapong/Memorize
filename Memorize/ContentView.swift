//
//  ContentView.swift
//  Memorize
//
//  Created by Mickey Damapong on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState: GameState = .start
    @State private var currentLevel: Int = 1
    @State private var cards: [Card] = []
    @State private var flippedCards: [Int] = []
    @State private var matchedCards: Set<Int> = []
    @State private var canFlip = true
    
    private let level1Emojis = ["🐶", "🐱", "🐰"]
    private let level2Emojis = ["🐶", "🐱", "🐰", "🐼"]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch gameState {
            case .start:
                StartView(onBegin: startGame)
            case .playing:
                GameView(
                    currentLevel: currentLevel,
                    cards: cards,
                    flippedCards: flippedCards,
                    matchedCards: matchedCards,
                    onCardTap: handleCardTap
                )
            case .levelComplete:
                LevelCompleteView(
                    currentLevel: currentLevel,
                    onNextLevel: nextLevel,
                    onRestart: restartToLevel1
                )
            case .gameOver:
                GameOverView(onPlayAgain: restartToLevel1)
            }
        }
    }
    
    private func startGame() {
        startLevel(1)
    }
    
    private func startLevel(_ level: Int) {
        currentLevel = level
        let emojis = level == 1 ? level1Emojis : level2Emojis
        let cardCount = level == 1 ? 6 : 8
        
        cards = (0..<cardCount).map { index in
            Card(id: index, emoji: emojis[index % emojis.count], isMatched: false)
        }.shuffled()
        
        flippedCards = []
        matchedCards = []
        canFlip = true
        gameState = .playing
    }
    
    private func nextLevel() {
        if currentLevel < 2 {
            startLevel(currentLevel + 1)
        } else {
            // All levels completed
            gameState = .gameOver
        }
    }
    
    private func restartToLevel1() {
        startLevel(1)
    }
    
    private func handleCardTap(_ cardIndex: Int) {
        guard canFlip && !matchedCards.contains(cardIndex) && !flippedCards.contains(cardIndex) else {
            return
        }
        
        flippedCards.append(cardIndex)
        
        if flippedCards.count == 2 {
            canFlip = false
            
            let firstCard = cards[flippedCards[0]]
            let secondCard = cards[flippedCards[1]]
            
            if firstCard.emoji == secondCard.emoji {
                // Match found
                matchedCards.insert(flippedCards[0])
                matchedCards.insert(flippedCards[1])
                
                // Update cards to show as matched
                cards[flippedCards[0]].isMatched = true
                cards[flippedCards[1]].isMatched = true
                
                flippedCards = []
                canFlip = true
                
                // Check if level is complete
                let requiredMatches = currentLevel == 1 ? 6 : 8
                if matchedCards.count == requiredMatches {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        gameState = .levelComplete
                    }
                }
            } else {
                // No match, flip cards back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    flippedCards = []
                    canFlip = true
                }
            }
        }
    }
}

// MARK: - Models
struct Card: Identifiable {
    let id: Int
    let emoji: String
    var isMatched: Bool
}

enum GameState {
    case start, playing, levelComplete, gameOver
}

// MARK: - Start View
struct StartView: View {
    let onBegin: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Memorize")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("How to Play:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("•")
                        Text("Tap two cards to flip them")
                    }
                    HStack {
                        Text("•")
                        Text("Find matching pairs of emojis")
                    }
                    HStack {
                        Text("•")
                        Text("Matched cards will fade out")
                    }
                    HStack {
                        Text("•")
                        Text("Complete Level 1: 6 cards (3 pairs)")
                    }
                    HStack {
                        Text("•")
                        Text("Complete Level 2: 8 cards (4 pairs)")
                    }
                }
                .font(.body)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Button(action: onBegin) {
                Text("Begin")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(radius: 3)
            }
        }
        .padding()
    }
}

// MARK: - Game View
struct GameView: View {
    let currentLevel: Int
    let cards: [Card]
    let flippedCards: [Int]
    let matchedCards: Set<Int>
    let onCardTap: (Int) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Memorize")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Level \(currentLevel)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(15)
            }
            .padding(.top)
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: currentLevel == 1 ? 3 : 4), spacing: 10) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    CardView(
                        card: card,
                        isFlipped: flippedCards.contains(index) || matchedCards.contains(index),
                        isMatched: matchedCards.contains(index)
                    )
                    .onTapGesture {
                        onCardTap(index)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: Card
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isMatched ? Color.clear : (isFlipped ? Color.white : Color.blue))
                .frame(height: 80)
                .shadow(radius: 3)
            
            if isFlipped && !isMatched {
                Text(card.emoji)
                    .font(.system(size: 40))
            } else if isMatched {
                Text(card.emoji)
                    .font(.system(size: 40))
                    .opacity(0.3)
            } else {
                Text("?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .opacity(isMatched ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isFlipped)
        .animation(.easeInOut(duration: 0.5), value: isMatched)
    }
}

// MARK: - Level Complete View
struct LevelCompleteView: View {
    let currentLevel: Int
    let onNextLevel: () -> Void
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Level \(currentLevel) Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Great job! You've matched all the cards in Level \(currentLevel)!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                if currentLevel < 2 {
                    Button(action: onNextLevel) {
                        Text("Next Level")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                            .shadow(radius: 3)
                    }
                }
                
                Button(action: onRestart) {
                    Text("Restart Level 1")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                }
            }
        }
        .padding()
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Congratulations!")
                .font(.system(size: 80))
            
            Text("Game Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("You've completed all levels! Well done!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onPlayAgain) {
                Text("Play Again")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .cornerRadius(25)
                    .shadow(radius: 3)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
