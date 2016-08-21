//
//  LWDeck.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LWDeck: NSObject {
    
    let initialCardCount = LWCard.Rank.validRanks.count * LWCard.Suit.validSuits.count
    var deck: [LWCard] = {
        
        var d: [LWCard] = Array()
        var jokerCount: Int = 0
        
        for rank in LWCard.Rank.validRanks {
            for suit in LWCard.Suit.validSuits {
                
                if rank == LWCard.Rank.Joker {
                    
                    if jokerCount < 2 {
                        let newCard: LWCard = LWCard(WithSuit: LWCard.Suit.Joker, Rank: LWCard.Rank.Joker)
                        jokerCount += 1
                        d.append(newCard)
                    } else {
                        print("have 2 jokers and dont need anymore")
                    }
                    
                } else {
                    
                    let newCard: LWCard = LWCard(WithSuit: suit, Rank: rank)
                    d.append(newCard)
                }
            }
        }
        
        return d
    }()
    
    var numberOfDecks: Int
    var cardCount: Int
    
    
    override init() {
        
        numberOfDecks = 1
        cardCount = initialCardCount * numberOfDecks
    }
    
    init(withNumberOfDecks count: Int) {
        
        numberOfDecks = count
        cardCount = initialCardCount * numberOfDecks
        super.init()
        duplicateDeck()
    }
    
    
    func duplicateDeck() {
        
        for _ in 1..<numberOfDecks {
            deck += deck
        }
    }
    
    
    func pickRandomCard() -> LWCard {
        //should check this to see if the conversions slow things down alot
        let randCardIndex = Int(arc4random_uniform(UInt32(cardCount)))
        return deck[randCardIndex]
    }
    
    
}



//class LWDeck: NSObject {
//    
//    let initialCardCount = LWCard.validRank().count * LWCard.validSuit().count
//    var deck: [LWCard] = {
//        
//        var d: [LWCard] = Array()
//        var jokerCount: Int = 0
//        
//        for rank in LWCard.validRank() {
//            for suit in LWCard.validSuit() {
//                
//                if rank == 14 {
//                    
//                    if jokerCount < 2 {
//                        let newCard: LWCard = LWCard(withSuit: "Joker", rank: 14, color: "Joker")
//                        jokerCount += 1
//                        d.append(newCard)
//                    } else {
//                        print("have 2 jokers and dont need anymore")
//                    }
//                    
//                } else {
//                    
//                    let newCard: LWCard = LWCard(withSuit: suit, rank: rank, color: "")
//                    d.append(newCard)
//                }
//                
//                
//                
//            }
//        }
//        
//        return d
//    }()


