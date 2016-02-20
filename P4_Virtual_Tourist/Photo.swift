//
//  Photo.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/2/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import CoreData
import UIKit

@objc(Photo)

class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let ImagePath = "imagePath"
        static let ImageData = "imageData"
        static let Pin = "pin"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        imagePath = dictionary[Keys.ImagePath] as? String

    }
    
    var image: UIImage? {
        get {
            return Flikr.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            Flikr.Caches.imageCache.storeImage(image, withIdentifier: imagePath!)
        }
    }
}