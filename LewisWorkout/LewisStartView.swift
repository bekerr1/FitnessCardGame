//
//  LewisStartView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/10/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisStartView: UIView {
    
    let labelHeightOffset: CGFloat = 80
    let labelDistance: CGFloat = 40
    
    let topCircleShape: CAShapeLayer
    let bottomCircleShape: CAShapeLayer
    let startButton: UIButton
    let toplabel: UILabel
    let bottomLabel: UILabel
    
    var crackedClubImage: UIImage!
    var crackedSpadeImage: UIImage!
    var wornHeartImage: UIImage!
    var wornDiamondImage: UIImage!
    
    
    required init?(coder aDecoder: NSCoder) {
        print(#function)
        topCircleShape = CAShapeLayer()
        bottomCircleShape = CAShapeLayer()
        startButton = UIButton(type: UIButtonType.RoundedRect)
        toplabel = UILabel(frame: CGRectMake(0, 0, 300, 80))
        bottomLabel = UILabel(frame: CGRectMake(0, 0, 300, 80))
        
        super.init(coder: aDecoder)
        
    }
    
    
    override init(frame: CGRect) {
        print(#function)
        topCircleShape = CAShapeLayer()
        bottomCircleShape = CAShapeLayer()
        startButton = UIButton(type: UIButtonType.RoundedRect)
        toplabel = UILabel(frame: CGRectMake(0, 0, 300, 20))
        bottomLabel = UILabel(frame: CGRectMake(0, 0, 300, 20))
        
        super.init(frame: frame)
    }
    
    
    func configureLayerShapes() {
        
        
        let topCircle = UIBezierPath(arcCenter: CGPointMake(self.frame.width/2, 280), radius: 400, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        
        let bottomCircle = UIBezierPath(arcCenter: CGPointMake(self.frame.width/2, self.frame.height + 280), radius: 400, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        
        topCircleShape.path = topCircle.CGPath
        topCircleShape.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor
        
        bottomCircleShape.path = bottomCircle.CGPath
        bottomCircleShape.fillColor = UIColor.blackColor().CGColor
        
        print(NSStringFromCGPoint(bottomCircleShape.position))
        self.layer.addSublayer(bottomCircleShape)
        self.layer.addSublayer(topCircleShape)
    }
    
    func configureStartButton() {
        
        
        startButton.frame = CGRectMake(0, 0, 150, 60)
        startButton.center = CGPointMake(self.frame.width/2, self.frame.height + 100)
        startButton.setTitle("Start Workout", forState: .Normal)
        startButton.backgroundColor = UIColor.blackColor()
        print(startButton.titleLabel?.font.fontName)
        startButton.titleLabel?.font = UIFont(name: ".SFUIText-Regular", size: 18)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.layer.cornerRadius = 10.0
        
        startButton.addTarget(self, action: #selector(startButtonTapped), forControlEvents: .TouchUpInside)
        
        self.addSubview(startButton)
        
    }
    
    func configureLabels() {
        
        toplabel.text = "Push-up"
        toplabel.textAlignment = .Center
        toplabel.textColor = UIColor.whiteColor()
        toplabel.font = UIFont(name: "Futura-CondensedExtraBold", size: 30)
        let fontNames = UIFont.fontNamesForFamilyName("Futura")
        for name in fontNames {
            print(name)
        }
        toplabel.center = CGPointMake(-toplabel.frame.width/2, self.frame.height/2 - labelDistance - labelHeightOffset)
        //toplabel.backgroundColor = UIColor.redColor()
        
        bottomLabel.text = "Card Game"
        bottomLabel.textAlignment = .Center
        bottomLabel.font = UIFont(name: "Futura-CondensedExtraBold", size: 30)
        bottomLabel.textColor = UIColor.whiteColor()
        bottomLabel.center = CGPointMake(self.frame.width+bottomLabel.frame.width/2, self.frame.height/2 - labelHeightOffset)
        //bottomLabel.backgroundColor = UIColor.redColor()
        
        
        self.addSubview(toplabel)
        self.addSubview(bottomLabel)
        
    }
    
    func animateLabelsToPosition() {
        
        
        UIView.animateWithDuration(1.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.toplabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    print("toplable Animated")
                    UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
                        
                        self.bottomLabel.center = CGPointMake(self.frame.width/2, self.frame.height/2 - self.labelHeightOffset)
                        
                        }, completion: {(completed: Bool) -> Void in
                            
                            if completed {
                                print("bottomlabel Animated")
                            }
                    })

                }
        })
        
        
    }
    
    
    func animateButtonToPosition() {
        
//        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseInOut, animations: {() -> Void in
//            
//            self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height - 200)
//            
//            }, completion: {(completed: Bool) -> Void in
//                
//                if completed {
//                    print("Button Animated")
//                }
//        })
        
        UIView.animateWithDuration(1.0, delay: 4.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height - 180)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    print("Button Animated")
                }
        })

    }
    
    
    func startButtonTapped() {
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseInOut, animations: {() -> Void in
            
            self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height - 210)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
                        
                        self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height + 100)
                        
                        }, completion: {(completed: Bool) -> Void in
                            
                            if completed {
                                print("Button Animated")
                                self.startButton.removeFromSuperview()
                                self.startLayerAnimations()
                            }
                    })

                }
        })
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseInOut, animations: {() -> Void in
            
            self.toplabel.center = CGPointMake(self.frame.width/2 + 20, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
            self.bottomLabel.center = CGPointMake(self.frame.width/2 - 20, self.frame.height/2 - self.labelHeightOffset)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
                        
                        self.toplabel.center = CGPointMake(-self.toplabel.frame.width/2, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
                        self.bottomLabel.center = CGPointMake(self.frame.width+self.bottomLabel.frame.width/2, self.frame.height/2 - self.labelHeightOffset)
                        
                        }, completion: {(completed: Bool) -> Void in
                            
                            if completed {
                                print("Button Animated")
                                self.startButton.removeFromSuperview()
                                
                            }
                    })
                    
                }
        })

        
    }
    
    
    func startLayerAnimations() {
        
        
        let upperPositionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        upperPositionAnimation.fromValue = topCircleShape.valueForKey("position")
        let pointToEndUpper = CGPointMake(0, -635)
        upperPositionAnimation.toValue = NSValue.init(CGPoint: pointToEndUpper)
        upperPositionAnimation.duration = 0.5
        topCircleShape.position = pointToEndUpper
        
        topCircleShape.addAnimation(upperPositionAnimation, forKey: "position")

        let lowerPositionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        lowerPositionAnimation.fromValue = bottomCircleShape.valueForKey("position")
        let pointToEndLower = CGPointMake(0, 80)
        lowerPositionAnimation.toValue = NSValue.init(CGPoint: pointToEndLower)
        lowerPositionAnimation.duration = 0.5
        bottomCircleShape.position = pointToEndLower
        
        bottomCircleShape.addAnimation(lowerPositionAnimation, forKey: "position")
    }
}


















