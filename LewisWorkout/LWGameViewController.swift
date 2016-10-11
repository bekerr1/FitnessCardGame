//
//  LWGameViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/29/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit




class LWGameViewController: UIViewController, GameViewCallBackDelegate, DetectorClassProtocol, PushupDelegate {
let DEVICE_TESTING = 1
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
    @IBOutlet var gameView: LWGameView!
    var deviceOrientation = UIDevice.currentDevice().orientation
    //View controllers (children)
    private var deckViewContainerController: LWDeckViewContainerController!
    private var deckVC: LWCardViewController!
    private var currentCardVC: LWCardViewController!
    private var tap: Bool = false
    private var detectorController: LWAVDetectorController!
    //Model (to main view)
    var pushData: PushupData = PushupData()
    var pushStats: PushupStatistics = PushupStatistics()
    var calibrationComplete: Bool = false
    var faceRectAreasForAccelerate: [Float] = Array()
    var faceRectFilter: FaceRectFilter?
    var currentPosition: PushupPosition?
    var frameQueue: DetectionQueue = DetectionQueue<CGFloat>()
    var dataTimer: NSTimer?
    var frameCount = 0
    var timerCount = 0
    
    //GDC
    var dataQueue: dispatch_queue_t?
    
    //MARK: Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewdidLoad on gameVC")
        print("ViewDidLoadframe = \(NSStringFromCGRect(gameView.frame))")
        
        
        //DeckVC is the childVC of deckViewContainerController. DeckVC is added as a child and gameView.deckViewContainer is set to the container's view.  This is so the container view can be animated and manipulated and the contents inside can also change independently
        deckVC = LWCardViewController()
        deckViewContainerController = LWDeckViewContainerController()
        print("setting view container")
        if let deck = deckVC {
            print("setting deckVC to container as child")
            deckViewContainerController.displayContentController(ViewController: deck)
        }
        gameView.deckViewContainer = deckViewContainerController.view
        gameView.deckViewContainer.frame = CGRectMake(0, 0, LewisGeometricConstants.deckContainerWidth, LewisGeometricConstants.deckContainerHeight)
        
        //Game view initialization type calls
        gameView.callBack = self
        gameView.viewGestures()
        gameView.setupFrameDependentElements()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        dataQueue = dispatch_queue_create("com.Lewis.Data", DISPATCH_QUEUE_SERIAL)
        
        view.addSubview(topHiderView)
        view.addSubview(bottomHiderView)
        view.addSubview(gameView.deckViewContainer)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillAppaerframe = \(NSStringFromCGRect(gameView.frame))")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppearframe = \(NSStringFromCGRect(self.view.frame))")
//#if DEVICE_TESTING
        detectorController = LWAVDetectorController(withparentFrame: self.view.frame)
        detectorController.delegate = self
