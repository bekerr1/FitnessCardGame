//
//  LewisCard.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisCard: NSObject, Suitable, Rankable {
    
    var suit: String
    var rank: Int
    
    
    override init() {
        //shouldnt use this
        self.suit = String()
        self.rank = -1
        
    }
    
    init(withSuit s: String, rank r: Int, color c: String) {
        self.suit = s
        self.rank = r
        
    }
    
    
    
    class func validSuit() -> [String] {
        //code
        return ["♦️", "♥️", "♣️", "♠️"]
    }
    
    
    class func validRank() -> [Int] {
        //code
        return [1, 2, 3, 4, 5] //, 6, 7, 8, 9, 10, 11, 12, 13, 14 test set
    }
    
    

}
