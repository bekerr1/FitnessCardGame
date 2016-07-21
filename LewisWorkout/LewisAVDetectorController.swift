//
//  LewisAVDetectorController.swift
//  LewisWorkout
//
//  Created by brendan kerr on 6/1/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import CoreImage
import CoreVideo
import ImageIO
import AVFoundation

enum AVSettingsSetupResult {
    case InputFailed
    case OutputFiled
    case CameraNotAuthorized
    case CameraRestricted
    case Success
    
}

enum ImageOrientation: Int {
    case PHOTOS_EXIF_0ROW_TOP_0COL_LEFT = 1, PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT = 2, PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT = 3, PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT = 4, PHOTOS_EXIF_0ROW_LEFT_0COL_TOP = 5, PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP = 6, PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM = 7, PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM = 8
}


protocol DetectorClassProtocol {
    
    func gotCIImageFromVideoDataOutput(image: CIImage)
    func getCenterForAlignment(CenterPoint center: CGPoint)
}


class LewisAVDetectorController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //MARK: Properties
    var detectionCount = 0
    var delegate: DetectorClassProtocol!
    var facesFound: UInt = 0
    
    var changeInArea: CGFloat = 0.0
    let areaChangeTolerance: CGFloat = 15000
    var oldFaceRectArea: CGFloat = 0.0
    var faceRectArea: CGFloat = 0.0
    var faceRectAreasForAverage: [CGFloat] = Array()
    var faceRectAreasForAccelerate: [Float] = Array()
    
    let faceDetector: CIDetector
    
    let rectDataPath: NSURL = {
        
        let fileName = "rectPushupData.txt"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let path = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(fileName)
        return path
        
    }()
    
    let brightnessDataPath: NSURL = {
        
        let fileName = "brightnessPushupData.txt"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let path = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(fileName)
        return path
        
    }()
    
    let captureDataOutput: AVCaptureVideoDataOutput = {
        print("capture output const")
        let capture = AVCaptureVideoDataOutput()
        //capture.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA as!  AnyObject]
        //capture.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        capture.alwaysDiscardsLateVideoFrames = true
        
        return capture
        
    }()
    
    let captureSession: AVCaptureSession = {
        
        let cs = AVCaptureSession()
        cs.sessionPreset = AVCaptureSessionPreset640x480
        return cs
        
    }()
    
    //let captureVideoPreviewLayer: AVCaptureVideoPreviewLayer
    var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    let square: UIImage = UIImage(named: "squarePNG")!
    
    let videoDataQueue: dispatch_queue_t = dispatch_queue_create("videoDataQueue", DISPATCH_QUEUE_SERIAL)
    let sessionSetupQueue: dispatch_queue_t = {
        
        let queue: dispatch_queue_t
        var attr: dispatch_queue_attr_t
        attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
            			QOS_CLASS_USER_INITIATED, 0);
        queue = dispatch_queue_create("sessionSetupQueue", attr)
        return queue
    }()
    
    var faceRectFilter: FaceRectFilter?
    
    var detectingMax: Bool = false
    var previewLayerActive: Bool = false
    var collectPushupData: Bool = false
    var deleteDataFileOnNewInstance: Bool = true
    var faceFound: Bool = false
    var calibrated: Bool = false
    
    let parentFrame: CGRect
    
    var setupResult: AVSettingsSetupResult = .Success
    
    //MARK: Inits
    
    //Convinience
    convenience override init() {
        self.init(withparentFrame: CGRectZero)
    }
    
    //Designated
    init(withparentFrame parentFrame: CGRect) {
        
        let context = CIContext()
        let detectorOptions = NSDictionary(objects: [CIDetectorAccuracyHigh, true, 0.5, 11], forKeys: [CIDetectorAccuracy, CIDetectorTracking, CIDetectorMinFeatureSize, CIDetectorNumberOfAngles])
        faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: detectorOptions as? [String : AnyObject])
        
        print("Detector Class Initialized (Phase 1)")
        self.parentFrame = parentFrame
        
        super.init()
        
        print("Working back down from super (Phase 2)")
        
        requestAuthorization()
        
        if setupResult == .Success {
            setupAVComponents()
        }
    }
    
    //MARK: AUTHORIZATION
    
    func requestAuthorization() {
        
        //REQUEST VIDEO AUTHORIZATION
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
            
        case AVAuthorizationStatus.Authorized:
            //User previously granted.
            break;
            
        case AVAuthorizationStatus.NotDetermined:
            //User has not yet granted access - ask user
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted: Bool) -> () in
                
                if granted {
                    print("camera was authorized by user")
                } else {
                    self.setupResult = .CameraNotAuthorized
                }
            })
            break
            
        case AVAuthorizationStatus.Denied:
            print("User did not give permission")
            self.setupResult = .CameraNotAuthorized
            break
            
        case AVAuthorizationStatus.Restricted:
            print("restricted")
            self.setupResult = .CameraRestricted
            break
            
        }

    }
    
    //MARK: Session setup
    
    func setupAVComponents() {
        print(#function)
        
        dispatch_async(sessionSetupQueue, {
            
            //SESSION
            
            //INPUT DEVICE
            let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            
            do {
                try device.lockForConfiguration()
                device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.Far
                device.unlockForConfiguration()
                print("range far set")
            } catch {
                
            }
            
            let inputDevice = self.deviceInputFromDevice(device)
            
            
            if self.captureSession.canAddInput(inputDevice) {
                self.captureSession.addInput(inputDevice)
            } else {
                print("input device couldnt be added")
            }
            
            //OUTPUT DEVICE
            self.captureDataOutput.setSampleBufferDelegate(self, queue: self.videoDataQueue)
            //SWift having trouble converting this
            //self.captureDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA as!  AnyObject]
            //print("captureData VideoSettings? = \(self.captureDataOutput.videoSettings.description)")
            
            if self.captureSession.canAddOutput(self.captureDataOutput) {
                self.captureSession.addOutput(self.captureDataOutput)
            } else {
                print("output device couldnt be added")
            }
            
            //PREVIEW LAYER
            let avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            avPreviewLayer.frame = self.parentFrame
            avPreviewLayer.backgroundColor = UIColor.blueColor().CGColor
            avPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer = avPreviewLayer
            
            //SWITCH FRONT CAMERA
            self.useFrontCamera()
            
            
            assert(self.setupResult == .Success)
            
            //self.startCaptureSession()
            
        })
        
        
    }
    
    //MARK: Session stuff
    
    func startCaptureSession() {
        print(#function)
        dispatch_async(sessionSetupQueue, {
            if self.setupResult == .Success {
                self.captureSession.startRunning()
                
            }
        })
    }
    
    func stopCaptureSession() {
        print(#function)
        dispatch_async(sessionSetupQueue, {
            self.captureSession.stopRunning()
        })
    }
    
    func getPreviewLayerForUse() -> AVCaptureVideoPreviewLayer {
        
        previewLayerActive = true
        return previewLayer
    }
    
    func useFrontCamera() {
        
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if device.position == .Front {
                previewLayer.session.beginConfiguration()
                let input = deviceInputFromDevice(device as! AVCaptureDevice)
                for oldInput in previewLayer.session.inputs {
                    previewLayer.session.removeInput(oldInput as! AVCaptureInput)
                    previewLayer.session.addInput(input)
                    previewLayer.session.commitConfiguration()
                    break
                }
            }
        }
    }
    
    func deviceInputFromDevice(device: AVCaptureDevice) -> AVCaptureDeviceInput {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            return deviceInput
        } catch {
            print("error when creating av input with device")
        }
        //Handle the case of no input device (program should not continue)
        let deviceInput = AVCaptureDeviceInput()
        assert(deviceInput.device != nil)
        return deviceInput
    }
    
    
    //MARK: FEATURES STUFF
    
    func drawFaceBoxesForFeatures(features: [CIFeature], forVideoBox videoBox: CGRect, deviceOrientation orientation: UIDeviceOrientation) {
        //print(#function)
        //Draw box on screen for testing of face detection, detect changes in box size
        
        let sublayersToPreviewLayer: [CALayer] = previewLayer.sublayers!
        
        var currentSublayer = 0
        let sublayersCount = sublayersToPreviewLayer.count
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        for layer in sublayersToPreviewLayer where layer.name == "FaceLayer" {
            //print("face layer found")
            layer.hidden = true
        }
        
        if features.count == 0 {
            //print("No features found this round")
            CATransaction.commit()
            return;
        } else {
            
            facesFound += 1
            if facesFound == 30 {
                faceFound = true
                calibrateForFacesFound()
            } else if facesFound % 10 == 0 {
                
            }
        }
        
        let prevLayerGravity = previewLayer.videoGravity
        let previewBox = LewisAVDetectorController.videoPreviewBoxForGravity(prevLayerGravity, frameSize: parentFrame.size, aperatureSize: videoBox.size)
        
        
        for feature in features {
        
            var faceRect = feature.bounds
            //print("original faceRect: \(NSStringFromCGRect(faceRect))")
            
            //Flip preview width and height
            var temp = faceRect.width
            faceRect.size.width = faceRect.size.height
            faceRect.size.height = temp
            temp = faceRect.origin.x
            faceRect.origin.x = faceRect.origin.y
            faceRect.origin.y = temp
            
            //Preview box may be scaled, so scale quardiantes to fit
            let widthScaleBy = previewBox.size.width / videoBox.size.height
            let heightScaleBy = previewBox.size.height / videoBox.size.width
            faceRect.size.width *= widthScaleBy
            faceRect.size.height *= heightScaleBy
            faceRect.origin.x *= widthScaleBy
            faceRect.origin.y *= heightScaleBy
            
            
            
            //print("new faceRect: \(NSStringFromCGRect(faceRect))")
//
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y)
            let faceRectArea = faceRect.size.height * faceRect.size.width
            
            let faceRectCenter = CGPointMake(faceRect.origin.x + CGRectGetWidth(faceRect)/2, faceRect.origin.y + CGRectGetHeight(faceRect)/2);
            delegate.getCenterForAlignment(CenterPoint: faceRectCenter)
            
            if !faceFound {
                faceRectAreasForAverage.append(faceRectArea)
                faceRectAreasForAccelerate.append(Float(faceRectArea))
            } else {
                faceRectFilter?.newRectArrived(faceRect)
            }


            var featureLayer = CALayer()
            
            while featureLayer.name != "FaceLayer" && currentSublayer < sublayersCount {
                let currentLayer = sublayersToPreviewLayer[currentSublayer]
                if currentLayer.name == "FaceLayer" {
                    featureLayer = currentLayer
                    currentLayer.hidden = false
                    
                }
                currentSublayer += 1
            }
            
            
            if featureLayer.name != "FaceLayer" {
                featureLayer.contents = square.CGImage
                featureLayer.name = "FaceLayer"
                previewLayer.addSublayer(featureLayer)
            }
            
            featureLayer.frame = faceRect
            
        }
        
        CATransaction.commit()
        
    }
    
    
    func calibrateForFacesFound() {
        

        faceRectFilter = FaceRectFilter(WithInitialPoints: faceRectAreasForAccelerate, FromNumberOfValues: UInt(faceRectAreasForAccelerate.count))
        //print("Got a mean from \(facesFound) faces, Mean: \(initialMean)")
    }
    
    
    
    class func videoPreviewBoxForGravity(gravity: NSString, frameSize fs: CGSize, aperatureSize apsize: CGSize) -> CGRect {
        //print(#function)
        
        //Aperture ratio is height/width becuase width is greater, probably due to the photo being
        //sideways when using iphone, no matter what orientation
        let apertureRatio = apsize.height / apsize.width
        let viewRatio = fs.width / fs.height
        
        var size = CGSizeZero
        
        //print("frameSize: Width = \(fs.width), Height = \(fs.height) \n AperatureSize: Width = \(apsize.width), Height = \(apsize.height)")
        
        if gravity == AVLayerVideoGravityResizeAspectFill {
            //print("a. Video gravity resize aspect fill")
            if viewRatio > apertureRatio {
                print("a-1")
                size.width = fs.width
                size.height = apsize.width * (fs.width / apsize.height)
            } else {
               // print("a-2")
                size.width = apsize.height * (fs.width / apsize.height)
                size.height = fs.height
            }
        } else if gravity == AVLayerVideoGravityResizeAspect {
            print("b. Video gravity resize aspect")
            if viewRatio > apertureRatio {
                print("b-1")
                size.width = apsize.height * (fs.height / apsize.width)
                size.height = fs.height
            } else {
                print("b-2")
                size.width = fs.width
                size.height = apsize.width * (fs.width / apsize.height)
            }
        } else if gravity == AVLayerVideoGravityResize {
            print("Video size resize")
            size.width = fs.width
            size.height = fs.height
        }
        
        //print("Size after tweaking: Width = \(size.width), Height = \(size.height)")
        
        var videoBox = CGRectZero
        videoBox.size = size;
        
        if size.width < fs.width {
            print("size.width < framesize.width")
            videoBox.origin.x = (fs.width - size.width) / 2
        } else {
            //print("size.width >= framesize.width")
            videoBox.origin.x = (size.width - fs.width) / 2
        }
        
        if size.height < fs.height {
            print("size.height < framesize.height")
            videoBox.origin.y = (fs.height - size.height) / 2
        } else {
            //print("size.height > framesize.height")
            videoBox.origin.y = (size.height - fs.height) / 2
        }
        
        //print("VideoBox return value: \(NSStringFromCGRect(videoBox))")
        
        return videoBox
    }
    
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        //print("got a sample")
        //capture delegate to analyze samples
        
        let brightness = brightnessFromSampleBuffer(sampleBuffer)
        //print("brightness = \(brightness)")
        
        let imageBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let imageHeight = CVPixelBufferGetHeight(imageBuffer)
        let imageWidth = CVPixelBufferGetWidth(imageBuffer)
        
        var imageCI: CIImage = CIImage(CVPixelBuffer: imageBuffer)
        //var newImage = CIImage()
          let curDeviceOrientation = UIDevice.currentDevice().orientation
        var exifOrientation: CFNumber = 0
        
        imageCI = determineFilterSettingsFromBrightness(brightness, AppliedToImage: imageCI, ImageHeight: imageHeight, ImageWidth: imageWidth)
        
        //for displaying image used every 20 images
        if detectionCount % 10 == 0 {
            //delegate.gotCIImageFromVideoDataOutput(imageCI)
            if !faceFound {
                //cropWidthOffset += 20
            }
        
        }
        detectionCount += 1
        
        
        //orientation 5 passed the dark face test
        //orientation 6 passed the dark face test
        exifOrientation = 6
        let options = ["CIDetectorImageOrientation" : exifOrientation]
        let features = faceDetector.featuresInImage(imageCI, options: options)
        
        //In obj-c i released the image but it seems i cant do that explicitly here - keep a lookout for leaks
        
        let fdesc: CMFormatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let clapbottomLeft: CGRect = CMVideoFormatDescriptionGetCleanAperture(fdesc, false)
        //let claptopLeft: CGRect = CMVideoFormatDescriptionGetCleanAperture(fdesc, true)
        //No differenct between two
        //print("\(NSStringFromCGRect(clapbottomLeft)), \(NSStringFromCGRect(claptopLeft))")
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.drawFaceBoxesForFeatures(features, forVideoBox: clapbottomLeft, deviceOrientation: curDeviceOrientation)
            
        })
    }
    
    //MARK: photo treatment utility
    
    func brightnessFromSampleBuffer(buffer: CMSampleBuffer) -> Float {
        
        var metadataDict: CFDictionary? = CMCopyDictionaryOfAttachments(nil,
                                                         buffer, kCMAttachmentMode_ShouldPropagate)
        let metadata = NSDictionary(dictionary: metadataDict!)
        metadataDict = nil
        let exifMetadata: NSDictionary = metadata["{Exif}"] as! NSDictionary
        return exifMetadata["BrightnessValue"] as! Float
        
    }
    
    
    var cropWidthOffset: CGFloat = 300
    var cropHeightOffset: CGFloat = 500
    var cropWidth: CGFloat = 300
    var cropHeight: CGFloat = 500
    
    func determineFilterSettingsFromBrightness(brightness: Float, AppliedToImage image: CIImage, ImageHeight height: Int, ImageWidth width: Int) -> CIImage {
        
        var returnImage = image
        
        //print(height, width)
        //Just tested this filter and it helps for face detection in dim light! -- very cool!
        //Combination of these three filters will detect a face in a very dark room
        //returnImage = returnImage.imageByApplyingFilter("CIHighlightShadowAdjust", withInputParameters: ["inputImage" : returnImage, "inputHighlightAmount" : 2.0, "inputShadowAmount" : 5.0])
        //returnImage = returnImage.imageByApplyingFilter("CIVibrance", withInputParameters: ["inputImage" : returnImage, "inputAmount" : 5.0])
        //returnImage = returnImage.imageByApplyingFilter("CIGammaAdjust", withInputParameters: ["inputImage" : returnImage, "inputPower" : 2.0])
        //returnImage = returnImage.imageByApplyingFilter("CIColorControls", withInputParameters: ["inputImage" : returnImage, "inputContrast" : 0.5])
        
        //let cropTangle = CIVector(CGRect: CGRectMake(0, 0, 400, 400))
        //returnImage = returnImage.imageByApplyingFilter("CICrop", withInputParameters: ["inputImage" : returnImage, "inputRectangle" : cropTangle])
        
        returnImage = returnImage.imageByApplyingFilter("CIExposureAdjust", withInputParameters: ["inputImage" : returnImage, "inputEV" : 2.0])
        returnImage = returnImage.imageByCroppingToRect(CGRectMake(CGFloat(width) - cropWidthOffset, CGFloat(height) - cropHeightOffset, cropWidth, cropHeight))
        
        return returnImage
        
        
    }
    
    
    
    //MARK: COllect data
    func feedDataToFileWithFaceRectArea(rectArea: CGFloat, FaceRectCenter rectCenter: CGPoint) {
        
        let dataText = "\(rectArea),\(NSStringFromCGPoint(rectCenter))\n"
        let firstText = "FaceRectAreaStart \(rectArea), FaceRectCenterStart \(NSStringFromCGPoint(rectCenter))\n\n"
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(rectDataPath.path!)
        {
            if writeText(firstText, ToURL: rectDataPath) {
                print("data wrote first time")
            } else {
                collectPushupData = false
            }

        }
        else
        {
            let handle = NSFileHandle(forWritingAtPath: rectDataPath.path!)
            handle?.seekToEndOfFile()
            handle?.writeData(dataText.dataUsingEncoding(NSUTF8StringEncoding)!)
            print("data wrote continuous")
        }
        
        
        
        assert(collectPushupData)
        
    }
    
    func feedDataToFileWithBrightness(brightness: Float, FilterOneParams params1: NSDictionary, FilterTwoParams params2: NSDictionary, FilterThreeParams params3: NSDictionary) {
        
        
    }
    
    
    func writeText(text: NSString, ToURL url: NSURL) -> Bool {
        
        //writing
        do {
            try text.writeToURL(url, atomically: false, encoding: NSUTF8StringEncoding)
            return true
        }
        catch {/* error handling here */
            return false
        }

    }
    
    
    func deleteDataFiles(files: [NSURL]) {
        
        let fileManager = NSFileManager.defaultManager()
        
        for file in files {
            
            do {
                try fileManager.removeItemAtURL(file)
            } catch {
                print("delete failed")
            }
                
        }
        
    }

}







