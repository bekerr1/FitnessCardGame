//
//  LewisClassicalCardShapes.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit


protocol Shapeable  {
    
    associatedtype Shape
    func thisShape() -> Shape
    func place(AtPoint point: CGPoint)
    func rotateBy(amount: CGFloat)
    func scaleBy(amount: CGFloat)
    func addNewAnimationToShape(animation: CAAnimation, ForKey key: String)
    func removeAnimationFromShapeWithKey(key: String)
    func removeShapeFromSuperView()
}

struct Shape<T : Shapeable> {
    var shape: T
    init(WithShape sh: T) {
        shape = sh
    }
}

extension UIImageView : Shapeable {
    
    typealias Shape = UIImageView
    
    func thisShape() -> Shape {
        return self
    }
    
    func place(AtPoint point: CGPoint) {
        self.center = point
    }
    
    func rotateBy(amount: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: amount)
    }
    
    func scaleBy(amount: CGFloat) {
        self.transform = CGAffineTransform(scaleX: amount, y: amount)
    }
    
    func addNewAnimationToShape(animation: CAAnimation, ForKey key: String) {
        self.layer.add(animation, forKey: key)
    }
    
    func removeAnimationFromShapeWithKey(key: String) {
        self.layer.removeAnimation(forKey: key)
    }
    
    func removeShapeFromSuperView() {
        self.removeFromSuperview()
    }
}
