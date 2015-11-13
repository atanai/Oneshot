//
//  ImageViewController.swift
//  OneShot
//
//  Created by F on 2/1/2558 BE.
//  Copyright (c) 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit
import CoreLocation

class ImageViewController:  UIViewController, UIGestureRecognizerDelegate {
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadToolBar()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadToolBar() {
        
        let navBar = Utils.createNavigationBar(self)
        let toolBar = Utils.createToolBar(self)
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "endPreview")
        closeButton.tintColor = UIColor.whiteColor()
        
        let mapButton = UIBarButtonItem(title: "Map", style: UIBarButtonItemStyle.Plain, target: self, action: "showMap")
        mapButton.tintColor = UIColor.whiteColor()
        
        if (CLLocationManager.locationServicesEnabled()) {
            
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
                    mapButton.enabled = false
            }
        }
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveImage")
        saveButton.tintColor = UIColor.whiteColor()
        
        let timeTaken = UILabel(frame: CGRectMake((self.view.frame.size.width/2) - 70, 40, 140, 20))
        timeTaken.adjustsFontSizeToFitWidth = true
        timeTaken.textColor = UIColor.whiteColor()
        timeTaken.textAlignment = NSTextAlignment.Natural
        
        imageView = UIImageView(frame: CGRectMake(0, Utils.getAdjustedYPosition(self), self.view.frame.size.width, self.view.frame.width * 1.333))
        
        let imageInfo = Utils.loadImage(CameraViewController.imageName)
        imageView.image = imageInfo.image
        timeTaken.text = imageInfo.timeTaken
        
        let items : NSArray = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil),
                                saveButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
                                mapButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
                                closeButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)]
        
        toolBar.setItems((items as! [UIBarButtonItem]), animated: true)
        
        let uiView = UIView(frame: self.view.bounds)
        uiView.addSubview(toolBar)
        
        self.view.addSubview(uiView)
        self.view.addSubview(imageView)
        self.view.addSubview(navBar)
        self.view.addSubview(timeTaken)
    }
    
    func endPreview() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    func showMap() {
        let mapView = storyboard?.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        self.presentViewController(mapView, animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        let alertController = UIAlertController(title: "Success", message: "The image has been saved to your Camera Roll", preferredStyle: .Alert)
            
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in }
        
        alertController.addAction(OKAction)
            
        self.presentViewController(alertController, animated: true, completion:nil)
    }
}