//#endif
        deckVC.setCardFaceDown()
        loadDeckVCContentsAndLayout()
        gameView.showContents()
        gameView.testTransform()
        
        
    }

    override func viewDidLayoutSubviews() {
        print("subviews layed")
        
        if self.tap {
            
            deckVC.deckTapAnimationFlipToFront()
            setCardVCViewToAnimated()
            //gameView.animationStart()
            gameView.testNewAnimationStart()
            tap = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder)}
    
    //MARK: Getting views contents ready for display
    
    ///Calls generateNewCardForViewing on LWCardViewController. Should only be used on initialization.
    func loadDeckVCContentsAndLayout() {
        deckVC.generateNewCardForViewing()
    }
    
    ///Gives the currentCardVC (card that the users interacts with) the deckVC's cardFrontView cardModel so when animation is complete the deckVC can be configure for the next card and the CurrentCardVC can interact with the user.
    func setCardVCViewToAnimated() {
        currentCardVC.useCardModel(CardModel: deckVC.cardFrontView.currentCardModel)
    }
    
    
    //MARK: Prepare for Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "deckSegue" {
            print("deck segue")
            deckVC = segue.destinationViewController as? LWCardViewController
        } else if segue.identifier == "cardSegue" {
            print("card segue")
            currentCardVC = segue.destinationViewController as? LWCardViewController
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
extension LWGameViewController {
    
    func startPreviewSession() {
//#if DEVICE_TESTING
        //let preview = detectorController.getPreviewLayerForUse()
        //self.view.layer.addSublayer(preview)
        detectorController.startCaptureSession()
//#endif
    }
    
    func stopPreviewSession() {
//#if DEVICE_TESTING
        detectorController.stopCaptureSession()
//#endif
    }
}





//MARK: View Callbacks
extension LWGameViewController {
    func deviceIsOriented() -> Bool {
//#if DEVICE_TESTING
        if deviceOrientation != .FaceUp {
            alertUserOfOrientationError()
            return false
        } else {
            tap = true
            detectorController.needAlignment = true
            return true
        }
//#endif
        //return true
    }
    
    ///Checks if the deckVC instance's cardFrontView's cardContentsSet property is true.  This property gets set to false on init, true when the cards contents is layed out, and back to false when the contents is removed from superview.
    func deckContentsSet() -> Bool {
        return deckVC.cardFrontView.cardContentsSet
    }
    
    func cardAnimationComplete() {
        deckVC.resetForCompletedAnimations()
    }
    
    func cardComplete() {
//#if DEVICE_TESTING
        detectorController.needAlignment = false
//#endif
    }
    
    func getShape(AtIndex index: Int) -> UIImageView? {
        return currentCardVC.shapeAtIndex(Index: index)
    }
    
    func getShapeCenter(ForShape shape: UIImageView, InView view: UIView) -> CGPoint {
        return currentCardVC.getPointFromView(shape, InView: view)
    }
    
    func currentCardBeingDisplayed() -> LWCard {
        return currentCardVC.cardFrontView.currentCardModel
    }
    
    func cardAboutToBeShown() -> LWCard {
        return deckVC.cardFrontView.currentCardModel
    }
    

}






//MARK: detection protocol
extension LWGameViewController {
    
    func getCenterForAlignment(CenterPoint center: CGPoint) {
        gameView.placeAlignmentView(At: center)
    }
    
    func gotCIImageFromVideoDataOutput(image: CIImage) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.gameView.add(Image: image)
        })
        
    }
    
    
    func dataCollectionTimer(timer: NSTimer) {
        //print("Timer hit")
        timerCount += 1
        guard let area = frameQueue.dequeue() else {
            return
        }
    
        do {
            
            self.calibrationComplete = try self.pushData.insertValue(ToAnalyze: Float(area))
                
//                count, value, stringID in
//                print("A good stat was returned with a value of \(value) with an ID of \(stringID)")
//                self.calibrationComplete = self.pushStats.needMoreData(WithID: stringID, Value: value)
////                if self.calibrationComplete {
////                    print("calibration should completed")
////                    self.newFaceArea(0.0)
////                }
//            }
        } catch (BadStatisticError.badStatistic(let message)) { //bad statistic error
            //print(message)
        } catch { //every other error
            
        }
        
        
    }
    
    func startTimer() {
        
        if dataTimer == nil && !calibrationComplete {
            print("Timer created")
            dataTimer = NSTimer(timeInterval: 0.1, target: self, selector: #selector(dataCollectionTimer(_:)), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(dataTimer!, forMode: "NSDefaultRunLoopMode")
        }
    }
    
    //Sometimes called from a queue other than main queue
    func newFaceArea(area: CGFloat) {
        //print("new area")
        frameCount += 1
        pushData.frameCount = frameCount
        startTimer()
        frameQueue.enqueue(area)
        
        if !calibrationComplete {
            //do nothing
            //print("calibration not complete")
        } else {
            dataTimer?.invalidate()
            print("Max Average ended up being \(self.pushStats.averageMaxValue) and Min Average ended up being \(self.pushStats.averageMinValue) and median of averages is \(self.pushStats.medianOfAverages)")
        }
        
        
        
        //        if faceRectAreasForAccelerate.count > 4 {
        //            if faceRectFilter == nil {
        //                currentPosition = .up
        //                faceRectFilter = FaceRectFilter(WithInitialPoints: faceRectAreasForAccelerate, FromNumberOfValues: UInt(faceRectAreasForAccelerate.count), CurrentMotion: currentPosition!)
        //                faceRectFilter?.delegate = self
        //            } else {
        //                if currentPosition == .up {
        //                    faceRectFilter?.newAreaArrived(area, Operation: >, Condition: <)
        //                } else {
        //                    faceRectFilter?.newAreaArrived(area, Operation: <, Condition: >)
        //                }
        //                //faceRectFilter?.newAreaArrived(area)
        //            }
        //        } else {
        //            faceRectAreasForAccelerate.append(Float(area))
        //        }
        
    }
    
    
    //this should be in controller
    //MARK: Pushup Delegate
    func pushupCompleted() {
        faceRectFilter = nil
        gameView.pushupActions()
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




