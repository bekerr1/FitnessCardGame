//
//  LWGameView.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//


/*
 This view splits up functionality into extensions.  The meat of the view, basically everything that has to do with start up and "restarting" is contained inside the main class.  Extra functionality is then dispersed into extensions with marks at the top.  Gives the property/method selector a cool look, i think.
 
 
 */
import UIKit
//
//MARK: Callback Protocol
protocol GameViewCallBackDelegate {
    func deviceIsOriented() -> Bool
    func cardAnimationComplete()
    func cardComplete()
    func startPreviewSession()
    func getShape(AtIndex index: Int) -> UIImageView
    func getShapeCenter(ForShape shape: UIImageView, InView view: UIView) -> CGPoint
    func currentCardBeingDisplayed() -> LWCard
    func cardAboutToBeShown() -> LWCard
    func stopPreviewSession()
}


enum PushupPosition {
    case down
    case up
}


class LWGameView: UIView, DetectorClassProtocol, PushupDelegate {
    
    //MARK: Properties
    var callBack: GameViewCallBackDelegate?
    var shadowLayer: CALayer = CALayer()
    let widthOffset: CGFloat = 0
    let heightOffset: CGFloat = 210
    private let calibrateLabel: UILabel = UILabel()
    var alignmentCenterPoint: CGPoint = CGPointZero
    var deckViewContainerFinalCenter: CGPoint?
    var deckViewContainerFinalSize: CGSize?
    //Subviews
    @IBOutlet weak var stageImageView: UIImageView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var currentCardContainer: UIView!
    var emptySpringCard: UIView = UIView()
    var placeholderEmptyCard: UIView = UIView()
    ///set to the view of LWDeckViewContainerController
    var deckViewContainer: UIView!
    @IBOutlet weak var deckPlaceholderView: LWDeckPlaceholderView!
    private var calibrateSlider: LWAnimatedSlider = LWAnimatedSlider()
    var decorationView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
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
    //StackViewPropertyLogic
    var totalCardsCompletedCount: Int {
        willSet (newValue) {
            totalCardsCompletedLabel.text = "\(newValue)"
        }
    }
    @IBOutlet weak var currentPushupCountLabel: UILabel!
    var currentPushupAnimatingLabel: UILabel = UILabel()
    var currentPushupCount: Int {
        willSet (newValue) {
           currentPushupCountLabel.text = "\(newValue)"
        }
    }
    @IBOutlet weak var pushupsCompletedLabel: UILabel!
    var totalPushupsCompletedCount: Int {
        willSet (newValue) {
            pushupsCompletedLabel.text = "\(newValue)"
        }
    }
    //GESTURES
    var deckTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    //View Model (does this belong in the controller??)
    var faceRectAreasForAccelerate: [Float] = Array()
    var faceRectFilter: FaceRectFilter?
    var currentPosition: PushupPosition?
    
