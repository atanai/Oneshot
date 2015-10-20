//
//  Utils.swift
//  OneShot
//
//  Created by F on 1/21/2558 BE.
//  Copyright (c) 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit

class Utils: NSObject {
    class func loadImage(fileName: String) -> (image: UIImage, timeTaken: String) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let path = paths.objectAtIndex(0) as! NSString
        
        if (path.length > 0) {
            let imageContent = path.stringByAppendingPathComponent(fileName)
            
            if (imageContent != "") {
                
                do {
                    let keys = try NSFileManager.defaultManager().attributesOfItemAtPath(imageContent) as? NSDictionary
                    
                    if (keys != nil) {
                        let imageTaken = keys?.objectForKey(NSFileCreationDate) as! NSDate

                        let timeString = NSDateFormatter.localizedStringFromDate(imageTaken, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                        let image = UIImage(contentsOfFile: imageContent)
            
                        if (image != nil) {
                            return (image!, timeString)
                        }
                    }
                } catch {
                    fatalError()
                }
            }
        }
        
        return (UIImage(), "")
    }
    
    class func getAdjustedYPosition(viewController: UIViewController) -> CGFloat {
        let viewHeight = viewController.view.frame.width * 1.333;
        let adjustedYPosition = (viewController.view.frame.height - viewHeight) / 2;
        
        return adjustedYPosition
    }
    
    class func createNavigationBar(viewController: UIViewController) -> UINavigationBar {
        let navBar = UINavigationBar(frame: CGRectMake(0, 0, viewController.view.frame.size.width, Utils.getAdjustedYPosition(viewController)))
        navBar.barStyle = UIBarStyle.Default
        navBar.barTintColor = UIColor.blackColor()
        
        return navBar

    }
    
    class func createToolBar(viewController: UIViewController) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRectMake(0, viewController.view.frame.size.height-Utils.getAdjustedYPosition(viewController), viewController.view.frame.size.width, Utils.getAdjustedYPosition(viewController)))
        toolBar.barStyle =  UIBarStyle.Default
        toolBar.barTintColor = UIColor.blackColor()
        
        return toolBar
    }
}
