//
//  LewisCardFrontView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/18/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit



class LewisCardFrontView: UIView {
    
    var currentCard: LewisCard = LewisCard()
    var pastCards: [LewisCard] = Array()
    let labelHeight: CGFloat = 60
    
    func newCardToView(newCard: LewisCard) {
        
        pastCards.append(currentCard)
        currentCard = newCard
    }
    

    //Card Orientations
    
    func single() -> UILabel {
        //# (ex. ace, 5, 7, 8, 9, 10
        let singleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: labelHeight))
        singleLabel.text = currentCard.suit
        singleLabel.textAlignment = .Center
        
        return singleLabel
    }
    
    func horizontalDouble() -> UILabel {
        // # # (ex. 4, 5, 6, 7, 8, 9, 10)
        let doubleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: labelHeight))
        doubleLabel.text = "\(currentCard.suit) \t \(currentCard.suit)"
        doubleLabel.textAlignment = .Center
        
        return doubleLabel
    }
    
    //Every card has a certain number of rows. each row has either a single or horizontal double
    
    func oneRow(atRowOne: UILabel) {
        
    }
    
    func twoRows(atRowOne: UILabel, RowTwo atrowTwo: UILabel) {
        
    }
    
    func threeRows(atRowOne: UILabel, RowTwo atrowTwo: UILabel, RowThree atrowThree: UILabel) {
        
    }
    
    func fourRows(atRowOne: UILabel, RowTwo atrowTwo: UILabel, RowThree atrowThree: UILabel, RowFour atrowFour: UILabel) {
        
    }
    
    func fiveRows(atRowOne: UILabel, RowTwo atrowTwo: UILabel, RowThree atrowThree: UILabel, RowFour atrowFour: UILabel, RowFive atrowFive: UILabel) {
        
    }
    
    func sixRows(atRowOne: UILabel, RowTwo atrowTwo: UILabel, RowThree atrowThree: UILabel, RowFour atrowFour: UILabel, RowFive atrowFive: UILabel, RowSix atrowSix: UILabel) {
        
    }
    
    
}