//        switch curDeviceOrientation {
//        case .PortraitUpsideDown:  // Device oriented vertically, home button on the top
//            //exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM.rawValue
//            exifOrientation = UIImageOrientation.Down.rawValue
//            break
//        case .LandscapeLeft:       // Device oriented horizontally, home button on the right
//            //exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
//            exifOrientation = UIImageOrientation.Left.rawValue
//            break
//        case .LandscapeRight:      // Device oriented horizontally, home button on the left
//            //exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_TOP_0COL_LEFT.rawValue
//            exifOrientation = UIImageOrientation.Right.rawValue
//            break
//        case .Portrait, .FaceUp:             // Device oriented vertically, home button on the bottom
//            print("Home button at bottom - Face Up")
//            //exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP.rawValue
//            exifOrientation = UIImageOrientation.Up.rawValue
//            break
//        default:
//            print("default clause")
//
//            break
//        }




//let adjustmentFilters = imageCI.autoAdjustmentFiltersWithOptions([kCIImageAutoAdjustEnhance : true])
//        if adjustmentFilters.count > 0 {
//
//            //print("got adjustments");
//            for filter in adjustmentFilters {
//
//
//                switch filter.name {
//                case "CIVibrance":
//                    print("\(filter.name)")
//                    //"Image" : image, "Amount" : CIAttributeTypeScalar
//                    //
//                    break
//                case "CIToneCurve":
//                    //Dont think i will implement this one
//                    break
//
//                case "CIHighlightShadowAdjust":
//                    print("\(filter.name)")
//                    //"Image" : image, "Highlight Amount" : CIAttributeTypeScalar (default is 1.00), "Shadow Amount" : CIAttributeTypeScalar