    @IBOutlet weak var cardContainerTopLayoutGuideConstraint: NSLayoutConstraint!
    //MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        print("coder init in game view")
        totalPushupsCompletedCount = 0
        currentPushupCount = 0
        totalCardsCompletedCount = 0
        
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        print("frame init in game view")
        totalPushupsCompletedCount = 0
        currentPushupCount = 0
        totalCardsCompletedCount = 0

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
        configureEmptyCardViews()
        configureAnimationLabels()
        
    }
    
    func testTransform() {
        //deckViewContainer.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        //deckViewContainer.transform = CGAffineTransformMakeScale(0.8, 0.8)
        //print("\(NSStringFromCGSize(deckPlaceholderView.frame.size))")
        //deckViewContainer.frame.size = currentCardContainer.frame.size
        //deckViewContainer.frame.size = deckPlaceholderView.frame.size
        deckViewContainer.center = deckPlaceholderView.center
        deckViewContainer.center.y += 10.0
        let concatTransforms = CGAffineTransformConcat(CGAffineTransformMakeRotation(CGFloat(M_PI_2)), CGAffineTransformMakeScale(0.7, 0.7))
        deckViewContainer.transform = concatTransforms //CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        if let sv = deckViewContainer.superview {
            print("DeckViewContainer has superview \(sv)")
            print(NSStringFromCGRect(deckViewContainer.frame))
            //deckViewContainer.backgroundColor = UIColor.redColor()
        }
    }
    
    func prepareView() {
        labelStackView.alpha = 0.0
        currentCardContainer.alpha = 0.0
        deckViewContainer.alpha = 0.0
        decorationView.alpha = 0.0
        currentCardContainer.hidden = true
    }
    
    
    func configureShadowLayer() {
        print("Game view frame: \(NSStringFromCGRect(self.frame))")
        
        decorationView.layer.frame = CGRectMake(0, 0, self.frame.width - widthOffset, self.frame.height - heightOffset)
        decorationView.layer.position = CGPointMake(self.frame.width/2, self.frame.height/2 - 75)
        decorationView.layer.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5).CGColor
        decorationView.layer.shadowOpacity = 1.0
        decorationView.layer.shadowRadius = 1.0
        decorationView.layer.shadowOffset = CGSizeMake(0.0, 15.0)
        decorationView.layer.masksToBounds = false
    
        insertSubview(decorationView, belowSubview: deckPlaceholderView)
        
    }
    
    func configureEmptyCardViews() {
        
        placeholderEmptyCard.frame = currentCardContainer.frame
        placeholderEmptyCard.backgroundColor = UIColor.whiteColor()
        placeholderEmptyCard.layer.cornerRadius = LewisGeometricConstants.cornerRadius
        placeholderEmptyCard.hidden = true
        
        emptySpringCard.frame = currentCardContainer.frame
        emptySpringCard.center = CGPointMake(currentCardContainer.center.x + frame.width, currentCardContainer.center.y)
        emptySpringCard.backgroundColor = UIColor.whiteColor()
        emptySpringCard.layer.cornerRadius = LewisGeometricConstants.cornerRadius
        
        insertSubview(placeholderEmptyCard, belowSubview: decorationView)
        insertSubview(emptySpringCard, aboveSubview: placeholderEmptyCard)
        
    }
    
    func configureAnimationLabels() {
        
        currentPushupAnimatingLabel.frame = currentPushupCountLabel.frame
        currentPushupAnimatingLabel.font = currentPushupCountLabel.font
        currentPushupAnimatingLabel.backgroundColor = UIColor.clearColor()
        currentPushupAnimatingLabel.textColor = UIColor.whiteColor()
        
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
            self.decorationView.alpha = 1.0
        })
        self.insertSubview(deckPlaceholderView, aboveSubview: deckViewContainer)
        
    }
    
    func resetForNextAnimation(WithFrame fr: CGRect) {
        
        //self.bringSubviewToFront(self.deckPlaceholderView)
        self.insertSubview(deckPlaceholderView, aboveSubview: deckViewContainer)
        self.deckViewContainer.transform = CGAffineTransformIdentity
        self.deckViewContainer.frame = fr
        self.deckViewContainer.hidden = false
    }
    
    
    
    func getAnimationPathFromPoints(StartPoint start: CGPoint, EndPoint end: CGPoint) -> CGMutablePath {
        
        let path = CGPathCreateMutable()
        let controlPoint = CGPointMake((end.x + 100) , ((start.y - end.y)/2) + end.y)
        CGPathMoveToPoint(path, nil, start.x, start.y)
        CGPathAddQuadCurveToPoint(path, nil, controlPoint.x, controlPoint.y, end.x, end.y)
        
        return path
    }
    
}





