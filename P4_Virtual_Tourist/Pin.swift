//
//  Pin.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/2/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import CoreData

@objc(Pin)

class Pin: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let PointAnnotation = "pointannotation"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Photos = "photos"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!

        super.init(entity: entity,insertIntoManagedObjectContext: context)

        id = dictionary[Keys.ID] as! Int
        longitude = dictionary[Keys.Longitude]! as! Double
        latitude = dictionary[Keys.Latitude]! as! Double
    }
}