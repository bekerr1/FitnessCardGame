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
    @IBOutlet weak var pushupCountLabel: UILabel!
    @IBOutlet weak var currentCardLabel: UILabel!
    @IBOutlet weak var cardsCompletedLabel: UILabel!
    
    @IBOutlet weak var currentCardContainer: UIView!
    @IBOutlet weak var deckViewContainer: UIView!
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        let deckTapDesture = UITapGestureRecognizer(target: self, action: #selector(deckTap))
        deckTapGesture = deckTapDesture
        let deckGestures = [deckTapGesture]
        deckPlaceholderView.gestureRecognizers = deckGestures
        deckPlaceholderView.referenceRect = deckViewContainer.frame
        
        let dataTapGesture = UITapGestureRecognizer(target: self, action: #selector(recordData))
        self.view.gestureRecognizers = [dataTapGesture]
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        deckPlaceholderView.createStackEffect()
        
        let insetFrame = CGRectInset(self.view.frame, 20.0, 40.0)
        print("insetFrame = \(NSStringFromCGRect(self.view.layer.bounds))")
        detectorController = LewisAVDetectorController(withparentFrame: insetFrame)
        detectorController.delegate = self
        
        print("frame = \(NSStringFromCGRect(self.view.frame))")
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
        
        let originalTransform = self.deckViewContainer.transform
        let originalFrame = self.deckViewContainer.frame
        
        deckVC.deckTapTransitionTo()

        UIView.animateWithDuration(1.0, animations: { () -> () in
            
            self.deckViewContainer.frame.size = CGSizeMake(self.currentCardContainer.frame.size.height, self.currentCardContainer.frame.size.width)
            self.deckViewContainer.center = self.currentCardContainer.center
            self.deckViewContainer.transform = CGAffineTransformRotate(self.deckViewContainer.transform, CGFloat(M_PI * 1.5))
            
            },
            completion: {(complete: Bool) -> () in
                print("animation 1 completed.")
                
        })
        
        
        UIView.animateWithDuration(0.6, delay: 0.4, options: .Autoreverse, animations: {() -> () in
            
            self.deckViewContainer.transform = CGAffineTransformScale(self.deckViewContainer.transform, 1.3, 1.3);
            
            }, completion: {(complete: Bool) -> () in
                print("Transform animation completed")
                //All animations completed at this point
                
                self.setCardVCViewToAnimated()
                self.resetViewsForNextAnimation(originalTransform: originalTransform, originalFrame: originalFrame)
                self.startPreviewSession()
                
        })

    }
    
    
    func setCardVCViewToAnimated() {
        //Get the deckVC's current deck model and set it to the cardVC's deck model
        currentCardVC.setViewToNewCard(deckVC.cardFrontView.currentCardModel)
    }
    
    
    func resetViewsForNextAnimation(originalTransform trans: CGAffineTransform, originalFrame frame: CGRect) {
        
        self.view.bringSubviewToFront(self.deckPlaceholderView)
        self.deckVC.resetTransitionViews()
        self.deckViewContainer.transform = trans
        self.deckViewContainer.frame = frame
    }
    
    func startPreviewSession() {
        
        deckTapGesture.enabled = false
        
        let preview = detectorController.getPreviewLayerForUse()
        //self.view.layer.addSublayer(preview)
        detectorController.startCaptureSession()
        
        self.view.addSubview(self.imageDisplayView)
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

}


//Tried to add view programatically but couldnt get it to follow constraits i wanted
//tried to add constraits and there was a conflict
//        deckPlaceholderView = UIView(frame: deckViewContainer.frame)
//        deckPlaceholderView.backgroundColor = UIColor.yellowColor()
//        deckPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(deckPlaceholderView)
//        self.view.bringSubviewToFront(deckViewContainer)'







