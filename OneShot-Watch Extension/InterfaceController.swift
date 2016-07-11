//
//  InterfaceController.swift
//  OneShot-Watch Extension
//
//  Created by Atanai Wuttisetpaiboon on 6/30/2559 BE.
//  Copyright © 2559 Atanai Wuttisetpaiboon. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var image: WKInterfaceImage!
    
    var session: WCSession! = nil
    var data: NSData! = nil
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if (WCSession.isSupported()) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // load image from local storage
        self.image.setImage(self.loadImage())
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        // save image to local storage
        self.saveImage(self.data)
        
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let value = applicationContext["image"] as! NSData
        
        dispatch_async(dispatch_get_main_queue()) {
            self.image.setImageData(value);
            self.data = value;
        }
    }
    
    func saveImage(image: NSData) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let path = paths.objectAtIndex(0) as! NSString
        
        if (path.length > 0) {
            let imageFile = path.stringByAppendingPathComponent("OneShot.jpg")
            // keep snapshot file
            image.writeToFile(imageFile, atomically: true)
        }
    }
    
    func loadImage() -> UIImage {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let path = paths.objectAtIndex(0) as! NSString
        
        if (path.length > 0) {
            let imageContent = path.stringByAppendingPathComponent("OneShot.jpg")
            
            if (imageContent != "") {
                return UIImage(contentsOfFile: imageContent)!
            }
        }
        
        return UIImage()
    }
}
