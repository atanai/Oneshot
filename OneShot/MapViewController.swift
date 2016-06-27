//
//  MapViewController.swift
//  OneShot
//
//  Created by F on 10/11/2558 BE.
//  Copyright © 2558 Atanai Wuttisetpaiboon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraViewHeight = self.view.frame.width * 1.333
        let adjustedYPosition = ((self.view.frame.height - cameraViewHeight) / 2) - 40
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height-adjustedYPosition, self.view.frame.size.width, adjustedYPosition))
        
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "endMap")
        doneButton.tintColor = UIColor.darkGrayColor()
        doneButton.style = UIBarButtonItemStyle.Plain
        
        let items : NSArray = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            doneButton]
        
        toolBar.setItems((items as! [UIBarButtonItem]), animated: true)
        
        
        self.view.addSubview(toolBar)

        self.mapView.delegate = self
        
        let geoStr = Utils.getFileGeolocation(CameraViewController.geoName) as String
        
        let list = geoStr.componentsSeparatedByString(",")
        
        let location = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(list[0])!,
            longitude: CLLocationDegrees(list[1])!
        )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Target"
        
        self.mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }

    func endMap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
