//
//  LewisCard.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/6/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit



struct LewisCard {
    
    //MARK: Types
    
    enum Suit {
        
        case Diamond
        case Heart
        case Club
        case Spade
        case Joker
        
        var suitString: String {
            switch self {
            case .Diamond: return "♦️"
            case .Heart: return "♥️"
            case .Club : return "♣️"
            case .Spade : return "♠️"
            case .Joker : return "🃏"
            }
        }
        
        var suitName: String {
            switch self {
            case .Diamond: return "Diamonds"
            case .Heart: return "Hearts"
            case .Club: return "Clubs"
            case .Spade: return "Spades"
            case .Joker: return "Joker"
            }
        }
        
        var suitImage: UIImage {
            switch self {
            case .Diamond:
                return UIImage(named: "WornDiamond")!
            case .Spade:
                return UIImage(named: "CrackingSpade")!
            case .Heart:
                return UIImage(named: "WornHeart")!
            case .Club:
                return UIImage(named: "CrackingClub")!
            case .Joker:
                return UIImage() //Joker image
            }
        }
        
        static let validSuits: [Suit] = [
            //.Diamond,
            .Heart
            //.Club,
            //.Spade
        ]
        
        
    }
    
    
    enum Rank: Int {
        
        case Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Joker
        
        var cardRank: String {
            switch self {
            case .Ace:
                return "Ace"
            case .Jack:
                return "Jack"
            case .Queen:
                return "Queen"
            case .King:
                return "King"
            case .Joker:
                return "Joker"
            case .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten:
                return String(self.rawValue)
                
            }
        }
        
        var rowsForRank: Int {
            switch self {
            case .Ace:
                return 1
            case .Two:
                return 2
            case .Three, .Five, .Six:
                return 3
            case .Seven:
                return 4
            case .Eight, .Nine:
                return 5
            case .Ten:
                return 6
            case .Jack, .Queen, .King, .Joker:
                return 0
            default:
                print("Default")
                return -1
            }
        }
        
        static let validRanks: [Rank] = [
            .Ace, .Two//, .Three, .Four,
            //.Five, .Six, .Seven, .Eight
            //.Nine, .Ten, .Jack, .Queen,
            //.King, .Joker
        ]
        
    }
    
    let suit: Suit
    let rank: Rank
    
    init(WithSuit suit: Suit, Rank rank: Rank) {
        self.suit = suit
        self.rank = rank
    }
    
}




//        case "♦️"
//        case "♥️"
//        case "♣️"
//        case "♠️"

//import UIKit
//
//class LewisCard: NSObject, Suitable, Rankable {
//    
//    var suit: String
//    var rank: Int
//    
//    
//    override init() {
//        //shouldnt use this
//        self.suit = String()
//        self.rank = -1
//        
//    }
//    
//    init(withSuit s: String, rank r: Int, color c: String) {
//        self.suit = s
//        self.rank = r
//        
//    }
//    
//    
//    
//    class func validSuit() -> [String] {
//        //code
//        return ["♦️", "♥️", "♣️", "♠️"]
//    }
//    
//    
//    class func validRank() -> [Int] {
//        //code
//        return [1, 2, 3, 4, 5] //, 6, 7, 8, 9, 10, 11, 12, 13, 14 test set
//    }
//    
//    
//
//}
