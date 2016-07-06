//
//  LewisClassicalCard.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


struct ClassicCard : Layout {
    
    
    let cardToModel: LewisCard
    var cardContents: [CAShapeLayer] = Array()
    var cardCounter = 0
    var cardContentShape: CAShapeLayer!
    
    var suitSize: CGSize
    let suitSizeWidth: CGFloat = 80
    let suitSizeHeight: CGFloat = 80
    var rectSection: CGSize!
    var offsets: [CGFloat]!
    

    //MARK: Init
    
    init(WithCard card: LewisCard) {
        
        cardToModel = card
        suitSize = CGSizeMake(suitSizeWidth, suitSizeHeight)
        modelClassicCard()
    }
    
    init(WithCard card: LewisCard, SuitSize ss: CGSize) {
        
        cardToModel = card
        suitSize = ss
        modelClassicCard()
    }
    
    //MARK: Layout protocol
    
    mutating func layout(rect: CGRect) {
        //Layout in given rect
        self.rectSection = rectSections(rect.size)
        self.offsets = placementPointOffsets()
        
        switch cardToModel.rank {
        case .Ace:
            
            
            newRowFormatter(FirstRow: empty,
                            SecondRow: empty,
                            ThirdRow: single,
                            FourthRow: empty,
                            FifthRow: empty,
                            SixthRow: empty)
            
            break
            
        case .Two:
            
            newRowFormatter(FirstRow: single,
                            SecondRow: empty,
                            ThirdRow: empty,
                            FourthRow: empty,
                            FifthRow: single,
                            SixthRow: empty)
            break
            
        case .Three:
            
            newRowFormatter(FirstRow: single,
                            SecondRow: empty,
                            ThirdRow: single,
                            FourthRow: empty,
                            FifthRow: single,
                            SixthRow: empty)
            
            break
            
        case .Four:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: empty,
                            ThirdRow: empty,
                            FourthRow: empty,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
            
        case .Five:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: empty,
                            ThirdRow: single,
                            FourthRow: empty,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
            
        case .Six:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: empty,
                            ThirdRow: horizontalDouble,
                            FourthRow: empty,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
            
        case .Seven:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: single,
                            ThirdRow: horizontalDouble,
                            FourthRow: empty,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
            
        case .Eight:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: single,
                            ThirdRow: horizontalDouble,
                            FourthRow: single,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
            
        case .Nine:
            
            newRowFormatter(FirstRow: horizontalDouble,
                            SecondRow: horizontalDouble,
                            ThirdRow: single,
                            FourthRow: horizontalDouble,
                            FifthRow: horizontalDouble,
                            SixthRow: empty)
            break
        default: break
            //defualt
        }
        
        
    }
    
    
    //MARK: Layout formatts
    
    mutating func newRowFormatter(FirstRow row1: (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer], SecondRow row2:
        (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer], ThirdRow row3:
        (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer], FourthRow row4:
        (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer], FifthRow row5:
        (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer], SixthRow row6:
        (atWidth: CGFloat, atHeight: CGFloat) -> [CAShapeLayer]) {
        
        var rowAccumulator: [CAShapeLayer] = Array()
        
        let first = row1(atWidth: rectSection.width, atHeight: heightForRow(1))
        rowAccumulator += first
        let second = row2(atWidth: rectSection.width, atHeight: heightForRow(2))
        rowAccumulator += second
        let third = row3(atWidth: rectSection.width, atHeight: heightForRow(3))
        rowAccumulator += third
        let fourth = row4(atWidth: rectSection.width, atHeight: heightForRow(4))
        rowAccumulator += fourth
        let fifth = row5(atWidth: rectSection.width, atHeight: heightForRow(5))
        rowAccumulator += fifth
        let sixth = row6(atWidth: rectSection.width, atHeight: heightForRow(6))
        rowAccumulator += sixth
        
        cardContents = rowAccumulator
        
    }
    
    
    func heightForRow(row: Int) -> CGFloat {
        
        return rectSection.height * offsets[row - 1]
    }
    
    
    
    
    func horizontalDouble(atWidth: CGFloat, Height atHeight: CGFloat) -> [CAShapeLayer] {
        
        //let leftShape: CAShapeLayer = cardContentShape.mutableCopy() as! CAShapeLayer
        //let rightShape: CAShapeLayer = cardContentShape.mutableCopy() as! CAShapeLayer
        
        let leftShape = cardContents[cardCounter-1]
        
        let rightShape = cardContents[cardCounter-1]
        
        leftShape.position = CGPointMake(atWidth - 50, atHeight)
        rightShape.position = CGPointMake(atWidth + 50, atHeight)
        
        return [leftShape, rightShape]
    }
    
