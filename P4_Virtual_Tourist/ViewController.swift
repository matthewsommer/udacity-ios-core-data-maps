//
//  ViewController.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 11/29/15.
//  Copyright © 2015 Matt Sommer. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editInfoView: UIView!
    
    let longPressGesture = UILongPressGestureRecognizer()
    var isLongPressInProgress: Bool = false
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self

        self.longPressGesture.minimumPressDuration = 0.5
        self.longPressGesture.addTarget(self, action: "handleLongPress:")
        self.view.addGestureRecognizer(self.longPressGesture)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
        for pin in self.fetchedResultsController.fetchedObjects! as! [Pin] {
            self.mapView.addAnnotation(pin)
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func addPin(point: MKPointAnnotation) -> Pin {
        
            let dictionary: [String : AnyObject] = [
                Pin.Keys.Title : point.title!,
                Pin.Keys.Longitude : point.coordinate.longitude,
                Pin.Keys.Latitude : point.coordinate.latitude
            ]

            let pin = Pin(dictionary: dictionary, context: sharedContext)
        
            for _ in 0...20 {
                let photo = Photo(insertIntoMangedObjectContext: sharedContext)
                photo.pin = pin
            }
        
            CoreDataStackManager.sharedInstance().saveContext()
        
        return pin
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {

        if self.isLongPressInProgress {
            return
        }
        self.isLongPressInProgress = true
        
        let touchLocation = gesture.locationInView(self.view)
        
        var coordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
        coordinates = mapView.convertPoint(touchLocation, toCoordinateFromView: self.view)
        
        let point = MKPointAnnotation()
        point.coordinate = coordinates
        point.title = String(point.coordinate.longitude) + "," + String(point.coordinate.latitude)
        self.mapView.addAnnotation(addPin(point))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.isLongPressInProgress = false
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if(editButton.title == "Edit") {
            performSegueWithIdentifier("showDetail", sender: self)
        }
        else if (editButton.title == "Done"){
            sharedContext.deleteObject(view.annotation! as! Pin)
            mapView.removeAnnotation(view.annotation!)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destination = segue.destinationViewController as! DetailsViewController
            destination.mapView = mapView
            destination.pin = mapView.selectedAnnotations.first as! Pin
        }
    }
    @IBAction func editButtonAction(sender: AnyObject) {
        if(editButton.title == "Edit") {
            editInfoView.hidden = false
            editButton.title = "Done"
        }
        else if (editButton.title == "Done"){
            editInfoView.hidden = true
            editButton.title = "Edit"
        }
    }
}

