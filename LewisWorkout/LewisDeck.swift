//
//  LewisDeck.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisDeck: NSObject {
    
    var deck: [LewisCard] = {
        
        var d: [LewisCard] = Array()
        var jokerCount: Int = 0
        
        for rank in LewisCard.validRank() {
            for suit in LewisCard.validSuit() {
                
                if rank == 14 {
                    
                    if jokerCount < 2 {
                        let newCard: LewisCard = LewisCard(withSuit: "Joker", rank: 14, color: "Joker")
                        jokerCount += 1
                        d.append(newCard)
                    } else {
                        print("have 2 jokers and dont need anymore")
                    }
                    
                } else {
                    
                    let newCard: LewisCard = LewisCard(withSuit: suit, rank: rank, color: "")
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
        cardCount = 54 * numberOfDecks
    }
    
    init(withNumberOfDecks count: Int) {
        
        numberOfDecks = count
        cardCount = 54 * numberOfDecks
        super.init()
        duplicateDeck()
    }
    
    
    func duplicateDeck() {
        
        for _ in 1..<numberOfDecks {
            deck += deck
        }
    }
    
    
    func pickRandomCard() -> LewisCard {
        //should check this to see if the conversions slow things down alot
        let randCardIndex = Int(arc4random_uniform(UInt32(cardCount)))
        return deck[randCardIndex]
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
