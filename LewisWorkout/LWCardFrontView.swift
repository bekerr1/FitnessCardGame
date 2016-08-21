//
//  LWCardFrontView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/18/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit



class LWCardFrontView: UIView {
    
    var currentCardModel: LWCard!
    var pastCards: [LWCard] = Array()
    //var sideWays: Bool = false
    var cardContents: [UIImageView] = Array()
    let labelFrameWidth: CGFloat = 50
    let labelFrameHeight: CGFloat = 100
    let cardTopLabel: UILabel!
    let cardBottomLabel: UILabel!
    
    let contentSize: CGSize = CGSizeMake(40, 40)
    
    
    required init?(coder aDecoder: NSCoder) {
        
        
        cardTopLabel = UILabel(frame: CGRectZero)
        cardTopLabel.backgroundColor = UIColor.yellowColor()
        cardTopLabel.frame = CGRectMake(0, 0, labelFrameWidth, labelFrameHeight)
        
        cardBottomLabel = UILabel(frame: CGRectZero)
        cardBottomLabel.backgroundColor = UIColor.yellowColor()
        cardBottomLabel.frame = CGRectMake(frame.width - labelFrameWidth, frame.height - labelFrameHeight, labelFrameWidth, labelFrameHeight)
        
        super.init(coder: aDecoder)
        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
    }
    
    //Not used, initialized from storyboard
//    override init(frame: CGRect) {
//        
//        super.init(frame: frame)
//        self.layer.cornerRadius = LewisGeometricConstants.cornerRadius
//    }
    
    override func layoutSubviews() {
        //Layout
        super.layoutSubviews()
        
//        if let model = currentCardModel {
//            let queue = ShapeQueue<UIImageView>(WithArray: self.cardContents)
//            var cardLayout = ClassicalCardLayout(WithContents: queue)
//            cardLayout.layout(Model: model, InsideRect: self.bounds)
//        }
        

    }
    
    
    func newCardToView(newCard: LWCard, Sideways side: Bool) {
        
        
        if side {
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }
        
        if currentCardModel != nil {
            pastCards.append(currentCardModel)
        }
        
        currentCardModel = newCard
        createViewContentsFromCardModel()
        addShapesToView()
        
        if let model = currentCardModel {
            layoutUsingModel(CardModel: model)
        }
        
        
    }
    
    func clearContentsFromScreen() {
        
        for suit in cardContents {
            suit.removeFromSuperview()
        }
        
        cardContents = Array()
    }
    
    func addShapesToView() {
        for shape in self.cardContents {
            self.addSubview(shape)
        }
    }
    
    func layoutUsingModel(CardModel model: LWCard) {
        
            let queue = ShapeQueue<UIImageView>(WithArray: self.cardContents)
            var cardLayout = ClassicalCardLayout(WithContents: queue)
            cardLayout.layout(Model: model, InsideRect: self.bounds)
        
    }
    
    
    func createViewContentsFromCardModel() {
        
        var result = Array<UIImageView>()
        for _ in 0..<currentCardModel.rank.rawValue {
            
            switch currentCardModel.rank {
            case .Jack, .Queen, .King, .Joker:
                //Change label
                break
            default:
                let imageView = UIImageView(frame: CGRectMake(0, 0, contentSize.width, contentSize.height))
                imageView.image = currentCardModel.suit.suitImage
                result.append(imageView)
                break
            }
        }
    
        cardContents = result
    }
    


}





//    func forceLayoutContent() {
//
////        if let model = currentCardModel {
////
////            var cardLayout = ClassicalCardLayout(WithContents: cardContents)
////            cardLayout.layout(Model: model, InsideRect: self.bounds, Sideways: sideWays)
////        }
//
//    }
//