//                    break
//                default:
//                    print("hit default")
//                }
//            }
//        }

//imageCI = imageCI.imageByApplyingFilter("CIColorControls", withInputParameters: ["inputImage" : imageCI, "inputBrightness" : 0.8, "inputContrast" : 0.5])




//        var closeNess: CGFloat = 1.0
//
//        if (detectingMax) {
//            // detect down
//
//            if (faceRectArea > (maxArea - maxTolerance))
//            {
//                print("DETECTED DOWN")
//                detectingMax = false
//
//                //Delegate call to do pushup
//
//            } else {
//
//                var vpoint: CGFloat = (minArea + minTolerance)
//
//                if (faceRectArea > (minArea + minTolerance)) {
//                    vpoint = faceRectArea - (minArea + minTolerance)
//                }
//
//                let vtotal: CGFloat = (maxArea - maxTolerance) - (minArea + minTolerance)
//
//                closeNess = (vpoint / vtotal)
//
//                print("DN Closeness: \(closeNess)  vpoint \(vpoint) vtotal \(vtotal)")
//
//                //Delegate call to will do push down
//
//            }
//
//
//
//        } else {
//
//            // DETECT up
//            if (faceRectArea < (minArea + minTolerance))
//            {
//                print("DETECTED UP")
//                detectingMax = true;
//
//                //Delegate call to push up
//
//            } else {
//
//                let vtotal = (maxArea - maxTolerance) - (minArea + minTolerance)
//
//                var vpoint = vtotal
//
//                if (faceRectArea < (maxArea - maxTolerance)) {
//                    vpoint = faceRectArea - (minArea + minTolerance)
//                }
//
//                closeNess = (vpoint / vtotal)
//
//                print("UP Closeness: \(closeNess)  vpoint \(vpoint) vtotal \(vtotal)")
//
//                //delegate call to will do push up
//
//            }
//
//        }


//            //print("offset faceRect: \(NSStringFromCGRect(faceRect))")
//
//
//            faceRectArea = faceRect.size.height * faceRect.size.width
//            let faceRectCenter = CGPointMake(faceRect.origin.x + CGRectGetWidth(faceRect)/2, faceRect.origin.y + CGRectGetHeight(faceRect)/2);
//

//
//            //print("change in area = \(changeInArea)")
//            //print("Face Rect Area = \(faceRectArea), Face Rect Center = \(faceRectCenter)")
//
//            //Happens on tap of screen - data is collected for face rect only
//            if collectPushupData {
//
//                if deleteDataFileOnNewInstance {
//                    deleteDataFiles([rectDataPath, brightnessDataPath])
//                }
//
//                feedDataToFileWithFaceRectArea(faceRectArea, FaceRectCenter: faceRectCenter)
//            }
//

