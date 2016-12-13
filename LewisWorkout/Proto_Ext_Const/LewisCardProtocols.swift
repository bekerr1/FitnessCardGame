//
//  LewisCardProtocols.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation


protocol Suitable {
    
    var suit: String {get set}
    static func validSuit() -> [String]
    
}

protocol Rankable {
    
    var rank: Int {get set}
    static func validRank() -> [Int]
    
}

