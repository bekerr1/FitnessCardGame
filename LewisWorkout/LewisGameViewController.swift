//
//  LewisGameViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisGameViewController: UIViewController, DetectorClassProtocol {
    
    //MARK: Properties
    var topHiderView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.blackColor()
        return result
        
    }()
    var bottomHiderView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.blackColor()
        return result
        
    }()
    
    var invisibleTopView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    
    @IBOutlet var gameView: LewisGameView!
    @IBOutlet weak var pushupCountLabel: UILabel!
    @IBOutlet weak var currentCardLabel: UILabel!
    @IBOutlet weak var cardsCompletedLabel: UILabel!
    
    @IBOutlet weak var stageImageView: UIImageView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var currentCardContainer: UIView!
    @IBOutlet weak var deckViewContainer: UIView!
    
    
    var alignmentCenterPoint: CGPoint = CGPointZero
    var alignmentLayer: CALayer = CALayer()
    let blankFaceImage: UIImage = UIImage(named: "blankFace")!
    @IBOutlet weak var deckPlaceholderView: LewisDeckPlaceholderView!
    private var deckVC: LewisDeckViewController!
    private var currentCardVC: LewisCardViewController!
    
    lazy var imageDisplayView: UIImageView = {
        
        let aview = UIImageView()
        aview.backgroundColor = UIColor.redColor()
        return aview
    }()
    
    private var tap: Bool = false
    var deckTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private var detectorController: LewisAVDetectorController!
    
    //MARK: Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewdidLoad on gameVC")
        // Do any additional setup after loading the view, typically from a nib.
        
        let deckTapDesture = UITapGestureRecognizer(target: self, action: #selector(deckTap))
        deckTapGesture = deckTapDesture
        let deckGestures = [deckTapGesture]
        deckPlaceholderView.gestureRecognizers = deckGestures
        deckPlaceholderView.referenceRect = deckViewContainer.frame
        
        let dataTapGesture = UITapGestureRecognizer(target: self, action: #selector(recordData))
        self.view.gestureRecognizers = [dataTapGesture]
        
        labelStackView.alpha = 0.0
        currentCardContainer.alpha = 0.0
        deckViewContainer.alpha = 0.0
        
        alignmentLayer.contents = blankFaceImage.CGImage
        alignmentLayer.hidden = true
        alignmentLayer.backgroundColor = UIColor.clearColor().CGColor
        alignmentLayer.frame = CGRectMake(0, 0, 90, 90)
        
        invisibleTopView.layer.addSublayer(alignmentLayer)
        invisibleTopView.frame = self.view.frame
        
        
        self.view.addSubview(topHiderView)
        self.view.addSubview(bottomHiderView)
        //self.view.addSubview(invisibleTopView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        deckPlaceholderView.createStackEffect()
        gameView.configureDecorationLayer()
        gameView.insertLayerBelow(Layer: currentCardContainer.layer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //let insetFrame = CGRectInset(self.view.frame, 20.0, 40.0)
        print("insetFrame = \(NSStringFromCGRect(self.view.layer.bounds))")
        detectorController = LewisAVDetectorController(withparentFrame: self.view.frame)
        detectorController.delegate = self
        
        alignmentCenterPoint = deckPlaceholderView.convertCenterOfSquareToView(self.view)
        print("AlignmentCenter = \(NSStringFromCGPoint(alignmentCenterPoint))")
        showViewContents()
        print("frame = \(NSStringFromCGRect(self.view.frame))")
    }
    
    
    func showViewContents() {
        
        UIView.animateWithDuration(2.0, animations: {
            
            self.labelStackView.alpha = 1.0
            self.currentCardContainer.alpha = 1.0
            self.deckViewContainer.alpha = 1.0
            
        })
        
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews layed")
        
        if self.tap {
            animationStart()
            tap = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    
    //MARK: Actions
    
    func animationStart() {
        
        //let originalTransform = self.deckViewContainer.transform
        let originalFrame = self.deckViewContainer.frame
        
        deckVC.deckTapTransitionTo()
        setCardVCViewToAnimated()

        UIView.animateWithDuration(1.0, animations: { () -> () in
            
            self.deckViewContainer.frame.size = CGSizeMake(self.currentCardContainer.frame.size.height, self.currentCardContainer.frame.size.width)
            self.deckViewContainer.center = self.currentCardContainer.center
            
            self.deckViewContainer.transform = CGAffineTransformRotate(self.deckViewContainer.transform, CGFloat(M_PI * 1.5))
            
            },
            completion: {(complete: Bool) -> () in
                print("animation 1 completed.")
                
        })
        
        let finalT = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 1.0), CGAffineTransformMakeRotation(CGFloat(M_PI * 1.5)))
        
        UIView.animateWithDuration(0.3, delay: 0.4, options: [.BeginFromCurrentState], animations: {
            
            self.deckViewContainer.transform = CGAffineTransformScale(self.deckViewContainer.transform, 1.3, 1.3);
            
            }, completion: {
                (complete) in
                
                if complete {
                    UIView.animateWithDuration(0.5, delay: 0.0, options: [.BeginFromCurrentState], animations: {
                        self.deckViewContainer.transform = finalT
                        
                        }, completion: {(complete: Bool) -> () in
                            print("Second Transform animation completed")
                            //All animations completed at this point
                            //self.startPreviewSession()
                            
                            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                                self.currentCardVC.view.hidden = false
                                self.deckViewContainer.hidden = true
                                
                                
                                }, completion: {(complete: Bool) -> () in
                                    print("Second Transform animation completed")
                                    //self.deckViewContainer.removeFromSuperview()
                                    self.resetViewsForNextAnimation(OriginalFrame: originalFrame)
                                    self.startPreviewSession()
                            })
                    })
                    
                } else {
                    self.deckViewContainer.transform = finalT
                    self.startPreviewSession()
                }
                
        })
        
    }
    
    
    func setCardVCViewToAnimated() {
        //Get the deckVC's current deck model and set it to the cardVC's deck model
        currentCardVC.view.hidden = true
        currentCardVC.setViewToNewCard(deckVC.cardFrontView.currentCardModel)
    }
    
    
    func resetViewsForNextAnimation(OriginalFrame frame: CGRect) {
        
        
        self.deckVC.view.hidden = true
        self.view.bringSubviewToFront(self.deckPlaceholderView)
        self.deckVC.resetTransitionViews()
        self.deckViewContainer.transform = CGAffineTransformIdentity
        self.deckViewContainer.frame = frame
    }
    
    func startPreviewSession() {
        
        deckTapGesture.enabled = false
        
        let preview = detectorController.getPreviewLayerForUse()
        //self.view.layer.addSublayer(preview)
        detectorController.startCaptureSession()
        
        //self.view.addSubview(self.imageDisplayView)
    }
    
    
    //MARK: GESTURES
    
    func deckTap() {
        print("DeckTapped " + #function)
        
        self.view.bringSubviewToFront(self.deckViewContainer)
        tap = true
    }
    
    
    func recordData() {
        
        self.detectorController.collectPushupData = !self.detectorController.collectPushupData
        if self.detectorController.collectPushupData {
            print("recording")
        } else {
            print("Not recording")
        }
    }
    
    
    //MARK: Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "deckSegue" {
            print("deck segue")
            deckVC = segue.destinationViewController as? LewisDeckViewController
        } else if segue.identifier == "cardSegue" {
            print("card segue")
            currentCardVC = segue.destinationViewController as? LewisCardViewController
        }
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
    
    
    func getCenterForAlignment(CenterPoint center: CGPoint) {
        //
        
        
        if invisibleTopView.superview == nil {
            self.view.addSubview(invisibleTopView)
            alignmentLayer.hidden = false
        }
        
        //Center = 160, 460 (468 is at very edge)
        //From y = 488 to 389 and x = 265 to 58
        //y - 79 = OB, y + 30 = OB
        //x - 102 = ob , x + 105 = ob
        
        
        
        let controlCenter = CGPointMake(160, 460)
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

}


//Tried to add view programatically but couldnt get it to follow constraits i wanted
//tried to add constraits and there was a conflict
//        deckPlaceholderView = UIView(frame: deckViewContainer.frame)
//        deckPlaceholderView.backgroundColor = UIColor.yellowColor()
//        deckPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(deckPlaceholderView)
//        self.view.bringSubviewToFront(deckViewContainer)'







