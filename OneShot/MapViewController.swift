//
//  MapViewController.swift
//  OneShot
//
//  Created by F on 10/11/2558 BE.
//  Copyright © 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraViewHeight = self.view.frame.width * 1.333;
        let adjustedYPosition = (self.view.frame.height - cameraViewHeight) / 2;
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height-adjustedYPosition, self.view.frame.size.width, adjustedYPosition))
        toolBar.barStyle =  UIBarStyle.Default
        toolBar.barTintColor = UIColor.blackColor()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "endMap")
        doneButton.tintColor = UIColor.darkGrayColor()
        doneButton.style = UIBarButtonItemStyle.Plain
        
        let items : NSArray = [
            doneButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)]
        
        toolBar.setItems((items as! [UIBarButtonItem]), animated: true)
        
        self.view.addSubview(toolBar)
    }
    
    
    func endMap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
