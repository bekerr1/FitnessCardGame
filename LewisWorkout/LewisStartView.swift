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
    @IBOutlet weak var selectStageLabel: UILabel!
    
    @IBOutlet weak var blurVisualView: UIVisualEffectView!
    
    var crackedClubImage: UIImage!
    var crackedSpadeImage: UIImage!
    var wornHeartImage: UIImage!
    var wornDiamondImage: UIImage!
    
    var clubImageView: UIImageView!
    var spadeImageView: UIImageView!
    var heartImageView: UIImageView!
    var diamondImageView: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        print(#function)
        topCircleShape = CAShapeLayer()
        bottomCircleShape = CAShapeLayer()
        startButton = UIButton(type: UIButtonType.RoundedRect)
        toplabel = UILabel(frame: CGRectMake(0, 0, 300, 80))
        bottomLabel = UILabel(frame: CGRectMake(0, 0, 300, 80))
        blurVisualView = UIVisualEffectView()
        super.init(coder: aDecoder)
        setupUIElements()
    }
    
//    override init(frame: CGRect) {
//        print(#function)
//        topCircleShape = CAShapeLayer()
//        bottomCircleShape = CAShapeLayer()
//        startButton = UIButton(type: UIButtonType.RoundedRect)
//        toplabel = UILabel(frame: CGRectMake(0, 0, 300, 20))
//        bottomLabel = UILabel(frame: CGRectMake(0, 0, 300, 20))
//        super.init(frame: frame)
//        setupUIElements()
//    }
    
    func setupUIElements() {
        
        crackedClubImage = UIImage(named:"CrackingClub")
        crackedSpadeImage = UIImage(named:"CrackingSpade")
        wornHeartImage = UIImage(named:"WornHeart")
        wornDiamondImage = UIImage(named:"WornDiamond")
        
        clubImageView = UIImageView(image: crackedClubImage)
        spadeImageView = UIImageView(image: crackedSpadeImage)
        heartImageView = UIImageView(image: wornHeartImage)
        diamondImageView =  UIImageView(image: wornDiamondImage)
    }
    
    
    //MARK: Configure
    
    func configure() {
        
        configureLayerShapes()
        configureStartButton()
        configureLabels()
        configureSuits()
    }
    
    
    func configureLayerShapes() {
        
        let topCircle = UIBezierPath(arcCenter: CGPointMake(self.frame.width/2, 280), radius: 400, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        
        let bottomCircle = UIBezierPath(arcCenter: CGPointMake(self.frame.width/2, self.frame.height + 280), radius: 400, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        
        topCircleShape.path = topCircle.CGPath
        topCircleShape.fillColor = UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor
        
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
    
    func configureSuits() {
        
//        suitsHiddenAndOffScreen()

        clubImageView.hidden = true
        spadeImageView.hidden = true
        heartImageView.hidden = true
        diamondImageView.hidden = true

        self.addSubview(clubImageView)
        self.addSubview(spadeImageView)
        self.addSubview(heartImageView)
        self.addSubview(diamondImageView)
    }
    

    func suitsHiddenAndOffScreen() {

        clubImageView.hidden = true
        spadeImageView.hidden = true
        heartImageView.hidden = true
        diamondImageView.hidden = true
        
        let imagesHeight = clubImageView.frame.size.height
        let horizontalSpacing = CGRectGetWidth(self.bounds) / 4.0
        let startVerticalPos = CGRectGetHeight(self.bounds) + imagesHeight / 2.0
        
        var centerX = horizontalSpacing / 2.0
        
        clubImageView.center = CGPointMake(centerX, startVerticalPos )
        centerX += horizontalSpacing
        spadeImageView.center = CGPointMake(centerX, startVerticalPos )
        centerX += horizontalSpacing
        heartImageView.center = CGPointMake(centerX, startVerticalPos )
        centerX += horizontalSpacing
        diamondImageView.center = CGPointMake(centerX, startVerticalPos )
    }
    
    
    
    func startButtonTapped() {
        
        // Start button dismiss
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseInOut, animations: {() -> Void in
            
            self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height - 210)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
                        
                        self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height + 100)
                        
                        }, completion: {(completed: Bool) -> Void in
                            
                            print("Button Animated")
                            self.startButton.removeFromSuperview()
                            self.startLayerAnimations()
                            self.animateBlurAway()
                    })

                }
        })
        
        
        // Labels dismiss
        
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseInOut, animations: {() -> Void in
            
            self.toplabel.center = CGPointMake(self.frame.width/2 + 20, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
            self.bottomLabel.center = CGPointMake(self.frame.width/2 - 20, self.frame.height/2 - self.labelHeightOffset)
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {() -> Void in
                        
                        self.toplabel.center = CGPointMake(-self.toplabel.frame.width/2, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
                        self.bottomLabel.center = CGPointMake(self.frame.width+self.bottomLabel.frame.width/2, self.frame.height/2 - self.labelHeightOffset)
                        
                        }, completion: {(completed: Bool) -> Void in
                            
                            self.startButton.removeFromSuperview()
                    })
                    
                } else {
                    
                    self.toplabel.center = CGPointMake(-self.toplabel.frame.width/2, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
                    self.bottomLabel.center = CGPointMake(self.frame.width+self.bottomLabel.frame.width/2, self.frame.height/2 - self.labelHeightOffset)
                    self.startButton.removeFromSuperview()
                }
        })
        
        
        // TODO: suits
        
        

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
    
    
    func animateBlurAway() {
        
        UIView.animateWithDuration(1.5, delay: 0.0, options: .CurveLinear, animations: {
            
            self.blurVisualView.alpha = 0.0
            
            } , completion: {
                (completed: Bool) in
                
                self.selectStageLabel.hidden = false
                self.blurVisualView.hidden = true
        })
    }
    
}