//MARK: Animations
extension LWGameView {
    
    
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
                            print("Second Transform animation completed")
                            self.currentCardContainer.hidden = false
                            self.deckViewContainer.hidden = true
                            self.resetForNextAnimation(WithFrame: originalFrame)
                            self.callBack!.cardAnimationComplete()
                            self.callBack!.startPreviewSession()
                            
                    })
                } else {
                    self.deckViewContainer.transform = finalT
                    self.callBack!.startPreviewSession()
                }
        })
    }
    
    func testNewAnimationStart() {
        
        //let originalFrame = self.deckViewContainer.frame
        
        UIView.animateWithDuration(1.0, animations: {
            
            //self.deckViewContainer.frame.size = CGSizeMake(self.currentCardContainer.frame.size.height, self.currentCardContainer.frame.size.width)
            //self.deckViewContainer.frame.size = self.deckViewContainerFinalSize!
            //self.deckViewContainer.center = self.currentCardContainer.center
            self.deckViewContainer.center = self.currentCardContainer.center
            //self.deckViewContainer.transform = CGAffineTransformRotate(self.deckViewContainer.transform, CGFloat(M_PI * 1.5))
            self.deckViewContainer.transform = CGAffineTransformIdentity
            
            }, completion: {(complete: Bool) -> () in
                print("animation 1 completed.")
                
        })
        
        //let finalT = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 1.0), CGAffineTransformMakeRotation(CGFloat(M_PI * 1.5)))
        UIView.animateWithDuration(0.3, delay: 0.4, options: [.BeginFromCurrentState], animations: {
            self.deckViewContainer.transform = CGAffineTransformScale(self.deckViewContainer.transform, 1.3, 1.3);
            
            }, completion: {(complete: Bool) in
                
                if complete {
                    UIView.animateWithDuration(0.5, delay: 0.0, options: [.BeginFromCurrentState], animations: {
                        self.deckViewContainer.transform = CGAffineTransformIdentity
                        
                        }, completion: {(complete: Bool) -> () in
                            print("Second Transform animation completed")
                            self.currentCardContainer.hidden = false
                            self.deckViewContainer.hidden = true
                            //self.resetForNextAnimation(WithFrame: originalFrame)
                            self.callBack!.cardAnimationComplete()
                            self.callBack!.startPreviewSession()
                            
                    })
                } else {
                    self.deckViewContainer.transform = CGAffineTransformIdentity
                    self.callBack!.cardAnimationComplete()
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
    
    
    
    //Auto layout was forcing this view to snap back into place, need to set the constrait.active to false and add it back after view has been hidden
    func animateCardUnderLayer() {
        print("3D transform")
        let currentCardSavedCenter = currentCardContainer.center
        let animatedCardSavedCenter = emptySpringCard.center
        self.placeholderEmptyCard.center = currentCardSavedCenter
        self.cardContainerTopLayoutGuideConstraint.constant = 600
        
        let lift = CGAffineTransformMakeScale(1.3, 1.3)
        //ANIMATE CARD OFFSCREEN
        UIView.animateKeyframesWithDuration(2.0, delay: 0.0, options: [], animations: {
            //scale view up ("lift up")
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/2, animations: {
                self.currentCardContainer.transform = lift
            })
            //animate out of view - so other view and come in and pretend to be it
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 1, animations: {
                self.layoutIfNeeded()
            })
            
            }, completion: {(complete: Bool) in
                if complete {
                    print("complete")
                    self.currentCardContainer.hidden = true
                    self.currentCardContainer.transform = CGAffineTransformIdentity
                    self.cardContainerTopLayoutGuideConstraint.constant = 40
                    self.layoutIfNeeded()
                }
        })
        
        //ANIMATE DUMMY UNDER DECORATION VIEW
        UIView.animateWithDuration(2.0, delay: 2.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.BeginFromCurrentState], animations: {
            
            self.emptySpringCard.center = currentCardSavedCenter
            
            }, completion: {(complete: Bool) in
                self.placeholderEmptyCard.hidden = false
                self.emptySpringCard.hidden = true
                self.emptySpringCard.center = animatedCardSavedCenter
                self.emptySpringCard.hidden = false
        })
    }
    
    
    func animateCurrentAmountToTotalCompleted() {
        
        let savedPosition = currentPushupAnimatingLabel.layer.position
        currentPushupAnimatingLabel.text = currentPushupCountLabel.text
        totalCardsCompletedCount += 1
        var startPoint = labelStackView.convertPoint(currentPushupCountLabel.center, toView: self)
        var endPoint = labelStackView.convertPoint(pushupsCompletedLabel.center, toView: self)
        startPoint.x += 40
        endPoint.x += 60
//        endPoint.x += 10
        
        insertSubview(currentPushupAnimatingLabel, belowSubview: labelStackView)
        let animationPath = getAnimationPathFromPoints(StartPoint: startPoint, EndPoint: endPoint)
        
        /*
            I wasnt sure if i should put the animation insie a view animation becuase:
                https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/CreatingBasicAnimations/CreatingBasicAnimations.html#//apple_ref/doc/uid/TP40004514-CH3-SW16
            I wrapped animation inside transaction and it seems to work fine.  It is a view backed layer im animating though, which is the reason for my confusion
        */
        
        CATransaction.begin()
        let labelAnimation = CAKeyframeAnimation(keyPath: "position")
        labelAnimation.path = animationPath
        labelAnimation.duration = 2.0
        self.currentPushupAnimatingLabel.layer.position = endPoint
        CATransaction.setCompletionBlock({
            self.currentPushupAnimatingLabel.removeFromSuperview()
            self.currentPushupAnimatingLabel.layer.position = savedPosition
            self.totalPushupsCompletedCount += self.currentPushupCount
            self.currentPushupCount = 0
            
        })
        
        self.currentPushupAnimatingLabel.layer.addAnimation(labelAnimation, forKey: "position")
        CATransaction.commit()

        
    }
    
    
}






