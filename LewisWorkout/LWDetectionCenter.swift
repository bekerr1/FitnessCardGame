//
//  LewisDetectionCenter.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/13/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import Accelerate


extension Array {
    
    func foreach(function: Element -> ()) {
        for elem in self {
            function(elem)
        }
    }
}

protocol PushupDelegate {
    
    func motionCompleted()
}



struct DetectionConfidence {
    
    var confidenceInDetection: CGFloat = 0
    var firstAreaAccepted: CGFloat = 0.0
    var currentArea: CGFloat? {
        willSet (newValue) {
            changeInArea = newValue! - firstAreaAccepted
        }
    }
    var changeInArea: CGFloat?
    
    let lowConfidence: CGFloat = 2
    let weakChange: CGFloat = 3000
    let mediumConfidence: CGFloat = 5
    let highConfidence: CGFloat = 10
    let strongChange: CGFloat = 8000
    let tolerance: CGFloat = 1.0
    
    init(WithFirstArea area: CGFloat) {
        print("Creating new confidence with first Area: \(area)")
        firstAreaAccepted = area
    }
    
    mutating func addToConfidence(NewArea faceArea: CGFloat) {
        confidenceInDetection += 1
        currentArea = faceArea
        print("added to confidence, confidence now at: \(confidenceInDetection) and change in area now at: \(changeInArea)")
    }
    
    
    mutating func checkConfidence(ForMotion position: PushupPosition) -> Bool {
        
        //if high confidence or medium confidence, change can be linient and still pass
//        if confidenceInDetection >= (highConfidence * tolerance) && lenientChange(ForMotion: position)  {
//            return true
//        } else if confidenceInDetection >= (mediumConfidence * tolerance) && lenientChange(ForMotion: position) {
//            return true
//            //when confidence is low, must have a confident change to pass
//        } else if confidenceInDetection >= (lowConfidence * tolerance) && confidentChange(ForMotion: position) {
//            return true
//        } else if confidentChange(ForMotion: position) {
//            return true
//        } else {
//            //not enough proof to complete current motion
//        }
//        return false
        if confidentChange(ForMotion: position) {
            return true
        } else {
            return false
        }
    }
    
    
    func lenientChange(ForMotion position: PushupPosition) -> Bool {
        if confidentChange(ForMotion: position) {
            return true
        } else {
            switch position {
            case .up:
                //up code
                return (changeInArea > weakChange) ? true : false
                
            case .down:
                //downcode
                return (changeInArea < -weakChange) ? true : false
                
//            default:
//                print("default")
            }
        }
    }
    
    func confidentChange(ForMotion position: PushupPosition) -> Bool {
        print("change in area: \(changeInArea)")
        switch position {
        case .up:
            //up code
            return (changeInArea > (strongChange * tolerance)) ? true : false
            
        case .down:
            //downcode
            return (changeInArea < -(strongChange * tolerance)) ? true : false
            
//        default:
//            print("default")
        }
    }
}




struct FaceRectFilter {
    
    var faceAreaArray = Array<CGFloat>()
    var lastAreaFromPreviousMotion: CGFloat = 0.0
    var delegate: PushupDelegate?
    var currentMotion: PushupPosition
    var currentSamplesF: [Float]
    var runningMeanF: Float = 0.0
    var lastValue: CGFloat
    var currentSamplePointer: Int = 0
    var currentDeclinedAreas: Int = 0
    var valuesSampledUI: UInt
    let upperPercent: CGFloat = 1.30
    let lowerPercent: CGFloat = 0.70
    var confidence: DetectionConfidence?
    
    
    init(WithInitialPoints samples: [Float], FromNumberOfValues count: UInt, CurrentMotion motion: PushupPosition) {
        
        currentMotion = motion
        currentSamplesF = samples
        valuesSampledUI = UInt(currentSamplesF.count)
        currentSamplePointer = 0
        
        vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        
        lastValue = CGFloat(runningMeanF)
        
        print("InitialMean: \(runningMeanF), AllowedOffset between: \(CGFloat(runningMeanF) * upperPercent), \(CGFloat(runningMeanF) * lowerPercent)")
        
    }
    
    
    mutating func newAreaArrived(area: CGFloat) {
        
        
        if checkIfAreaIsInRange(Area: area) {
            confidence?.addToConfidence(NewArea: area)
        }
        
        vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        
        if currentSamplePointer == Int(valuesSampledUI) {
            currentSamplePointer = 0
        }
        
        guard var nonnilconfidence = confidence else {
            return
        }
        
        if nonnilconfidence.checkConfidence(ForMotion: currentMotion) {
            delegate?.motionCompleted()
            lastAreaFromPreviousMotion = nonnilconfidence.currentArea!
            confidence = nil
        }
    }
    
