//
//  LWDeckViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/31/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit


class LWCardViewController: UIViewController {
    
    //MARK: Properties
    
    let resetQueue: dispatch_queue_t?
    
    var switchTransitions: Bool = true
    var deckModel: LWDeck
    
    lazy var cardBackView: LWCardBackView = {
        print("fromView initialized")
        let aview: LWCardBackView = LWCardBackView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.whiteColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        return aview
    }()
    
    lazy var cardFrontView: LWCardFrontView = {
        print("toView initialized")
        let aview: LWCardFrontView = LWCardFrontView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.whiteColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        return aview
    }()
    
    
    //MARK: Initialize/ViewCalls
    
    required init?(coder aDecoder: NSCoder) {
        self.deckModel = LWDeck()
        resetQueue = dispatch_queue_create("com.LewisWorkout.ResetQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))
        super.init(coder: aDecoder)
    }
    
    
    init() {
        self.deckModel = LWDeck()
        resetQueue = dispatch_queue_create("com.LewisWorkout.ResetQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("deck init in deckVC")
        
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appeared in deckVC")
        
        view.addSubview(cardBackView)
        view.addSubview(cardFrontView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("view appeared in deckVC")
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews layed in deckVC")
    }
    
//    override func loadView() {
//        print("Deck LoadView Called")
//        self.view = UIView.init(frame: CGRectMake(0, 0, LewisGeometricConstants.deckContainerWidth, LewisGeometricConstants.deckContainerHeight))
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: animations
    
    func deckTapAnimationFlipToFront() {
        flipToFront()
    }
    
    func setCardFaceUp() {
        view.insertSubview(cardFrontView, aboveSubview: cardBackView)
    }
    
    func setCardFaceDown() {
        view.insertSubview(cardBackView, aboveSubview: cardFrontView)
    }
    
    private func flipToFront() {
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
        
        UIView.transitionWithView(view, duration: 1.0, options: transitionOptions, animations: {
            self.cardBackView.hidden = true
            self.cardFrontView.hidden = false
            }, completion: nil)
    }
    
    private func flipToBack() {
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
        
        UIView.transitionWithView(view, duration: 1.0, options: transitionOptions, animations: {
            self.cardBackView.hidden = false
            self.cardFrontView.hidden = true
            }, completion: nil)
    }
    
    ///Called when all deck animations are completed
    func resetForCompletedAnimation() {
        resetFlipBackToFront()
        cardFrontView.clearContentsFromScreen()
    }
    
    ///Called when all deck animations are completed.  Resets the flip views, clears contents from hidden front view, and generates new card for viewing.
    func resetForCompletedAnimations() {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.resetFlipBackToFront()
            self.cardFrontView.clearContentsFromScreen()
            self.generateNewCardForViewing()
        })
    }
    
    private func resetFlipBackToFront() {
        
        self.cardBackView.hidden = false
        self.cardFrontView.hidden = true
    }
    
    private func resetFlipFrontToBack() {
        
        self.cardBackView.hidden = true
        self.cardFrontView.hidden = false
    }
    
    //MARK: Model stuff
    
    private func randomCardFromDeck() -> LWCard {
        return deckModel.pickRandomCard(WithReplacement: false)
    }

    ///Generates a random card model from the deck and sets that model to the cardFrontView view model.  This causes the frontView of this instance to create a fully configured card.
    func generateNewCardForViewing() {
        
        let card = randomCardFromDeck()
        print("\(card.suit), \(card.rank)")
        cardFrontView.newCardToView(card)
        
    }
    
    func useCardModel(CardModel model: LWCard) {
        cardFrontView.newCardToView(model)
    }
    
    func shapeAtIndex(Index dex: Int) -> UIImageView? {
        return (cardFrontView.cardContents.count > dex) ? cardFrontView.cardContents[dex] : nil
    }
    
    func getPointFromView(view: UIView, InView toView: UIView) -> CGPoint {
        return cardFrontView.convertPoint(view.center, toView: toView)
    }
    
    


}












//Couldnt figure out how to get this to work, probably cuase im an idiot
//Was setting view1 to view2 (or vica verca) and i couldnt find out how to compensate
//Flip() makes more sence to me
//    func animateTransition() {
//
//        UIView.transitionFromView((switchTransitions ? view1 : view2), toView: (switchTransitions ? view2 : view1), duration: 1.0, options: [.TransitionFlipFromRight], completion: {(complete: Bool) -> () in
//            print("transition animation complete in deckVC")
//
//            self.switchTransitions = !self.switchTransitions
//            self.resetFlipBackToFront()
//
//
//        })
//    }





