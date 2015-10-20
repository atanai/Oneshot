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
}
