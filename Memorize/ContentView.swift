//
//  ContentView.swift
//  Memorize
//
//  Created by Mickey Damapong on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState: GameState = .start
    @State private var cards: [Card] = []
    @State private var flippedCards: [Int] = []
    @State private var matchedCards: Set<Int> = []
    @State private var canFlip = true
    
    private let emojis = ["🐶", "🐱", "🐰", "🐼", "🐨", "🦊"]
    
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
                    cards: cards,
                    flippedCards: flippedCards,
                    matchedCards: matchedCards,
                    onCardTap: handleCardTap
                )
            case .gameOver:
                GameOverView(onPlayAgain: startGame)
            }
        }
    }
    
    private func startGame() {
        // Create 6 cards (3 pairs)
        cards = (0..<6).map { index in
            Card(id: index, emoji: emojis[index % 3], isMatched: false)
        }.shuffled()
        
        flippedCards = []
        matchedCards = []
        canFlip = true
        gameState = .playing
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
                
                // Check if game is complete
                if matchedCards.count == 6 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        gameState = .gameOver
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
    case start, playing, gameOver
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
                        Text("Match all 6 cards to win!")
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
    let cards: [Card]
    let flippedCards: [Int]
    let matchedCards: Set<Int>
    let onCardTap: (Int) -> Void
    
    var body: some View {
        VStack {
            Text("Memorize")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
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

// MARK: - Game Over View
struct GameOverView: View {
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Congratulations! You've matched all the cards!")
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
