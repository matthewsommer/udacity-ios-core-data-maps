//
//  Flikr.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/3/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import Foundation
import UIKit
import MapKit

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

class Flikr : NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    
    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey
        
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":id") != nil {
            assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":id", withString: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValueForKey(Keys.ID)
        }
        
        let urlString = Constants.BaseUrlSSL + mutableResource + Flikr.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = Flikr.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                print("Step 3 - taskForResource's completionHandler is invoked.")
                Flikr.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    class func taskRandomFlikrImage(coordinate: CLLocationCoordinate2D, completionHandler: (imageData: NSData?, imageID: String, error: NSError?) ->  Void) -> NSURLSessionDataTask {
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(coordinate.latitude, longitude: coordinate.longitude),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + Flikr.escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let imageID = photoDictionary["id"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        if let imageData = NSData(contentsOfURL: imageURL!) {
                            dispatch_async(dispatch_get_main_queue(), {
                                completionHandler(imageData: imageData, imageID: imageID!, error: nil)
                            })
                        } else {
                            print("Image does not exist at \(imageURL)")
                        }
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    print("Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    class func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult[Flikr.Keys.ErrorStatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Flikr Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("Step 4 - parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Flikr {
        
        struct Singleton {
            static let sharedInstance = Flikr()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Date Formatter
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}