//
//  LWAnimatedSlider.swift
//  Calibrate Slider
//
//  Created by brendan kerr on 7/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import QuartzCore

class LWAnimatedSlider: UIControl {
    
    override var frame: CGRect {
        didSet {
            updateSliderLayerPosition()
        }
    }
    
    var animationTime: NSTimeInterval
    var flexableSlider: Bool = true
    var horizontal: Bool = true
    var gradientWhileSliding: Bool = true
    
    var previousLocation: CGPoint?
    let maxValue: Double = 1.0
    let minValue: Double = 0.0
    var sliderPosition: Double = 0.0
    var sliderStartPosition: CGPoint = CGPointZero
    var sliderStartFrame: CGRect = CGRectZero
    
    let rectInsetLayer: LWSlidePadLayer = LWSlidePadLayer()
    let sliderLayer: LWSliderLayer = LWSliderLayer()
    
    override init(frame: CGRect) {
        animationTime = 0.0
        super.init(frame: frame)
        
        rectInsetLayer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.addSublayer(rectInsetLayer)
        
        sliderLayer.backgroundColor = UIColor.blackColor().CGColor
        self.layer.addSublayer(sliderLayer)
        
        //configLayerFrames()
    }
    
    
    func configLayerFrames() {
        
        let insetFrame = CGRectInset(self.layer.frame, 12.0, 6.0)
        print(NSStringFromCGRect(self.layer.frame), NSStringFromCGRect(insetFrame))
        rectInsetLayer.frame = CGRectMake(0, 0, insetFrame.width, insetFrame.height)
        rectInsetLayer.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        rectInsetLayer.cornerRadius = 10        
        
        rectInsetLayer.configGradient()
        
        sliderStartPosition = CGPointMake(12, 3)
        sliderStartFrame = CGRectMake(sliderStartPosition.x, sliderStartPosition.y, insetFrame.height, insetFrame.height + 6)
        sliderLayer.frame = sliderStartFrame
        sliderLayer.cornerRadius = 5
        sliderLayer.borderWidth = 0.5
        sliderLayer.borderColor = UIColor.whiteColor().CGColor
        
        sliderLayer.configRidges()
        
        
    }
    
    
    convenience init(WithAnimationTime interval: NSTimeInterval, InitialFrame frame: CGRect) {
        
        self.init(frame: frame)
        animationTime = interval
        print("convinience continues")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func updateSliderLayerPosition() {
        
        let newSliderPoint = CGFloat(positionForNewValue(NewValue: sliderPosition))
        //sliderLayer.position = CGPointMake(sliderStartPosition.x + newSliderPoint, sliderStartPosition.y)
         sliderLayer.frame = CGRectMake(sliderStartPosition.x + newSliderPoint - thumbWidth/2.0, sliderStartPosition.y, sliderLayer.frame.width, sliderLayer.frame.height)
        sliderLayer.setNeedsDisplay()
        
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    func positionForNewValue(NewValue value: Double) -> Double {
        // the sliders movable distance                                //Sliders Position
        print("Value coming in: \(value)")
        let movableDistance = Double((frame.width - 50))
        let distancePlusSliderWid = (maxValue - minValue)
        let returnPosition = (movableDistance * (value - minValue)) / (distancePlusSliderWid) + Double(thumbWidth / 2.0) //movable distance + half slider width
        print("New position: \(returnPosition)")
        return Double(returnPosition)
        
    }

    //MARK: TOUCH tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        //first touch
        previousLocation = touch.locationInView(self)
        
        if sliderLayer.frame.contains(previousLocation!) {
            print("Slider begin touch")
            sliderLayer.touched = true
        }
        
        return sliderLayer.touched
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }

    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        //Keep touching
        let location = touch.locationInView(self)
        
        let changeInLocation = Double(location.x - previousLocation!.x)
        let changeValue = ((maxValue - minValue) * changeInLocation) / ((Double(bounds.width) - Double(sliderLayer.frame.width)))
        print("location Change: \(changeInLocation), Value change: \(changeValue)")
        
        previousLocation = location
        
        if sliderLayer.touched {
            sliderPosition += changeValue
            sliderPosition = boundValue(sliderPosition, toLowerValue: minValue, upperValue: maxValue)
            sliderLayer.sliding = true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        print("sliderPosition on update: \(sliderPosition)")
        updateSliderLayerPosition()
        CATransaction.commit()
        
        return sliderLayer.sliding
        
    }
    
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        //Touches are over
        
        sliderLayer.sliding = false
        sliderLayer.touched = false
        
        if sliderPosition != 1.0 {
            sliderLayer.animateSliderBack(To: sliderStartPosition)
            sliderPosition = 0.0
        } else {
            //slider reached full range - initiate calibration -
            //Calibration will be a 2 step process, will take about 5 seconds - for the first 3.5 seconds nothing will happen as to give the user time to get into position - the last 1.5 seconds will be used to collect face samples and give to the detection center.
        }
    }
    
    
    //MARK: Animations
    
        
    
    
}
