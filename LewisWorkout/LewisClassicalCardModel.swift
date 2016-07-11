//
//  LewisClassicalCardModel.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation


struct ClassicalCardModel {
    
    let card: LewisCard
    
    init(WithCard card: LewisCard) {
        
        self.card = card
    }
    
    
    init(WithCard card: LewisCard, ShapeContent content: Queue) {
        
        self.card = card
        
    }
    
    mutating func createModelFromCard() -> Queue {
        
        let contentQueue = Queue()
        
        for _ in 0..<card.rank.rawValue {
            
            switch card.suit {
            case .Heart:
                
                let heart = Heart()
                contentQueue.enqueue(heart.shape)
                
                break
            default:
                break
            }
            
        }
        
        return contentQueue
    }
    
}