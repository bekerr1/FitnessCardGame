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


class LewisAVDetectorController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    lazy var faceDetector: CIDetector = {
        print("face detector lazy var")
        let detectorOptions = NSDictionary(objects: [CIDetectorAccuracyHigh, CIDetectorTypeFace, 0.5, 7], forKeys: [CIDetectorAccuracy, CIDetectorTracking, CIDetectorMinFeatureSize, CIDetectorNumberOfAngles])
        let fd = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions as? [String : AnyObject])
        
        return fd
        
    }()
    
    let captureDataOutput: AVCaptureVideoDataOutput = {
        print("capture output const")
        let capture = AVCaptureVideoDataOutput()
        capture.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA as! AnyObject]
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
    
    let minArea: CGFloat = 7000.0
    let maxArea: CGFloat = 60000.0
    let minTolerance: CGFloat = 5000.0
    let maxTolerance: CGFloat = 20000.0
    
    var detectingMax: Bool = false
    var cameraAuthorized: Bool = false
    var previewLayerActive: Bool = false
    
    let parentFrameSize: CGSize
    
    var setupResult: AVSettingsSetupResult = .Success
    
    //Convinience
    convenience override init() {
        self.init(withParentFrameSize: CGSizeZero)
    }
    
    //Designated
    init(withParentFrameSize parentFrameSize: CGSize) {
        
        print("Detector Class Initialized (Phase 1)")
        self.parentFrameSize = parentFrameSize
        
        super.init()
        
        print("Working back down from super (Phase 2)")
        
        requestAuthorization()
        
        if setupResult == .Success && cameraAuthorized {
            setupAVComponents()
        }
    }
    
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
                self.cameraAuthorized = granted
                if self.cameraAuthorized {
                    print("camera was authorized by user")
                } else {
                    self.setupResult = .CameraNotAuthorized
                }
            })
            break
            
        case AVAuthorizationStatus.Denied:
            print("User did not give permission")
            self.cameraAuthorized = false
            self.setupResult = .CameraNotAuthorized
            break
            
        case AVAuthorizationStatus.Restricted:
            print("restricted")
            self.setupResult = .CameraRestricted
            self.cameraAuthorized = false
            break
            
        }

    }
    
    
    func setupAVComponents() {
        print(#function)
        
        dispatch_async(sessionSetupQueue, {
            
            //SESSION
            
            //INPUT DEVICE
            let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let inputDevice = self.deviceInputFromDevice(device)
            
            if self.captureSession.canAddInput(inputDevice) {
                self.captureSession.addInput(inputDevice)
            } else {
                print("input device couldnt be added")
            }
            
            //OUTPUT DEVICE
            self.captureDataOutput.setSampleBufferDelegate(self, queue: self.videoDataQueue)
            
            if self.captureSession.canAddOutput(self.captureDataOutput) {
                self.captureSession.addOutput(self.captureDataOutput)
            } else {
                print("output device couldnt be added")
            }
            
            //PREVIEW LAYER
            let avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer = avPreviewLayer
            
            //SWITCH FRONT CAMERA
            self.useFrontCamera()
            
            
            assert(self.setupResult == .Success)
            
            self.startCaptureSession()
            
        })
        
        
    }
    
    func startCaptureSession() {
        print(#function)
        dispatch_async(sessionSetupQueue, {
            if self.setupResult == .Success {
                self.captureSession.startRunning()
            }
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
    
    
    func drawFaceBoxesForFeatures(features: [CIFeature], forVideoBox videoBox: CGRect, deviceOrientation orientation: UIDeviceOrientation) {
        print(#function)
        //Draw box on screen for testing of face detection, detect changes in box size
        
        let sublayersToPreviewLayer: [CALayer] = previewLayer.sublayers!
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        for layer in sublayersToPreviewLayer where layer.name == "FaceLayer" {
            print("face layer found")
            layer.hidden = true
        }
        
        if features.count == 0 {
            print("No features found this round")
            CATransaction.commit()
            return;
        }
        
        let prevLayerGravity = previewLayer.videoGravity
        let previewBox = LewisAVDetectorController.videoPreviewBoxForGravity(prevLayerGravity, frameSize: parentFrameSize, aperatureSize: videoBox.size)
        
        for feature in features {
            
            var faceRect = feature.bounds
            
            print("original faceRect: \(NSStringFromCGRect(faceRect))")
            
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
            
            print("new faceRect: \(NSStringFromCGRect(faceRect))")
            
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y)
            
            print("offest faceRect: \(NSStringFromCGRect(faceRect))")
            
            //use these later
            //let faceRectArea = faceRect.size.height * faceRect.size.width
            //let faceRectCenter = CGPointMake(faceRect.origin.x + CGRectGetWidth(faceRect)/2, faceRect.origin.y + CGRectGetHeight(faceRect)/2);
            
            var featureLayer = CALayer()
            
            while sublayersToPreviewLayer.count > 0 {
                let currentLayer = sublayersToPreviewLayer[1]
                if currentLayer.name == "FaceLayer" {
                    featureLayer = currentLayer
                    currentLayer.hidden = false
                }
            }
            
            
            if sublayersToPreviewLayer.count == 0 {
                featureLayer.contents = square.CGImage
                featureLayer.name = "FaceLayer"
                previewLayer.addSublayer(featureLayer)
            }
            
            featureLayer.frame = faceRect
            
        }
        
    }
    
    
    class func videoPreviewBoxForGravity(gravity: NSString, frameSize fs: CGSize, aperatureSize apsize: CGSize) -> CGRect {
        print(#function)
        
        let apertureRatio = apsize.height / apsize.width
        let viewRatio = fs.width / fs.height
        
        var size = CGSizeZero
        
        print("frameSize: Width = \(fs.width), Height = \(fs.height) \n AperatureSize: Width = \(apsize.width), Height = \(apsize.height)")
        
        if gravity == AVLayerVideoGravityResizeAspectFill {
            print("a. Video gravity resize aspect fill")
            if viewRatio > apertureRatio {
                print("a-1")
                size.width = fs.width
                size.height = apsize.width * (fs.width / apsize.height)
            } else {
                print("a-2")
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
        
        print("Size after tweaking: Width = \(size.width), Height = \(size.height)")
        
        var videoBox = CGRectZero
        videoBox.size = size;
        if size.width < fs.width {
            print("size.width < framesize.width")
            videoBox.origin.x = (fs.width - size.width) / 2
        } else {
            print("size.width > framesize.width")
            videoBox.origin.x = (size.width - fs.width) / 2
        }
        
        if size.height < fs.height {
            print("size.height < framesize.height")
            videoBox.origin.y = (fs.height - size.height) / 2
        } else {
            print("size.height > framesize.height")
            videoBox.origin.y = (size.height - fs.height) / 2
        }
        
        print("VideoBox return value: \(NSStringFromCGRect(videoBox))")
        
        return videoBox
    }
    
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        print("got a sample")
        //capture delegate to analyze samples
        
        let imageBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let imageCI: CIImage = CIImage(CVPixelBuffer: imageBuffer)
        let curDeviceOrientation = UIDevice.currentDevice().orientation
        var exifOrientation: CFNumber = ImageOrientation.PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM.rawValue
        
        switch curDeviceOrientation {
        case .PortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM.rawValue
            break
        case .LandscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
            break
        case .LandscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_TOP_0COL_LEFT.rawValue
            break
        case .Portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = ImageOrientation.PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP.rawValue
            break
        default:
            print("default clause")
            break
        }
        
        let imageOptions = NSDictionary(object: exifOrientation, forKey: CIDetectorImageOrientation)
        let features = faceDetector.featuresInImage(imageCI, options: imageOptions as? [String : AnyObject])
        
        //In obj-c i released the image but it seems i cant do that explicitly here
        
        let fdesc: CMFormatDescriptionRef = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let clap: CGRect = CMVideoFormatDescriptionGetCleanAperture(fdesc, false)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.drawFaceBoxesForFeatures(features, forVideoBox: clap, deviceOrientation: curDeviceOrientation)
        })
    }

}













