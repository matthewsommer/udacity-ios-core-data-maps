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
        static let Pin = "pin"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
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
        if imagePath != nil {
            let fileURL = getFileURL()
            return UIImage(contentsOfFile: fileURL.path!)
        }
        return nil
    }
    
    func getFileURL() -> NSURL {
        let fileName = (imagePath! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray:[String] = [dirPath, fileName]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)
        return fileURL!
    }
    
    override func prepareForDeletion() {
        if let imagePath = self.imagePath {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imagePath)
            }
            catch let error as NSError {

            }
        }
    }
}