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
    
    func pushupCompleted()
}


class FaceRectFilter {
    
    enum CurrentPushupPosition {
        case start
        case up
        case down
        case finish
    }
    
    var pushupCycle: CurrentPushupPosition = .start {
        willSet {
            lastAction = pushupCycle
        }
    }
    var lastAction: CurrentPushupPosition = .start
    
    var faceRectQueue = DetectionQueue<CGRect>()
    var faceAreaArray = Array<CGFloat>()
    
    var delegate: PushupDelegate?
    
    var initialSamplesCG: [CGFloat]
    var valuesSampledCG: CGFloat
    var currentSamplesF: [Float]
    
    var currentSamplePointer: Int = 0
    var currentDeclinedAreas: Int = 0
    
    var valuesTracked: Int = 5
    var valuesSampledUI: UInt
    var runningMeanCG: CGFloat = 0.0
    var runningMeanF: Float = 0.0
    
    var allowedPercentOfMean: Float = 0.0
    let percentOfMean: Float = 0.30
    var allowedPercentOfMeanCG: CGFloat = 0.0
    let percentOfMeanCG: CGFloat = 0.30
    
    var countOfAreas: CGFloat = 0.0
    var runningSum: CGFloat = 0.0
    var runningStdDev: CGFloat = 0.0
    
    var pushupCount = 0
    var sum: Float = 0.0
    var startingMean: Float = 0.0
    init(WithInitialPoints samples: [CGFloat], FromNumberOfValues count: CGFloat) {
        
        initialSamplesCG = samples
        valuesSampledCG = count
        currentSamplesF = Array()
        valuesSampledUI = 0
        
        initialSamplesCG.foreach {
            self.runningMeanCG += $0
        }
        runningMeanCG /= valuesSampledCG
        
        allowedPercentOfMeanCG = runningMeanCG * percentOfMeanCG
    }
    
    init(WithInitialPoints samples: [Float], FromNumberOfValues count: UInt) {
        
        currentSamplesF = Array(samples[0..<valuesTracked])
        valuesSampledUI = UInt(currentSamplesF.count)
        initialSamplesCG = Array()
        valuesSampledCG = 0.0
        currentSamplePointer = 0
        
        vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        startingMean = runningMeanF
        allowedPercentOfMean = runningMeanF * percentOfMean
        print("InitialMean: \(runningMeanF), AllowedOffset: \(allowedPercentOfMean)")
        
    }
    
    func newRectArrived(rect: CGRect) {
        
        
        let faceRectArea = rect.size.height * rect.size.width
        
        
        if Float(faceRectArea) < (runningMeanF + allowedPercentOfMean) && Float(faceRectArea) > (runningMeanF - allowedPercentOfMean) {
            print("FaceRectArea allowed: \(faceRectArea)")
            //currentSamplesF[currentSamplePointer] = Float(faceRectArea)
            currentSamplePointer += 1
            currentDeclinedAreas = 0
            
            if valuesSampledUI < 6 && valuesSampledUI != 5 {
                valuesSampledUI = UInt(currentSamplePointer)
            }
            
            if  runningMeanF == startingMean && lastAction == .down {
                pushupCycle = .up
            }
            
            
            
            print(valuesSampledUI)
            
            
        } else {
            
            //values arent being accepted
            //print("FaceRectArea outside allowed value: \(faceRectArea)")
            currentDeclinedAreas += 1
            if currentDeclinedAreas == 5 {
                //currentSamplesF = Array(count: Int(valuesTracked), repeatedValue: 0)
                valuesSampledUI = 0
                currentSamplePointer = 0
                runningMeanF = startingMean
            }
        }
        
        //check if waiting for accepted mean values
        if currentDeclinedAreas >= 5 {
            print("CurrentlyDeclined")
            pushupCycle = .down
            //dont calculate mean - at this point values sampled = 1 and current samples is an array of all 0's
        } else {
            
            vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        }
        
        //print("runningMean: \(runningMeanF)")
        
        
        //reset circular buffer
        if self.currentSamplePointer == valuesTracked {
            self.currentSamplePointer = 0
        }
        
        checkForCompletedCycle()
        
    }
    
    
    
    func checkForCompletedCycle() {
        
        switch pushupCycle {
        case .up:
            print("COUNT PUSHUP")
            
            NSNotificationCenter.defaultCenter().postNotificationName("pushupCompleted", object: nil)
            pushupCycle = .start
            pushupCount += 1
            
        default:
            break
        }
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








//let faceRectCenter = CGPointMake(rect.origin.x + CGRectGetWidth(rect)/2, rect.origin.y + CGRectGetHeight(rect)/2);