    func single(atWidth: CGFloat, Height atHeight: CGFloat) -> [CAShapeLayer] {
        
        //let singleShape: CAShapeLayer = cardContentShape.mutableCopy() as! CAShapeLayer
        
        let singleShape = cardContents[cardCounter]
        cardCounter - 1
        singleShape.position = CGPointMake(atWidth, atHeight)
        return [singleShape]
    }
    
    func empty(atWidth: CGFloat, Height atHeight: CGFloat) -> [CAShapeLayer] {
        
        return []
    }
    
    
    mutating func decrementCounter() {
        
        cardCounter -= 1
    }
    
    

    
    //MARK: Shape blueprints
    
    mutating func modelClassicCard() {
        
        switch cardToModel.suit {
        case .Club:
            //clubstruct
            break
        case .Heart:
            
            let bottomPoint = CGPointMake(suitSize.width / 2, suitSize.height)
            let leftControl = CGPointMake(suitSize.width / 6, suitSize.height / 6)
            let topPoint = CGPointMake(suitSize.width / 2, suitSize.height / 2)
            let rightControl = CGPointMake((suitSize.width / 6) * 5, (suitSize.height / 6) * 5)
            
            print("\(NSStringFromCGPoint(bottomPoint)), \(NSStringFromCGPoint(leftControl)), \(NSStringFromCGPoint(topPoint)), \(NSStringFromCGPoint(rightControl))")
            
            let heartDesign = HeartDesign(bottomPoint, leftControl, topPoint, rightControl)
            
            let heartShape = Heart(WithDesign: heartDesign)
            let heartShapeLayer = CAShapeLayer()
            heartShapeLayer.path = heartShape.drawWithPath()
            
            cardContentShape = heartShapeLayer
            fillCardContentsWithShape(heartShapeLayer)
            break
            
        case .Spade:
            
            break
            
        case .Diamond:
            
            break
            
        case .Joker:
            
            break
            
        default:
            //default
            break
        }
    }
    
    
    mutating func fillCardContentsWithShape(shape: CAShapeLayer) {
        
        for _ in 0..<cardToModel.rank.rawValue {
            
            let shapeReference = shape
            cardContents.append(shapeReference)
            cardCounter += 1
        }
    }
    
    
    
    //MARK: Utilities for where to place each shape
    
    func placementPointOffsets() -> [CGFloat] {
        
        switch cardToModel.rank.rowsForRank {
        case 1:
            return [0, 0, 3, 0, 0, 0]
        case 2:
            return [1, 0, 0, 0, 5, 0]
        case 3:
            return [1, 0, 3, 0, 5, 0]
        case 4:
            return [1, 2, 3, 0, 5, 0]
        case 5:
            return [1, 2, 3, 4, 5, 0]
        case 6:
            return [1, 2, 3, 5, 6, 7]
        default:
            print("defualt")
            return []
        }
    }
    
    func rectSections(rectSize: CGSize) -> CGSize {
        
        if cardToModel.rank.rawValue < 9 {
            return CGSizeMake(rectSize.width/2, rectSize.height/6)
        } else if cardToModel.rank.rawValue == 9 || cardToModel.rank.rawValue == 10  {
            return CGSizeMake(rectSize.width/2, rectSize.height/8)
        } else {
            return CGSizeZero
        }
    }
    
    
    
}








