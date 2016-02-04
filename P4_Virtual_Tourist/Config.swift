//
//  Config.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/3/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import Foundation

// MARK: - Files Support
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("VirtualTourist-Context")

class Config: NSObject, NSCoding {
    
    // Default values from 1/12/15
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    
    override init() {
        
    }
    
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
    }
    
    // MARK: - NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init?(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObjectForKey(BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObjectForKey(PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObjectForKey(ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encodeObject(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encodeObject(posterSizes, forKey: PosterSizesKey)
        aCoder.encodeObject(profileSizes, forKey: ProfileSizesKey)
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> Config? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? Config
        } else {
            return nil
        }
    }
}