//MARK: Gestures
extension LWGameView {
    
    func deckTap() {
        print("DeckTapped " + #function)
        
        if callBack!.deviceIsOriented() {
            
            self.insertSubview(deckViewContainer, aboveSubview: deckPlaceholderView)
        }
    }
    
}






//MARK: View Reacting to Pushups
extension LWGameView {
    
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
            //self.currentPushupCountLabel.text = "\(self.currentPushupCount)"
            print("suitCenterInSuperVIew: \(NSStringFromCGPoint(suitCenter)), SuitDesiredNewCenterInSuperView: \(NSStringFromCGPoint(suitNewCenter)), SuitActualNewCenterInSuperView: \(NSStringFromCGPoint(currentSuit.center))")
            
            let currentCard = self.callBack!.currentCardBeingDisplayed()
            if currentCard.rank.rawValue != self.currentPushupCount {
                //If the pushup count doesnt match rank, keep doing pushups
                
            } else {
                //Do all actions to get ready for the next card
                self.currentCardCompleted()
            }

            
        })
        
    }
    //this should be in controller
    //MARK: Pushup Delegate
    func pushupCompleted() {
        faceRectFilter = nil
        pushupActions()
    }
    
    func motionCompleted() {
        
        if currentPosition == .up {
            print("\(currentPosition) motion completed")
            currentPosition = .down
            faceRectFilter?.currentMotion = currentPosition!
        } else if currentPosition == .down {
            print("\(currentPosition) motion completed")
            currentPosition = .up
            pushupCompleted()
        }
    }
}






//MARK: Card Completion Cycle
extension LWGameView {
    
    func currentCardCompleted() {
        print("running Completion cycle")
        callBack!.cardComplete()
        removeAlignment()
        callBack!.stopPreviewSession()
        animateCardUnderLayer()
        animateCurrentAmountToTotalCompleted()
        resetViewForNextCard()
        
    }
    
