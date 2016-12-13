//
//  LewisClassicalCard.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


//struct ClassicCard : Layout {
//    
//    
//    let cardToModel: LewisCard
//    var cardContents: [CAShapeLayer] = Array()
//    var cardCounter = 0
//    var cardContentShape: CAShapeLayer!
//    
//    var suitSize: CGSize
//    let suitSizeWidth: CGFloat = 80
//    let suitSizeHeight: CGFloat = 80
//    var rectSection: CGSize!
//    var offsets: [CGFloat]!
//    
//
//    //MARK: Init
//    
//    init(WithCard card: LewisCard) {
//        
//        cardToModel = card
//        suitSize = CGSizeMake(suitSizeWidth, suitSizeHeight)
//        modelClassicCard()
//    }
//    
//    init(WithCard card: LewisCard, SuitSize ss: CGSize) {
//        
//        cardToModel = card
//        suitSize = ss
//        modelClassicCard()
//    }
//    
//    
//    
//    
//    mutating func decrementCounter() {
//        
//        cardCounter -= 1
//    }
//    
//    
//
//    
//    //MARK: Shape blueprints
//    
//    mutating func modelClassicCard() {
//        
//        switch cardToModel.suit {
//        case .Club:
//            //clubstruct
//            break
//        case .Heart:
//            
//            let bottomPoint = CGPointMake(suitSize.width / 2, suitSize.height)
//            let leftControl = CGPointMake(suitSize.width / 6, suitSize.height / 6)
//            let topPoint = CGPointMake(suitSize.width / 2, suitSize.height / 2)
//            let rightControl = CGPointMake((suitSize.width / 6) * 5, (suitSize.height / 6) * 5)
//            
//            print("\(NSStringFromCGPoint(bottomPoint)), \(NSStringFromCGPoint(leftControl)), \(NSStringFromCGPoint(topPoint)), \(NSStringFromCGPoint(rightControl))")
//            
//            let heartDesign = HeartDesign(bottomPoint, leftControl, topPoint, rightControl)
//            
//            let heartShape = Heart(WithDesign: heartDesign)
//            let heartShapeLayer = CAShapeLayer()
//            heartShapeLayer.path = heartShape.drawWithPath()
//            
//            cardContentShape = heartShapeLayer
//            fillCardContentsWithShape(heartShapeLayer)
//            break
//            
//        case .Spade:
//            
//            break
//            
//        case .Diamond:
//            
//            break
//            
//        case .Joker:
//            
//            break
//            
//        default:
//            //default
//            break
//        }
//    }
//    
//    
//    mutating func fillCardContentsWithShape(shape: CAShapeLayer) {
//        
//        for _ in 0..<cardToModel.rank.rawValue {
//            
//            let shapeReference = shape
//            cardContents.append(shapeReference)
//            cardCounter += 1
//        }
//    }
//    
//    
//    
//    //MARK: Utilities for where to place each shape
//    
//    func placementPointOffsets() -> [CGFloat] {
//        
//        switch cardToModel.rank.rowsForRank {
//        case 1:
//            return [0, 0, 3, 0, 0, 0]
//        case 2:
//            return [1, 0, 0, 0, 5, 0]
//        case 3:
//            return [1, 0, 3, 0, 5, 0]
//        case 4:
//            return [1, 2, 3, 0, 5, 0]
//        case 5:
//            return [1, 2, 3, 4, 5, 0]
//        case 6:
//            return [1, 2, 3, 5, 6, 7]
//        default:
//            print("defualt")
//            return []
//        }
//    }
//    
//    func rectSections(rectSize: CGSize) -> CGSize {
//        
//        if cardToModel.rank.rawValue < 9 {
//            return CGSizeMake(rectSize.width/2, rectSize.height/6)
//        } else if cardToModel.rank.rawValue == 9 || cardToModel.rank.rawValue == 10  {
//            return CGSizeMake(rectSize.width/2, rectSize.height/8)
//        } else {
//            return CGSizeZero
//        }
//    }
//    
//    
//    
//}








