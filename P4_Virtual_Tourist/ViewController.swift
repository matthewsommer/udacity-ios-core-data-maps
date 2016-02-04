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
    
    let longPressGesture = UILongPressGestureRecognizer()
    var isLongPressInProgress: Bool = false
    var annotations = [MKPointAnnotation]()
    var editMode: Bool = false
    
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
            let point = MKPointAnnotation()
            point.coordinate.latitude = pin.latitude
            point.coordinate.longitude = pin.longitude
            self.annotations.append(point)
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func addPin(point: MKPointAnnotation) {
        
            let dictionary: [String : AnyObject] = [
                Pin.Keys.ID : self.mapView.annotations.count,
                Pin.Keys.Longitude : point.coordinate.longitude,
                Pin.Keys.Latitude : point.coordinate.latitude
            ]

            let _ = Pin(dictionary: dictionary, context: sharedContext)
            
            CoreDataStackManager.sharedInstance().saveContext()
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
        self.mapView.addAnnotation(point)

        addPin(point)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.isLongPressInProgress = false
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier("showDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destination = segue.destinationViewController as! DetailsViewController
            destination.mapView = mapView
            //TODO: This is always the last pin added, which is not correct.
            //destination.pin = selectedPin
        }
    }
    @IBAction func editButtonAction(sender: AnyObject) {
    }
}

