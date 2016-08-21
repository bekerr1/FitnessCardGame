//
//  LewisGameViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit




class LewisGameViewController: UIViewController, GameViewCallBackDelegate {
    
    //MARK: Properties
    //Subviews used in transition
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
    //Main View
    @IBOutlet var gameView: LewisGameView!
    var deviceOrientation = UIDevice.currentDevice().orientation
    //View controllers
    private var deckVC: LewisDeckViewController!
    private var currentCardVC: LewisCardViewController!
    private var tap: Bool = false
    private var detectorController: LewisAVDetectorController!
    
    
    
    //MARK: Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewdidLoad on gameVC")
        print("ViewDidLoadframe = \(NSStringFromCGRect(gameView.frame))")
        // Do any additional setup after loading the view, typically from a nib.
        
        gameView.callBack = self
        gameView.viewGestures()
        gameView.setupFrameDependentElements()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        view.addSubview(topHiderView)
        view.addSubview(bottomHiderView)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillAppaerframe = \(NSStringFromCGRect(gameView.frame))")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppearframe = \(NSStringFromCGRect(self.view.frame))")
        
        detectorController = LewisAVDetectorController(withparentFrame: self.view.frame)
        detectorController.delegate = gameView
        gameView.showContents()
        
    }

    override func viewDidLayoutSubviews() {
        print("subviews layed")
        
        if self.tap {
            
            deckVC.deckTapTransitionTo()
            setCardVCViewToAnimated()
            gameView.animationStart()
            tap = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder)}
    
    
    func setCardVCViewToAnimated() {
        //Get the deckVC's current deck model and set it to the cardVC's deck model
        
        currentCardVC.setViewToNewCard(deckVC.cardFrontView.currentCardModel)
    }
    
    
    
    //MARK: Prepare for Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "deckSegue" {
            print("deck segue")
            deckVC = segue.destinationViewController as? LewisDeckViewController
        } else if segue.identifier == "cardSegue" {
            print("card segue")
            currentCardVC = segue.destinationViewController as? LewisCardViewController
        } else if segue.identifier == "calibrateVC" {
            print("calibrate segue")
            //calibrateVC = segue.destinationViewController as? LWCalibrateControlViewController
        }
    }
    
    
    //MARK: notifications
    func orientationChanged(notification: NSNotification) {
        
        let orientation = UIDevice.currentDevice().orientation
        print("Orientation Changed To: \(orientation)")
        deviceOrientation = orientation
    }
    
    
    //MARK: Alerts
    func alertUserOfOrientationError() {
        
        let alertVC = UIAlertController(title: "Orientation Error", message: "Phone must be laying flat on the ground!", preferredStyle: .Alert)
        
        let alertAction = UIAlertAction(title: "Sorry", style: .Default, handler: {(action: UIAlertAction) in
         //Do nothing for now
        })
        
        alertVC.addAction(alertAction)
        self.presentViewController(alertVC, animated: false, completion: nil)
    }
    

}




//MARK: Capture Session
extension LewisGameViewController {
    
    func startPreviewSession() {
        
        let preview = detectorController.getPreviewLayerForUse()
        //self.view.layer.addSublayer(preview)
        detectorController.startCaptureSession()
    }
    
    func stopPreviewSession() {
        
        detectorController.stopCaptureSession()
    }
}





//MARK: View Callbacks
extension LewisGameViewController {
    func deviceIsOriented() -> Bool {
        
        if deviceOrientation != .FaceUp {
            alertUserOfOrientationError()
            return false
        } else {
            tap = true
            detectorController.needAlignment = true
            return true
        }
    }
    
    func cardAnimationComplete() {
        self.deckVC.resetTransitionViews()
        self.deckVC.cardFrontView.clearContentsFromScreen()
    }
    
    func cardComplete() {
        detectorController.needAlignment = false
    }
    
    func getShape(AtIndex index: Int) -> UIImageView {
        return currentCardVC.shapeAtIndex(Index: index)
    }
    
    func getShapeCenter(ForShape shape: UIImageView, InView view: UIView) -> CGPoint {
        return currentCardVC.getPointFromView(shape, InView: view)
    }
    
    func currentCardBeingDisplayed() -> LewisCard {
        return currentCardVC.cardFrontView.currentCardModel
    }
    
    func cardAboutToBeShown() -> LewisCard {
        return deckVC.cardFrontView.currentCardModel
    }
    

}













//Tried to add view programatically but couldnt get it to follow constraits i wanted
//tried to add constraits and there was a conflict
//        deckPlaceholderView = UIView(frame: deckViewContainer.frame)
//        deckPlaceholderView.backgroundColor = UIColor.yellowColor()
//        deckPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(deckPlaceholderView)
//        self.view.bringSubviewToFront(deckViewContainer)'



//    func recordData() {
//
//        self.detectorController.collectPushupData = !self.detectorController.collectPushupData
//        if self.detectorController.collectPushupData {
//            print("recording")
//        } else {
//            print("Not recording")
//        }
//    }




