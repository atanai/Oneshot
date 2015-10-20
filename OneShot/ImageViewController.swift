//
//  ImageViewController.swift
//  OneShot
//
//  Created by F on 2/1/2558 BE.
//  Copyright (c) 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit

class ImageViewController:  UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate,
                            UIPickerViewDataSource, UIPickerViewDelegate {
    
    var imageView: UIImageView!
    var alarm: NSTimer!
    var timePicker: UIPickerView!
    let pickerData = ["Mozzarella","Gorgonzola","Provolone","Brie","Maytag Blue","Sharp Cheddar","Monterrey Jack","Stilton","Gouda","Goat Cheese", "Asiago"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadToolBar()
        
        alarm = NSTimer()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadToolBar() {
        let cameraViewHeight = self.view.frame.width * 1.333;
        let adjustedYPosition = (self.view.frame.height - cameraViewHeight) / 2;
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height-adjustedYPosition, self.view.frame.size.width, adjustedYPosition))
        toolBar.barStyle =  UIBarStyle.Default
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePreview")
        doneButton.tintColor = UIColor.darkGrayColor()
        doneButton.style = UIBarButtonItemStyle.Plain
        
        let mapButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showMap")
        mapButton.tintColor = UIColor.darkGrayColor()
        mapButton.style = UIBarButtonItemStyle.Plain
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveImage")
        saveButton.tintColor = UIColor.darkGrayColor()
        saveButton.style = UIBarButtonItemStyle.Plain
        
        let timeTaken = UILabel(frame: CGRectMake((self.view.frame.size.width/2) - 70, 40, 140, 20))
        timeTaken.adjustsFontSizeToFitWidth = true
        timeTaken.textColor = UIColor.blackColor()
        timeTaken.textAlignment = NSTextAlignment.Natural
        
        imageView = UIImageView(frame: CGRectMake(0, adjustedYPosition, self.view.frame.size.width, self.view.frame.width * 1.333))
        
        let imageInfo = Utils.loadImage(CameraViewController.imageName)
        imageView.image = imageInfo.image
        timeTaken.text = imageInfo.timeTaken
        
        timePicker = UIPickerView()
        timePicker.dataSource = self
        timePicker.delegate = self
        
        let items : NSArray = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil),
                                saveButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
                                mapButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
                                doneButton,
                                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: nil)]
        
        toolBar.setItems((items as! [UIBarButtonItem]), animated: true)
        
        let uiView = UIView(frame: self.view.bounds)
        uiView.addSubview(toolBar)
        //uiView.addSubview(timePicker)
        
        self.view.addSubview(uiView)
        self.view.addSubview(imageView)
        self.view.addSubview(timeTaken)
    }
    
    func donePreview() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImage() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    func showMap() {
        let mapView = storyboard?.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        self.presentViewController(mapView, animated: true, completion: nil)
    }
    
    func startTimer() {
        if (!alarm.valid) {
            alarm = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "displayAlarm", userInfo: nil, repeats: false)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(pickerData.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .Center
        
        return pickerLabel
        
    }
    
    func displayAlarm() {
        dispatch_async(dispatch_get_main_queue(), {
            UIAlertView(title: "Wake up", message: "Wake up", delegate: nil, cancelButtonTitle: "Close").show()
        })
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        dispatch_async(dispatch_get_main_queue(), {
            UIAlertView(title: "Success", message: "This image has been saved to your Camera Roll successfully", delegate: nil, cancelButtonTitle: "Close").show()
        })
    }
}
