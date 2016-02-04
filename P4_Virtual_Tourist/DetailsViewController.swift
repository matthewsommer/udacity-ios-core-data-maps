//
//  DetailsViewController.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/2/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import UIKit
import MapKit
import CoreData

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "649cee171c219d19efff76e858db7624"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

class DetailsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var pin: Pin!
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.mapView.delegate = self
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 40000, 40000)
        mapView.region = region
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": Flikr.createBoundingBoxString(pin.coordinate.latitude, longitude: pin.coordinate.longitude),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        //Flikr.getImageFromFlickrBySearch(methodArguments)
        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {}
//        
//        fetchedResultsController.delegate = self
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "Title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    @IBAction func buttonButtonClicked() {
        
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
        } else {
            deleteSelectedColors()
        }
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
    }
    
    func deleteSelectedColors() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for color in photosToDelete {
            sharedContext.deleteObject(color)
        }
        
        selectedIndexes = [NSIndexPath]()
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Colors"
        } else {
            bottomButton.title = "Clear All"
        }
    }
}

