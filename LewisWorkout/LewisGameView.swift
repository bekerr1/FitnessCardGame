//
//  LewisGameView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//


/*
 This view splits up functionality into extensions.  The meat of the view, basically everything that has to do with start up and "restarting" is contained inside the main class.  Extra functionality is then dispersed into extensions with marks at the top.  Gives the property/method selector a cool look, i think.
 
 
 */
import UIKit

//MARK: Callback Protocol
protocol GameViewCallBackDelegate {
    func deviceIsOriented() -> Bool
    func cardAnimationComplete()
    func startPreviewSession()
    func getShape(AtIndex index: Int) -> UIImageView
    func getShapeCenter(ForShape shape: UIImageView, InView view: UIView) -> CGPoint
    func currentCardBeingDisplayed() -> LewisCard
    func cardAboutToBeShown() -> LewisCard
}


class LewisGameView: UIView, DetectorClassProtocol {
    
    //MARK: Properties
    var callBack: GameViewCallBackDelegate?
    var shadowLayer: CALayer = CALayer()
    let widthOffset: CGFloat = 0
    let heightOffset: CGFloat = 210
    private let calibrateLabel: UILabel = UILabel()
    var alignmentCenterPoint: CGPoint = CGPointZero
    //Subviews
    @IBOutlet weak var stageImageView: UIImageView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var currentCardContainer: UIView!
    @IBOutlet weak var deckViewContainer: UIView!
    @IBOutlet weak var deckPlaceholderView: LewisDeckPlaceholderView!
    private var calibrateSlider: LWAnimatedSlider = LWAnimatedSlider()
    var invisibleTopView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    
    lazy var imageDisplayView: UIImageView = {
        
        let aview = UIImageView()
        aview.backgroundColor = UIColor.redColor()
        return aview
    }()
    
    let blankFaceImage: UIImage = UIImage(named: "blankFace")!
    
    //SubLayers
    var alignmentLayer: CALayer = CALayer()
    
    //StackViewProperties
    @IBOutlet weak var pushupCountLabel: UILabel!
    @IBOutlet weak var currentCardLabel: UILabel!
    @IBOutlet weak var cardsCompletedLabel: UILabel!
    @IBOutlet weak var totalCardsCompletedLabel: UILabel!
    var totalCardsCompletedCount: Int = 0
    @IBOutlet weak var currentPushupCountLabel: UILabel!
    var currentPushupCount: Int = 0
    @IBOutlet weak var pushupsCompletedLabel: UILabel!
    var totalPushupsCompletedCount: Int = 0
    //GESTURES
    var deckTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    
    //MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func drawRect(rect: CGRect) {}
    
    //MARK: Setup
    func viewGestures() {
        
        let deckTapDesture = UITapGestureRecognizer(target: self, action: #selector(deckTap))
        deckTapGesture = deckTapDesture
        let deckGestures = [deckTapGesture]
        deckPlaceholderView.gestureRecognizers = deckGestures

    }
    
    func setupFrameDependentElements() {
        configureShadowLayer()
        configureCalibrateLabel()
        deckPlaceholderView.createStackEffect()
        configureAlignment()
        prepareView()
    }
    
    func prepareView() {
        labelStackView.alpha = 0.0
        currentCardContainer.alpha = 0.0
        deckViewContainer.alpha = 0.0
    }
    
    func configureShadowLayer() {
        print("Game view frame: \(NSStringFromCGRect(self.frame))")
        
        shadowLayer.frame = CGRectMake(0, 0, self.frame.width - widthOffset, self.frame.height - heightOffset)
        shadowLayer.position = CGPointMake(self.frame.width/2, self.frame.height/2 - 75)
        shadowLayer.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5).CGColor
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowRadius = 1.0
        shadowLayer.shadowOffset = CGSizeMake(0.0, 15.0)
        shadowLayer.masksToBounds = false
        self.layer.insertSublayer(shadowLayer, below: currentCardContainer.layer)
        
    }
    
