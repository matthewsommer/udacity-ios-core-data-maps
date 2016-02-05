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
        static let ImagePath = "imagePath"
        static let value = "value"
        static let ImageData = "imageData"
        static let Pin = "pin"
    }
    
    @NSManaged var imagePath: String?
    @NSManaged var value: UIColor
    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        value = UIColor.whiteColor()
    }
}