//
//  LewisWorkoutTests.swift
//  LewisWorkoutTests
//
//  Created by brendan kerr on 5/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import XCTest
@testable import LewisWorkout

class LewisWorkoutTests: XCTestCase {
    
    var singleDeck: LewisDeck!
    var multiDeck: LewisDeck!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        singleDeck = LewisDeck()
        multiDeck = LewisDeck(withNumberOfDecks: 2)
        
    }
    
    func testDeckCreation() {
        
        XCTAssert(singleDeck.deck.count == 54)
        XCTAssert(multiDeck.deck.count == 108)
    }
    
    func testContentsOfDeck() {
        
        var clubcount = 0
        var heartcount = 0
        var spadecount = 0
        var diamcount = 0
        var jokercount = 0
        
        for card in singleDeck.deck {
            switch card.suit {
                case "♦️":
                    diamcount += 1
                    break
                case "♥️":
                    heartcount += 1
                    break
                case "♣️":
                    clubcount += 1
                    break
                case "♠️":
                    spadecount += 1
                    break
                default:
                    print("joker??")
                    jokercount += 1
                    break
            }
        }
        
        XCTAssert(diamcount == 13)
        XCTAssert(spadecount == 13)
        XCTAssert(heartcount == 13)
        XCTAssert(clubcount == 13)
        XCTAssert(jokercount == 2)
        
        clubcount = 0
        heartcount = 0
        spadecount = 0
        diamcount = 0
        jokercount = 0
        
        for card in multiDeck.deck {
            switch card.suit {
            case "♦️":
                diamcount += 1
                break
            case "♥️":
                heartcount += 1
                break
            case "♣️":
                clubcount += 1
                break
            case "♠️":
                spadecount += 1
                break
            default:
                print("joker??")
                jokercount += 1
                break
            }
        }
        
        XCTAssert(diamcount == 26)
        XCTAssert(spadecount == 26)
        XCTAssert(heartcount == 26)
        XCTAssert(clubcount == 26)
        XCTAssert(jokercount == 4)

    }
    
    func testCardRankRange() {
        
        for card in singleDeck.deck {
            
            XCTAssertGreaterThan(14, card.rank)
            XCTAssertLessThan(0, card.rank)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
