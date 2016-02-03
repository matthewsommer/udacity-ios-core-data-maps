//
//  ViewController.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 11/29/15.
//  Copyright © 2015 Matt Sommer. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let longPressGesture = UILongPressGestureRecognizer()
    var isLongPressInProgress: Bool = false
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self

        self.longPressGesture.minimumPressDuration = 0.5
        self.longPressGesture.addTarget(self, action: "handleLongPress:")
        self.view.addGestureRecognizer(self.longPressGesture)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {

        if self.isLongPressInProgress {
            return
        }
        self.isLongPressInProgress = true
        
        let touchLocation = gesture.locationInView(self.view)
        
        print(touchLocation.x)
        print(touchLocation.y)
        
        
        var coordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
        coordinates = mapView.convertPoint(touchLocation, toCoordinateFromView: self.view)
        
        let point = MKPointAnnotation()
        point.coordinate = coordinates
        point.title = "test"
        self.annotations.append(point)
        self.mapView.addAnnotations(self.annotations)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.isLongPressInProgress = false
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pin!.pinTintColor = UIColor.redColor()
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .InfoLight)
        } else {
            pin!.annotation = annotation
        }
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("showDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "addLocation" {
//            let destination = segue.destinationViewController as! SubmitInfoViewController
//            destination.mapView = mapView
//        }
    }
}

