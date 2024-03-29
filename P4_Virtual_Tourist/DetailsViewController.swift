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

class DetailsViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
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

        collectionView.dataSource = self;
        collectionView.delegate = self;

        mapView.addAnnotation(pin)
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 40000, 40000)
        mapView.region = region
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
        
        updateBottomButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        let width = floor(self.collectionView.frame.size.width/3 - 4)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.imageView.image = UIImage(named: "LaunchImage")
        cell.activityIndicator.startAnimating()
        if photo.imagePath != nil {
            cell.imageView.image = photo.image
            cell.activityIndicator.stopAnimating()
        }
        
        cell.viewSelectedMask.alpha = 1.0
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.viewSelectedMask.alpha = 0.3
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        cell.viewSelectedMask.alpha = 1.0
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.viewSelectedMask.alpha = 0.3
        }
        
        updateBottomButton()
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
    
    @IBAction func buttonButtonClicked() {
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            getAllPhotos()
            collectionView.reloadData()
        } else {
            deleteSelectedPhotos()
        }
    }
    
    func getAllPhotos() {
        for _ in 0...20 {
            let photo = Photo(insertIntoMangedObjectContext: sharedContext)
            photo.pin = pin
            
            Flikr.taskRandomFlikrImage(pin.coordinate, completionHandler: { (imageData, imageID, error) -> Void in
                if let error = error {
                    print("Image download error: \(error.localizedDescription)")
                }
                
                let filename = imageID + ".jpg"
                let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let pathArray = [dirPath, filename]
                let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
                
                if let data = imageData {
                    let image = UIImage(data: data)
                    UIImageJPEGRepresentation(image!, 100)!.writeToFile(fileURL.path!, atomically: true)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        photo.imagePath = fileURL.path
                    }
                    
                    CoreDataStackManager.sharedInstance().saveContext()
                }
        })
        }
    }
    
    func deleteAllPhotos() {
        for photo: Photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        updateBottomButton()
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo: Photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        selectedIndexes = [NSIndexPath]()
        
        updateBottomButton()
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
        }
        else {
            bottomButton.title = "New Collection"
        }
    }
}

