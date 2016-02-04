//
//  Pin.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/2/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import CoreData
import MapKit

@objc(Pin)

class Pin: NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Title = "Title"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Photos = "photos"
    }
    
    @NSManaged var title: String?
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

        title = dictionary[Keys.Title] as? String
        longitude = dictionary[Keys.Longitude]! as! Double
        latitude = dictionary[Keys.Latitude]! as! Double
    }
    
    var locationCoordinate = CLLocationCoordinate2D()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            locationCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            
            return locationCoordinate
        }
    }
}