// MARK: programmedAnimation extension

extension LewisStartView {
    
    func programmedAnimation() {

        suitsHiddenAndOffScreen()

        startButton.hidden = true
        toplabel.hidden = true
        bottomLabel.hidden = true

        startButton.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds) + 100)
        toplabel.center = CGPointMake(-toplabel.frame.width/2, CGRectGetHeight(self.bounds)/2 - labelDistance - labelHeightOffset)
        bottomLabel.center = CGPointMake(CGRectGetWidth(self.bounds) + bottomLabel.frame.width/2, CGRectGetHeight(self.bounds)/2 - labelHeightOffset)


        func labels() {
            let delaySeconds = 0.5
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.programmedAnimateLabelsToPosition()
            }
        }
        
        func suits() {
            let delaySeconds = 1.5
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.programmedAnimateSuitsToPosition()
            }
        }
        
        func buttons() {
            let delaySeconds = 3.0
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.programmedAnimateButtonToPosition()
            }
        }
        
        startButton.hidden = false
        toplabel.hidden = false
        bottomLabel.hidden = false

        labels()
        suits()
        buttons()
    }
    
    
    func programmedAnimateLabelsToPosition() {

        let topFinalPosition = CGPointMake(self.frame.width/2, self.frame.height/2 - self.labelDistance - self.labelHeightOffset)
        let bottomFinalPosition = CGPointMake(self.frame.width/2, self.frame.height/2 - self.labelHeightOffset)
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.toplabel.center = topFinalPosition
            
            }, completion: {(completed: Bool) -> Void in
                
                if completed {
                    print("toplable Animated")
                    UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
                        
                        self.bottomLabel.center = bottomFinalPosition
                        
                        }, completion: nil)
                }
        })
    }
    
    
    func programmedAnimateSuitsToPosition() {
        
        // Hide and set Start OFF screen
        
        let imagesHeight = clubImageView.frame.size.height
        let horizontalSpacing = CGRectGetWidth(self.bounds) / 4.0
        let finalVerticalPos = CGRectGetHeight(self.bounds) - imagesHeight / 2.0
        
        var centerX = horizontalSpacing / 2.0
        
        //        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseInOut, animations: {() -> Void in
        
        
        clubImageView.hidden = false
        spadeImageView.hidden = false
        heartImageView.hidden = false
        diamondImageView.hidden = false
        
        centerX = horizontalSpacing / 2.0
        
        let totalDuration = 0.5
        
        UIView.animateWithDuration(1.0, delay: totalDuration * 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.clubImageView.center = CGPointMake(centerX, finalVerticalPos )
            }, completion: nil)
        
        centerX += horizontalSpacing
        
        UIView.animateWithDuration(1.0, delay: totalDuration * 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.spadeImageView.center = CGPointMake(centerX, finalVerticalPos )
            }, completion: nil)
        
        
        centerX += horizontalSpacing
        
        UIView.animateWithDuration(1.0, delay: totalDuration * 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.heartImageView.center = CGPointMake(centerX, finalVerticalPos )
            }, completion: nil)
        
        
        centerX += horizontalSpacing
        
        UIView.animateWithDuration(1.0, delay: totalDuration * 1.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.diamondImageView.center = CGPointMake(centerX, finalVerticalPos )
            }, completion: nil)
        
    }
    
    func programmedAnimateButtonToPosition() {
        
        //        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseInOut, animations: {() -> Void in
        //
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() -> Void in
            
            self.startButton.center = CGPointMake(self.frame.width/2, self.frame.height - 180)
            
            }, completion: nil)
    }
    
}




















