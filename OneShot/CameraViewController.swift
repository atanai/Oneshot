//
//  CameraViewController.swift
//  OneShot
//
//  Created by F on 2/1/2558 BE.
//  Copyright (c) 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import CoreLocation
import WatchConnectivity


class CameraViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate {
    class var imageName: String { return "OneShot.jpg" } // snapshot image name
    class var geoName: String { return "Geolocation.txt" }
    
    let captureSession = AVCaptureSession()
    let outputImage = AVCaptureStillImageOutput()
    
    // If we find a device we'll store it here for later use
    var captureDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var previewButton: UIButton?
    var image: UIImage?
    
    // pan location
    var startLocation: CGPoint?
    var lastPosition: CGFloat?
    
    let locationManager = CLLocationManager()
    
    var session: WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageInfo = Utils.loadImage(CameraViewController.imageName)
        self.image = imageInfo.image
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    self.captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            self.loadConfig()
            self.beginSession()
            self.loadToolBar()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture)
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager?.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if (WCSession.isSupported()) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
        
    }
    
    var targetZoome : Float = 0.0
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        if (recognizer.state == UIGestureRecognizerState.Began) {
            lastPosition = recognizer.translationInView(self.view).x
        } else if (recognizer.state == UIGestureRecognizerState.Changed) {
            
            let translation = recognizer.translationInView(self.view)
            let xTranslation = translation.x
            let xTranslationPer = xTranslation / UIScreen.mainScreen().bounds.size.width
            
            
            if (xTranslation > lastPosition) {
                targetZoome = targetZoome + Float(abs(xTranslationPer) * 0.1)
            } else {
                targetZoome = targetZoome - Float(abs(xTranslationPer) * 0.1)
            }
            
            targetZoome = max(targetZoome, 1.0)
            targetZoome = min(targetZoome, 5.0)
            
            lastPosition = xTranslation
            
            dispatch_async(dispatch_get_main_queue(), {
                var err : NSError? = nil
                
                do {
                    try self.captureDevice?.lockForConfiguration()
                } catch let error as NSError {
                    err = error
                } catch {
                    fatalError()
                }
                
                if err != nil {
                    print("error: \(err?.localizedDescription)")
                    return
                }
                
                self.captureDevice?.videoZoomFactor = CGFloat(self.targetZoome)
                self.captureDevice?.unlockForConfiguration()
            })
            
        }
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let currentZoonFactor = self.captureDevice?.videoZoomFactor
            var nextZoomFact = currentZoonFactor!
            
            var err : NSError? = nil
            
            do {
                try self.captureDevice?.lockForConfiguration()
            } catch let error as NSError {
                err = error
            } catch {
                fatalError()
            }
            
            if err != nil {
                print("error: \(err?.localizedDescription)")
                return
            }
            
            if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
                if (currentZoonFactor > 1) {
                    nextZoomFact = currentZoonFactor! - 1.0
                }
            } else {
                if (currentZoonFactor < self.captureDevice?.activeFormat.videoMaxZoomFactor) {
                    nextZoomFact = currentZoonFactor! + 1.0
                }
            }
            
            self.captureDevice?.rampToVideoZoomFactor(nextZoomFact, withRate: 1)
            
            self.captureDevice?.unlockForConfiguration()
        })
    }
    
    
    func loadConfig() {
        // full photo resolution
        if (self.captureSession.canSetSessionPreset(AVCaptureSessionPresetPhoto)) {
            self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        }
        
        var err : NSError? = nil
        do {
            //auto focus and zoom level
            try self.captureDevice?.lockForConfiguration()
        } catch let error as NSError {
            err = error
        }
        if err != nil {
            print("error: \(err?.localizedDescription)")
            return
        }
        
        if ((self.captureDevice?.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus))!) {
            self.captureDevice?.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
        }
        
        if ((self.captureDevice?.hasFlash)!) {
            self.captureDevice?.flashMode = AVCaptureFlashMode.Auto
        }
        
        self.captureDevice?.unlockForConfiguration()
    }
    
    func beginSession() {
        let err : NSError? = nil
        do {
            try self.captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        
            if err != nil {
                print("error: \(err?.localizedDescription)")
                return
            }
        } catch {
            fatalError()
        }
        
        self.outputImage.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        self.captureSession.addOutput(self.outputImage)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        self.previewLayer?.frame = self.view.layer.frame
        self.view.layer.addSublayer(self.previewLayer!)
        
        self.captureSession.startRunning()
    }
    
    func loadToolBar() {
        
        let navBar = Utils.createNavigationBar(self)
        let toolBar = Utils.createToolBar(self)
        
        self.previewButton = UIButton(frame: CGRectMake(0, self.view.frame.size.width-45, 45, 45))
        
        self.previewButton?.setImage(self.image, forState: UIControlState.Normal)
        self.previewButton?.addTarget(self, action: #selector(CameraViewController.previewImage), forControlEvents: UIControlEvents.TouchDown)
        
        let takeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: #selector(CameraViewController.takePhoto))
        takeButton.tintColor = UIColor.whiteColor()
        
        let items : NSArray = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            takeButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            UIBarButtonItem(customView: self.previewButton!)]
        
        
        toolBar.setItems((items as! [UIBarButtonItem]), animated: true)
        
        // parent view for our overlay
        let cameraView = UIView(frame: self.view.bounds)
        
        cameraView.addSubview(toolBar)
        cameraView.addSubview(navBar)
        
        self.view.addSubview(cameraView)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func takePhoto() {
        self.startCapturingImage() {
            (image: UIImage?, error: NSError?) in
        }
    }
    
    func startCapturingImage(completion:((image: UIImage?, error: NSError?) -> Void)?) {
        self.outputImage.captureStillImageAsynchronouslyFromConnection(
            self.outputImage.connectionWithMediaType(AVMediaTypeVideo),completionHandler: {
                (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                if imageDataSampleBuffer != nil {
                    let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    self.image = UIImage(data: imageData)!
                    self.previewButton?.setImage(self.image, forState: UIControlState.Normal)
                    self.saveImage(self.image!)
                    self.saveGeolocation()
                    completion!(image: self.image, error:nil)
                }
            }
        )
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func saveImage(image: UIImage) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let path = paths.objectAtIndex(0) as! NSString
        
        if (path.length > 0) {
            let imageFile = path.stringByAppendingPathComponent(CameraViewController.imageName)
            let data = UIImageJPEGRepresentation(image, 1.0)
            
            // keep snapshot file
            data!.writeToFile(imageFile, atomically: true)
            
            // resize image for watch
            let resizeImage = self.ResizeImage(image, targetSize: CGSizeMake(400.0, 400.0))
            let convertedImage = UIImagePNGRepresentation(resizeImage)
            
            // send image to watch
            let message : [String : AnyObject]
            message = [
                "image":convertedImage!
            ]
            
            do {
                try self.session.updateApplicationContext(message)
            } catch {
                // ignore an error if cannot send to watch
            }
        }
    }
    
    func saveGeolocation() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            
            if ((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse)
            {
                let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
                let path = paths.objectAtIndex(0) as! NSString
        
                if (path.length > 0) {
                    let geoFile = path.stringByAppendingPathComponent(CameraViewController.geoName)
            
                    let latitude = String(format: "%f", (self.locationManager.location?.coordinate.latitude)!)
                    let longtitude = String(format: "%f", (self.locationManager.location?.coordinate.longitude)!)
            
                    let geoString = latitude + "," + longtitude
            
                    do {
                        try geoString.writeToFile(geoFile, atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    catch {
                        print("Cannot write geoFile")
                    }
                }
            }
        }
    }
    
    func previewImage() {
        let previewImage = storyboard?.instantiateViewControllerWithIdentifier("ImageView") as! ImageViewController
        self.presentViewController(previewImage, animated: true, completion: nil)
    }
}