    func resetViewForNextCard() {
        
        
    }
    
    
}




//This should be in controller
//MARK: detection protocol
extension LWGameView {
    
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
    
    //Called from a queue other than main queue
    func newFaceArea(area: CGFloat) {
        
        if faceRectAreasForAccelerate.count > 4 {
            if faceRectFilter == nil {
                currentPosition = .up
                faceRectFilter = FaceRectFilter(WithInitialPoints: faceRectAreasForAccelerate, FromNumberOfValues: UInt(faceRectAreasForAccelerate.count), CurrentMotion: currentPosition!)
                faceRectFilter?.delegate = self
            } else {
                if currentPosition == .up {
                    faceRectFilter?.newAreaArrived(area, Operation: >, Condition: <)
                } else {
                    faceRectFilter?.newAreaArrived(area, Operation: <, Condition: >)
                }
                //faceRectFilter?.newAreaArrived(area)
            }
        } else {
            faceRectAreasForAccelerate.append(Float(area))
        }
        
        
    }
}





//MARK: Alignment code
extension LWGameView {
    ///Removes face graphic for user face alignment
    func removeAlignment() {
        dispatch_async(dispatch_get_main_queue(), {
            self.invisibleTopView.removeFromSuperview()
        })
        
    }
    
}







//MARK: Trash bin for depreicated Code/code i may get back to or may not - to be deleted
extension LWGameView {
    
    
    //MARK: NOtifications
    
    //    func pushupCompleted(notification: NSNotification) {
    //        print("Pushup Herd in Gameview")
    //        let currentCard = callBack!.currentCardBeingDisplayed()
    //        dispatch_async(dispatch_get_main_queue(), {
    //            if currentCard.rank.rawValue != self.currentPushupCount {
    //                //If the pushup count doesnt match rank, keep doing pushups
    //                self.pushupActions()
    //            } else {
    //                //Do all actions to get ready for the next card
    //                self.currentCardCompleted()
    //            }
    //
    //        })
    //        
    //    }
    
    //        UIView.animateKeyframesWithDuration(3.0, delay: 0.0, options: [.BeginFromCurrentState, .Repeat], animations: {
    //            //Animate transform to simulate lifting of card
    ////            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/6, animations: {
    ////                self.currentCardContainer.layer.transform = threeDtransform
    ////            })
    //
    //            //animate card back to simulate putting card under shadow
    //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 2/3, animations: {
    //                //self.currentCardVC.view.layer.transform = threeDtransform
    //                //self.currentCardContainer.layer.transform = threeDtransform
    //                self.currentCardContainer.center = tempCenter
    //            })
    //
    //
    //            //set card layer below shadow layer
    //
    //
    //            //animate transform back to normal and a little shunkin to simulate depth
    //
    //
    //
    //            //animate card back to center
    //            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
    //                //self.currentCardVC.view.layer.transform = CATransform3DIdentity
    //                //self.currentCardContainer.layer.transform = CATransform3DIdentity
    //                self.currentCardContainer.center = savedCenter
    //            })
    //            }, completion: nil)
    
    //        currentCardContainer.layer.anchorPoint = CGPointMake(0.5, 0.0)
    //        let transform = CABasicAnimation(keyPath: "transform")
    //        transform.fromValue = NSValue.init(CATransform3D: CATransform3DIdentity)
    //        transform.toValue = NSValue.init(CATransform3D: threeDtransform)
    //        transform.duration = 3.0
    //        transform.additive = true
    //        currentCardContainer.layer.addAnimation(transform, forKey: "layerTransform")
    //        currentCardContainer.layer.transform = threeDtransform
    
    //        UIView.animateWithDuration(3.0, delay: 0.0, options: .BeginFromCurrentState, animations: {
    //            self.currentCardContainer.layer.transform = threeDtransform
    //            self.currentCardContainer.center = tempCenter
    //            }, completion: nil)

    
}

