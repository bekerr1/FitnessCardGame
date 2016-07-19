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

class FaceRectFilter {
    
    
    var faceRectQueue = DetectionQueue<CGRect>()
    var faceAreaArray = Array<CGFloat>()
    let rectAnalyzer: FaceRectAnalyzer = FaceRectAnalyzer()
    
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
    
    var count = 0
    var sum: Float = 0.0
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
        allowedPercentOfMean = runningMeanF * percentOfMean
        print("InitialMean: \(runningMeanF), AllowedOffset: \(allowedPercentOfMean)")
        
    }
    
    func newRectArrived(rect: CGRect) {
        
        
        let faceRectArea = rect.size.height * rect.size.width
        count += 1
        
        if Float(faceRectArea) < (runningMeanF + allowedPercentOfMean) && Float(faceRectArea) > (runningMeanF - allowedPercentOfMean) {
            print("FaceRectArea allowed: \(faceRectArea)")
            currentSamplesF[currentSamplePointer] = Float(faceRectArea)
            currentSamplePointer += 1
            currentDeclinedAreas = 0
            
            if valuesSampledUI < 6 {
                valuesSampledUI = UInt(currentSamplePointer)
            }
            
        } else {
            
            //values arent being accepted
            print("FaceRectArea outside allowed value: \(faceRectArea)")
            currentDeclinedAreas += 1
            if currentDeclinedAreas == 10 {
                currentSamplesF = Array(count: Int(valuesSampledUI), repeatedValue: 0)
                valuesSampledUI = 0
                currentSamplePointer = 0
            }
        }
        
        //check if waiting for accepted mean values
        if currentDeclinedAreas >= 10 {
            
            //dont calculate mean - at this point values sampled = 1 and current samples is an array of all 0's
        } else {
            
            vDSP_meanv(&currentSamplesF, 1, &runningMeanF, valuesSampledUI)
        }
        
        print("runningMean: \(runningMeanF)")
        
        
        //reset circular buffer
        if self.currentSamplePointer == Int(valuesSampledUI) {
            self.currentSamplePointer = 0
        }
        
    }
    
    
    func calculateStdDev() {
        
        
        

    }
    
//    func computeRunningStdDev() {
//        
//        faceAreaArray.foreach {
//            self.runningStdDev += ($0 - self.runningMean) * ($0 - self.runningMean)
//        }
//        runningStdDev /= countOfAreas
//        runningStdDev = sqrt(runningStdDev)
//        
//        print(runningStdDev)
//    }
}


class FaceRectAnalyzer {
    
    var faceRectQueue = DetectionQueue<CGRect>()
    
    init() {}
    
    func newRectArrived(rect: CGRect) {
        
        faceRectQueue.enqueue(rect)
        
    }
    
    func engine() {
        
        
        while true {
            if let rect = faceRectQueue.dequeue() {
                processRect(rect)
            }
            
        }
    }
    
    
    func processRect(faceRect: CGRect) {
        
        
        

    }
}









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