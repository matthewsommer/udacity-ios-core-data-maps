//
//  Constants.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/3/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import Foundation

extension Flikr {
    
    struct Constants {
        
        // MARK: - URLs
        static let ApiKey = "649cee171c219d19efff76e858db7624"
        static let BaseUrl = "http://api.flickr.com/services/rest/"
        static let BaseUrlSSL = "https://api.flickr.com/services/rest/"
        static let BaseImageUrl = "http://image.tmdb.org/t/p/"
    }
    
    struct Resources {
        

    }
    
    struct Keys {
        static let ID = "id"
        static let ErrorStatusMessage = "status_message"
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
    }
}