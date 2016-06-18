//
//  LewisDeckViewController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 5/31/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class LewisDeckViewController: UIViewController {
    
    
    var switchTransitions: Bool = true
    var deckModel: LewisDeck

    lazy var cardBackView: LewisCardBackView = {
        print("fromView initialized")
        let aview: LewisCardBackView = LewisCardBackView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.redColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        aview.layer.cornerRadius = 20.0
        return aview
    }()
    
    lazy var cardFrontView: LewisCardFrontView = {
        print("toView initialized")
        let aview: LewisCardFrontView = LewisCardFrontView.init(frame: self.view.bounds)
        aview.backgroundColor = UIColor.whiteColor()
        aview.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        aview.layer.cornerRadius = 20.0
        return aview
    }()
    
    
    //MARK: Initialize
    
    required init?(coder aDecoder: NSCoder) {
        self.deckModel = LewisDeck()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("deck init")
        
        self.view.clipsToBounds = true
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appeared")

        self.view.addSubview(self.cardFrontView)
        self.view.addSubview(self.cardBackView)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("view appeared")
        
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

        animateTransition()
    }
    
    
    func animateTransition() {
        
        UIView.transitionFromView((switchTransitions ? self.cardBackView : self.cardFrontView), toView: (switchTransitions ? self.cardFrontView : self.cardBackView), duration: 1.0, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: {(complete: Bool) -> () in
            print("transition animation complete")
            
            self.switchTransitions = !self.switchTransitions
            
            
        
        })
    }
    
    
    func resetTransitionViews() {
        
        if self.switchTransitions {
            self.cardBackView.backgroundColor = UIColor.redColor()
            self.cardFrontView.backgroundColor = UIColor.greenColor()
        } else {
            self.cardBackView.backgroundColor = UIColor.greenColor()
            self.cardFrontView.backgroundColor = UIColor.redColor()
        }
    }
    
    //MARK: Model stuff
    
    func randomCardFromDeck() -> LewisCard {
        
        return deckModel.pickRandomCard()
    }
    
    


}

















