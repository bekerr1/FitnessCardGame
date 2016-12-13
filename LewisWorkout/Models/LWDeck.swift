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
                
                if rank == LWCard.Rank.joker {
                    
                    if jokerCount < 2 {
                        let newCard: LWCard = LWCard(WithSuit: LWCard.Suit.joker, Rank: LWCard.Rank.joker)
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
    
    
    func pickRandomCard(WithReplacement replace: Bool) -> LWCard {
        //should check this to see if the conversions slow things down alot
        let randCardIndex = Int(arc4random_uniform(UInt32(cardCount - 1)))
        let returnCard = deck[randCardIndex]
        if replace {
           //Do nothing, card stays in deck
        } else {
            deck.remove(at: randCardIndex)
            cardCount -= 1
        }
        return returnCard
    }
    
    
}