    mutating func newAreaArrived(area: CGFloat, Operation operate: (Float, Float) -> Bool, Condition condition: (Float, Float) -> Bool) {
        
        
        if checkIfAreaIsInRange(Area: area, Operation: operate, Condition: condition) {
            confidence?.addToConfidence(NewArea: area)
        }
        
        vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        
        if currentSamplePointer == Int(valuesSampledUI) {
            currentSamplePointer = 0
        }
        
        guard var nonnilconfidence = confidence else {
            return
        }
        
        if nonnilconfidence.checkConfidence(ForMotion: currentMotion) {
            delegate?.motionCompleted()
            lastAreaFromPreviousMotion = nonnilconfidence.currentArea!
            confidence = nil
        }
    }


    
    mutating func checkIfAreaIsInRange(Area faceRectArea: CGFloat, Operation operate: (Float, Float) -> Bool, Condition condition: (Float, Float) -> Bool) -> Bool {
        
        var percentOfMean: Float = 0.0
        var minMaxValue: Float = 0.0
        var conditioner: Float = 0.0
        
        if operate(1, 0) {
            percentOfMean = Float(lowerPercent)
            minMaxValue = currentSamplesF[0]
            conditioner = Float(upperPercent)
        } else {
            percentOfMean = Float(upperPercent)
            minMaxValue = Float(lastAreaFromPreviousMotion)
            conditioner = Float(lowerPercent)
        }
        
        
        if operate(Float(faceRectArea), Float(lastValue)) && operate(Float(faceRectArea), minMaxValue) && condition(Float(faceRectArea), Float(lastValue) * conditioner) {
            print("FaceRectArea allowed: \(faceRectArea)")
            currentSamplesF[currentSamplePointer] = Float(faceRectArea)
            currentSamplePointer += 1
            lastValue = faceRectArea
            
            if confidence == nil {
                confidence = DetectionConfidence(WithFirstArea: (lastAreaFromPreviousMotion > 0.0) ? lastAreaFromPreviousMotion : CGFloat(runningMeanF))
            }
            return true
        } else {
            print("FaceRectArea not allowed: \(faceRectArea)")
        }
        return false
    }
    
    
    mutating func checkIfAreaIsInRange(Area faceRectArea: CGFloat) -> Bool {
        
        //if Float(faceRectArea) < (runningMeanF * upperPercentOfMean) && Float(faceRectArea) > (runningMeanF * lowerPercentOfMean)
        if faceRectArea < (lastValue * upperPercent) && faceRectArea > (lastValue * lowerPercent) {
            print("FaceRectArea allowed: \(faceRectArea)")
            currentSamplesF[currentSamplePointer] = Float(faceRectArea)
            currentSamplePointer += 1
            lastValue = faceRectArea
            
            if confidence == nil {
                confidence = DetectionConfidence(WithFirstArea: (lastAreaFromPreviousMotion > 0.0) ? lastAreaFromPreviousMotion : CGFloat(currentSamplesF[0]))
            }
            return true
        } else {
            print("FaceRectArea not allowed: \(faceRectArea)")
        }
        return false
    }
}




//class FaceRectAnalyzer {
//
//    var faceRectQueue = DetectionQueue<CGRect>()
//    
//    init() {}
//    
//    func newRectArrived(rect: CGRect) {
//        
//        faceRectQueue.enqueue(rect)
//        
//    }
//    
//    func engine() {
//        
//        
//        while true {
//            if let rect = faceRectQueue.dequeue() {
//                processRect(rect)
//            }
//            
//        }
//    }
//    
//    
//    func processRect(faceRect: CGRect) {
//        
//        
//        
//
//    }
//}
//
//
//
//





//        if !faceFound {
//            faceRectAreasForAverage.append(faceRectArea)
//        }
//
//        //print("change in area = \(changeInArea)")
//        //print("Face Rect Area = \(faceRectArea), Face Rect Center = \(faceRectCenter)")
//
//        //Happens on tap of screen - data is collected for face rect only
//        if collectPushupData {
//
//            if deleteDataFileOnNewInstance {
//                deleteDataFiles([rectDataPath, brightnessDataPath])
//            }
//
//            feedDataToFileWithFaceRectArea(faceRectArea, FaceRectCenter: faceRectCenter)
//        }





//STANDARD DEVIATION USING ACCELERATE

//        float *imageR =  [0.1,0.2,0.3,0.4,...]; // vector of values
//        int numValues = 100; // number of values in imageR
//        float mean = 0; // place holder for mean
//        vDSP_meanv(imageR,1,&mean,numValues); // find the mean of the vector
//        mean = -1*mean // Invert mean so when we add it is actually subtraction
//        float *subMeanVec  = (float*)calloc(numValues,sizeof(float)); // placeholder vector
//        vDSP_vsadd(imageR,1,&mean,subMeanVec,1,numValues) // subtract mean from vector
//        free(imageR); // free memory
//        float *squared = (float*)calloc(numValues,sizeof(float)); // placeholder for squared vector
//        vDSP_vsq(subMeanVec,1,squared,1,numValues); // Square vector element by element
//        free(subMeanVec); // free some memory
//        float sum = 0; // place holder for sum
//        vDSP_sve(squared,1,&sum,numValues); sum entire vector
//        free(squared); // free squared vector
//        float stdDev = sqrt(sum/numValues); // calculated std deviation



//    mutating func checkForCompletedCycle() {
//
//        switch pushupCycle {
//        case .up:
//            print("COUNT PUSHUP")
//
//            NSNotificationCenter.defaultCenter().postNotificationName("pushupCompleted", object: nil)
//            pushupCycle = .start
//            pushupCount += 1
//
//        default:
//            break
//        }
//    }



//        lastArea = thisArea
//        thisArea = faceArea
//
//        switch motion {
//        case .down:
//            if thisArea < lastArea {
//                confidenceInDetection += 1
//            } else {
//                confidenceInDetection -= 1
//            }
//            break
//        case .start:
//            if thisArea > lastArea {
//                confidenceInDetection += 1
//            } else {
//                confidenceInDetection -= 1
//            }
//            break
//        default:
//            print("default")
//        }




//} else {
//    
//    //values arent being accepted
//    //print("FaceRectArea outside allowed value: \(faceRectArea)")
//    currentDeclinedAreas += 1
//    if currentDeclinedAreas == 5 {
//        //currentSamplesF = Array(count: Int(valuesTracked), repeatedValue: 0)
//        valuesSampledUI = 0
//        currentSamplePointer = 0
//        runningMeanF = startingMean
//    }
//}
//




//let faceRectCenter = CGPointMake(rect.origin.x + CGRectGetWidth(rect)/2, rect.origin.y + CGRectGetHeight(rect)/2);