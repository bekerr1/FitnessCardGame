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
        return confidentChange(ForMotion: position)
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
        }
    }
}




class FaceRectFilter {
    
    var faceAreaArray = Array<CGFloat>()
    var lastAreaFromPreviousMotion: CGFloat = 0.0
    var delegate: PushupDelegate?
    var currentMotion: PushupPosition
    var currentSamplesF: [Float] = Array()
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
    
    
    func newAreaArrived(area: CGFloat) {
        
        
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
    
    func newAreaArrived(area: CGFloat, Operation operate: (Float, Float) -> Bool, Condition condition: (Float, Float) -> Bool) {
        
        
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


    
    func checkIfAreaIsInRange(Area faceRectArea: CGFloat, Operation operate: (Float, Float) -> Bool, Condition condition: (Float, Float) -> Bool) -> Bool {
        
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
    
    
    func checkIfAreaIsInRange(Area faceRectArea: CGFloat) -> Bool {
        
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



class PushupStatistics {
    
    private var maxValues: [Float]
    private var enoughMaxValues: Bool
    private var minValues: [Float]
    private var enoughMinValues: Bool
    
    var averageMaxValue: Float {
        didSet {
            medianOfAverages = averageMaxValue - averageMinValue
        }
    }
    var averageMinValue: Float {
        didSet {
            medianOfAverages = averageMaxValue - averageMinValue
        }
    }

    var medianOfAverages: Float?
    
    
    init() {
        maxValues = Array()
        averageMaxValue = 0.0
        enoughMaxValues = false
        
        minValues = Array()
        averageMinValue = 0.0
        enoughMinValues = false
    }
    
    func needMoreData(WithID sid: String) -> (Bool, (Float) -> ()) {
        switch sid {
        case "Max":
            if maxValues.count < 5 {
                enoughMaxValues = false
                return (false, { data in
                    print("max value recieved of \(data)")
                    self.maxValues.append(data)
                })
                
            } else {
                enoughMaxValues = true
            }
        case "Min":
            if minValues.count < 10 {
                enoughMinValues = false
                return (false, { data in
                    print("min value recieved of \(data)")
                    self.minValues.append(data)
                })
                
            } else {
                enoughMinValues = true
            }
        default: break
            
        }
        
        return calibrationComplete()
    }
    
    
    func calibrationComplete() -> (Bool, (Float) -> ()) {
        minValues = Array(Set(minValues))
        maxValues = Array(Set(maxValues))
        return ((enoughMaxValues && enoughMinValues), {_ in
            self.averageMaxValue = self.maxValues.reduce(0, combine: +)
            self.averageMaxValue = (self.maxValues.count != 0) ? self.averageMaxValue / Float(self.maxValues.count) : self.averageMaxValue / 1
            
            self.averageMinValue = self.minValues.reduce(0, combine: +)
            self.averageMinValue = (self.minValues.count != 0) ? self.averageMinValue / Float(self.minValues.count) : self.averageMinValue / 1
            
        })
    }
    
}



enum BadStatisticError: ErrorType {
    case badStatistic(String)
}


//Made up of all value types!! could this be a struct or is it too big??!?! Large structs are stored on the heap anyway, is the class mem allocation really that bad...
class PushupData {
    
    enum ValueDescription {
        
        case increasing(Int, Float, Float, Float)
        case decreasing(Int, Float, Float, Float)
        case neutral
        
        var thisManyTimes: Int {
            switch self {
            case .increasing(let times, _,  _, _):
                return times
                
            case .decreasing(let times, _, _, _):
                return times
                
            case neutral:
                return 0
            }
        }
        
        var currentValue: Float {
            switch self {
            case .increasing(_, let currentVal, _, _):
                return currentVal
            case .decreasing(_, let currentVal, _, _):
                return currentVal
            case .neutral:
                return 0
            }
        }
        
        var change: Float {
            switch self {
            case .increasing(_, let val, let previous, let change):
                return change + (val - previous)
            case .decreasing(_, let val, let previous, let change):
                return change + (previous - val)
            case .neutral:
                return 0
            }
        }
        
        var valueType: String {
            switch self {
            case .increasing(_, _, _, _):
                return "Max"
            case .decreasing(_, _, _, _):
                return "Min"
            default:
                "Something Else"
            }
            return ""
        }
    }
    
    var maxValue: Float?
    var minValue: Float?
    var meanValue: Float?
    var pushupValues: [Float] = Array()
    var pushupCounter: Int = 0
    var changeInPushup: Float = 0
    var valueCount: Int = 0
    var frameCount: Int = 0
    var vDescription: ValueDescription = .neutral
    var previousValue: Float = 0.0
    
    //var valueAnalyzer: (Float, Float, Int, Float) -> (Int, Float)
    
    init() {}
    
    func valueAnalyzer(OfPrevious previousValue: Float, Current value: Float, PushupCount count: Int, ChangeInValue totalChange: Float) -> (Int, Float, String) {
        
        switch self.vDescription {
        case .increasing(count, _, _, _):
            if value > previousValue - 1000 {
                
                self.vDescription = .increasing(count + 1, value, previousValue, totalChange)
                //print("increasing value \(self.vDescription.thisManyTimes) times with a change of \(self.vDescription.change)")
                
            } else if value == previousValue {
                self.vDescription = .increasing(count + 1, value, previousValue, 0)
            } else {
                self.vDescription = .decreasing(0, 0, 0, 0)
                return (0, 0, "")
            }
            
            
            
        case .decreasing(count, _, _, _):
            if value < previousValue + 1000 {
                
                self.vDescription = .decreasing(count + 1, value, previousValue, totalChange)
                //print("decreasing value \(self.vDescription.thisManyTimes) times with a change of \(self.vDescription.change)")
                
            } else if value == previousValue {
                self.vDescription = .decreasing(count + 1, value, previousValue, 0)
            } else {
                self.vDescription = .increasing(0, 0, 0, 0)
                return (0, 0, "")
            }
            
            
        case .neutral:
            
            print("starting out neutral")
            self.vDescription = value >= previousValue ? .increasing(count, value, 0, totalChange) : .decreasing(count, value, 0, totalChange)
            return (count, totalChange, "")
            
        default:
            
            print("IS NEUTRAL")
            self.vDescription = .neutral
        }
        
        return (count + 1, self.vDescription.change, self.vDescription.valueType)
    }
    
    
    func insertValue(ToAnalyze value: Float, GoodStat block: (Int, Float, String) -> ()) throws {
        frameCount += 1
        var stringMaxMinID: String = ""
        
        if frameCount > 20 {
            //print("new value to analyze \(value)")
            pushupValues.append(value)
            (pushupCounter, changeInPushup, stringMaxMinID) = valueAnalyzer(OfPrevious: previousValue, Current: value, PushupCount: pushupCounter, ChangeInValue: changeInPushup)
        } else {
            print("still ignoring frames")
        }
        
        previousValue = value
        
        guard let _ = goodStatistic() else {
            throw BadStatisticError.badStatistic("Unreliable Statistic.")
        }
        
        block(pushupCounter, previousValue, stringMaxMinID)
    }
    
    
    func goodStatistic() -> Bool? {
        
        if pushupCounter >= 3 && changeInPushup > 5000 { //just changed to 7000 w/o testing, 6500 worked
            return true
        }
        return nil
    }
    
    
}







//    mutating func createAnalyzer() {
//
//        self.valueAnalyzer = { previousValue, value, count, totalChange in
//
//            var returnCount = 0
//            var returnChange: Float = 0.0
//
//            switch self.vDescription {
//            case .increasing(count, _, _, _):
//                if value > previousValue - 1000 {
//
//                    self.vDescription = .increasing(count + 1, value, previousValue, totalChange)
//                    print("increasing value \(self.vDescription.thisManyTimes) times with a change of \(self.vDescription.change)")
//
//                } else if value == previousValue {
//                    self.vDescription = .increasing(count + 1, value, previousValue, 0)
//                } else {
//                    self.vDescription = .decreasing(0, 0, 0, 0)
//                    return (0, 0)
//                }
//
//                returnCount = count + 1
//                returnChange = self.vDescription.change
//
//            case .decreasing(count, _, _, _):
//                if value < previousValue + 1000 {
//
//                    self.vDescription = .decreasing(count + 1, value, previousValue, totalChange)
//                    print("decreasing value \(self.vDescription.thisManyTimes) times with a change of \(self.vDescription.change)")
//
//                } else if value == previousValue {
//                    self.vDescription = .decreasing(count + 1, value, previousValue, 0)
//                } else {
//                    self.vDescription = .increasing(0, 0, 0, 0)
//                    return (0, 0)
//                }
//
//                returnCount = count + 1
//                returnChange = self.vDescription.change
//
//            case .neutral:
//
//                print("starting out neutral")
//                self.vDescription = value >= previousValue ? .increasing(count, value, 0, totalChange) : .decreasing(count, value, 0, totalChange)
//                return (count, totalChange)
//
//            default:
//
//                print("IS NEUTRAL")
//                self.vDescription = .neutral
//            }
//            return (returnCount, returnChange)
//        }
//
//
//    }


//self.valueAnalyzer = { previousValue, value in
//    
//    switch self.vDescription {
//    case .increasing(Int(previousValue)):
//        if value > previousValue {
//            print("increasing value")
//            self.vDescription = .increasing(value)
//        }
//        break
//        
//    case .decreasing(Int(previousValue)):
//        if value < previousValue {
//            print("decreasing value")
//            self.vDescription = .decreasing(value)
//        }
//        break
//        
//    case .neutral:
//        print("starting out neutral")
//        self.vDescription = value >= previousValue ? .increasing(value) : .decreasing(value)
//        
//    default:
//        print("IS NEUTRAL")
//        self.vDescription = .neutral
//    }
//}



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