//    func newCardToView(newCard: LWCard, Sideways side: Bool) {
//
//        sideWays = side
//        clearCurrentOrientation()
//        pastCards.append(currentCard)
//        currentCard = newCard
//        determineCardOrientation()
//    }
//
//
//    func clearCurrentOrientation() {
//
//        for label in activeLabels {
//            label.removeFromSuperview()
//        }
//
//        activeLabels = Array()
//    }
//
//
//    func determineCardOrientation() {
//
//        switch currentCard.rank {
//        case 1:
//
//            oneRow(single())
//            break
//
//        case 2:
//
//            twoRows(single(), RowTwo: single())
//            break
//
//        case 3:
//
//            threeRows(single(), RowTwo: single(), RowThree: single())
//            break
//
//        case 4:
//
//            twoRows(horizontalDouble(), RowTwo: horizontalDouble())
//            break
//
//        case 5:
//
//            threeRows(horizontalDouble(), RowTwo: single(), RowThree: horizontalDouble())
//            break
//
//        case 6:
//
//            threeRows(horizontalDouble(), RowTwo: horizontalDouble(), RowThree: horizontalDouble())
//            break
//
////        case 7:
////
////
////        case 8:
////
////        case 9:
////
////        case 10:
////
////        case 11, 12, 13, 14:
//
//        default:
//            print("hit default")
//            break
//
//        }
//    }
//
//
//    //Card Orientations
//
//    func single() -> UILabel {
//        //# (ex. ace, 2, 3, 5, 7, 8, 9, 10
//        let singleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: labelHeight))
//        singleLabel.text = currentCard.suit
//        singleLabel.textAlignment = .Center
//        singleLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin]
//
//        if sideWays {
//            singleLabel.transform = CGAffineTransformRotate(singleLabel.transform, CGFloat(M_PI * 0.5))
//
//        }
//
//        return singleLabel
//    }
//
//    func horizontalDouble() -> UILabel {
//        // # # (ex. 4, 5, 6, 7, 8, 9, 10)
//        let doubleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: labelHeight))
//        doubleLabel.text = "\(currentCard.suit) \t\t \(currentCard.suit)"
//        doubleLabel.textAlignment = .Center
//        doubleLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin]
//
//        if sideWays {
//            doubleLabel.transform = CGAffineTransformRotate(doubleLabel.transform, CGFloat(M_PI * 0.5))
//
//        }
//
//        return doubleLabel
//    }
//
//    func halfWidth() -> CGFloat {
//        return (sideWays ? self.bounds.size.height / 2 : self.bounds.size.width / 2)
//        //return self.bounds.size.height / 2
//        //return self.bounds.size.width / 2
//    }
//
//    func heightDividedInto(sections: CGFloat) -> CGFloat {
//        return (sideWays ? self.bounds.size.width / sections : self.bounds.size.height / sections)
//        //return self.bounds.size.width / sections
//        //return self.bounds.size.height / sections
//    }
//
//    //Every card has a certain number of rows. each row has either a single or horizontal double
//
//    func oneRow<T: UIView>(atRowOne: T) {
//
//        let halfHeight = heightDividedInto(2.0);
//
//        if sideWays {
//            atRowOne.center = CGPoint(x: halfHeight, y: halfWidth())
//        } else {
//            atRowOne.center = CGPoint(x: halfWidth(), y: halfHeight)
//        }
//
//        activeLabels.append(atRowOne)
//        self.addSubview(atRowOne)
//    }
//
//    func twoRows<T: UIView>(atRowOne: T, RowTwo atrowTwo: T) {
//
//        let quarterHeight = heightDividedInto(4)
//
//        if sideWays {
//            atRowOne.center = CGPoint(x: quarterHeight, y: halfWidth())
//            atrowTwo.center = CGPoint(x: quarterHeight * 3, y: halfWidth())
//        } else {
//            atRowOne.center = CGPoint(x: halfWidth(), y: quarterHeight)
//            atrowTwo.center = CGPoint(x: halfWidth(), y: quarterHeight * 3)
//        }
//
//        activeLabels.append(atRowOne)
//        activeLabels.append(atrowTwo)
//
//        self.addSubview(atRowOne)
//        self.addSubview(atrowTwo)
//    }
//
//    func threeRows<T: UIView>(atRowOne: T, RowTwo atrowTwo: T, RowThree atrowThree: T) {
//
//        let sixHeight = heightDividedInto(6)
//
//        if sideWays {
//            atRowOne.center = CGPoint(x: sixHeight, y: halfWidth())
//            atrowTwo.center = CGPoint(x: sixHeight * 3, y: halfWidth())
//            atrowThree.center = CGPoint(x: sixHeight * 5, y: halfWidth())
//        } else {
//            atRowOne.center = CGPoint(x: halfWidth(), y: sixHeight)
//            atrowTwo.center = CGPoint(x: halfWidth(), y: sixHeight * 3)
//            atrowThree.center = CGPoint(x: halfWidth(), y: sixHeight * 5)
//        }
//
//        activeLabels.append(atRowOne)
//        activeLabels.append(atrowTwo)
//        activeLabels.append(atrowThree)
//
//        self.addSubview(atRowOne)
//        self.addSubview(atrowTwo)
//        self.addSubview(atrowThree)
//
//    }
//
//    func fourRows<T: UIView>(atRowOne: T, RowTwo atrowTwo: T, RowThree atrowThree: T, RowFour atrowFour: T) {
//
//    }
//
//    func fiveRows<T: UIView>(atRowOne: T, RowTwo atrowTwo: T, RowThree atrowThree: T, RowFour atrowFour: T, RowFive atrowFive: T) {
//
//    }
//
//    func sixRows<T: UIView>(atRowOne: T, RowTwo atrowTwo: T, RowThree atrowThree: T, RowFour atrowFour: T, RowFive atrowFive: T, RowSix atrowSix: T) {
//
//    }


//        if side {
//            cardTopLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
//            cardTopLabel.frame = CGRectMake(labelFrameWidth, 0, labelFrameWidth, labelFrameHeight)
//            cardBottomLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) / 2)
//            cardBottomLabel.frame = CGRectMake(frame.width - labelFrameHeight, frame.height, labelFrameWidth, labelFrameHeight)
//        } else {
//            cardTopLabel.frame = CGRectMake(0, 0, labelFrameWidth, labelFrameHeight)
//            cardBottomLabel.frame = CGRectMake(frame.width - labelFrameWidth, frame.height - labelFrameHeight, labelFrameWidth, labelFrameHeight)
//        }


