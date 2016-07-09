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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if (WCSession.isSupported() && self.session == nil) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Configure interface objects here.
        if (WCSession.isSupported() && self.session == nil) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let value = applicationContext["image"] as! NSData
        
        dispatch_async(dispatch_get_main_queue()) {
            //self.image.setImage(UIImage(contentsOfFile: value));
            self.image.setImageData(value);
        }
    }
}
