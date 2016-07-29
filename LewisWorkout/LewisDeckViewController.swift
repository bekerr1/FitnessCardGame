//
//  LewisDeckViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/31/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisDeckViewController: UIViewController {
    
    //MARK: Properties
    
    var switchTransitions: Bool = true
    var deckModel: LewisDeck
    
    lazy var cardBackView: LewisCardBackView = {
        print("fromView initialized")
        let aview: LewisCardBackView = LewisCardBackView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.grayColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        return aview
    }()
    
    lazy var cardFrontView: LewisCardFrontView = {
        print("toView initialized")
        let aview: LewisCardFrontView = LewisCardFrontView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.whiteColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        return aview
    }()
    
    
    //MARK: Initialize/ViewCalls
    
    required init?(coder aDecoder: NSCoder) {
        self.deckModel = LewisDeck()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("deck init in deckVC")
        
        self.view.clipsToBounds = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appeared in deckVC")
        
        self.view.addSubview(cardFrontView)
        self.view.addSubview(cardBackView)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("view appeared in deckVC")
        
        //generateNewCardForViewing()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        print("subviews layed in deckVC")
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: animations
    
    func deckTapTransitionTo() {

        generateNewCardForViewing()
        flip()
        //animateTransition()
    }
    
    
    func flip() {
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
        
        UIView.transitionWithView(self.view, duration: 1.0, options: transitionOptions, animations: {
            self.cardBackView.hidden = true
            self.cardFrontView.hidden = false
            }, completion: nil)
    }
    
    
    
    func resetTransitionViews() {
        
        self.cardBackView.hidden = false
        self.cardFrontView.hidden = true
        //self.cardFrontView.currentCardModel = nil
    }
    
    //MARK: Model stuff
    
    func randomCardFromDeck() -> LewisCard {
        return deckModel.pickRandomCard()
    }

    
    func generateNewCardForViewing() {
        
        let card = randomCardFromDeck()
        print("\(card.suit), \(card.rank)")
        cardFrontView.newCardToView(card, Sideways: true)
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
//            self.resetTransitionViews()
//
//
//        })
//    }