    func configureCalibrateSlider() {
        
        calibrateSlider.frame = CGRect(x: -35, y: 450,
                                       width: 150, height: 61)
        calibrateSlider.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        calibrateSlider.layer.cornerRadius = 10.0
        calibrateSlider.configLayerFrames()
        calibrateSlider.layer.borderColor = UIColor.blackColor().CGColor
        calibrateSlider.layer.borderWidth = 1.0
        calibrateSlider.horizontal = false
        calibrateSlider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 0.5)
        addSubview(calibrateSlider)
    }
    
    func configureAlignment() {
        
        let dataTapGesture = UITapGestureRecognizer(target: self, action: #selector(simulatePushup))
        invisibleTopView.gestureRecognizers = [dataTapGesture]
        
        alignmentLayer.contents = blankFaceImage.CGImage
        alignmentLayer.hidden = true
        alignmentLayer.backgroundColor = UIColor.clearColor().CGColor
        alignmentLayer.frame = CGRectMake(0, 0, 90, 90)
        
        invisibleTopView.layer.addSublayer(alignmentLayer)
        invisibleTopView.frame = self.frame

    }
    
    func configureCalibrateLabel() {
        
        calibrateLabel.frame = CGRectMake(0, 0, 180, 30)
        calibrateLabel.center = CGPointZero
        calibrateLabel.backgroundColor = UIColor.clearColor()
        calibrateLabel.text = "Slide to Calibrate"
        calibrateLabel.textColor = UIColor.whiteColor()
        calibrateLabel.font = UIFont(name: "Chalkduster", size: 13)
        //self.addSubview(calibrateLabel)
    }
    
    
    func showContents() {
        
        UIView.animateWithDuration(2.0, animations: {
            
            self.labelStackView.alpha = 1.0
            self.currentCardContainer.alpha = 1.0
            self.deckViewContainer.alpha = 1.0
            
        })
        
    }
    
    func resetForNextAnimation(WithFrame fr: CGRect) {
        
        self.bringSubviewToFront(self.deckPlaceholderView)
        self.deckViewContainer.transform = CGAffineTransformIdentity
        self.deckViewContainer.frame = fr
    }
    
    
    //MARK: NOtifications
    
    func pushupCompleted(notification: NSNotification) {
        print("Pushup Herd from GameVC")
        let currentCard = callBack!.currentCardBeingDisplayed()
        if currentCard.rank.rawValue != currentPushupCount {
            //If the pushup count doesnt match rank, keep doing pushups
            pushupActions()
        } else {
            //Do all actions to get ready for the next card
            currentCardCompleted()
        }
        
    }



}





//MARK: Animations
extension LewisGameView {
    
    
    func animationStart() {
        
        let originalFrame = self.deckViewContainer.frame
        
        UIView.animateWithDuration(1.0, animations: {
            
            self.deckViewContainer.frame.size = CGSizeMake(self.currentCardContainer.frame.size.height, self.currentCardContainer.frame.size.width)
            self.deckViewContainer.center = self.currentCardContainer.center
            self.deckViewContainer.transform = CGAffineTransformRotate(self.deckViewContainer.transform, CGFloat(M_PI * 1.5))
            
            }, completion: {(complete: Bool) -> () in
                print("animation 1 completed.")
                
        })
        
        let finalT = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 1.0), CGAffineTransformMakeRotation(CGFloat(M_PI * 1.5)))
        UIView.animateWithDuration(0.3, delay: 0.4, options: [.BeginFromCurrentState], animations: {
            self.deckViewContainer.transform = CGAffineTransformScale(self.deckViewContainer.transform, 1.3, 1.3);
            
            }, completion: {(complete: Bool) in
                
                if complete {
                    UIView.animateWithDuration(0.5, delay: 0.0, options: [.BeginFromCurrentState], animations: {
                        self.deckViewContainer.transform = finalT
                        
                        }, completion: {(complete: Bool) -> () in
                            print("First Transform animation completed")
                            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                                self.currentCardContainer.hidden = false
                                self.deckViewContainer.hidden = true
                                
                                }, completion: {(complete: Bool) -> () in
                                    print("Second Transform animation completed")
                                    self.resetForNextAnimation(WithFrame: originalFrame)
                                    self.callBack!.cardAnimationComplete()
                                    self.callBack!.startPreviewSession()
                            })
                    })
                } else {
                    self.deckViewContainer.transform = finalT
                    self.callBack!.startPreviewSession()
                }
        })
    }
    
    
    //Generic function, takes a type that conforms to protocol shapeable and calls shapeable functions.  Did this in an attempt
    //to allow other shapeable object to be passed to this function and animated.  Must extend whatever class conforms to shapeable tho
    //Sometimes Protocols with associated types arent exactly what you think they are, but sometimes they are :)
    func animateSuit<T: Shapeable>(Suit s: T, ToPosition point: CGPoint) {
        
        let totalDuration:Double = 1.0
        let repeats:Double = 10.0
        
        UIView.animateWithDuration(totalDuration, delay: 0.0, options: .CurveEaseOut, animations: {
            
            s.place(AtPoint: point)
            
            }, completion: {(complete: Bool) in
                s.removeAnimationFromShapeWithKey("shapeSpin")
                s.removeShapeFromSuperView()
                
        })
        
        UIView.animateWithDuration(totalDuration * 0.5, delay: totalDuration * 0.5, options: .CurveEaseOut, animations: {
            
            s.scaleBy(0.1)
            
            }, completion: nil)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = NSNumber(float: 0.0)
        rotateAnimation.toValue = NSNumber(float: 2 * Float(M_PI))
        rotateAnimation.duration = totalDuration / repeats
        rotateAnimation.repeatCount = Float(repeats)
        s.addNewAnimationToShape(rotateAnimation, ForKey: "shapeSpin")
        
    }
    
    
    
    
}






//MARK: Gestures
extension LewisGameView {
    
    func deckTap() {
        print("DeckTapped " + #function)
        
        if callBack!.deviceIsOriented() {
            self.bringSubviewToFront(self.deckViewContainer)
        }
    }
    
}






//MARK: View Reacting to Pushups
extension LewisGameView {
    
    func simulatePushup() {
        pushupActions()
    }
    
    func pushupActions() {
        
        
        //animate suit to position
        let suitToAnimate = callBack!.getShape(AtIndex: currentPushupCount)
        let suitCenter = callBack!.getShapeCenter(ForShape: suitToAnimate, InView: self)
        let suitNewCenter = labelStackView.convertPoint(currentPushupCountLabel.center, toView: self)
        
        let currentSuit = UIImageView(image: suitToAnimate.image!)
        currentSuit.frame = suitToAnimate.frame
        currentSuit.center = suitCenter
        
        currentPushupCount += 1
        //this call pushupActions() comes from a self-created queue so need to do ui stuff on main queue
        dispatch_async(dispatch_get_main_queue(), {
            //animate suit to position
            self.addSubview(currentSuit)
            suitToAnimate.removeFromSuperview()
            self.animateSuit(Suit: currentSuit, ToPosition: suitNewCenter)
            
            //add a count to pushups this card
            self.currentPushupCountLabel.text = "\(self.currentPushupCount)"
            
        })
        
        //
        print("suitCenterInSuperVIew: \(NSStringFromCGPoint(suitCenter)), SuitDesiredNewCenterInSuperView: \(NSStringFromCGPoint(suitNewCenter)), SuitActualNewCenterInSuperView: \(NSStringFromCGPoint(currentSuit.center))")
        
        let currentCard = callBack!.currentCardBeingDisplayed()
        if currentCard.rank.rawValue != currentPushupCount {
            //If the pushup count doesnt match rank, keep doing pushups
            
        } else {
            //Do all actions to get ready for the next card
            currentCardCompleted()
        }
    }

}






//MARK: Card Completion Cycle
extension LewisGameView {
    
    func currentCardCompleted() {
        print("running Completion cycle")
        //animateCardUnderLayer()
        addCurrentAmountToTotalCompleted()
        //incrementCardsCompleted()
        //resetViewForNextCard()
    }
    
    
    
    func addCurrentAmountToTotalCompleted() {
        
        
    }
    
    
    func animateCardUnderLayer() {
        print("3D transform")
        //let transformAnim = CABasicAnimation(keyPath: "rotation")
        
        let threeDtransform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.2, 4.0, 4.0, 1.2)
        
        
        UIView.animateKeyframesWithDuration(3.0, delay: 0.0, options: [.BeginFromCurrentState, .Repeat], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 2/3, animations: {
                //self.currentCardVC.view.layer.transform = threeDtransform
                self.currentCardContainer.layer.transform = threeDtransform
            })
            
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                //self.currentCardVC.view.layer.transform = CATransform3DIdentity
                self.currentCardContainer.layer.transform = CATransform3DIdentity
            })
            }, completion: nil)
        
    }
    
}





//MARK: detection protocol
extension LewisGameView {
    
    func getCenterForAlignment(CenterPoint center: CGPoint) {
        
        if invisibleTopView.superview == nil {
            alignmentCenterPoint = deckPlaceholderView.convertCenterOfSquareToView(self)
            print("AlignmentCenter = \(NSStringFromCGPoint(alignmentCenterPoint))")
            self.addSubview(invisibleTopView)
            alignmentLayer.hidden = false
        }
        
        //Center = 160, 460 (468 is at very edge)
        //From y = 488 to 389 and x = 265 to 58
        //y - 79 = OB, y + 30 = OB
        //x - 102 = ob , x + 105 = ob
        
        
        
        let controlCenter = CGPointMake(alignmentCenterPoint.x, alignmentCenterPoint.y - 10)
        let actualShiftAmountY: CGFloat = 20
        let actualShiftAmountX: CGFloat = 10
        let xOutOfBounds: CGFloat = 102
        
        let xShift = center.x - controlCenter.x
        let xOffset = (xShift / xOutOfBounds) * actualShiftAmountX
        
        var yOffset: CGFloat = 0.0
        let yShift = center.y - controlCenter.y
        
        if yShift > 0 {
            yOffset = (yShift / 30.0) * actualShiftAmountY
        } else {
            yOffset = (yShift / 70.0) * actualShiftAmountY
        }
        
        let adjustedCenter = CGPointMake(controlCenter.x + xOffset, controlCenter.y + yOffset)
        //print("\(NSStringFromCGPoint(adjustedCenter))")
        alignmentLayer.position = adjustedCenter
    }
    
    func gotCIImageFromVideoDataOutput(image: CIImage) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let newImage = UIImage(CIImage: image)
            let imageSize = newImage.size
            self.imageDisplayView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
            print("\(NSStringFromCGRect(self.imageDisplayView.frame))")
            self.imageDisplayView.image = newImage
            
        })
        
    }
}
